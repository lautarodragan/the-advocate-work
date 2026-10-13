---
name: "The invisible walls lost when trimming events"
description: "When a map goes past 120 events, the trim also leaves out invisible walls: on eight maps of Desert Nightmare the hero can pass where the original stops them"
type: bug
status: draft
---

Measured by Carpintero on 2026-10-10 (`events-that-dont-fit-in-the-map-ram.md`):
when a map goes past the 120 events of RAM, `Game::trim`
(`rm2k-snes/convert/src/trim.rs`) leaves out what loses the least, and the
third class is "an invisible wall". Desert: "9 lose decoration and 8
of those invisible walls". He himself left noted what remains: "the
invisible walls could go into the map's passability, and the decoration
be baked (`decorative_events`) instead of lost: the trim runs before
Wally, so today what goes away isn't baked".

**Checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): the
`converter.log` of Desert Nightmare's release gives the same lists as on
2026-10-10. These lose invisible walls (wall only, or drawing and wall):

| map | events with a wall that go away |
|---|---|
| 2 Dusty Creek | 5 |
| 4 Werkstatt | 23 + 27 |
| 5 Wohngegend | 11 |
| 14 Polizeirevier | 20 + 27 |
| 61 Werkstatt-Nacht | 23 + 28 |
| 62 Wohngegend-Nacht | 13 |
| 66 Polizeirevier-Nacht | 20 + 26 |
| 172 Alte Minensiedlung | 12 |

In Vampires Dawn, map 164 (Thessa) loses two with drawing and wall,
events 253 and 254 (also checked today, in a VD build with its
own System: the trim doesn't depend on that).

**What you see while playing**: on those maps the hero walks through cells that
are blocked in the original. Which ones they are, and whether they let you reach
somewhere you shouldn't, wasn't looked at in an emulator.

**How to see it**: `just cartridges release` in `desert-nightmare/` and
`grep "lose an invisible wall\|looks and a wall" build/release/converter.log`;
the event numbers are on each line.
