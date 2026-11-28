---
name: "The shared conversion cache grows without bound"
description: "Nothing ever deletes an entry of the machine's cache: every reinstall of a stage, of ca65 or of the runtime leaves the whole previous set of answers behind, and a full set for the nine games is over a gigabyte"
type: refactor
status: testing
assignee: taro
author: huron
agents: [cardon, carpintero]
links:
  found-in: [a-conversion-cache-shared-by-the-worktrees]
---

Seen by Hurón on 2026-11-23, in
[`a-conversion-cache-shared-by-the-worktrees`](a-conversion-cache-shared-by-the-worktrees.md),
with the-advocate at `e3c93e76` (branch `huron-shared-cache`) and the
ports at `5745ec0`.

**What happens**: the cache that `CACHE` in the ports' `machine.just`
names —one for every checkout— keys each value by the binaries that made
it, so a new `wally`, a new `ca65` or a new runtime makes new keys, and
the old entries stay. Nothing deletes them. After one cold build of the
nine games, `du -sh` of the cache gave `stages/` 749 MB —every stage's
answers— and `ca65/` 394 MB —one object per cartridge, Vampires Dawn's
alone tens of megabytes—; `msu-tracks/` is hard links to the builds'
`.pcm` and costs nothing while a build keeps them, and all the space once
no build does.

**How to see it**: `du -sh ~/.cache/advocate/*` before and after
reinstalling `wally` and building the games once more.

It can be emptied by hand whenever nothing is building; deleting it while
something builds can take away a game unpacked from its `.zip` under a
converter that is reading it.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: what evicts the machine's conversion cache (AGENTS.md
says "It has no eviction yet"). It matters more while
`the-stages-speak-json-nobody-types` keys every stage's answer by the
converter's binary: every converter change leaves a full set (~1 GB for
the nine games) behind.

**Options**: (a) nothing automatic, a recipe that empties it when nothing
builds; (b) each build deletes entries not read in N days (by atime or a
touched stamp); (c) a size cap, oldest first; (d) wait for
`a-stage-s-cache-key-once-it-is-a-library`, then decide.

**Recommendation**: (b), with N around 14 days, done in `cache.rs` with a
lock so that nothing reads an entry being deleted; it is toolchain code
with a cost to choose (disk against rebuilding), so it is yours.

### 2026-11-28, taro: an answer: (b)

> (b)

### 2026-11-28, Hornero: (b), to todo

To `todo` with (b): each build deletes the entries not read in about 14
days, in `cache.rs`, with a lock so nothing reads an entry being deleted.

### 2026-11-28, Carpintero: a question for taro

**What to decide**: whether fourteen days is still the number, now that
it is measured. The machine's cache grew 92 GB in its first five days
—some 18 GB a day, mostly stage answers that every new `advocate`
expires—, so with fourteen days it settles at a couple of hundred
gigabytes on the disk `~` shares with the host.

**Options**: (a) keep fourteen days; (b) four days: a worktree older
than that rebuilds cold, minutes, and the cache settles at some 70 GB;
(c) wait for `a-stage-s-cache-key-once-it-is-a-library`, which would
stop every converter change from expiring every stage's answer, and
decide then.

**Recommendation**: (b) now, and look again after (c) lands: it is the
constant `UNUSED_FOR` in `cache.rs`, one line.

### 2026-11-28, taro: 4 days

> Vamos con 4

### 2026-11-28, Hornero: 4 days, after the verification

taro answered in the chat, quoted above: `UNUSED_FOR` goes to 4 days. Hornero changes it once the verification running on main ends (nothing is touched while a suite runs), with the eviction's tests rerun.

## Log

### 2026-11-28, Carpintero: taken; the cache measured

From the-advocate `b4654a3a`, on a branch `carpintero-cache-eviction`
in the-advocate and in the-advocate-docs.

`du -sh ~/.cache/advocate` at 10:00: **92 GB**, five days after the
cache became shared —`stages/` 49 GB in 169,799 entries, `msu-tracks/`
37 GB, `ca65/` 5.8 GB, `zip/` 193 MB, the rest a few MB—. Of
`msu-tracks/`, only 389 entries (9.1 GB) are still hard links a build
keeps; the other 28 GB are tracks no build has any more.

**What a first eviction would remove today: nothing.** The oldest entry
is five days old. By access time, the entries nobody read in:

| days | entries | GB only the cache holds |
|---|---|---|
| 0 | 63,013 | 20.6 |
| 2 | 27,638 | 10.8 |
| 3 | 49,244 | 16.8 |
| 4 | 35,053 | 33.7 |
| 5 | 126 | 0.4 |

Counted with `find -mindepth 2 -maxdepth 2 -printf '%A@ %n %s'`, the
sweep's own rule, without deleting anything. At that rate —some 18 GB a
day, mostly stage answers expired by each new `advocate`— fourteen days
let the cache reach a couple of hundred gigabytes before the sweeps catch
up with it.

### 2026-11-28, Carpintero: the sweep and the lock

In `rm2k-snes/project/src/cache.rs`, the-advocate `18ef20c6`:

- **The stamp is each entry's access time, written by the cache
  itself** with `futimens` on every `load`, `fetch_file`, `store`,
  `store_file` and the new `touch`, and on the directories of `zip/`
  and `own-files/` when they are reused. Not the kernel's: here it is
  `relatime` (ext4), elsewhere it may be `noatime`, and a track fetched
  as a hard link is not read. Not the modification time: the MSU-1
  tracks are hard links shared with the builds' `.pcm`. Written only
  when the stamp is a day old.
- **The lock is per process**: every process that touches the cache
  holds a shared `flock` on `<cache>/.lock` until it exits —every
  function of `cache.rs` takes it, and `Environment::unpack` too, so a
  tool that reads the game below the cache holds it even when it
  unpacks nothing—. `advocate build`, before touching the cache, calls
  `evict_and_hold`: it tries the lock exclusive without waiting; if it
  gets it and the last sweep (`<cache>/.swept`) is a day old, it
  deletes every entry with a stamp older than fourteen days and every
  `.tmp-*` a dead process left, then keeps the lock shared. With
  anybody else holding the cache it does not sweep and does not wait.
  So nothing is deleted under a living reader and a crashed process
  never leaves the cache locked; the cost is that it sweeps only in a
  moment nobody else uses the cache.
- **The tracks**: a build whose `.pcm` is still the one the cache keeps
  now touches the cache's copy, so it is not evicted while builds use
  it. That edit is in `tracks.rs`, one of the sources the tracks are
  keyed by: **every MSU-1 track renders once more** after the merge
  —ABL's 106 took part of a four-minute `just cartridges` here—.
- `tests/eviction.rs`: the sweep with stamps set back, with the clock
  ahead, once a day, and the lock between two processes (the test
  binary as its own child); red with `hold` and the stamp made no-ops.

AGENTS.md, the book's `internals/pipeline.md` ("The conversion cache",
new) and the ports' `machine.just` say it.

### 2026-11-28, Carpintero: verified, to testing

Branches `carpintero-cache-eviction`: the-advocate `a0c09940` (main
`5f6d5d48` merged), the ports `98be32aa` (`7ff51a0b` merged), the book
`7975345`. All run with `advocate` installed from the branch in
`.local-tools` and a cache of my own (`CACHE`, a hard-linked copy of the
machine's), so no sweep ran on the shared one:

- the-advocate: `just test` 31 passed; `just lint` green (with
  `SOUNDFONT` FluidR3); `env -u SOUNDFONT just rust-test` green;
  `just test-game` 231 passed, 6 skipped;
- the ports, after merging main: ABL's `just tests` 1623 passed,
  2 skipped; `just boot` 209 passed;
- ABL's `release` with `NO_CACHE=1` and cached, byte for byte equal
  (`fbeabc99…`), and equal to the stamped `build/release/abl.sfc`.

What no test covers: a sweep on a real cache while builds run —the lock
is tested with processes of the test binary, not with `advocate` and a
stage—; the first real sweep on the machine's cache, which deletes
nothing until 2026-12-07, two weeks after its oldest entry.

**When merging**: `just install advocate` (it compiles in `rm2k-project`
and `rm2k-snes-audio`); every MSU-1 track renders once more, see above.
