---
name: "Characters a route gives a graphic to are not drawn"
description: "An event whose pages all lack a graphic and that a forced route gives one (move command 34) never appears: scenes lose characters that walk in, talk and leave"
type: bug
status: testing
assignee: taro
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

## Done (2026-10-19, Calandria)

Branches `calandria-route-graphics` in the-advocate (from `9592b88b`), the
ports (from `c420032`) and the book. **To install when merging**: `events`,
`wally` and `convert`, and the runtime changed (`runtime/event_pages.s`,
`runtime/npcs.s`), so every cartridge is rebuilt. No opcode taken (0x52 is
still free); `SAVE_BYTES` does not change.

* **The scan says who a route dresses.** The events compiler's page records
  carry `route_graphics`, `[event index, graphic index]`, walked from the
  compiled `OP_ROUTE`s like `route_targets` (`pages.rs`, with its test).
* **Wally gives them a row** (`dressed_by_routes` in `events.rs`): an event
  whose pages all draw nothing and that some compiled route dresses with a
  graphic that has pixels gets a hidden row with the first such graphic,
  whose graphic follows its pages —a new page draws nothing and hides it
  again, as `SetupFromPage` does—. A route that only dresses an event with
  a blank slot is hiding it, and gets no row. The converter says which
  ("a route dresses them: a hidden row each").
* **Their palettes go after the map's own.** A row only a route dresses
  (`Npc::dressed`) is left out of the pages' pass of the palette split, and
  a leader candidate that only such a row shows is split like the leaders
  that get no palette of their own: both go with the routes' graphics.
  Without this, the party walking in Book of Three's race (map 64) took the
  yellow soldiers' palette, and the race milestone's golden went red.
* **And they are left out where they cost the map.** `convert` converts a
  map with dressed rows twice, and keeps them unless that loses the map
  something it did not lose without them (`loses_more`): another kind of
  loss, another event, or a graphic of its own lent a palette. What the
  dressed characters pay themselves —their graphic lent, a wait for a slot
  of the cache— stays. Three maps leave theirs out, and say so ("aren't
  drawn: with them the map loses"): Book of Three's 46, Frozen World's 88
  (its menu pictures) and ABL's 83 (a tile's palette). Draft:
  [`characters-a-route-dresses-left-out-where-they-cost-the-map`](characters-a-route-dresses-left-out-where-they-cost-the-map.md),
  with a Known issues line in each game's page.
* **The runtime: coming back from a battle no longer undresses them.**
  `npc_poses_forget` made the next refresh set every row up from its page,
  and a page that draws nothing hid the row: Gwydion and Gurgi vanished
  after Gurgi's fight. Now it asks for every page again with
  `applied_again` set, and `page_graphic` leaves a row whose page draws
  nothing alone then. The same for a row its page draws, whose route
  graphic is still undone: draft
  [`a-route-graphic-on-a-paged-row-is-undone-after-a-battle`](a-route-graphic-on-a-paged-row-is-undone-after-a-battle.md).

**Measured**, with today's dumps: The Book of Three, 29 events on 13 maps
get a row (map 46 leaves its 2 out); ABL 33 on 18 (map 83 leaves 1 out);
Frozen World 39 on 23 (map 88 leaves 2 out); Sunset over Imdahl 7 on 7;
Desert Nightmare 2 on 2; Zounds 1; Vampires Dawn, Dooms 2 and El Dorado
none. The counts in the description above were routes, an upper bound.

**Tested**: `test_book_of_three_milestones.py` photographs four scenes in
the middle (`SCENE_PHOTOS`): Gwydion and Gurgi beside Taran after the
fight (21), Gwydion at the river (22), Eilonwy in the cell (32) and the
party before Eiddileg (83). Red with the tools of `9592b88b` (in snes9x,
where the test stops), green with the branch's in snes9x and bsnes. No existing golden moved. Ran, with the
branch's tools: `just test` and `just lint` in the-advocate; ABL's `just
cartridges` and `just tests` (1580 passed; the only red, map 83's pump,
went when map 83 left Forem out); `just boot` in the ports (73 passed).
Captures before and after, in
`/shared/captures/2026-10-19-book-of-three-route-graphics/`.

**Not covered by any test**: that a dressed row hides again when its
event's page changes; that the fallback keeps Frozen World's 88 menu
pictures (it is the converter's log that says so, no test opens the menu
there); the other games' scenes, which only build. The four scene
goldens were looked at against the scenes' lines, not compared with the
original under Wine.

[`order-34-in-a-page-own-route`](order-34-in-a-page-own-route.md) does not
fall out of this: an own route has no room for the graphic's operand. Said
there.
