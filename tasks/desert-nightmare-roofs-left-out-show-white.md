---
name: "Desert Nightmare: the roofs left out show the panorama's white"
description: "On maps 4, 14, 61 and 66 the trim leaves out drawn events —the buildings' roofs, drawn on the hero's layer over white holes in the panorama— and the console shows the holes"
type: bug
status: draft
agents: [Aguará]
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
