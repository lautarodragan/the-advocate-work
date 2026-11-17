---
name: "Poses only when an event can show them"
description: "Every character on a map carries its twelve poses in the cartridge and gets a VRAM slot sized for them, also the NPCs that never move: Dooms 2's map 1 has 16 still NPCs facing down and '31 with their twelve poses'"
type: feature
status: testing
assignee: taro
agents: [Calandria, Hurón, Mulita]
---

Left by Calandria on 2026-10-16, from taro's plan for Dooms 2's map 1
(`dooms-2-slots-and-menu-dont-fit-in-their-bank.md`), tools `30ab0ca6`,
ports `f8aca68`:

> a general optimization: poses loaded only when needed

**What is seen**: in the converter's log of Dooms 2's release, map 1 says
"sprites: 31 characters, 29 slots, 500 tiles in VRAM, 8 palettes; 31 with
their twelve poses in the cartridge". Its 16 NPCs with a graphic are all
still —`move_type` 0, no route, every page facing down— and nobody turns
them: of the twelve poses of each, the map can show one. The same line in
the other maps of the game reads "N with their twelve poses" for every
character, still or not.

**What exists already**: in VRAM, most of it. Still characters share a
slot per (CharSet, index, facing) with only the tiles of that pose, the
distant ones take turns on one, the slots are a cache, and the walking
steps upload their pose in vblank —"Characters and sprites" under the
book's lossless optimizations, and `internals/vram.md`—. And
`poses-without-their-empty-tiles.md`, in testing, stores each pose without
its empty tiles and shares the NPCs' poses whole.

**What this would add**: in the **cartridge**, carrying for each
character only the poses some page of the map can show —one for a still
NPC nobody turns, the four facings for one that turns without walking,
the twelve for a walker—, with the converter deciding it from the pages
and routes as `possible_leaders` decides who can lead. What the log
counts as "with their twelve poses" says how much it would save per map;
it is not measured in bytes here. A page change that gives the event a
route it did not have —a switch— has to be seen by the same analysis, or
the pose is missing when it walks.

**How to see it**: `just cartridges release` in `dooms2/` and the
`sprites:` line of map 1 in `build/release/converter.log`.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
An optimisation of the cartridge and of VRAM; nothing stops on its own,
but it is one of the two ways open for
[`vampires-dawn-maps-that-dont-fit-in-vram`](vampires-dawn-maps-that-dont-fit-in-vram.md),
which takes it if it measures it as the one that fits them. **Done** is
the converter deciding, from each map's pages and routes, which of the
twelve poses each character can show —one, four or twelve, a page change
that gives a route counted— and carrying and slotting only those; the
`sprites:` line saying how many of each, and the bytes saved per game
measured. First step: count, over the nine games, how many characters
fall in each of the three classes.

## The first step, to Mulita (2026-11-17)

taro asked whether this still applies. Hornero found that Wally already
gives the twelve poses only to what walks, turns or animates
(`rm2k-snes/wally/src/moves.rs`), yet the log of today's builds still
says almost every character carries them: Dooms 2's map 1, "34
characters, 29 slots, 500 tiles in VRAM, 8 palettes; 33 with their twelve
poses in the cartridge", where this task counted 16 still NPCs nobody
turns; ABL and Vampires Dawn read the same. taro, translated: go ahead
with the first step as a short study.

Done for this step: why map 1 counts 33 (a classification that takes still
NPCs for movers —a route or page naming them without moving them— or a
log that miscounts); the count per class (one pose, four, twelve) over the
nine games; the bytes each game would save, and what it would mean for
Vampires Dawn (full, maps out of VRAM). A recommendation; no
implementation unless the cause is a plain bug in the classification.

## The study (Mulita, 2026-11-17)

Against the-advocate `c48be14b` and the ports `d5d8d29`, the global tools.
Each game's `release` rebuilt in a ports worktree of my own with a
throwaway `wally` on the PATH that runs the global one and keeps each
`map` call's request and answer; the classification read from those
answers, not reimplemented.

**Map 1 of Dooms 2 is classified right, and the log counts right.** The
log's last number is the length of `animated` in `wally map`'s answer —the
characters that go to the cartridge with twelve poses—, and on map 1 it is
33 of 34 for these reasons, none of them a mistake:

* the eleven leader candidates (`leaders` of the request): the hero walks;
* the ten graphics command 34 changes to (`route_graphics`), which keep
  walking;
* **the sixteen NPCs turn toward the hero.** Every page of each is
  `animation_type` 0 with the action trigger, so RM2k turns it to face
  whoever talks to it (`ScheduleForegroundExecution` with `face_player`,
  in EasyRPG's `game_event.cpp`); the compiler's scan says `turns` for
  all of them and `moves` puts them in `turning`, which gives the twelve
  poses of every graphic of every page that turns. It is the "Choose"
  map: you walk up to each scenario and talk to it. What this task said
  —"nobody turns them"— missed the trigger.
* and fourteen of them have a page with the same graphic translucent,
  which the converter bakes against its cell (`~horneado:<map>:<x>:<y>`):
  another character for the cartridge, one per NPC, twelve poses each,
  turning too.

The only one that walks is event 3 (`movable`: a route on its own page
turns it, outside a cache it walks). So the class that is missing is not
"one pose" but **"four facings"**: what turns toward the hero can only
show its page's pattern in each of the four directions (EasyRPG changes
the direction and keeps the frame, and turns it back with `UpdateFacing`
when the event ends).

The runtime already relies on that: `turn_toward_hero.s` builds the
turned pose from `TURN_DIR` and **the column of the previous one**.

**The count over the nine games.** For each character the cartridge
carries twelve poses of, the poses it can really show: twelve for a leader
candidate, a walker and a graphic command 34 changes to; the four facings
at its page's column for one that turns toward the hero, or that routes
only turn in a cache; the three of its row for a still one that animates;
and the pose (or poses) the cache's or the shared slots' stills name.
Every key of `animated` got a reason. "Per map" counts a character once
in each map; "per bank" once per pose bank of the cartridge (a character
per quantization, the needs joined over the maps). The bytes are the
cartridge's pose records —distinct, without their empty tiles, as
`poses()` in mapdata emits them; the "now" column matches each
converter's "N distinct" line— carrying only the showable ones.

| game | per map: twelve / turns / row / one / several stills | per bank: twelve / turns / row / one / stills | pose records now | only the showable | saves |
|---|---|---|---|---|---|
| ABL | 5005 / 72 / 78 / 22 / 3 | 142 / 31 / 7 / 22 / 2 | 462,778 B | 393,748 B | 67.4 KB, 1.05 banks |
| Book of Three | 587 / 8 / 15 / 37 / 0 | 32 / 3 / 13 / 37 / 0 | 259,558 B | 126,352 B | 130.1 KB, 2.03 banks |
| Desert Nightmare | 1810 / 4 / 2 / 90 / 261 | 298 / 4 / 2 / 68 / 195 | 910,210 B | 795,120 B | 112.4 KB, 1.76 banks |
| Dooms 2 | 1354 / 38 / 1 / 0 / 0 | 49 / 28 / 1 / 0 / 0 | 196,344 B | 150,184 B | 45.1 KB, 0.70 banks |
| El Dorado | 186 / 6 / 20 / 31 / 12 | 74 / 6 / 14 / 30 / 12 | 251,324 B | 195,070 B | 54.9 KB, 0.86 banks |
| Frozen World | 389 / 58 / 5 / 53 / 13 | 115 / 19 / 3 / 53 / 12 | 424,392 B | 265,222 B | 155.4 KB, 2.43 banks |
| Sunset over Imdahl | 419 / 43 / 164 / 62 / 11 | 115 / 11 / 121 / 60 / 11 | 502,786 B | 344,340 B | 154.7 KB, 2.42 banks |
| Vampires Dawn | 5040 / 56 / 598 / 372 / 29 | 366 / 22 / 457 / 339 / 17 | 1,497,574 B | 1,015,562 B | 470.7 KB, 7.35 banks |
| Zounds | 2005 / 55 / 18 / 54 / 8 | 88 / 35 / 16 / 54 / 8 | 344,462 B | 231,734 B | 110.1 KB, 1.72 banks |

Dooms 2's map 1, per map: 15 twelve (leaders, route graphics and the
walker) and 18 that only turn. The "twelve" per map are mostly leader
candidates, which every map carries: per bank there are far fewer.
"One" and "several stills" exist only in maps with a cache or shared
slots, where stills are uploaded from the cartridge's poses; elsewhere a
still one that does not turn is already one pose in the sprite bank and
never reaches the cartridge's pose banks, which is why the task's "one
pose" class barely shows.

**VRAM does not change**: a still one already takes one pose in a slot
shared by (CharSet, index, pose), one that turns uploads into the map's
single turn slot, and a walker's or an animated one's slot is sixteen
tiles whatever the cartridge carries. So the nine Vampires Dawn maps that
are out because of VRAM
([`vampires-dawn-maps-that-dont-fit-in-vram`](vampires-dawn-maps-that-dont-fit-in-vram.md))
do not come back with this: that one has to go the other way, a
degradation of the sprites. What it does give Vampires Dawn is 470 KB
less of poses in a cartridge whose release puts 580 pieces, 4,700,913
bytes, in the `.msu` (measured in this build): about a tenth of the spill
back to ROM.

**Recommendation**: worth doing, as a cartridge optimisation and not a
VRAM one, and not urgent for any game but Vampires Dawn. How: Wally
already knows each character's showable poses —`map_poses` in
`sprites/npc.rs` computes them for the palettes; it only has to give
four facings instead of twelve to `turning`, and the same to a cache's
turners— and could answer them with each bank; mapdata's `poses()` would
join them per bank across maps and emit only those records, pointing the
rest of the twelve pointers of the entry at any emitted one (the table
format stays). The risk is a pose the analysis misses: it would show
another one, not crash, and a guard can check that every pose a row can
ask for —the page's, the turn's from `TURN_DIR`, a cache still's— is in
its bank.

Done by Mulita for this step: no implementation (the cause is not a bug).
How it was measured, to repeat it: `just cartridges release` in each
game with a `wally` on the PATH that runs the global one and copies
`request.json` and `--out` of each `map` call. The two builds that failed
(Desert Nightmare: "unknown opcode", Sunset: an assertion in
`text_layer.s`) failed because the global tools were reinstalled while
they ran; every map of both had already been answered by the unchanged
`wally`, and their "now" matches the converter logs of
`~/the-advocate-ports`.

## Implement it (taro, 2026-11-17)

taro, after the study's numbers: go ahead. Mulita implements the
recommendation: the four facings instead of twelve for what only turns
(and what turns by route on a cache map), from Wally's `map_poses`; mapdata
emits per bank only the poses some map can ask for, the spare pointers
aimed at a pose that is there; a converter guard that every pose a row can
ask for is in its bank.

## The implementation (Mulita, 2026-11-17)

From the-advocate `ea529d5a` and the ports `69a722b`, branches
`mulita-poses` in both.

`git blame` first: the twelve poses for `turning` came with the port of
the map's sprites to Rust (`756fe507`, 2026-09-30), a simplification of
what the Python did, not a constraint of the runtime.

What the runtime asks the pose table for, read from it before deciding:

* the turn toward the hero: `TURN_DIR * 3` plus the column of the row's
  previous pose (`turn_toward_hero.s`), from the page's +30 entry;
* a route's turn: direction times three plus the route slot's column,
  which `route_for_event` starts at 1 and `fixed_graphic_into_slot` sets
  to the page's for a fixed graphic (`refresh_npc` in `npcs.s`); a cache's
  turner takes it as a still key through `still_turn`, which moves the
  key by as much as the pose: so the cache keeps naming the twelve, and
  only the cartridge's records shrink;
* the rest as the study said: rows that walk or animate, `walker_graphic`,
  the leaders, command 34, the shared slots and the cache's stills.

So "what only turns" carries the four facings of each of its pages'
columns and, for a cache's turner, of the middle column too.

How:

* **Wally** — `map_poses` gives a still event in `turning` the four
  facings of its pages' columns (`pose_facings`), and one in `movable`
  that turns, the twelve; the map's answer carries, per bank, which poses
  it can show (`cartridge_poses`: `map_poses`, the cache turners' facings
  and the shared slots' poses), as a fourth element of `banks`.
* **The converter** passes it on.
* **mapdata** — `poses()` joins it per bank over the maps and emits only
  those records; the other pointers aim at a shown pose of the same
  direction, else column (`stand_in`). Before that, `requested()` reads
  from the map's own tables —actors, command 34, rows, pages' +30, shared
  poses, the cache's stills— every pose the console can ask for, and one
  the bank lacks stops the build. A bank without the fourth element keeps
  its twelve: the test fixture's tables come out byte for byte the same.

Tests, red before: Wally's
`one_that_only_turns_carries_the_four_facings_of_its_columns` (red by
assertion: it got the twelve) and
`the_cartridge_carries_what_shows_turns_and_takes_turns`; mapdata's
`tests/poses.rs`, four cases (they did not compile before: no `Bank`, no
`stand_in`, `poses` without the rows).

Two corrections the first builds asked for, each its own commit:

* **The palettes still count the twelve.** Counted over the four
  facings, a character that turns came out quantized a little
  differently and stopped sharing the bank of the maps where it walks:
  ABL carried twelve banks more, 7 KB of what the facings save, and
  colours moved. The cartridge carries four; the palettes are chosen as
  before, so nothing on screen changes.
* **The guard asks only a cache's turners for facings.** It first took
  any character whose twelve still poses the cache names as a turner's,
  and stopped El Dorado (map 12: pressure plates a route turns, and
  arrowheads of the same `Gold:2` in other columns that never turn) and
  Desert Nightmare (map 15, `Polizei_Gasse:2`). Who a route turns is not
  in the tables, so Wally says it in the cache's `turners`; the poses the
  guard derives from the tables and the runtime's rule.

`main` moved during the measurement (the global runtime went to
`272a0b66`): the "after" builds run entirely with tools installed from my
branch —`project cartridge events wally mapdata convert`—, whose runtime
is `ea529d5a`'s, the same the "before" builds used.

### Measured (Mulita, 2026-11-17)

Each game's `release`, before with the global tools at `ea529d5a` and
after with my branch's (`237ca6ec`), same runtime, in a ports worktree at
`69a722b`. "Records" are the pose records the cartridge carries, from
mapdata's notes (`2 × distinct + 32 × drawn tiles`); "left out", the
pointers that now aim at a stand-in; the banks, `just space`'s release.

| game | records before | after | saves | left out of | data banks used |
|---|---|---|---|---|---|
| ABL | 462,778 B | 393,942 B | 67.2 KB, 1.05 banks | 568 of 2,448 | 117 → 115 (free halves 9 → 11) |
| Book of Three | 259,558 B | 126,352 B | 130.1 KB, 2.03 | 548 of 1,020 | 45 → 43 |
| Desert Nightmare | 910,210 B | 799,290 B | 108.3 KB, 1.69 | 1,909 of 6,804 | 92 → 91 |
| Dooms 2 | 196,344 B | 150,184 B | 45.1 KB, 0.70 | 233 of 936 | 38 → 38 (gaps 2,991 → 49,151 B) |
| El Dorado | 251,324 B | 199,950 B | 50.2 KB, 0.78 | 543 of 1,632 | 19 → 18 |
| Frozen World | 424,392 B | 275,146 B | 145.7 KB, 2.28 | 733 of 2,424 | 63 → 61 |
| Sunset over Imdahl | 502,786 B | 345,924 B | 153.2 KB, 2.39 | 1,916 of 3,816 | 84 → 82 |
| Vampires Dawn | 1,497,574 B | 1,029,130 B | 457.5 KB, 7.15 | 8,035 of 14,412 | 126 → 126 (full) |
| Zounds | 344,462 B | 233,254 B | 108.6 KB, 1.70 | 1,077 of 2,412 | 64 → 62 |

Against the study: the same within a few KB —Book of Three and Dooms 2
exactly; Desert Nightmare, El Dorado and Vampires Dawn a little less,
because a cache's turner also carries the middle column's facings, where
a route slot starts—.

**Vampires Dawn's `.msu` spill**: 580 pieces, 4,700,913 bytes, before;
461 pieces, 4,233,332 bytes, after —467,581 bytes back in the ROM, the
`.msu` from 33,617,408 to 33,135,360 bytes—. The cartridge stays full:
what leaves the poses is taken by what used to spill.

### Tests and what is left (Mulita, 2026-11-17)

On the merged tree —the-advocate `mulita-poses` with `main` at
`df470ebb`, the ports `mulita-poses` with `main`—, every tool from the
branch (`install-local … project cartridge events wally mapdata
convert`):

* `just test`, green; `crate-test` of wally, mapdata, convert and events,
  green.
* ABL's `just tests`: 1679 passed, 2 skipped; **no golden moved**, which
  is what says the walkers, the ones that animate and every turn the
  suite already looked at are unchanged.
* New, `test_a_still_one_turns_toward_the_hero_from_each_side` in
  `test_talk_golden.py`: the bar patron of map 10 —still, turns toward
  the hero— talked to from each side (cases `talk-twin-right`, `-down`,
  `-left`, and `talk-twin` from above), TURN_EV and TURN_DIR checked and
  the frame against a golden. The goldens were taken with the twelve
  poses in the cartridge (the branch's tools with `ea529d5a`'s convert,
  which drops what the map can show, so mapdata keeps the twelve), and
  the test is green with the four facings. It is a regression guard: no
  ROM before the change makes it red.
* `just boot` at the ports' root: 155 passed.
* `just test-game`: 4 red —the leader-name goldens and Goombario in
  `tl_glyph_hi`—, the same 4 on `main` with the global tools: the drafts
  `the-test-games-leader-name-goldens-are-red-on-main` and
  `goombario-reads-widths-from-an-untaken-if-branch`.

What the suite does not cover: a cache's turner turned by a route (the
guard checks its facings are carried; no ROM test turns one and looks at
it), and a still one that turns toward the hero on a page whose column is
not the middle one.

**To install when merging**: `wally mapdata convert`. The three go
together: the answer's fourth element of `banks` and the cache's
`turners` travel Wally → convert → mapdata; a mapdata without them keeps
the twelve, a convert without them drops them.
