---
name: "Characters a route dresses, left out where they cost the map"
description: "Two maps leave out the rows of the events a route dresses because with them the map loses something of its own: Book of Three's lava tunnels (Gurgi and Eilonwy) and ABL's factory (a tile's palette); Frozen World's Cliff Swamp 3 was the third until 2026-10-19"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-10-19, measured with the converter of the-advocate
`a2168be6` (branch `calandria-route-graphics`) and the ports `bbfa831`,
when fixing
[`characters-a-route-gives-a-graphic-are-not-drawn`](characters-a-route-gives-a-graphic-are-not-drawn.md).

Since that fix an event whose pages draw nothing and that a route dresses
(command 34) gets a row and appears. Wally converts each such map twice,
with and without those rows, and keeps them unless they cost the map
something it did not lose without them (`loses_more` in `map.rs`). Three
maps pay, and leave them out; each says it in `converter.log`, "aren't
drawn: with them the map loses":

* **The Book of Three, map 46** ("Lava Tunnels"): Eilonwy (event 12) and
  Gurgi (13), in the rescue scene. With them the tile events
  `@tile:cave4:39` and `:41` are drawn with someone else's palette: the
  map's eight palettes are full.
* ~~**The Frozen World, map 88** ("Cliff Swamp 3"): the Dark Wizard (8) and
  Borto (9). With their two walker slots the common events' menu pictures
  —`MenuEquipPlates`, `MenuItemManage`, `MenuPartyStats`— no longer fit
  the sprite tiles.~~ Gone on 2026-10-19 (Mulita): the menu became a
  `ShowChoice` and has no pictures, so both are drawn —"a hidden row each"
  in `converter.log`—. See
  [`frozen-world-the-b-menu-is-blind-on-the-maps-without-room`](frozen-world-the-b-menu-is-blind-on-the-maps-without-room.md).
* **A Blurred Line, map 83** ("Dalia at the Factory"): Forem (13), dressed
  as `Future1` 5. With it the pump's tile `ChipSet1:138` loses its palette
  (nine pixels of `test_delcentric_pump_golden`'s map 83 captures).

How to see it: `just cartridges` in each game, and grep `converter.log` for
"aren't drawn: with them". Playing, the scenes on those maps go on with
those characters missing, as before the fix.

## Checked (2026-10-20, Tijereta)

In the release builds of the ports `68bf55b` (the-advocate `8f290c39`),
`grep "aren't drawn: with them"` gives The Book of Three's 46 and ABL's 83
as above, and a new one: **A Blurred Line, map 246**, events 5 and 6,
"with them the map loses rain-colors-lent". Still undefined: each map pays
something different.
