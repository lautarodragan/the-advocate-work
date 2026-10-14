---
name: "ABL: the agents on the road to Paradise do not come"
description: "On the map with the panorama where an agent knocks Arden down, the original spawns agents that run at Talan every so often and start a battle when they touch him; in the port nothing appears"
type: bug
status: testing
assignee: taro
agents: [Aguará]
---

taro, on 2026-10-14: "On the road to Paradise, on the map with the
panorama where Arden is lost (an agent attacks her and she falls), and the
agents appear: in the original, NPCs spawn and run at Talan periodically.
Touching Talan starts a battle. In ours that simply doesn't happen."

Which map it is is to be found: the road is 105 Mountain Path, 106 and 107
TunnelToParadise, between the tunnel (66) and 108 Distant Paradise —see
[`world-7-the-road-to-paradise`](world-7-the-road-to-paradise.md)—.

## Log

**2026-10-14, Aguará.** It is map 105 'Mountain Path', the one with the
Evening1 panorama. Event 4, stepped on at (52,17), brings the vehicles:
it turns 326 on, puts event 5 —`AgencyGuardChasing!`, `BLAgents`— at
(69,18) and turns 327 on, which wakes the parallel event 6. That one puts
Talan's row in variable 53 and turns 328 on (row 18 or more) or 329
(above). Event 5's pages 2 and 3, on 328 and 329, are the guard: layer
same, an own route of `move_towards_hero` zigzagging up and down
—`[9, 2, 9, 0, 9]` and `[9, 0, 9, 2, 9]`, repeating, skippable—,
frequency 8, speed 5, and **trigger 2, the event's touch**. Its page
disables escape, fights troop 184, enables it again and sends the guard
back to (69,18): so he comes again and again, which is the "every so
often" of taro's report.

Measured in the original with Wine (2015 runtime, a copy that starts on
105 at (53,17) with Talan and Arden): a step left, the two messages, and
the guard comes from the bottom right and touches Talan in about two
seconds; the battle with the Agency Guard starts.

**Two causes, both in the tools, measured.** `culprits` says every page
of 105 compiles, and that is true and does not see either:

1. **The own route with 9 was left out on purpose**: `route::own`
   refused `move_towards_hero` while no test got there —its doc comment
   said so, from 2026-09-29, and named these two pages—. The page stayed
   active and drawn at (69,18), still. With the route accepted, the guard
   ran up to Talan and stood next to him.
2. **Trigger 2 was not triggerable at all**: `pages::triggerable` only
   had 0, 1, 3 and 4, so its pages were emitted without code, without a
   warning in the converter or in `culprits` —which only looks at the
   triggers of troop pages—. 64 pages of ABL on 8 maps (105, the
   skeletons of 285, the monsters of 327-338), all on the hero's layer;
   284 more in Frozen World, Desert Nightmare and Vampires Dawn.

The fix: the own route takes 9 (not inside a jump, as in a forced
route); trigger-2 pages compile; the ROM fires them from the hero's side
as touch (`queue_by_action` takes 2 when it looks for touch) and from the
event's, with `collide_with_hero` in `event_routes.s`: a refused step
whose cell is the hero's fires the event's active page if it is trigger
2 on the hero's layer and the interpreter is free —RM2k's
`Game_Event::CheckCollisonOnMoveFailure`—. Not done: an event on another
layer that ends a step on the hero (`CheckEventCollision`), none in ABL:
a draft.

**Done, to testing.** Branches `aguara-paradise-agents` in the-advocate
(`14dde765` the own route with 9, `ff37c971` the event's touch), in the
ports (`289cfa1` the test and the harness, `ce31636` the golden) and in
the book (`957e246`: the row in `internals/events.md` and a Known issues
line for the pacing people).

ABL's new test is
`test_the_guard_of_105_runs_at_talan_and_touching_him_is_a_battle`, in
`tests/abl/test_paradise.py`: red with the tools of `a7f278e6` (the
guard never left (69,18)), green with the branch. The paradise
playthrough already expected the guard and could not play a battle that
opens in the middle of a step: `walk_to` now does, and on the way to the
ambush the guard catches Talan twice; both battles are won.

What ran, with the branch's tools: ABL's `just tests` all green, no
golden moved besides the new one; `just boot` of the other seven, 9
green; `just test` 27; the crate tests of events, wally, mapdata,
convert and cartridge. Bank 0 has room left in every cartridge (`just
space`).

**When merging, install**: `events wally mapdata convert cartridge` —and
`project`, only because the runtime changed and its path is compiled in—.

**Not covered by any test**: the hero bumping into or pressing A on a
trigger-2 event (the touch path; nothing reaches it with a trigger 2),
and a forced route's refused step against the hero, which goes through
the same branch as the own route's.

**Found and not fixed**, drafts:
[`events-that-walk-by-a-movement-type-stand-still`](events-that-walk-by-a-movement-type-stand-still.md)
(movement types 1 to 5 do not walk: the pacing NPCs of Sector 34 and
Yun Town, the skeletons of 285; a Known issues line in ABL's page) and
[`the-event-s-touch-from-another-layer`](the-event-s-touch-from-another-layer.md).

**For taro to play**: 105, from the world's tunnel. Step on the cell
where Talan says "What's that?!": a guard comes running from the right
and catches him; the battle is troop 184. After it he comes again from
the same place. Running left to the tunnel (event 7, the ambush) is the
way out.
