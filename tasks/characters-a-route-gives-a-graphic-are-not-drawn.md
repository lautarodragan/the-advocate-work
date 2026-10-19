---
name: "Characters a route gives a graphic to are not drawn"
description: "An event whose pages all lack a graphic and that a forced route gives one (move command 34) never appears: scenes lose characters that walk in, talk and leave"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

Seen by Mulita on 2026-10-15, comparing The Book of Three with the original
under Wine, with the-advocate `fa9d1a14` and the ports `0ca371b`.

**What is seen**: in a cutscene, a character that the original places with
`ChangeEventLocation` and dresses with a `MoveEvent` whose route changes its
graphic (move command 34) is not there in the port. The scene's messages and
moves go on, with nobody. Seen in The Book of Three on map 21 (two
characters during Gurgi's scene), map 22 (the companion at the river), map
26 (the companion before the ambush) and map 32 (the visitor in the cell,
who talks for a whole scene).

**Where it stops**: Wally's `collect_npcs` leaves out an event whose pages
all lack a graphic, so it has no row in the NPC table, and the runtime's
`change_graphic` (in `runtime/event_routes.s`) drops the change for an event
without a row —its comment says so—. Neither the converter nor
`degradations.json` mentions it.

**How many**, counted in the dumps (routes with command 34 aimed at an event
whose pages are all blank; an upper bound, since some of them dress the
event with an empty CharSet slot to hide it): The Book of Three 43 on 14
maps (2, 20, 21, 22, 26, 32, 46, 63, 64, 71, 72, 76, 81, 83), ABL 64,
Frozen World 78, Desert Nightmare 63, Sunset Over Imdahl 23, Vampires Dawn
2, Dooms 2 and El Dorado none.

**How to see it**: the ports' `tests/test_book_of_three_milestones.py`, case
`milestone-gurgi`: the scene after the step up has two characters next to
the hero in the original and none in the port.

## Defined (2026-10-16, Carpintero)

Scenes lose their characters in five games, ABL among them. **Done**: an
event whose pages carry no graphic but that a forced route (command 34)
dresses gets an NPC row and a slot for that graphic, and appears;
`milestone-gurgi` sees the two characters next to the hero. **First
step**: in Wally's `collect_npcs`, collect the graphics routes give to
such events (the converter already knows them, `route_graphics`), and
what that costs in rows on the busiest maps. The command-34 graphics go
through the same per-map table as
[`frozen-world-map-2-route-graphic-changes-past-the-table`](frozen-world-map-2-route-graphic-changes-past-the-table.md).

## Work (2026-10-19, Calandria)

Branches `calandria-route-graphics` in the-advocate (from `9592b88b`), the
ports (from `c420032`) and the book.

* The events compiler's scan says, for each page, which graphics its
  compiled routes give which events: `route_graphics`, `[event index,
  graphic index]`, walked from the bytecode like `route_targets`.
* Wally gives an event whose pages all draw nothing and that some route
  dresses with a graphic that has pixels a hidden row of its own
  (`dressed_by_routes`), whose graphic follows its pages: a page that
  becomes active hides it again, as `SetupFromPage` does. The runtime
  needed nothing: `change_graphic` already dresses a row.
* The Book of Three: 37 events on the 14 maps get a row, and the converter
  says which (`a route dresses them: a hidden row each`). Captures of the
  scenes before and after: the characters show.
