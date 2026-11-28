---
name: "game.rs keeps the volume ceilings table's reader"
description: "Game::ceilings, Game::ceilings_path and the free ceilings_path in rm2k-snes-audio's game.rs read patches/auto/music/ceilings.toml, which nothing writes or reads any more; removing them renders every MSU-1 track of every game again, because game.rs is in the tracks' cache key"
type: refactor
status: done
author: mulita
links:
  found-in: [the-volume-ceilings-are-measured-without-a-rom]
---

**What was seen**: since
[`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)
(the-advocate, branch `mulita-ceilings`, 2026-11-28), each song's volume
ceiling is measured while the music compiles, and the versioned table
`patches/auto/music/ceilings.toml` is gone from ABL and was never in the
other games. Three functions of `rm2k-snes/rm2k-snes-audio/src/game.rs`
still read it —`ceilings_path`, `Game::ceilings_path` and
`Game::ceilings`, with their comments saying a tool measures it in the
ROM—, and nothing calls them.

**Why they were left**: `game.rs` is one of the four files of
`OWN_SOURCES` in `src/tracks.rs`, the MSU-1 tracks' cache key, so any
change to it —a comment included— renders every track of every game
again and leaves one more copy in the cache, which has no eviction: 2.5
GB for ABL alone. Measured by doing it: the first build of ABL's
`release` with them removed made its 106 tracks again (the copies were
deleted from the cache afterwards, and the change reverted).

**How to see it**: `git grep -n "fn ceilings" rm2k-snes/rm2k-snes-audio/src/game.rs`
in the-advocate, and `git grep -n "ceilings()"` finds no caller.

Removing them is free when it goes with another change that has to touch
`game.rs` anyway, or with one that narrows the tracks' key.

## Log

### 2026-11-28, Chajá: two more comments for the same change

Found doing
[`the-advocate-still-speaks-of-the-stages-binaries`](the-advocate-still-speaks-of-the-stages-binaries.md),
and left for the same reason —both files are in `OWN_SOURCES`—:

* `src/tracks.rs`, above `OWN_SOURCES`: "Since the tracks are a
  subcommand of `rm2k-snes-audio` the executable carries the whole
  compiler" —they are a call of `advocate`'s since 2026-11-25—.
* `src/fail.rs`, its header: "a build script wants to tell them apart
  without reading the message" —the two kinds were the binary's exit
  codes, and the binary went on 2026-11-28—.

Whoever removes the reader fixes these in the same change.

### 2026-11-28, Hornero: done with the cache's eviction

Removed on the-advocate after merging
[`the-shared-conversion-cache-grows-without-bound`](the-shared-conversion-cache-grows-without-bound.md),
which touches `tracks.rs` and so renders every track once anyway: the
reader (`ceilings_path` and `Game::ceilings`) and Chajá's two comments, in
the same commit, so the tracks render once for all of it.
