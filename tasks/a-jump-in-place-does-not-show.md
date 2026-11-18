---
name: "A jump in place does not show"
description: "A route with Begin Jump and End Jump and nothing between —a hop on the spot— shows nothing on the console; in ABL's Hover-Tram the two robbed passengers should hop"
type: bug
status: testing
assignee: taro
agents: [Calandria]
game: abl
---

taro, on 2026-11-18, playing the build of the ports `0316595` on Mesen,
translated:

> Everything renders correctly now (which is incredible :D) but no NPC
> jumped at the robberies. Honestly I don't remember how it is in the
> original either. Is it intentional that they don't jump?

It is not: in map 13's `EV0028`, `MoveEvent` on `Jump1` (event 1) and on
`Jump2` (event 6) is the route `[24, 25]` —Begin Jump, End Jump—, a jump of
zero cells, which RPG_RT draws as a hop on the spot, right before each
"TRAM PASSENGER" line ("All of my creds are gone!", "Someone's taken my
gold and silver plated chronometer!"). Both are still events after the
Hover-Tram's fork (`abl-the-hover-tram-s-crowd-is-cut`), so the fork did
not cause it; whether it ever showed is to be measured.

Done means: the hop drawn as RPG_RT draws it (height and frames, from
EasyRPG's `Game_Character` jump code and RPG_RT where it matters), for any
event and the hero; a ROM test on the tram scene; other jumps in place
across the games found (a sweep of routes with nothing between 24 and 25).

# What was done (Calandria, 2026-11-18)

**The cause**: `Game_Character::Jump` asks `MakeWay` whether it can land
only `if (dx != 0 || dy != 0)`; in place it jumps on whatever cell it is
on. The ROM's `build_hero_jump` and `build_ev_jump` (`runtime/oam.s` in
the-advocate) called `can_fall` always, and `can_fall` wants the target
passable from all four sides and free of other events. `Jump1` (5,5) and
`Jump2` (8,5) stand on cells with **no passage at all** —0 in map 13's
collision—, so the hop was skipped: the route consumed `24` and `25` on the
same frame and the jump stayed at zero. Measured on the `tram` scene of
`test_talk_golden.py`: Jump1's route starts at tick 2456 and its `+13` never
leaves 0. It never showed: the check is as old as the jumps (`a95ac7f7`,
2026-09-04), and the cells are the same in the original's `.lmu`.

The arc itself was already right for a zero-distance jump —`jump_npc_position`
and `jump_hero_position` with `dx = dy = 0` leave the pixels on the cell, and
`jump_height_of` is `GetJumpHeight`—, so the fix is only the gate.

**The fix** (the-advocate, `calandria-jump-in-place`): in place, both skip
the turn and `can_fall` and start the jump on their own cell. The hero also
gets `hero_heading` down: `Jump` runs `SetDirection(dy >= 0 ? Down : Up)`
before looking at the distance, and only the facing waits for `dx || dy`.
An event's slot keeps only its facing, so nothing there.

**The test** (the ports, `calandria-jump-in-place`):
`tests/rpgmaker/test_jump_in_place.py`, with a new case
`jump-in-place-hero`. Red before the fix, both:

* the tram passengers, on the `talk-tram` scene with A every 40 ticks: each
  hops fifteen ticks —speed 3, `jump_speed` 16— with the arc reaching 16
  pixels and the cell unchanged. Before: "Jump1 was 0 ticks in the air";
* the hero on map 6's wall (19,10), facing left, `[15, 24, 25]` and
  `ProceedWithMovement`: ten ticks in the air with the page held, the cell
  and pixels unchanged, facing still left, `hero_heading` down, and the page
  ends after landing. Before: "the hero was 0 ticks in the air".

That the hop counts for route waits was already true and is now covered:
`any_routes` looks at the slot's `+13` and at `route_jump`, the same for a
hop as for any jump. The tram scene does not wait on it —it is
`MoveEvent` and `Wait 0.5 s`—, so its lines follow as before.

## The sweep: routes with a jump that does not move

Over the nine games' `data/` (the dumps; the ports' patched maps repeat
them), a `24` whose `25` comes with nothing between —or, "adds to zero",
with moves that cancel out, like `[0, 2]`, which RM2k also jumps in place—.
In `MoveEvent`s and in the pages' own routes and the common events. Desert
Nightmare has none. "this event" is a `MoveEvent` on 10005.

* **abl**, 254:
  Map0001 1 event, adds to zero; Map0003 1 event, adds to zero; Map0007 1 hero; Map0008 2 event, 1 this event; Map0009 1 hero, 1 this event; Map0011 3 event, 3 this event; Map0012 1 hero; Map0013 2 event; Map0014 2 event; Map0017 1 hero; Map0019 1 hero; Map0020 1 this event; Map0028 2 hero; Map0032 3 event; Map0038 2 event, 1 this event; Map0045 6 hero; Map0046 1 hero; Map0047 3 event, 1 hero; Map0057 4 hero; Map0058 1 hero; Map0081 1 hero; Map0083 1 hero; Map0085 4 event, 4 hero; Map0093 5 event; Map0095 1 this event; Map0096 1 hero; Map0098 6 hero; Map0100 2 event; Map0102 2 event; Map0105 3 hero; Map0106 3 event, 1 hero; Map0107 1 hero; Map0109 1 event; Map0114 5 hero; Map0117 4 event, 1 hero; Map0118 2 event, 1 hero; Map0121 4 event, 3 hero; Map0126 1 event; Map0127 16 event, 1 hero; Map0128 3 event, 3 hero; Map0130 1 event; Map0132 1 hero; Map0142 1 event, 3 hero; Map0145 2 event; Map0147 1 event; Map0148 1 event; Map0149 5 event; Map0150 1 hero; Map0157 2 event; Map0159 1 hero; Map0165 4 event, 3 hero; Map0166 1 event; Map0167 2 event, 1 hero; Map0168 2 event; Map0169 1 event; Map0171 2 event; Map0172 1 event; Map0173 2 hero; Map0200 1 hero; Map0203 4 event; Map0207 8 event, 2 hero; Map0208 1 event, 1 hero; Map0212 1 event; Map0215 1 event; Map0218 1 event, 1 hero; Map0220 1 event; Map0231 2 event; Map0232 2 event; Map0233 1 hero; Map0237 3 hero; Map0241 1 event; Map0242 4 event; Map0244 1 event; Map0259 2 event; Map0261 3 hero; Map0264 5 event; Map0268 1 event; Map0273 1 hero; Map0276 1 hero; Map0277 3 event, 1 event, adds to zero, 6 hero; Map0284 4 event; Map0287 2 event; Map0288 7 event; Map0307 1 event; Map0311 1 hero; Map0313 4 event; Map0314 1 event; Map0316 1 event; Map0318 4 event; Map0345 2 event, 1 event, adds to zero; Map0347 1 event; Map0350 2 event.
* **book-of-three**, 112:
  Map0005 1 hero; Map0006 3 hero; Map0017 4 hero; Map0020 1 hero; Map0021 1 hero; Map0022 2 event, 1 hero; Map0023 1 event; Map0025 5 event, 2 hero; Map0026 1 hero; Map0029 3 event; Map0030 2 event, 2 hero; Map0031 2 hero; Map0032 1 event, 6 hero; Map0033 1 event; Map0038 3 event; Map0042 3 hero; Map0044 1 event, 4 hero; Map0045 6 event, 2 hero; Map0046 2 event, 1 hero; Map0052 2 event; Map0054 8 event; Map0056 4 event; Map0057 1 hero; Map0059 1 event; Map0060 1 hero; Map0061 3 event; Map0063 2 event, 1 hero; Map0064 8 event, 2 hero; Map0065 4 event; Map0067 1 event; Map0068 1 event; Map0071 2 event; Map0072 3 event; Map0073 1 event; Map0075 1 event; Map0076 2 event; Map0081 2 event; Map0088 1 hero.
* **dooms2**, 25:
  Map0011 1 this event; Map0012 1 event, 1 hero; Map0013 2 this event; Map0020 3 hero; Map0022 1 hero; Map0024 1 event, 2 this event; Map0029 2 this event; Map0030 1 event, 1 this event; Map0035 1 hero; Map0037 1 this event; Map0040 1 this event; Map0053 2 hero; Map0064 1 this event; Map0075 1 this event; Map0079 2 this event.
* **el-dorado**, 31:
  commonevents 1 hero; Map0002 3 hero; Map0003 8 event; Map0005 4 hero; Map0007 2 event, adds to zero, 3 hero; Map0009 3 hero; Map0011 6 hero; Map0012 1 hero.
* **frozen-world**, 320:
  Map0001 203 event; Map0006 2 event; Map0008 1 event; Map0011 1 hero; Map0033 1 hero; Map0034 2 event; Map0037 4 hero; Map0047 2 event, 3 hero; Map0051 1 event, 4 own route; Map0053 1 event; Map0055 3 event; Map0065 1 hero; Map0072 6 event, 2 hero; Map0073 3 hero; Map0075 2 hero; Map0076 1 event, 3 hero; Map0077 1 hero; Map0084 1 event, 1 hero; Map0088 1 event; Map0089 3 hero; Map0098 1 hero; Map0099 1 event, 2 hero; Map0100 3 event; Map0108 1 hero; Map0120 9 event, 1 hero; Map0123 1 hero; Map0125 1 event; Map0127 1 event; Map0129 2 hero; Map0130 1 event, 1 hero; Map0132 1 event; Map0133 4 event, 2 event, adds to zero; Map0135 10 event; Map0136 1 event, 2 this event; Map0140 8 event, 1 hero; Map0141 8 event; Map0142 1 event; Map0150 3 event; Map0155 1 event.
* **sunset-over-imdahl**, 2:
  Map0004 1 event; Map0056 1 this event.
* **vampires-dawn**, 92:
  Map0014 1 event; Map0016 1 event; Map0062 1 hero; Map0118 4 event; Map0131 1 own route; Map0173 2 own route; Map0175 4 own route; Map0176 2 own route; Map0177 15 own route, adds to zero; Map0201 1 this event; Map0208 4 event; Map0209 18 own route; Map0220 1 this event; Map0221 6 own route; Map0256 3 event; Map0279 28 own route.
* **zounds**, 11:
  Map0002 1 own route, adds to zero; Map0005 1 event, 1 hero; Map0039 1 hero; Map0062 1 event, 1 this event; Map0099 1 event; Map0149 4 this event.

How many of those the ROM skipped before depends on the cell each one
stands on when it hops, and that was not measured: only the ones on a cell
not passable from all four sides —or with another event on it— changed.
The script is a throwaway; it decodes each `MoveEvent`'s parameters with the
operands of 32 to 35 skipped, as `route::decode` does.

## What was run, and what it does not cover

* ABL's `just tests` with the branch's tools —`project` and `cartridge`
  installed locally only so that the cartridges assemble this worktree's
  runtime; no Rust changed—: green but for the index of `tests/README.md`,
  which was missing the new file and is fixed in the same commit. That
  includes `test_cores.py`. **No golden moved**: no golden case reaches a
  hop in place on a cell with no passage.
* `just boot`, the other eight games: green, serially. (With `-n 8` it
  is not: each test builds its game, and eight at once race on the same
  `build/` —"symbol already defined" in `mapdata.inc`—. It runs serial
  on purpose.)
* The captures of both hops, frame by frame, are in
  `/shared/captures/2026-11-18-jump-in-place/` —not goldens—.
* **Not compared against RPG_RT under Wine**: the height and the frames
  come from EasyRPG's `Game_Character` (`GetJumpHeight`, `jump_speed`), the
  same the ROM already followed for jumps that move. taro has not played
  it.
* Of the sweep's jumps, the only ones run are the tram's two. A hop in
  place by an event of a page's **own** route —Vampires Dawn has 76, The
  Frozen World 4— goes through the same `build_ev_jump`, but no test runs
  one.

**Branches**: `calandria-jump-in-place` in the-advocate (`9ea86f4d`) and
in the ports. `just space`: `release` is the tightest in data banks —0
whole banks free, 11 halves—, and `test-msu` in bank 1, 140 bytes.

**When merging**: nothing to install: the change is in `runtime/`, which
the cartridges assemble from `~/the-advocate`, and no Rust changed.
