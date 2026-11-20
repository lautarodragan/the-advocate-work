---
name: "Desert Nightmare: the cartridge has no room left"
description: "Since the painted pieces the ROM is 126 of 126 data banks with a 1,395-byte gap, and what cannot go to the .msu no longer fits: one more common event that compiles was enough to stop the build"
type: bug
status: doing
assignee: Carpintero
game: desert-nightmare
agents: [Chajá, Carpintero]
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

## Taken as a study (2026-11-20, Carpintero)

taro, translated, about Chajá's `commons_not_copied = [14]`:

> It was fine in order to finish the task without adding scope, but the
> next step should be to not need that option. Can you launch an agent to
> analyse what options we have? I suppose the maps have to go to the ROM
> no matter what, because of the streaming, but I can think of possible
> solutions. In the worst case, maybe we can implement some kind of
> chunking to store maps in the msu and load them in parts. In other
> words, another level of streaming, designed for the msu's read speed +
> the cycles available while walking the map. But we should be able to
> store graphics in the msu and free room for maps. That is something we
> already do.

**Done means**: a study in the book, under the port, dated: what fills
Desert Nightmare's ROM today (by kind: painted cells, map code, graphics,
music, tables…), which of it could live in the `.msu` the way the battle
backgrounds and the loaded-on-entry data already do, why common 14 costs
~9 KB per map copied (and whether the copies could be shared or made
smaller instead of not copied), and the options ranked by cost and room
won —down to streaming painted cells from the `.msu` in chunks, with its
read speed and the cycles a walking frame has, measured—. The
recommendation that makes `commons_not_copied` unnecessary.
