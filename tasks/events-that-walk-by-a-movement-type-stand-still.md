---
name: "Events that walk by a movement type stand still"
description: "A page whose movement type is random, vertical, horizontal, toward the hero or away from him (1 to 5) gets no route, so the event stands at its cell: NPCs that pace in Sector 34 and Yun Town, ABL's chasing skeletons and monsters, most of Vampires Dawn's walkers"
type: bug
status: testing
assignee: taro
agents: [Hurón]
---

Seen by Aguará on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, while fixing
[`abl-the-agents-on-the-road-to-paradise-do-not-come`](abl-the-agents-on-the-road-to-paradise-do-not-come.md),
in every game. Measured over the dumps and read in the code; **not seen
playing**.

**What is seen**: an event whose page walks by RM2k's movement types
—`MoveType_random` (1), `vertical` (2), `horizontal` (3), `toward` (4)
and `away` (5)— stands still at its cell in the port. Only the custom
type (6), a page's own route, walks: `route::own` in
`rm2k-snes/events/src/route.rs` returns nothing for the others ("they are
another machine"), and the ROM only moves events that have a route slot.

Pages with a CharSet and one of those types, per game, from `data/` of
each port: ABL 127 on 29 maps (in `release`, the pacing NPCs of 38, 67,
70 —Marcy— and 73; outside it, the 54 skeleton pages of 285 Tasgarde
Mainframe, which run at the hero with an event's touch, and the monsters
of rooms 324 to 344); Sunset 31; Book of Three 9; Frozen World 80;
Desert Nightmare 39; Vampires Dawn 859.

**To reproduce**: in ABL, map 70, Marcy (event 6) paces left and right
in the original and stands still in the port.

The ROM already walks, in a route, the steps those types are made of:
`move_random` (8), `move_towards_hero` (9) and `move_away_from_hero`
(10), in `runtime/event_routes.s`. What RM2k adds on top for each type
—`MoveTypeRandom`, `MoveTypeCycle`, `MoveTypeTowardsPlayer` and company
in easyrpg-player's `game_event.cpp`, with their own pauses and their
distance rules— is not there.

## Hurón, 2026-10-14

Starting from the-advocate `51b4b1b2`, the ports `d91049e`, the book
`35b5356`. Branches `huron-walkers` in the three.

**Confirmed in the ROM** (`abl.sfc` of `d91049e`, the global tools): the
three pacers of `release` that a test reaches —Marcy on 70, the cook on 73,
the Yun Town one on 67— stay at their cell for 600 to 1800 frames
(`tests/abl/test_walkers.py`, red). **And in the original**, with Wine and
the start moved to map 70 (a retouched copy of the game in
`~/scratch/huron/walkers/wine/`): Marcy runs from x=3 to x=7 of her row and
back, about 2.5 s a round trip.

How it is done: the compiler gives a page of type 1 to 5 an own route of a
single command, `ROUTE_BY_TYPE` (48) plus the type —49 to 53, not RM2k's
codes, which end at 41—, repeating. The ROM sends that command to
`walk_by_type.s`, new, in the FAR bank, which decides the step as
`Game_Event::MoveTypeRandom`, `MoveTypeCycle` and
`MoveTypeTowardsOrAwayPlayer` do, and tries it with the route's `move`.
Everything else is the route's: slot, step, walk cycle, the wait after a
step, the bump that fires an event's touch and the stop while a page runs.
What is the type's: the refusal does not retry the command nor turn the
event; after 20 frames a cycle turns back; after 60, or if the bump fired a
page, the whole wait starts again. The random one waits 3/5 to 6/5 of a
step after each step. Its draws come from a xorshift of its own,
`walk_rng`, seeded at reset, so that `ControlVars`'s random numbers do not
change with how many walkers there are.

State per slot: +14 of the route slot (a jump's dx, which a type never
walks): the frames trying in vain and whether +30 is a known direction. Far
RAM: 6 bytes. Bank 0: the glue in `ev_route_frame`, `load_page_into_slot`,
`resume_page` and `boot`.

Two things that are not RM2k's, in the book's new divergence
"What walking by a movement type does not model": a walker takes a route
slot only while four others stay free, so `MoveEvent` still finds room
(Vampires Dawn's Limm has 56 walkers and walks eight; measured there, no
frame lost in 1200); and frequency 1 —rejected in a route— walks with a
255-frame wait, for Sunset's ravens (`route_after_step` has an entry for
it now). Also there: own draws, the console's screen for "in sight", the
first step after a turn's wait.

**Vampires Dawn stopped building** with the walkers: map 163 fit only
with a cache of slots after fusing its background, and Wally's fusion
only looked at the plain and shared conversions, whose sprites no longer
fit with six more walkers. Fixed in Wally (its own commit): the fusion
also looks at the cache conversion.

### Tests

* ABL `tests/abl/test_walkers.py`: the three pacers (70, 73, 67) walk
  their axis both ways, and Marcy stands still while a page runs. Red
  before, green after.
* ports `tests/test_walkers.py`: random (Book of Three 52), away (Vampires
  Dawn 51) and toward with the event's touch (Vampires Dawn 359). Red
  against main's cartridges, green after.
* Goldens that moved, in their own commit of the ports: 26 of ABL (the
  deli's cook on 73, Marcy on 70) and Sunset's five painted ones of the
  square (map 2). Looked at side by side; sheets in
  `~/scratch/huron/captures/2026-10-14-walkers/`.
* ABL suite green (1305 + the 2 multi-golden tests rerun green after the
  last round), `just boot` green, `just test` 27.

Not covered by a test: a type walker that a forced route moves and then
gives back (`resume_page`), and the reserve of slots on a map with more
walkers than eight (measured by hand on Limm).

### Pages with types 1 to 5 and a graphic, per game

From the dumps: ABL 127 (`release` carries 10 of them, on 38, 67, 70 and
73), Sunset 31, Book of Three 9, Frozen World 80, Desert Nightmare 39,
Vampires Dawn 859, Dooms 2 and El Dorado none.

### Drafts

* [`page-conditions-on-switches-past-1023-read-other-ram`](page-conditions-on-switches-past-1023-read-other-ram.md):
  VD 735 pages, Frozen World 45; in VD's 433 the fleeing figures pick their
  dead page.
* [`vampires-dawn-tradan-hangs-on-arriving-from-the-start`](vampires-dawn-tradan-hangs-on-arriving-from-the-start.md).

### To merge

Files touched in the-advocate: `rm2k-snes/events/src/{route,codes}.rs`,
`rm2k-snes/mapdata/src/{emit,record,request}.rs`,
`rm2k-snes/convert/src/emit.rs`, `rm2k-snes/wally/src/map.rs`,
`runtime/{walk_by_type.s (new),event_routes.s,event_pages.s,boot.s,main.s}`.
No opcode used (0x4F–0x52 left free). Far RAM: 7 bytes in `FARBSS`.
Install after merging: `just install events convert mapdata wally`.
