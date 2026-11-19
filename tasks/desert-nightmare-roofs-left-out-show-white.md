---
name: "Desert Nightmare: the roofs left out show the panorama's white"
description: "On maps 4, 14, 61 and 66 the trim leaves out drawn events —the buildings' roofs, drawn on the hero's layer over white holes in the panorama— and the console shows the holes"
type: bug
status: draft
agents: [Aguará, Hurón, Cardón]
---

Seen by Aguará on 2026-10-20, at the-advocate `8f290c39` and the ports
`68bf55b` (and the same with `aguara-invisible-walls`): on Desert
Nightmare's map 4, *Werkstatt*, the screen around the street has white
rectangles. The map draws almost nothing with its ChipSet; it is its
panorama `Werkstatt`, which has white holes where the buildings go, and
the buildings are events with CharSets `Werkstatt2..4` on the hero's
layer, one per cell. The map has 191 events and the console's RAM holds
120, so the trim leaves out what loses the least: 13 drawings and 27
drawn walls —ids 128 136 141 144..167, the roof at x 14..21, y 1..5 is
most of them—. Since 2026-10-20 their walls stay, in the passability
(`invisible-walls-lost-when-trimming-events`), but their drawing is lost,
and the hole shows.

The same on maps 14, 61 and 66 (the police station and the night copies),
which lose 25 to 28 drawn walls each, and a few drawings on 2, 59
and 172 (11 to 15 each). Besides, map 4 has 114 events drawn and the table holds 104: ten
more are not drawn even with a row.

**To reproduce**: `just cartridges release` in `desert-nightmare/`, and
`grep "map 4:" build/release/converter.log`; on screen, any jump to map 4
—the capture `map4-after.png` in
`/shared/captures/2026-10-20-invisible-walls/`—.

What would fix it, from `divergences/events-that-do-not-fit-in-the-ram.md`
in the book: bake what is left out into the background, as
`decorative_events` does, which today cannot because the trim runs before
Wally and Wally never sees those events. A roof on the hero's layer whose
pose spills out of its cell is not baked by `decor.rs` either.

## Checked (2026-11-19, Hurón): on 34 maps, and not only the trim

At the-advocate `62b6e5cb` and the ports `1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md):
the white holes are on many more maps than the four the trim cuts, and
the trim is the smallest of three causes. Entered with a door's teleport
and played, maps 3, 4, 5, 12, 14 and 62 show white rectangles where the
buildings go (`/shared/captures/2026-11-19-desert-nightmare/contact-maps.png`,
against EasyRPG), and map 2 has no motel or store at all. What leaves the
pieces undrawn, from `degradations.json`:

* `events-wait-for-a-slot` on **34 maps** —80 events on screen and 15
  slots on map 2, 90 and 23 on map 5, 74 and 11 on 172—: the ones drawn
  last never get a slot (still missing after 240 ticks);
* `events-not-drawn` on 9 —the table's 104—;
* `event-left-out` on 7 —the RAM's 120—.

Map 3 (116 events, 81 drawn) has white holes with none of the last two.
`[graphics] baked_events = true`, tried on a scratch build, draws 32
events into the background on maps 48, 104, 105 and 182 and none on the
towns. The book's research names what would take them.

## The trim runs before any bake (2026-11-19, Cardón)

At the same commits, for
[`desert-nightmare-can-the-towns-be-baked`](desert-nightmare-can-the-towns-be-baked.md):
the RAM's trim (`trim.rs` in the converter) takes events out of the map
before Wally reads it, so no bake can see them. On maps 2, 4, 14, 59, 61,
66 and 172 it leaves out 183 drawn events (map 4: 40, 61: 41, 14: 34,
66: 31); 150 of them always show one look and nobody moves them. The
study's prototype read them from the whole map and painted them into the
panorama with the rest: map 4's roofs and walls come back
(`/shared/captures/2026-11-19-dn-towns/`).
