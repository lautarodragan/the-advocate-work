---
name: "ABL: Core's blood turns brown"
description: "On map 3, Emitter Room, the Future1 tile Lysander used as Core's blood on the floor (46,19) comes out brown on the console, from how the colours are grouped into palettes; give the map a tile of its own in Core's blood colours"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-11-16, with captures from Mesen:

> Core's blood on the floor changes colour, because of the palette
> distribution, and turns brown. It looks very ugly, and doesn't look like
> blood... The original tile isn't really blood-coloured either. It seems
> Lysander used a tile that was available in the tileset to simulate
> blood. The tile is from `Future1`. Position (46,19) on map 3, Emitter
> Room.

> Probably the best is a fix specific to this map. Since we can, and the
> original isn't particularly pretty, we could create a tile that is a
> copy-paste of the existing tile but with the colours of Core's blood.

In parallel, [`abl-is-there-a-better-palette-grouping`](abl-is-there-a-better-palette-grouping.md)
asks whether Adeleine could group the colours better in general; this one
is the targeted fix regardless.

Done means: map 3 draws that cell (and any other cell of the same pool, if
the map has more) with a tile in the red of Core's blood —taken from
Core's own sprite/CharSet colours as the console shows them—, through the
manual patches (a ChipSet added with its recipe, the map forked), with
nothing else on the map getting worse (the map's other colours, its
degradations), captures before/after for taro.

## Log
