---
name: "A page change restarts a route with the same commands"
description: "When an event changes page and both pages' own routes have the same length and command codes, RM2k keeps the route's place; the ROM starts it over from the first command"
type: bug
status: draft
author: calandria
agents: [Calandria]
links:
  found-in: [abl-the-chase-follows-the-row-talan-is-on]
---

Seen by Calandria on 2026-11-15, reading the code while measuring the
patched chase of ABL's map 105
([`abl-the-chase-follows-the-row-talan-is-on`](abl-the-chase-follows-the-row-talan-is-on.md)),
at the-advocate c9860b49 and the-advocate-ports 098d3e3.

* **RM2k**, as EasyRPG has it in `Game_Event::RefreshPage`
  (`src/game_event.cpp`): on a page change the own route's index goes back
  to 0, **unless** the old page's route and the new one have the same
  number of commands and the same command codes —the parameters are not
  compared—; then the event goes on from where it was. Not measured in
  RPG_RT: EasyRPG's comment says RPG_RT does it.
* **The ROM**: `apply_pages`, in `runtime/event_pages.s`, loads the new
  page's route from the start whenever the page changes
  (`load_page_into_slot`), whatever the routes are.

On 105 the two pages' routes differ (`T D T U T` against `T U T D T`), so
both restart, and the ROM matches RPG_RT frame for frame there.

Where it would show in ABL: one event of the dump has two pages with own
routes of the same codes, map 37's event 18 at (52,31), pages 1 and 2
(switch 161, and 161 with 225), a ten-step walk left and back right. When
225 turns on with the event mid-route, RM2k would go on and the ROM starts
the walk over. Not looked at in the game.

To find others: the pages of one event with `move_type` custom and the
same list of `command_id`s in `move_route`.
