---
name: "Desert Nightmare: the cartridge has no room left"
description: "Since the painted pieces the ROM is 126 of 126 data banks with a 1,395-byte gap, and what cannot go to the .msu no longer fits: one more common event that compiles was enough to stop the build"
type: bug
status: draft
game: desert-nightmare
agents: [Chajá]
---

Seen by Chajá on 2026-11-20, at the-advocate `4f38ea03` and the ports
`a34b393`, for
[`desert-nightmare-items-cannot-be-used`](desert-nightmare-items-cannot-be-used.md).

**What was seen**: `rm2k-snes-space` on Desert Nightmare's `release`
built with the tools of `4f38ea03`: 126 of 126 data banks, 0 free, one
gap of 1,395 B. The `.msu` takes only what is read when a map loads; the
painted cells (`paint_tiles_*`, 4 MB raw over 93 maps), the poses and the
maps' code that stays in the ROM do not go.

So a change that only compiles more pages can stop the build. Making the
event compiler read the hero's map id made common event 14 compile, and
its copy into 181 maps (`common_pages` in the converter) added ~9 KB of
bytecode to each: the maps' code went past `LZ2_CAP_CODE` and stayed in
the ROM uncompressed (`map_code` in LZ2 1,079.7 KB → 3.1 KB), and
`just cartridges` failed with "a piece of 23040 bytes needs a new bank,
and the 126 banks the cartridge has for data are taken, even with the
1118 piece(s) that may go to the .msu there". Taking map 34 out of
`painted_events` (38,400 B of cells) did not make it fit. What let it
build was keeping 14 shared (`[events] commons_not_copied = [14]`).

And a copied automatic common costs its whole bytecode in every map it is
copied into, which nothing weighs against the WRAM cap of the map's code:
the other copy, common 12, is still in the 181 maps. Not measured: how
much of the ROM the maps' code that already stayed in it takes.

**To reproduce**: the-advocate `chaja-control-vars` at `b5e353b5` (before
the knob), the ports `a34b393`, `just cartridges` in `desert-nightmare/`
with that worktree's `events convert cartridge` first on the PATH.
