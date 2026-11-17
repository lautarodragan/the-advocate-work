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

Hornero passed taro's names mid-task: the key `posed_events` is now
`baked_events` (same values) and the new one `baked_events_nudge`, not
`bake_max_offset`. The tools refuse the old name with the new one —as
they refuse an old `rm2k-snes.toml`— instead of keeping an alias; the
ports' `RENAMES.md` has the row. Wally's own names (`posed`, the request's
`posed_stills`) stay: they are not the project's.

Red before: the new whole-map test on cd3fecb8's Wally keeps the event an
object, "a pose is drawn past its cell".

ABL's release converted with `baked_events = true` (throwaway: it does
not link, as Mulita measured), nudge 0 against 2: 41 more events go in
and none goes out —the 33 chests (`BLObjs` 2, all by (−1, +2)), seven
`BLObjs` 3 on maps 108, 243 and 244 by (0, +1) and one by (0, +2), and
the radio of map 243—, for +4,726 B of data (map tiles +4,425, posed
record +1,591, sprite poses +2,940 against sprite tiles −4,833). The
pose bank grows because it changes with which poses stay sprites —14
of its blocks are new, 13 gone—, the same +2.4 KB Mulita attributed to
her edited image.
