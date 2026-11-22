---
name: "ABL: the factory pump's light is grey"
description: "On map 83 the pump's red light is drawn grey: Forem, whom a scene places there, takes the map's last palette, and the pump's tile falls to the nearest colour left, which has no red"
type: bug
game: abl
status: draft
author: hornero
---

Left in the book's Known issues by
[`characters-a-route-dresses-left-out-where-they-cost-the-map`](characters-a-route-dresses-left-out-where-they-cost-the-map.md),
which brought Forem into map 83's scene and paid for it with the pump's
red; taro closed that task on 2026-11-17, and the light stays to be looked
at here. Not re-measured since: the palette grouping and the still events
drawn into the background have changed since that task, so the first step
is to see whether it is still grey.

## Log

### 2026-11-22, Tijereta: Forem is out again

Seen in passing, in ABL's release build of the ports `89f77b4`
(the-advocate `0ae40e0a`): map 83's `converter.log` no longer has a
"drawn with someone else's" line —no tile of it is lent a palette now—,
and it says instead that Forem (event 13) is left out because with him
the rain's colours would be lent. So the trade this draft is about seems
gone the other way: the light should have its red, and Forem is missing.
Not looked at on screen. The missing Forem is its own draft,
[`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md).
