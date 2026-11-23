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
