---
name: "Book of Three: the hero freezes in Caer Dallben East"
description: "On map 4 the hero walks with no walking animation and always facing the way it came in; it is right on map 3, inside the houses, and again after leaving map 4"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-10-13: in Caer Dallben East (map 4) the hero keeps a fixed
direction and no animation. Moving works, but there is no walking
animation and it always faces the same way: down if it came in facing
down, right if it came in from the left. It is fine on the map before and
inside the houses, it fixes itself every time the hero leaves map 4 and
breaks again on coming back. It happens without talking to anyone since
the start. taro went through the map's events, the teleports to it and
every common event, and nothing in them explains it.

What Hornero saw in `build/release/converter.log` of Book of Three: map 4
is the only one at the sprite budget —"7 characters, 9 slots, 256 tiles in
VRAM, 5 palettes; **6** with their twelve poses in the cartridge"—, so one
character has no twelve poses in the cartridge. If that one is the hero,
it is drawn with the one pose loaded when the map loads, which is what is
seen. To be measured, not assumed.

## Log
