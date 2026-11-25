---
name: "The ports' boot tests and the delivery take too long"
description: "`just boot` runs its 183 tests in one process (22 min) while ABL's 1723 take under 5 with xdist; each delivery rewrites ~10 GB of unchanged MSU-1 tracks on the NAS and builds the games one after the other"
type: feature
game: advocate
status: testing
assignee: taro
author: taro
agents: [Calandria, Hurón]
---

taro, on 2026-11-21, translated:

> Is there any optimisation left we could apply to the test suite and/or
> the delivery of the games? I remember we already optimised the test
> suite several times. [...] I don't know if there is anything
> significant left to gain without doing something very hacky... or
> buying more hardware 😛

What was seen the same day, with the machine's 16 threads:

- **`just boot`** (the ports' root) is a plain `pytest`, no `-n`: 183
  tests in 22 min 30 s, against ABL's 1723 in 4 min 39 s with xdist. It
  is not parallel because each test builds its game's cartridge the first
  time it needs it (`build` in `tests/games.py`), and two workers would
  build the same one at once. ABL solved it by building first (`tests:
  _xdist cartridges`).
- **`just deliver`** (the ports' root) builds the eight games one after
  the other, and for each one deletes and copies all its `.pcm` tracks to
  the NAS: about 10 GB a delivery (ABL's own `deliver`, 2.5 GB more),
  when the tracks barely change between deliveries.

taro, on the second, the same day:

> if it's worth it, we could mount a `/shared2` (or like `/builds`,
> better) mounted on the host's disk, without going through the network.
> It stays on the same machine, it's an NVMe SSD, etc. It's probably the
> easiest. I like to minimise the writes on the SSD, but we're not
> writing 10gb a minute either... nor an hour...

The mount is the host's —taro's `box`—; what this task gives it is the
measurement, so that the choice is made with numbers.

## Log

### 2026-11-21, Calandria: `just boot` in parallel, deliveries that copy only what changed

On the ports branch `calandria-fast-boot-deliver`, from `d17237a`.

#### `just boot`

- `games.py` builds a game under a `flock` on `<game>/build/cartridges.lock`,
  once per run among all the xdist workers: the lock's file keeps the run
  (`PYTEST_XDIST_TESTRUNUID`), the builder's exit, the tail of its output
  and the `--list --json` taken right after, and a worker that gets the
  lock after another built reads that instead of building.
- `conftest.py`, once collected, asks in every worker for the games its
  selection needs, all at once in threads: each game builds once, all of
  them at the same time, and the first test starts when they are built.
  Which games is a guess —a `game` parameter, else the game names quoted
  in the module or in the test modules it imports from, else all of
  them—; a game the guess misses is built by the test that asks for it, as
  before. On `d17237a` no test falls back to "all of them", and
  `-k vampires` needs only Vampires Dawn, `-k zounds` only Zounds.
- `PROCESSES`, `xdist` and `_xdist` moved from ABL's `justfile` to
  `machine.just`, and `boot` uses them.

#### `just deliver`

- `copy_changed.py`, at the root of the ports, used by both `deliver`s:
  a file is copied only if its size or its mtime differ from the
  destination's, and its mtime is copied with it. Same size and another
  mtime —a destination copied before this, or a track rendered again with
  the same bytes— is compared byte for byte once, and the destination
  takes the source's mtime. Only the tracks of the game's pattern that the
  build no longer has are deleted; anything else in the folder stays.
- The NAS keeps mtimes in 100 ns and truncates: checked writing one.
- The root's `deliver` builds the games at the same time, each into its
  `build/deliver.log`, shown if it fails.

### 2026-11-21, Calandria: measured before and after

Wall time, bytes the NAS share received —`Bytes written` of
`/proc/fs/cifs/Stats`— and, for the local destination, what the disk under
`~` wrote —`/sys/block/nvme0n1/stat`, with a `sync` inside the
measurement—. Before is `d17237a`, after is the branch; nothing else ran,
except Aguará building Desert Nightmare for a minute every ~10, which
overlapped the last minute of both warm `just boot`s.

#### `just boot`, 188 tests, all passing every time

| run | before (serial) | after (xdist, 8) |
|---|---|---|
| cold, no `build/` at all | 1205 s | 397 s |
| warm, nothing stale | 817 s | 191 s |
| `-k vampires`, warm | — | 13.5 s, builds only Vampires Dawn |

Warm, the end is held by one test: `test_the_end` of The Book of Three's
milestones, 98 s alone; the next is 77 s. Cold, the eight games build at
once and the first test starts when the last one is built.

#### `just deliver`, the eight games at the root

| run | NAS | | local disk | |
|---|---|---|---|---|
| | time | written | time | written |
| before, nothing changed | 73 s | 7.67 GB | 4.3 s | 7.67 GB |
| before, Zounds changed | 107 s | 7.67 GB | 32 s | 7.86 GB |
| after, nothing changed | 1.4 s | 0.00 GB | 1.1 s | 0 |
| after, Zounds changed | 31 s | 8.4 MB | 30 s | 0.2 GB* |
| after, first onto a folder the old one wrote | 96 s | read 7.66 GB | 3.0 s | 0 |

"Zounds changed" is a throwaway commit to its title, so its ROM really
changes; the rest of the time is building it. *The local disk's figure
is the build's own output: that ROM was already in the folder, from the
before run with the same title, and was not copied. The last row is the one time
cost: every file has the same size and another mtime, so it is compared
byte for byte once and takes the source's mtime.

#### ABL's `deliver`

| run | NAS | | local disk | |
|---|---|---|---|---|
| before, nothing changed | 32 s | 2.61 GB | 1.1 s | 2.61 GB |
| after, nothing changed | 3.5 s | 0 | 0.1 s | 0 |
| after, first onto the old one's folder | 36 s | read 2.61 GB | 0.8 s | 0 |

The 3.5 s that are left are `runtime/`, deleted and extracted again
from `git archive` every time: small files over SMB.

#### Hash or size and mtime

Comparing byte for byte reads the destination back over the network:
96 s for the 7.66 GB of the eight games, where copying them took 73 s. So
size and mtime decide, and the byte compare is only what is done when the
mtime differs and the size does not.

#### A `/builds` on the host's disk

With the incremental copy, a delivery where nothing changed takes 1.4 s
to the NAS and 1.1 s to the local disk, and one where a game changed is
the game's build in both. The disk only wins the first copy of a folder,
or when every track changes —a new SoundFont, a new synthesizer—: 7.7 GB
in ~4 s against ~73 s. The SSD's writes are then what changed, the same
as the NAS's. The local stand-in was `~/scratch/calandria/`, ext4 on the
same disk the host has.

#### Verified

- `just boot`, cold and warm, at `42379bf`: 188 passed each time, as the
  serial run at `d17237a`.
- ABL's `just tests` at `42379bf`: 1728 passed, 2 skipped.
- A test run by hand with plain `pytest`, no xdist, still builds what it
  needs: `pytest test_vampires_dawn_tradan.py`.
- The real delivery, root and ABL, at `80422a5` —main merged, nothing
  uncommitted on either side, the-advocate at `a537d967`—, to
  `/shared/builds/`: the first one onto the old folders, so it compared
  everything once; the ROMs, `.msu`s and ABL's `.dbg` were copied and no
  track; the track counts match the builds, and taro's saves in `abl/`
  stayed.

#### What no test covers

- `copy_changed.py` has no test: it ran against the NAS and a local
  directory, and a smoke script of mine covered a new file, a removed
  track, a file the folder had that is not the build's, same bytes with
  another mtime and other bytes with the same size.
- The root's `deliver` with a game that does not build: the branch that
  shows its `build/deliver.log` never ran.
- A test whose game `needed` misses: none does today, and then the test
  builds it itself under the lock, a path the suite did not run with
  xdist.
- Two `just boot`s at once in the same checkout: the lock serialises
  their builds, but it was not run.

To install when merging: nothing; only the ports change.

### 2026-11-22, Hurón: no capture

Tooling: the suite's speed and the delivery's copying, nothing on any
screen. How to check it: `just boot` from the ports' root should run in
parallel and take minutes, not the 22 of before; and after a `just
deliver`, the next one should copy only the ROMs, the `.msu`s and the
`.dbg`, not the tracks again, leaving your
saves in each game's folder of `/shared/builds/` alone.
