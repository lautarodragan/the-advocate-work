---
name: "A conversion cache shared by the worktrees"
description: "Every worktree of the ports rebuilds every game's cartridges from nothing, with the same inputs; a cache outside the checkouts —~/.cache/advocate?— keyed by the inputs and the binaries' hashes, extended to Wally, rm2k-snes-audio and whatever else is worth it, would build only what a branch changes"
type: refactor
status: doing
assignee: Hurón
agents: [Hornero, Hurón]
author: taro
---

> Add a task to `todo` for the converter cache across worktrees
> (~/.cache/advocate?), and add wally, rm2k-snes-audio and anything else
> we think is worth it to the cache.

taro, 2026-11-22, after Hornero counted where the CPU went with five agents
at once: each one builds every game's cartridges in its own worktree of
the ports, from inputs that are the same for all but what its branch
changes. At that moment the converter, Wally and rm2k-snes-audio added up
to some two and a half cores.

**What exists**: `build/cache/` in each game's project —see `cache.rs` in
`rm2k-project` and "Environment traps" in `AGENTS.md`—, keyed by the hash
of the sources and of the binaries that produce what is stored, and only
for the MSU-1 tracks. It lives inside each checkout, so no worktree sees
another's.

**What is asked**: the same kind of key, in a cache outside the
checkouts, shared by all of them; and more stages behind it —Wally's maps,
rm2k-snes-audio's music and samples, whatever a measurement shows is
worth it—. The rule that already holds goes on holding: a change to what
is cached is verified with `NO_CACHE=1`, both ROMs byte for byte equal. And
two worktrees writing the same entry at once must not corrupt it.

## Log

### 2026-11-23, Hornero: taken for Hurón

> great! and can this one be done in parallel?

### 2026-11-23, Hurón: where a cold `just cartridges` goes

A fresh worktree of the ports at 8aef866, the global tools of the-advocate
75d46e3c, and each game's `just cartridges` in series —ABL with its MSU-1
tracks, the others without, as their recipes do—. Each binary the build
runs was wrapped in a shim that logs its wall and CPU time (bash's `time`,
which counts the children it waits for). From Vampires Dawn on, Carpintero
was building at the same time, so those two walls are high.

| game | wall | CPU |
|---|---:|---:|
| ABL (11 cartridges + tracks) | 116 s | 706 s |
| The Book of Three | 14 s | 35 s |
| Desert Nightmare | 97 s | 201 s |
| Doom's 2 | 19 s | 28 s |
| El Dorado | 5 s | 10 s |
| The Frozen World | 43 s | 86 s |
| Sunset over Imdahl | 118 s | 550 s |
| Vampires Dawn | 235 s | 689 s |
| Zounds | 39 s | 122 s |
| **all nine** | **687 s** | **2426 s** |

Per stage, CPU over the nine:

| stage | calls | CPU |
|---|---:|---:|
| Wally, `wally map` | 1578 | 1596 s |
| the MSU-1 tracks, `rm2k-snes-msu` (fluidsynth, 300 s of it) | 1 | 315 s |
| `ca65` | 20 | 201 s |
| `rm2k-snes-images`, all its commands | 9417 | 94 s |
| the converter itself, without its stages | 20 | ~76 s |
| `rm2k-snes-events` scan + compile | 41 | 42 s |
| `rm2k-snes-audio cartridge` | 19 | 39 s |
| `rm2k-snes-mapdata emit` | 20 | 32 s |
| `rm2k-snes-screens`, all | 106 | 13 s |
| `ld65` | 20 | 10 s |
| battle, patches | | ~1 s |

What that says:

* **Wally is two thirds of everything**, and it is a stage called per map
  with a request: the natural thing to cache. ABL asks it 353 times for
  11 cartridges, many of them the same map with the same request, so a
  cache helps inside one worktree too.
* **`ca65` is on the critical path of the big games**: one call per
  cartridge, single-threaded —95 s of Vampires Dawn's 235, 24 s of Desert
  Nightmare's 97—. With Wally cached, it would be most of what is left.
* **The tracks** are already cached inside a checkout, by their sha256;
  what a second worktree lacks is the `.pcm` itself.
* The rest of the stages that go through `stage::run` —images, events,
  screens, battle— are small one by one, but go behind the same key for
  free. `rm2k-snes-audio cartridge` and `rm2k-snes-mapdata emit` write
  outside their answer —into the cartridge's directory, `raw/`—, and add
  up to 71 s over the nine: not worth a cache of their own for now.

### 2026-11-23, Hurón: the cache, shared, and what it saves

#### What is cached

the-advocate `huron-shared-cache`, the ports `huron-shared-cache`.

* **Every stage that goes through `stage::run`** —Wally, the images, the
  screens, the events, the battle—: its whole answer, the files it writes
  into `--out`, under the key of its binary by content, the command, the
  request and the flags, with every path in them by what it holds. A
  `--search-dir` goes by its RM2k folders alone —one of them is the root
  of the tools' checkout, see the draft
  [`the-tools-checkout-is-searched-for-a-game-s-resources`](the-tools-checkout-is-searched-for-a-game-s-resources.md)—,
  a folder the cache made by its name, and a folder that is not there as
  missing.
* **`ca65`'s object**, keyed by the binary, its flags and every file it
  reads by name and content. Copied, not linked: `ca65` rewrites it in
  place. `ld65` runs always.
* **The MSU-1 tracks themselves**, hard-linked into `msu-tracks/` next to
  the sha256 the cache already kept, and linked from there into a build
  that lacks them.
* The games unpacked from their `.zip` and the merged own files were
  already in the cache, by content: now they are shared too.

**Not cached**: `rm2k-snes-mapdata emit` —it writes `raw/` besides its
answer— and `rm2k-snes-audio cartridge` —it writes straight into the
cartridge's directory and the `.msu`—: 31 s and 36 s of CPU over the nine
games, which is most of what a warm build still does. The converter
itself, `ld65` and the bank packing run always.

**Where**: `CACHE` in the ports' `machine.just`, `/root/.cache/advocate`
by default, which every game's `justfile` passes as `--cache` and ABL's
harness reads (`ABL_CACHE` is gone). The tools know no path: without
`--cache` they keep it in each game's `build/cache/`, as before.

**Two writers**: every value is written aside —under a name of the
process, the call and the time, since two threads of one process share
the pid— and renamed. The old tracks' store used the pid alone; the new
test, four writers against four readers on an 8 MB value, was red with a
plain write and with the pid-only name.

#### Measured

Total wall of `just cartridges` for the nine games in series, ABL with its
tracks. The machine was loaded by other agents' suites during the second
and third columns —load 13 to 28—, so the CPU column says more:

| | wall | CPU |
|---|---:|---:|
| before, cold (global tools) | 687 s | 2426 s |
| cold, empty cache | 777 s | 2616 s |
| a second worktree, warm cache | **68 s** | **134 s** |
| `NO_CACHE=1` (no shims) | 925 s | |

Per game, cold before → second worktree warm: ABL 116 → 15 s, Vampires
Dawn 235 → 18, Desert Nightmare 97 → 8.5, Sunset 118 → 5.5, Zounds 39 →
6. A cold build fills the cache with ~750 MB of stage answers and
~390 MB of objects; the tracks are links.

The first warm run found no Wally answer for Sunset, Vampires Dawn and
Zounds: their `--search-dir <worktree>/build/patches-manual` does not
exist, and went into the key as the worktree's path. Fixed —a missing
path after a path flag goes as missing—, with its test red first.

#### Verified

* **`NO_CACHE=1` gives the same ROMs**: the nine games built in a fresh
  worktree with `NO_CACHE=1`, compared byte for byte with the cold build
  with the cache and with the second worktree's warm one: the 20 ROMs
  equal, and every `.inc`, `.msu`, `.pcm` and JSON; only the `.dbg`, the
  `.o`, `stamp.txt` and `events-request.json` differ, which carry paths,
  dates or the binaries' hashes and differ between any two worktrees.
* **Two worktrees at once**: (see the next entry).
* New tests, each shown red first: `rm2k-project`'s `tests/cache.rs`
  (writers that race, a fetched link replaced, a tree by content), the
  converter's `stage::tests` (a key by content and not by place, a
  search dir by its RM2k folders, a missing folder), `object_key` in
  `rm2k-snes-cartridge`, and a track another build made, in
  `rm2k-snes-audio`.

**What no test covers**: that a hit in `stage::run` or in `assemble`
returns what the stage or `ca65` would have made is covered only by the
`NO_CACHE=1` comparison above, which nothing runs on its own; and that no
stage reads a file its request and flags do not name —the key's
assumption, written next to `key` in `stage.rs`—. A stage that started to
read something else would be served stale answers without a word.
