---
name: "ABL: the Hover-Tram's crowd is cut"
description: "Map 13 has more characters on a line than the PPU draws; still people could be baked into the background if what they draw outside their cell lands where nobody can stand"
type: feature
status: testing
assignee: taro
agents: [Cardón]
game: abl
---

taro, on 2026-11-17, translated (screenshots kept in
`~/scratch/hornero/hover-tram-in-game.png` and `hover-tram-sprites.png`):

> An age-old bug (not a bug, technically): in `Hover-Tram` (map 13), not
> all the characters are drawn because there are too many sprites.
>
> My original plan was a patch of that map that baked the sprites that do
> not move (almost all), but now that we have several optimisations that
> detect things statically, maybe we could build on that and detect this
> at compile time, without a patch.
>
> In that map, event `EV0028` has all the commands. Some NPCs move (they
> get off/on the hover tram) —targets of `EV0028`'s `MoveEvent`s—. They
> seem to be named accordingly: `Leave1`, `Leave2`, etc.; and `Jump1` and
> `Jump2`, which jump.
>
> If we can bake at compile time, it would also be good to deduplicate:
> `EV0020` and `EV0019` are the same graphic —same CharSet + same ChipSet
> tile—. The resulting baked tile should be one for both.
>
> Maybe it's best to tackle it in two stages: one that simply bakes the
> ones that 100% don't move, and then see where that takes us.

**Why they are not baked today** (Hornero, reading `wally` at the-advocate
`7dab7d82`): `posed_events` skips any map with a visible panorama (map 13
has `Evening2`), and `posed::select` takes only poses that fit their
16x16 cell within `baked_events_nudge`; a person is 24x32. The twenty
still ones have one page with no commands, action trigger: with an empty
list RPG_RT does not turn them toward the hero (EasyRPG's
`ScheduleForegroundExecution` returns before facing).

**Stage 1, generic** (this task): a pose may spill out of its cell into
cells **nobody can stand on** —impassable for the hero and for every
event—, so nothing can be behind its head. Not if anything on the map or
in a common event can phase: a route with Phasing On for anyone (the hero
too, by `MoveEvent`), an event page with "through", a `SetEventLocation`
that can land there. And a visible panorama does not exclude the map if
every cell the bake writes is opaque. taro noted, translated:

> True, but the ones in the lower row do not meet that condition… but
> anyway, what you propose is worth it.

and:

> Regarding passability: shouldn't we take into account MoveEvent
> commands that turn phasing on?

So the lower row (y=9), whose heads fall on the aisle, stays out of this
rule. **Measure, don't assume**: how many events bake in ABL and in the
other games, the background tiles and blocks it costs (`just space`), the
sprites left per line on map 13, and whether identical people on
identical floors share their blocks (`EV0019`/`EV0020`). Then say what is
left for map 13's lower row: e.g. the part of a pose drawn over a cell
only walkers *behind* it can reach going to the layer above (BG2, in
front of objects), or stage 2, a patch of the map.

## Log

**2026-11-17, Cardón.** Started from the-advocate `7dab7d82`, the ports
`e87e936`; branches `cardon-hover-tram` in both.

What map 13 is, read from its data: the seated row is y=5 (seats, closed
to walking but for x=2 and 17) under row 4 (the seats' backs, closed);
the standing row is y=9, on the aisle (rows 6-9 open). So the seated
people's heads fall on closed cells, and the standing people's on the
aisle, as Hornero said.

**The hero phases on this map.** `EV0028`, autostart, walks Talan right
six cells, turns Phasing On, sits him on (8,5) through the seats, and
later walks him down and out by the door with it still on, then teleports
him to map 16 —whose event 1 turns it off—. `rm2k_rules::reach` read that
as "the hero walks through walls afterwards", which is anywhere: under
stage 1's rule as written, map 13 bakes nobody. Refined in `reach`: a
page in the foreground that takes the hero off the map before it can end
only *holds* him where its routes leave him —covered, his later routes in
that list walk from there through walls, but he does not walk on from
there—. Never covers more than before.

`rm2k_rules::reach` was covering far more of map 13 than RM2k can reach,
and each of these kept the seated row out; all fixed in `reach`, each a
commit with its test, each covering fewer cells and never more —which
also lowers more on a game with `unreachable_above_below`—:

* a parallel list (the common events) walking the hero from where a scene
  holds him left him free and phasing: now he stays held;
* every event's cell was open to everyone, so the hero walked from the
  aisle onto the seats where people sit (CharSets) and from there, phasing,
  onto the seats' backs: now only events drawn with a tile (bridges) open
  their cell;
* every step of a route could fail and the route go on: only a skippable
  route's; one that is not waits, and a step onto a closed cell never
  comes —the hero no longer "stops anywhere" on his way to the seat—;
* an autostart page that asks for nothing, under pages that ask only for
  switches nothing on the map turns off, starts where the hero arrives
  (2,7), not wherever he can walk;
* the hero and events walking on their own stepped diagonally, and passed
  over the seat beside the end seat: RM2k 2000 walks them in four
  directions.

And in the converter: ABL's "recall the hero's cell five rows up" put him
on any open cell of *every* map —the Hover-Tram's window panes are open
cells, so he could be put on the wall—; the recalls whose map variable is
only set to numbers go only to those maps (60 and 61 in ABL).

**Horizontal spill, decided**: measured on map 13, the seated people draw
0 px past their cell's sides but one (`EV0009`, 3 px each side); their
heads are 16 px wide, so 24-26 px of each head fall in the 4 px columns a
neighbour's sprite covers. A character on the row above is never let
through. One on the event's own row to its left —behind it in RM2k's
order— is let through: it already draws its 4 px side over every event
baked into its cell, which the book's divergence accepts, and the spill
adds the same 4 px over the head; one to the right is in front in RM2k
too. On the event's own cell RM2k puts the higher id in front; the hero is
taken as behind.

**Panorama**: allowed when the map's panorama goes mode 3 or flattened
—the ways that draw the poses' rows of the extension; baked, painted,
black and mode 1 do not— and every cell the bake writes is opaque in
every drawing. Map 3 (mode 1) crashed the first try: the extension was
not built.

**Colours**: map 13's background had a budget of 35 CGRAM entries; the
seated people bring 48 colours more, and `same_split` refuses any budget
change. For a set with spills, the split may move if the layer above
keeps its tiles and cells and nothing merges more (`only_the_split_moved`):
with it 7 of 7 seated still people go in; without it, 2 (`EV0007`,
`EV0008`).

**What does not reach: ABL recalls a computed place on every map.** The
recall of `CE42`/`CE44` memorizes the hero's place and recalls it with
its row changed —"five rows up"— so the converter's `any_open` stays on
for every map: on map 13 the hero can be put on any aisle cell, and the
trip scene, which starts where he arrives, can then seat him on any seat
of the row from x=8 on, or walk him onto a seat beside one of them. So
only `EV0005`, `EV0008` and `EV0009` pass the rule (and of them only
`EV0005` goes in: see "Colours, again" below); `Leave1`, `EV0004`, `EV0007`
and `EV0026` are ruled out by the hero seated on their cell or beside
them. In RM2k the trip runs once (it turns switch 69 on before leaving),
from (2,7): that is what `reach` cannot know. With `any_open` off for map
13 (measured on a hand-edited request), all seven go in.

Measured, ABL, the-advocate `9f0e21d0`, global runtime `7dab7d82`:

* (first measure) events into the background: 478 before, 614 after —112 of them drawn
  past their cells, on 20 maps (13 21 28 29 42 83 90 199 200 225 229 242
  258 288 291 295 298 314 316 345); the other 24 are in-cell ones on maps
  with a panorama that shows, newly allowed—;
* (first measure, superseded below)
* sharing: `EV0019`/`EV0020` are on the standing row, which does not
  bake. On the seated row, with all seven in (the hand-edited request),
  `EV0007` and `EV0008` —both Future2:5 on the same seat— get the same
  pose block, 26, and `EV0004` and `EV0005` —Future1:7— the same 25: the
  blocks are deduplicated by what they draw, and the head cells above are
  map cells, deduplicated the same way.

**Colours, again.** The suite's patches check showed it: moving the
split for map 13's people took the panorama from 46 kept colours to 32 —
the evening outside the windows drawn worse—. `only_the_split_moved` now
also asks the panorama to keep its colours and tiles; with it, of the
three that pass the rule only `EV0005` fits. The colours are the second
wall on this map, after `reach`.

**And the test cartridges.** `teleport-missing` baked more of map 21 than
`release` (fewer maps, so fewer arrivals): the converter now gathers where
the hero arrives over the whole game's maps, and a map decides the same
in every cartridge.

## Final, 2026-11-18

the-advocate `cardon-hover-tram` (from `7dab7d82`, with `f658861c`
merged), ports `cardon-hover-tram` (with main `da4074f` merged), book
`cardon-hover-tram`. To install when merging: **wally, convert** (and
rm2k-rules goes into wally); the runtime is untouched by this branch.

* ABL release: 478 events in the background → 612; 110 of them drawn
  past their cells, on 20 maps; the rest are inside their cells on maps
  whose panorama shows, newly allowed. `just space`: release (the
  tightest) 11 free halves of 32 KB → 10, gaps 20,299 → 29,895 B;
  test-special unchanged.
* Map 13: `EV0005` in the background. `just objects-per-line abl --map
  13`: the seated row's lines 13 characters / 52 slivers → 12 / 48; the
  standing row's 14 / 56, unchanged. Still over: Mulita's STAT77 test
  keeps map 13.
* Zounds (the only other game with `baked_events`): 427 → 457, 22 past
  their cells on 9 maps (49 59 108 109 126 128 155 175 176); free banks
  unchanged (46), gaps 44,309 → 32,437 B. The other seven games do not
  turn `baked_events` on: nothing bakes there (not measured with it on).
* Sharing: with all seven in (hand-edited request), identical people on
  identical seats share their pose block (`EV0007`/`EV0008`: 26,
  `EV0004`/`EV0005`: 25).
* Goldens: ABL's ten (tram, panorama-13, elevator, delcentric pump 83)
  and Book of Three's three (the barrel's top, drawn below by the
  lowering since reach covers less), each looked at, in their own
  commits; side by side in `/shared/captures/2026-11-17-hover-tram/`.
* Verified: `just test`; ABL's `just tests` (1686 passed, test_cores
  included) and `just boot` with the branch's wally, convert and
  cartridge (the merged runtime) on the PATH.

## What is left: stage 2 (proposal, not implemented)

Map 13's crowd is cut by two things this stage cannot move:

1. **The standing row's heads are over the aisle**, where the hero
   walks behind them. Proposal: the part of a pose drawn over a cell that
   only walkers *behind* the event can reach goes to BG2, the layer above
   (in front of objects at priority 1), and the rest to BG1 as now. BG2
   is 4-bit and its palettes are the layer above's —the people bring
   ~48 colours, which on map 13 do not fit with the panorama's—, and a
   walker in front of the person passing over that cell would go under
   the head: true only for cells nobody *in front* can cover. Measuring
   it needs the layer above's palettes on map 13 first.
2. **ABL's recalls and the run-once scene**, which keep four seated
   people out (draft
   [`reach-does-not-know-a-scene-runs-once`](reach-does-not-know-a-scene-runs-once.md)),
   and **the colours**: map 13's background has 35 entries beside the
   panorama.

The cheaper way is taro's first plan: a patch of map 13 that bakes the
crowd as tiles of the map (the people never change), with the colours
chosen by hand against the panorama's. That is per map and per game, and
it is the one that reaches the standing row too.

## Stage 2: a patch of map 13 (2026-11-18, Hornero)

Stage 1 merged (the-advocate `44e25d4f`, the ports `45ed2bf`): one seated
person baked, the one cut at the right of the upper row now shows; the
standing row is still 14 characters, 56 slivers. taro, translated, to
merging it and patching the map: "Dale :D". taro's plan, from the start of
this task: a fork of map 13 in `patches/manual/` with a ChipSet that bakes
the people that never move, and maybe the `Jump` ones baked at first and
swapped by a `ReplaceTile` for the empty seat when they jump, showing their
events then.

## Log, stage 2

**2026-11-18, Cardón.** Started from the-advocate `44e25d4f`, the ports
`45ed2bf`; branches `cardon-hover-tram-patch` in both.

Who moves, read from `EV0028`: its `MoveEvent`s name `Jump1` (1),
`Jump2` (6), `Leave2` (21), `Leave3` (23), `Leave4` (25), `Stash` (27) and
the hero, and nothing else on the map moves an event of map 13 (it calls
no common event). **`Leave1` (3) is never moved**: its name says it was
meant to, but no command names it, in RM2k either. It is baked with the
other twenty: 21 still people, 8 seated and 13 standing.

What the map asks of the bake, which `from_charset` could not do:

* the seated people's heads fall on the seat backs, upper tile 73, which
  RM2k draws below characters (passability 0, no star): the head has to
  compose over it;
* `EV0009` (3,5) draws one column past each side of its cell (3 pixels
  each side, on its body's rows): on (2,5), an open cell, and on (4,5),
  behind `EV0008` —RM2k draws by row, then column, then id, so the one
  further right is in front—.

So `from_charset` takes `cells`, `[dx, dy, slot, under]` relative to the
event's cell, `under` the slot composed below (convert, the-advocate
`08f42f8d`, with its test red on the old code). `head`/`body` stay.

**The fork** (ports, `abl/patches/manual/`): `maps/Map0013.json` is the
dump's map without the 21 baked events, `chipset_id` 57 and the `id`;
`maps/Map0013.tiles` is the dump's but for rows 4, 5, 8 and 9 of the
upper layer; `ChipSet/0057.json` is `BLChip1` (9) with passability for 22
new upper slots (100-124) and the recipe: `prune` 13 and twelve
`from_charset` items. Written by a throwaway script, so the fork's JSON
is the dump's text with whole event blocks taken out. Passability: the
person's own cell closed (0) as the event was; a head over the seat back
keeps 73's 0; a standing head on the aisle and `EV0009`'s spill on (2,5)
are open, 15. Identical poses on identical backgrounds share their slots
(`EV0007`/`EV0008`'s head, `EV0002`/`Leave1`, `EV0019`/`EV0020`…; and
`EV0024`'s body is `EV0002`'s).

**The pattern.** RPG_RT draws `EV0016`-`EV0020` (page pattern 2,
animation type 0) on the middle pattern, and so does EasyRPG
(`SetupFromPage` sets the page's pattern only for a fixed graphic or
spinning); the ROM drew pattern 2. The bake takes 1, as RM2k. The ROM's
general behaviour is the draft
[`a-character-stands-on-its-middle-pattern`](a-character-stands-on-its-middle-pattern.md)
(78 pages of ABL, 46 maps).

**Colours.** The people's colours go to the background: map 13's lower
layer 29 colours → 85 (budget 35 → 99), no merges; the panorama keeps 15
of its 157 colours instead of 46. Measured against `Evening2` at 15 bits,
0.77 → 0.83 levels off per pixel on average: side by side the clouds
look the same, and it shows through three small windows. Taken that way:
the people, which fill the screen, keep every colour. `patches/auto/maps/0013.toml`
regenerated.

**Against RM2k.** (1) `rm2k-render` layers + RM2k's draw order (row,
column, id), original data against the fork: 9 pixels differ, all
`Leave2`'s (8,9) right side over `EV0022` (9,9), which RM2k draws in front
and the bake cannot. (2) RPG_RT 2015 under Wine, two copies of the game
that start a new game on map 13 at (2,7) —one as it is, one with the fork,
ChipSet 57 in the database and its built PNG—, a capture 4 s after each
Return through the scene: every stop of the original matches a stop of
the patched run but for those same 7 pixels (28 at 2x) —the runs drift
by one stop where a Return lands during a wait, and the "received" line
is not shaken with the map—; the people that walk off, the thief's walk
over the seated row and his turns are the same. The hero is not drawn in
either copy (the new game's party, actor 10; not chased), so his walk is
not compared; his cells are unchanged by the fork.

**The line limit.** `just objects-per-line abl --map 13`: 0 over. The
runtime's STAT77 counts over the whole trip (a probe, not committed:
arrive at (2,7), A every 30 frames until map 16, 2400 frames): range over
0, time over 0. So the `Jump` swap is not needed and was not done.
`test_the_frames_the_ppu_drops_objects_are_counted` went red as expected
("the Hover-Tram no longer goes over by slivers (0 of 120 frames)") and
moved to map 318, The Show, whose audience is 14 characters, 56 slivers,
at the entrance (sweep of 2026-11-17).

## Final, stage 2, 2026-11-18

the-advocate `cardon-hover-tram-patch` (`08f42f8d`, from `44e25d4f`), the
ports `cardon-hover-tram-patch` (`5515d04` the fork, `f8330dc` the
goldens, from `45ed2bf`), the book `cardon-hover-tram-patch` (`73e3378`:
the decision "The Hover-Tram's crowd is part of the map", the known issue
of crowded lines without the Hover-Tram, the new known issue of the
pattern). main had not moved in any of them. **To install when merging:
convert.**

* Map 13: 21 still people baked, 6 movers stay events; busiest line 6
  characters (seated row, hero included), standing row 1.
  `objects-per-line`: 0 over. STAT77 over the trip: 0/0. The `Jump` swap
  was not needed and was not done.
* `just space`, release (the tightest): 11 free halves of 32 KB, gaps
  1,392 B, bank 0 3,992 B (stage 1's end: 10 halves, 29,895 B).
* Goldens: six (panorama-13-arrival, tram-900, tram-1200, tram-trip-10,
  -30, -60), in their own commit; side by side, with RPG_RT's captures
  and the composed RM2k reference, in
  `/shared/captures/2026-11-18-hover-tram-patch/`.
* Verified: `just test` in the-advocate; ABL's `just tests` (1686 passed,
  test_cores included) and `just patches-check`, with this branch's
  convert on the PATH; `abl.sfc` sha256 `94922c66483bc3e8…`.

Not covered by the suite: the RPG_RT comparison and the STAT77 count over
the whole trip were throwaway runs (scripts in `~/scratch/cardon/tram2/`);
in the RPG_RT measuring copy the hero is not drawn (a new game's party,
not chased), so his walk was compared only by its cells, which the fork
does not change. Drafts: [`a-character-stands-on-its-middle-pattern`](a-character-stands-on-its-middle-pattern.md),
new; [`reach-does-not-know-a-scene-runs-once`](reach-does-not-know-a-scene-runs-once.md)
gets a line saying map 13 no longer shows it.
