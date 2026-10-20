---
name: "Characters a route dresses, left out where they cost the map"
description: "Two maps leave out the rows of the events a route dresses because with them the map loses something of its own: Book of Three's lava tunnels (Gurgi and Eilonwy) and ABL's factory (a tile's palette); Frozen World's Cliff Swamp 3 was the third until 2026-10-19"
type: bug
status: testing
assignee: taro
agents: [Calandria, Chajá]
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

## Defined (2026-10-20, Chajá)

Measured on the-advocate `3bc68ac4` and the ports `b5cfc1e`, with a wally
that keeps the dressed rows whatever they cost, side by side with the one
of `main`, in snes9x:

* **The Book of Three, map 46.** With Eilonwy and Gurgi, what the map
  pays is the rope bridge's two tile events, `@tile:cave4:39` and `:41`
  —events 29 to 32, which switch 251 lays across the lava at cells (9,
  57..60)—: lent a palette, **344 pixels change, and what changes is one
  light blue for another** in the bridge's zigzag; side by side it is hard
  to tell which is which. Gurgi himself goes lent too, which is his own
  cost and the rule already accepted: brown on brown, he reads as Gurgi.
  Against that, without them the rescue scene runs with two of its four
  characters missing. **Keep them.**
* **A Blurred Line, map 83**: what Forem costs is a tile too, the pump's
  `@tile:ChipSet1:138` —nine pixels of `test_delcentric_pump_golden`'s map
  83 captures, per Calandria—. The same rule covers it.
* **A Blurred Line, map 246**: what events 5 and 6 cost is the rain's
  colours (`rain-colors-lent`), not a tile. Not covered by this; it stays
  written below.

**Done**: a dressed row whose only cost is a tile event drawn with someone
else's palette is kept: Book of Three's 46 and ABL's 83 draw their
dressed characters, and their `converter.log` says "a hidden row each"
and names the lent tiles in its "drawn with someone else's" line.

**First step**: `loses_more` in wally's `map.rs` does not count a lent
tile. The split already serves the tiles last —"a tile goes in only while
it fits"—, so a lent tile is the order the map chose, not a loss the
dressed rows cause.

## Done (2026-10-20, Chajá)

the-advocate `e5130fd7`, branch `chaja-lava-tunnels`: `lent_more`, split
out of `loses_more` in wally's `map.rs`, does not count a tile event lent
a palette, with three unit tests (shown red first). The Book of Three's
map 46 and A Blurred Line's map 83 now say "a hidden row each" in
`converter.log`, and name the lent tiles in their "drawn with someone
else's" line.

What it costs, looked at:

* **Map 46**: the rope bridge's blue, one shade for another (344 pixels);
  Gurgi lent too, brown on brown.
* **Map 83**: the pump's tile loses its red light —nine pixels, grey in
  the palette it borrows—. ABL's two goldens of `test_delcentric_pump[83]`
  changed for that alone, in their own commit of the ports
  (`ebdfc2e`), and it is a line in ABL's "Known issues".

Map 246 is not covered —it pays with the rain's colours, not a tile— and
went to its own draft,
[`abl-paradise-and-emily-left-out-at-the-northern-surl-camp`](abl-paradise-and-emily-left-out-at-the-northern-surl-camp.md).

What was run: the rescue scene of `milestone-rescue` with and without the
change, in snes9x —Eilonwy and Gurgi on screen from tick 80 on—, the
bridge with switch 251 set by hand, and ABL's suite. **Forem on map 83 was
not looked at on screen**: no test plays that scene, only the pump's
photos, where he is not.

**To play**: The Book of Three, the rescue in the lava tunnels: Eilonwy
and Gurgi run in beside Fflewddur. A Blurred Line, the factory with Dalia:
Forem is there.

**What to install when merging**: `just install wally`.
