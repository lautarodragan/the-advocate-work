---
name: "Vampires Dawn's world grid does not fit in WRAM"
description: "Map 1 of Vampires Dawn, the world (300x300), has a map_cells stream of 147,232 bytes against 64 KB of WRAM, so it is left out; the code half of the problem was solved by putting map code in ROM, the grid was not"
type: feature
status: draft
author: hornero
links:
  relates: [map-streams-that-dont-fit-in-wram]
---

Left open when taro closed
[`map-streams-that-dont-fit-in-wram`](map-streams-that-dont-fit-in-wram.md)
on 2026-11-16, which moved a map's code to ROM when it does not fit. Its
"Not done: the grid": the grid is read through `ptr_more`/`ptr_minus`
across two WRAM halves, so the same trick does not apply as is.
