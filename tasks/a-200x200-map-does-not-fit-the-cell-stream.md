---
name: "A 200x200 map does not fit the WRAM cell stream"
description: "rm2k-snes-mapdata stops the whole build at Zounds' map 30 (200x200): its map_cells stream is 47,232 bytes and 32,768 fit in WRAM; no other map of the eight ports gets near"
type: bug
status: todo
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**What happens**: `rm2k-snes-mapdata: map 30: a stream of map_cells is
47232 bytes and 32768 fit in WRAM: see the LZ2 reservation in
runtime/far_ram.s`, and the build stops. Map 30, "Sueño 2 (Hover Tram)",
is 200x200 = 40,000 cells; the next largest in Zounds is 100x50, and the
limit at that rate (~1.18 bytes per cell) is about 27,700 cells. The
study excluded the map in the toml to go on.

**What to decide**: whether a map over the reservation is left out with a
warning —as events over 120 or pictures over two are— instead of stopping
the build, and whether the reservation can grow or the stream be split
for a map that size (the console's own limit is the 64 KB of a bank for
the decompressed layers, not WRAM's 32 KB half).

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: still
so —`check_streams` in `rm2k-snes/mapdata/src/materials.rs` stops the
build, and Zounds' `rm2k-snes.toml` still excludes map 30—. A correction
to the arithmetic above: `map_cells` is not compressed at ~1.18 bytes per
cell; it is the grid, two bytes per cell, cut in two streams of up to
`HALF_GRID` (32 KB) each —`compressed_parts`—, one per half of bank
`$7F`. 40,000 cells are 80,000 bytes: the first half takes 32,768 and the
second is the 47,232 of the message. The limit is then the 64 KB bank,
32,768 cells (a 181x181 map), not about 27,700.

## Defined

Todo, on 2026-10-16, by Cardón, at the-advocate `f4709d0b`: Zounds still excludes map 30
by hand. Two things, the first is the task and the second is measured:

**Done** means a map over the grid's room does not stop the build: it is
left out with a WARNING and a loss in `degradations.json`, as events over
120 are, and Zounds' `excluded = [30]` goes. Whether map 30 can be held at
all —the grid is 64 KB of bank `$7F` at two bytes a cell, so 32,768 cells;
a byte per cell, or a grid read from ROM, would be the ways— the agent
measures and writes down, without building it unless it is cheap.
**First step**: `check_streams` in `rm2k-snes/mapdata/src/materials.rs`,
and how the converter already leaves out a map it cannot hold.
