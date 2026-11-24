---
name: "Desert Nightmare: the cartridge has no room left"
description: "Since the painted pieces the ROM is 126 of 126 data banks with a 1,395-byte gap, and what cannot go to the .msu no longer fits: one more common event that compiles was enough to stop the build"
type: bug
status: done
assignee: taro
author: chaja
game: desert-nightmare
agents: [Chajá, Carpintero]
links:
  relates: [desert-nightmare-the-map-cursor-is-shared-on-ten-maps, identical-copies-of-a-common-event-are-stored-in-every-map]
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

## Log (Carpintero)

**2026-11-20.** Worktrees at the-advocate `16081af9` and the ports
`1177cbc`, branches `carpintero-dn-room` in both and in the book. Desert
Nightmare's and Vampires Dawn's `release` rebuilt there with the global
tools (which are `16081af9`'s), to measure from the build's `.dbg` and
the packed `.inc`. Already known before starting, not measured again:
the painted cells dedup figures of Cardón's study (29.5% distinct within
a map), and the FX Pak's seek cost from "The `.msu` file" (about 2 ms
with a track playing).

**What the builds say.** Desert Nightmare's ROM, by the `.dbg`'s labels:
painted cells and their tables 4,196,264 B (54.8%), maps' bytecode in LZ2
995,603 (13.0%), maps' graphics streams 611,242, poses 515,320, the three
precomposed fonts 364,416, pictures 343,300, samples 198,099. The packing
sent 105 pieces (1,037,034 B) to the `.msu`, and **kept 2,059,635 B of
kinds the `.msu` takes**: 126/126 is how `pack_with_msu` works, not a
full cartridge. Vampires Dawn: 3,103,859 B of those kept.

**Why Chajá's build failed**: with 14 and 12 copied every one of the 181
maps' bytecode passes `LZ2_CAP_CODE` and stays raw in the ROM, 3,940,530
B. A copy pastes what its common calls: 14's copy is 7,317 B (3,243
without its seven calls to 13), 12's 13,833 (1,023 without its seven to
11). Common 12's copies draw nothing (all its and 11's pictures are
320x240) and are ~1.05 MB of LZ2 of today's 1.1 MB of maps' bytecode.
Copying 14 and not 12: 754,186 B of LZ2, 352 KB less than today, largest
map 10,021 B. Drafts written for each finding.

**The frame** (Mesen2's line profiler, harness `Session`, a throwaway
script): walked on map 172, 1,030 frames, the camera moving on 360 (38
column and 52 row crossings), the main loop leaves 206 of the 262 lines
free at the median while the camera moves, 120 on a crossing frame and
67 at the worst; on map 4, 219 and 74. No tick ran past its frame.

**Written**: the research page
`ports/desert-nightmare/research/2026-11-20-where-the-room-goes.md` in
the book (branch `carpintero-dn-room`), with SUMMARY and a link from the
port's decision; links checked. Nothing in the-advocate or the ports.

**To testing (2026-11-20).** A study: nothing to install and nothing to
play. To merge: the book's `carpintero-dn-room` (the research page,
SUMMARY, the decision's link). The recommendation: copy a common only if
the copy draws a small picture the shared body cannot —for this game, 14
and not 12, 352 KB less than today and `commons_not_copied` unnecessary—;
then the painted cells stored once (about 2.4 MB), which could make the
MSU-1 optional again. Streaming the cells from the `.msu` is feasible on
bandwidth and frame time and the most expensive; not needed after those.
Drafts: `desert-nightmare-common-12-is-copied-and-draws-nothing`,
`identical-copies-of-a-common-event-are-stored-in-every-map`,
`desert-nightmare-the-map-cursor-is-shared-on-ten-maps`,
`the-font-is-precomposed-three-times`, and a dated section in
`painted-maps-carry-every-cell`. None shows while playing, so no line in
the port's "Known issues".
