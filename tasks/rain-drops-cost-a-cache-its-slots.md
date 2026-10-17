---
name: "The raindrops cost a cache its slots"
description: "Rain is drawn whenever its greys fit a palette, before the cache counts its slots: Vampires Dawn's 51 gives up 21 animations for it and its 163 has events waiting"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Seen by Calandria on 2026-10-16, with the-advocate `8c6a345b` and the
ports `059ddcd`, measuring
[`abl-the-sixty-one-torches-of-map-148-stand-still`](abl-the-sixty-one-torches-of-map-148-stand-still.md).
Read from `degradations.json` and `wally map`, not played.

**What it is**: the drops go at the next row of four blocks after the
sprite bank (`rain_drops` in wally's `sprites/extras.rs`), and the cache
gets the slots that are left after them. Rain is drawn whenever its three
greys fit a palette; nothing weighs it against the slots it takes. With
the fix for empty pages that turned, palettes freed up and fifteen
Vampires Dawn maps got their rain back, and two of them lost something
else for it:

* **51**: the cache goes from 30 slots to 26, animating would make four
  events wait, so its 21 still events that animate stand still.
* **163**: the cache goes from 14 slots to 11, and up to two events wait
  for one.

Sunset Over Imdahl rains on most of its maps and had this before the fix:
2, 3, 4, 12, 13, 14, 15, 56, 57 and 58 have events waiting, and 1, 2, 3,
12, 13, 14, 15 and 46 still events standing still, with the rain.

A proposal is on the-advocate's branch `calandria-rain-before-slots`
(`836861f0`, on top of the fix): a map that rains and loses either is
converted again without the rain, and that one goes if it loses less of
both and nothing else. Its commit has what it changes in both games:
Sunset loses the rain on twelve more maps. Which loss is worse is taro's.

**How to see it**: `just cartridges` in `vampires-dawn/` with the fix, and
maps 51 and 163 in `build/release/degradations.json`.

## taro's decision

taro, on 2026-10-17: the rain is not given up. If both do not fit, the
animations go —so `calandria-rain-before-slots` is not merged—, but first
look for ways to keep both, also when it rains.

## Log

**2026-10-17, Calandria**, from the-advocate `b15c9408` and the ports
`bd92975`, on branches `calandria-rain-and-slots` of both:

* Where the cost comes from: `rain_drops` put the drops at the next row
  of blocks (64 tiles) after the bank, always, and the cache's slot count
  is the most that fit *with* the extras. So the rain cost a whole row:
  up to four slots, and on 51 exactly four (30 to 26). Drawing a 32x32
  pose uses its four tile columns (24 wide, centred), so there is no free
  column inside a block; but the last row of blocks, when partly taken,
  leaves whole free columns, and the drops are two 8x8 objects read by
  tile number: they fit there.
* Idea 1, the strip in the free columns (`strip_base` in wally's
  `extras.rs`, for the drops and the timer's glyphs): the rain costs a
  slot only when the slots would fill the last row exactly; otherwise
  none.

  Measured on `release` against the same tools without it (map-level
  losses in `degradations.json`): Vampires Dawn 51 animates 18 of its 21
  still events (the biggest of its 3 looks) with a cache of 29, peak 29;
  102 and 209
  animate everything; 163, 262 and 429 have nobody waiting. Waiting maps
  9 to 6, still animations dropped 7 to 5. Sunset Over Imdahl: nobody
  waits on 2, 13, 14, 15 and 57; 3, 4, 12, 56 and 58 wait less (cache 6 to
  9, 7 to 10, 6 to 9, 11 to 14, 7 to 10); 1 animates 4 events more and 46
  everything. Waiting maps 11 to 6. (Sunset's maps go painted: 256 sprite
  tiles, 16 blocks, so a row is a quarter of the bank.) The pictures fit
  on 9 more maps of Vampires Dawn and one of Sunset, as a side effect.
* Idea 2, the greys lent a palette when none has room (`lend_to_rain`,
  as the timer is): rain on every map of the three games —it was not
  drawn on 47 of Vampires Dawn, whose rain is a parallel common event
  that can run anywhere, 1 of Sunset and 32 of ABL, Paradise among them,
  which is `abl-it-does-not-rain-in-paradise`—. The greys are mostly a
  step off on one channel; the worst, VD 50's darkest, is [2, 4, 0]. It
  costs a slot where a cache fills its last row: VD 95, 141, 168, 201,
  222 and 239, and 240 has one event waiting; ABL's farm (127) 30 to 29.
* Measured and dropped: drawing a drop's bottom half with the top tile
  two pixels left (3 tiles instead of 6) gains nothing once the strip
  goes into free columns —a free column always has the four rows—.
  Raining only where it can rain (a walk like the timer's) does not pay
  either: Vampires Dawn sets it from a parallel common event.
* Idea 3, twins that animate share a slot of the cache too: since
  2026-10-15 they shared everywhere but in a cache, where each wanted its
  own while in view. A twin's row now carries its leader's key (128 plus
  the leader) in the tile byte and its own poses; `cache_want` seeks that
  key like a still pose, `cache_took` hands the slot to the leader too,
  and the leader's uploads keep it up to date even out of view. In a cache
  a twin that only appears with its page shares too (Sunset's lamps: a
  blank page and the lamp on a switch). Vampires Dawn: every still event
  that animates in RM2k animates (7 maps and 151 events dropped at
  `b15c9408`, none now); Sunset: 13 and 15 animate everything, 14 ten
  more; 1, 3, 12 and 14 still drop 81 events (152 at `b15c9408`).
  New ROM test in the ports, `tests/test_cache_twins.py` (Vampires Dawn's
  236, four braziers on screen whose leader is thirty cells away): red
  with main's tools —they stand still—, green with these.
* What is left, measured: the rain costs one slot where the slots fill the
  32 blocks exactly (VD 95, 141, 168, 201, 222, 239, 240; ABL's farm, 30
  to 29), because there is no free tile anywhere in a full bank. Sunset's
  towns wait even with nothing animating: painted maps have 16 blocks of
  sprites and the battle animation's box takes four of them. Looked at
  and not done: the painted layout leaves $4E00-$4FFF free (32 tiles),
  which OBJ's second name table can reach with name select 3 —room for the
  strip outside the bank, both rows of it—. Measured with Wally on the
  kept requests, with and without rain: on Sunset's 3, 4, 12, 56 and 58
  the strip still costs one slot (9 to 10, 10 to 11, 9 to 10, 14 to 15, 10
  to 11), and none of them would stop waiting (peaks 18, 21, 15, 19, 36).
  It asks for OBSEL per map, its own upload in `load_sprite` and the
  painting kept off those 1 KB: not worth one slot that leaves the wait.
* Merged with main's nearest colour in CIE Lab (Carpintero): the lending
  measures in Lab too. With luma, Paradise's light grey went to a yellow
  ([18, 16, 11]); in Lab it goes to the palette's only grey, [8, 8, 8].
  Map-level losses the same as before the merge in the three games.

Verified, with the merged tools (the-advocate `eb16d48b`, the ports
`14001eb`): ABL's suite, 1565 passed and 2 skipped, no golden moved;
`just test`; `just test-game` (with `SOUNDFONT` GeneralUser-GS); the crate
tests of wally and mapdata; the ports' `just boot`, 60 passed once Sunset's two goldens moved (below); and
`tests/test_cache_twins.py`, red with main's tools and green with these.
What no test covers: the lent greys and the strip's place are only
looked at, in `/shared/captures/2026-10-17-rain-and-animations/` (rain
forced in far RAM); no golden of the suite shows rain on a map that
lends. The twins' path in a cache is covered only on Vampires Dawn's 236,
whose leader is out of view; one that only appears with its page (Sunset)
is not run by any test.

To install when merging: `wally` and `mapdata`; `runtime/cache_slots.s`
changed.

Branches, all `calandria-rain-and-slots`: the-advocate (`eb16d48b`, main
merged), the ports (main merged; the ROM test and Sunset's two goldens,
`035e79e`), the book (main merged). `calandria-rain-before-slots` is not
merged, per taro's decision, and can be deleted. Two goldens of the
ports' `test_painted.py` moved: Sunset's square now animates its water
sparkles; before, after and difference in the captures. What stays open
is in the draft
[`sunset-towns-crowds-wait-for-a-slot`](sunset-towns-crowds-wait-for-a-slot.md).
