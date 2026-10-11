---
name: "Other games: the re-sweep"
description: "Measure the seven games again with today's tools —what builds, what cuts, which pages do not compile— and leave it as a new research in the book"
type: research
status: testing
assignee: taro
agents: [Aguará]
---

From taro, on 2026-10-10: pick up the other games again "in the order you propose". The survey is from 2026-10-05 and the tasks that followed it, from the 06; since then Adeleine's palettes, the two-byte encounters, the decoratives and more came in. This is the new snapshot, without fixing anything.

## How it is measured (Aguará, 2026-10-10)

With the global tools (snes-rm2k 1afe6457), in a worktree of the ports of my own (branch `aguara-rebarrido`, no commits) and without touching code:

* **The whole cartridge**, as committed in each port (with its crutches), and the `compile` request saved by a wrapper in the PATH for `culprits --every-map`.
* **Without crutches**: the same toml without `system`, without `excluded` and with `party = []`, excluding one at a time the map the error names.
* **Each map**: this time next to the boot map (`maps = [arranque, m]`), instead of alone with `BOOT_FRAMES = 255`: that way the runtime does not need changing. It runs about 2 s per map.
* Vampires Dawn, to see behind its first wall: a copy of the game (symlinks) whose `Music/` has only the 125 songs the dump names, and `start_map = 8`.

## Result

In the book, branch `aguara-rebarrido` of snes-rm2k-docs: `src/research/2026-10-10-otros-juegos-de-nuevo.md` and an "As of 2026-10-10" section in each `src/ports/<juego>/README.md`. The ROMs, as the ports are committed, in `/shared/builds/otros-juegos/` (all except Vampires Dawn, which does not build).

What is new behind:

* Vampires Dawn: `Music/` with 281 files and the track in one byte (it counts the unused ones too, also with `--without-tracks`); after that, the troop members in a one-byte table (470); and its boot map does not fit in `BOOT_FRAMES` (46 of 44).
* Sunset takes ~2 h 40 min to build: 138 big pictures in the background, ~4 min each measured alone. Unverified suspect: `27a28646` (Adeleine per tile group).
* The exclusions committed in the ports are the survey's and are more than needed: BoT needs only 46, Dooms 2 1/10/14/63, Frozen 1/2, Desert the twelve from the sweep.

Nothing was looked at in an emulator. No code was touched; nothing to install when merging.
