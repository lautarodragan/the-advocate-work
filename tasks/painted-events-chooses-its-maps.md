---
name: "painted_events chooses its maps"
description: "`painted_events = true` paints every map where painting adds no degradation, decided by the converter from the degradations it already computes, so no game keeps a hand-written list that ages"
type: feature
status: todo
---

From [`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md):
Desert Nightmare's `advocate.toml` lists by hand the 95 maps
`painted_events` paints. The list came from a measurement —every map with a
piece painted, its degradations compared with the unpainted map's, the
ones that got worse taken out (18, 33 and 71 waited for sprite slots, 42
one-screen interiors lost the message box's two pictures)—, but it was
measured once: a change in the runtime or the game ages it silently, and
another game would have to repeat it by hand.

taro, on 2026-11-19, translated, asked whether the tools decide it:

> Does the tool do it dynamically, without having to judge it for a
> particular game?

and, to making it a task: "leave it as a task but don't launch it yet".

**What**: `painted_events = true` means "every map where painting adds no
degradation": the converter converts the map both ways, compares the
degradations it already reports, and keeps the one that loses less. A
list keeps working as today. The cost is conversion time —those maps
twice— which the cache absorbs.

**Done means**: Desert Nightmare's list replaced by `true` with the same
maps painted (or the difference explained), every other game's ROMs byte
for byte the same, and the converter saying which maps it did not paint
and why.
