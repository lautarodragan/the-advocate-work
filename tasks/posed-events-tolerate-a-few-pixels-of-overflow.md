---
name: "Posed events tolerate a few pixels of overflow"
description: "A still event whose pose spills a few pixels out of its cell goes into the background anyway, shifted into the cell: `bake_max_offset`, a number of pixels, on by default; ABL's 33 chests drawn 1 px right and 2 px up are the case"
type: feature
status: testing
assignee: taro
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
pose bank grows because it changes with which poses stay sprites —27
of its blocks are new, 13 gone—, the same +2.4 KB Mulita attributed to
her edited image.

The nudge on ABL, each value against 0 (all `baked_events = true`): 1 →
+7 events (+1,660 B), 2 → +41 (+4,726 B), 3 → the same 41, 4 and 8 →
+42, the 42nd a `Missiles` drawing 4 px above its cell on purpose. No
event goes out at any value, and no event needed "different shifts".
The default is 2: it is where a drawing that is only misaligned stops.
The graphic shifted and also kept as an object elsewhere: `BLObjs` 2,
56 events on maps 20, 21, 26, 32, 255 and 316 —moved by a command, or
on a map whose panorama stays—; no map has both.

Found on the way, and told to Hornero: ABL cannot link any cartridge
with `baked_events` on, because `posed.s`'s far RAM (~700 B) does not
fit: release's FARBSS + SWITCHES leave 12 B of FARRAM, and a test
cartridge holding only maps 38, 59, 108 and 244 overflows by 23 B.
Mulita is moving `POSED_REG` into `$7F`. So ABL's captures are drawn
offline —the layers by `rm2k-render`, the pose from the original
CharSet at RM2k's place and at the shifted one—, not from the ROM:
`captures/2026-11-16-bake-max-offset/`.

`just test` green (0fdbf5d2); `cargo test -p wally -p rm2k-snes-convert`
green; ABL's `just tests` with the local wally and convert: 1661 passed,
2 skipped, no golden moved (ABL has the key off).

The other games, `baked_events = true`, nudge 2 against 0: Desert
Nightmare +5 (+990 B), El Dorado +2 (+952 B), Vampires Dawn +17
(+497 B), Zounds +1 —map 17's chest, (0, +2)— (+375 B); The Book of
Three, Dooms2, The Frozen World and Sunset none. The table is in the
book's page.

The first Zounds run showed the nudge taking events *out*: on map 156
four shifted ones went in and three that fit as they are went out,
because Wally's fallback tries the still events CharSet by CharSet, the
most numerous first, and a shifted group came first. Fixed in Wally
(8e670c9e): the ones that fit as they are are tried first, exactly as
with no nudge, and the shifted ones only on top. Test
`a_shifted_event_never_takes_the_place_of_one_that_fits_as_it_is`, red
before. Every game was converted again at 2 with it: none loses an
event. Zounds' map 156 now takes none of its shifted ones.

The same graphic shifted and left an object on the same map, a pixel or
two apart: Vampires Dawn's map 148, El Dorado's 2 and 5, Desert
Nightmare's 105 and 182. None in ABL or Zounds.

The captures, in `captures/2026-11-16-bake-max-offset/`: ABL's are drawn
offline (its cartridges cannot link with the key on, see above): the
chest of map 38, the `BLObjs` 3 ones of maps 108 and 244, and the radio
of map 243, each where RM2k draws it, shifted, and the difference. And
Zounds' map 17 chest, from the emulator, at nudge 0 and 2. It goes into
the background 2 px lower, 193 pixels.

`just boot` with the merged tools (the-advocate 112e0984, which has main's
a7c8c2d0 in it): 152 passed. One golden moved, Zounds' `zounds-debug-ship`,
by those same 193 pixels of map 17's chest. It was looked at and
committed apart (ports daf8675), and on the second run the file was
green. ABL's `just tests` was run before the merge with main (1661
passed, no golden moved, since ABL has the key off). It was not run again
on the merged tree.

Branches `cardon-bake-max-offset` in the-advocate (112e0984), the ports
(b3efc58) and the book (31161e0), each with main merged in.

**To install when merging**: `just install wally convert` in
the-advocate. Main's Carpintero merge also asks for `mapdata` (Hornero
said it was not reinstalled yet). Without it, every game's cartridge
fails with `LZ2_CAP_PANORAMA` undefined.
