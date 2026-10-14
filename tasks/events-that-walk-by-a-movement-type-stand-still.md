---
name: "Events that walk by a movement type stand still"
description: "A page whose movement type is random, vertical, horizontal, toward the hero or away from him (1 to 5) gets no route, so the event stands at its cell: NPCs that pace in Sector 34 and Yun Town, ABL's chasing skeletons and monsters, most of Vampires Dawn's walkers"
type: bug
status: draft
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
