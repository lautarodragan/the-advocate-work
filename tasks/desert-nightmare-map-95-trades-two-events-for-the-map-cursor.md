---
name: "Desert Nightmare's map 95 trades two events for the map cursor"
description: "With the message box's pictures gone, the converter draws the menu's map cursor on map 95 and leaves out two events a route dresses, 4 and 13"
type: bug
status: todo
author: huron
---

Seen by Hurón on 2026-11-21, doing
[`desert-nightmare-own-message-frame`](desert-nightmare-own-message-frame.md),
with the-advocate at `a537d967` and the ports' branch `huron-dn-frame`
(from `a36d80b`), in `build/release/converter.log` of `desert-nightmare/`.

**What changed**: before, map 95 did not draw the message box's pictures
nor the common events' `Kartencursor` (the menu's map cursor), and drew
events 4 and 13, which draw nothing on any page and a route dresses. With
the box's pictures gone the converter draws `Kartencursor` and says:
"events 4, 13 draw nothing on any page and a route dresses them, and they
aren't drawn: with them the map loses pictures-not-drawn". The two events
are on the map the whole time; the cursor shows only when the player
opens the map screen from the menu on that map.

**Not looked at**: what 4 and 13 are in the scene —map 95 is one of the
dream maps—, nor whether the converter's choice between dressed events
and a common event's picture should weigh which is seen more. Not played.
