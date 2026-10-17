---
name: "A refresh costs frames on maps of many pages"
description: "Choosing the active pages still walks every page of the map at ~1.85 lines each: a switch that flips on The Frozen World's maps 2 and 3 (~420 pages) costs ~3 frames"
type: refactor
status: draft
---

Seen by Aguará on 2026-10-17, measuring
[`frozen-world-the-battle-maps-lag`](frozen-world-the-battle-maps-lag.md),
with the-advocate `a15a9111`, in snes9x with a line profiler.

**What was seen**: since that task a refresh only happens when a switch or
a variable a page looks at really changes, and it only sets up the events
whose page changed; but every refresh still walks every page of the map to
choose the active ones. With a refresh forced on every frame:

    map                         pages   pick_pages   apply_pages   frames/tick
    The Frozen World map 3        413      766           73            4.00
    The Frozen World map 2        425      771          155            4.03
    The Frozen World map 1        165      318          145            3.00
    The Frozen World map 14        50      105           45            1.18

So each switch flip there freezes the picture ~3 frames: placing a plate on
map 2, or the switches a turn of the fight turns on map 1. What a page
costs is its conditions —`conditions_ok`, two `switch_on`, the item and
the variable read from the table each time— and the walk itself; and
nothing tells the refresh which events' pages look at what changed, so it
looks at all of them.

**To reproduce**: `refresh` set to 1 on every tick from the harness, on
those maps.
