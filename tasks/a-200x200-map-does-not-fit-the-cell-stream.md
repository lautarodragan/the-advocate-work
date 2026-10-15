---
name: "A 200x200 map does not fit the WRAM cell stream"
description: "rm2k-snes-mapdata stops the whole build at Zounds' map 30 (200x200): its map_cells stream is 47,232 bytes and 32,768 fit in WRAM; no other map of the eight ports gets near"
type: bug
status: draft
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
