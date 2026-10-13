---
name: "Delcentric Factory: the right pump misses a tile"
description: "Of the two decorative pumps on the left of map 17, the right one misses a tile in one of its two frames; the left one is right"
type: bug
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-12 (seen for a long time, with Talan and with Dalia): in
Delcentric Factory there are machines that go up and down, decoration. Of
the two on the left of the map, the left one works perfectly, but the right
one misses a tile in one of its two animation frames.

What the map does (map 17, read from `data/maps/Map0017.json` by Hornero):

* The left pump is four tile events, `Mech4`..`Mech1` (ids 1–4) at x 27,
  y 64–67; the right one three, `Mech3b`, `Mech2b`, `Mech1b` (ids 8, 6, 5)
  at x 31, y 65–67.
* `AnimatePump` (id 7, parallel) loops: `TradeEventLocations` 4↔5, 6↔3,
  2↔8, then `SetEventLocation` of event 1 (`Mech4`) to (31, 64), wait 0.3
  s; and the same swaps, and `Mech4` back to (27, 64).
* So the pump that is up takes `Mech4` as its fourth tile: the missing tile
  is most likely `Mech4` not shown at (31, 64) —`SetEventLocation` of a
  tile event, and how wally decides what is baked (`rm2k-snes/wally/src/
  map.rs`, `baking.rs`)—. To be measured, not assumed.

## Log
