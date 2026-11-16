---
name: "Posed events tolerate a few pixels of overflow"
description: "A still event whose pose spills a few pixels out of its cell goes into the background anyway, shifted into the cell: `bake_max_offset`, a number of pixels, on by default; ABL's 33 chests drawn 1 px right and 2 px up are the case"
type: feature
status: doing
assignee: Cardón
agents: [Cardón]
---

From [`abl-room-for-still-events-in-the-background`](abl-room-for-still-events-in-the-background.md):
33 of ABL's chests stay objects only because `BLObjs.png` draws the chest
1 px right and 2 px up of its cell. Hornero offered a recipe op that
shifts those poses (explicit, ABL's own) or a converter tolerance. taro,
on 2026-11-16:

> Hmm, that tempts me a lot! If the complexity isn't much, I'd like to
> try it. If it goes well, it should be an option of the build process
> (on by default), in case we don't want to turn it on globally for a
> game. Maybe it could be an integer instead of a boolean. Something like
> "bake_max_offset". Unless you think there's a good reason, I'd use a
> single number. `bake_max_offset = 3` means +/- 3 px in `x` and/or `y`,
> for example.

Done means: a pose whose drawn pixels fit a 16x16 cell once shifted by at
most `bake_max_offset` px in x and/or y goes into the background shifted
(nothing cropped), in the project file's `[graphics]` with a default on;
the converter's log says, per event, that it was shifted and by how much;
measured with ABL's `posed_events` on (how many more go in, the chests
among them, what it costs) and on the other games; side-by-side captures
of shifted events; tests in the tool.

## Log

Cardón, from the-advocate cd3fecb8 and the ports b024af2, branches
`cardon-bake-max-offset` in the-advocate, the ports and the book. The
shift is decided in Wally's `posed::why_not`, over the union of the
opaque pixels of every pose the event can show: one shift for all of
them, the smallest that puts that union inside the 16x16 cell. Each
pose's frame is moved by it before it is painted, so everything after
the choice —the extension's cells, `compose`, the blocks— is unchanged.
If no single shift within the limit fits them all, though each pose
alone would fit, the event stays an object with a reason of its own,
so the log tells it apart from one that does not fit at all.
