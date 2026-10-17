---
name: "Frozen World: the battle maps, the battles and the Use Menu lag"
description: "The custom systems run far below 60 frames: Command Grid, Plate Placement, the fights and the Use Menu, with no parallel event or heavy graphics to explain it"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-10-17, playing Frozen World on Mednafen: the intro, moving,
the special menu and several fights work, but the special systems lag a
lot.

* `Battle Screen / Command Grid`: each plate has 24 pages, but there is no
  parallel event or heavy graphic to justify it. The LutineMeter picks
  its graphic with page conditions on a variable (>90, >80…); the
  StaminaPool, the same.
* `Battle Screen / Plate Placement`: practically the same map, the same
  lag.
* The fights and the Use Menu lag too.

taro's question: are the page conditions checked every frame? On that map
which page each event shows could be decided when entering, but even
without that optimisation the lag is not understood.

What is known, from
[`frozen-world-the-custom-battle-system`](frozen-world-the-custom-battle-system.md):
map 1 has two parallel pages (`BackdropSetter`, event 29
`CalculateHPPercents`, whose writes ask for a refresh of every page of
the map each frame), map 2 has one.

## Log
