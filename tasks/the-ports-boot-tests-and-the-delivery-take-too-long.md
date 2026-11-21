---
name: "The ports' boot tests and the delivery take too long"
description: "`just boot` runs its 183 tests in one process (22 min) while ABL's 1723 take under 5 with xdist; each delivery rewrites ~10 GB of unchanged MSU-1 tracks on the NAS and builds the games one after the other"
type: feature
status: doing
assignee: Calandria
author: taro
agents: [Calandria]
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
