---
name: "Event page records compressed behind the grid"
description: "Store each map's event page records (`pages_*`) in LZ2 and unpack them with the grid's stream, as the bytecode already is: ~125 KB freed in ABL's release; then turn `posed_events` on for the whole of ABL with that room"
type: feature
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-11-16, after [`abl-room-for-still-events-in-the-background`](abl-room-for-still-events-in-the-background.md) (Mulita's study):

> SIII :D

to "compress the page records (~125 KB), then `posed_events` on in the
whole of ABL". The study measured the records raw at 193,376 B and 68,513
B in LZ2 piece by piece; they carry no linker symbol (their code pointer
is already `GRID_HIGH + offset`); the largest is 12,192 B and fits behind
the grid in `$7F`. Not measured: that every map fits, the cycles on the
console, that they survive a battle as the bytecode does.

Done means: the records in LZ2 behind the grid for every game, `page_ptr`
reading WRAM; measured per map (fits, load time) with the gain; ROM tests
(a map's pages after a load and after a battle); all suites green; then
`posed_events = true` in ABL's `advocate.toml`, every golden that moves
looked at, and its Known issues line for map 8's signs gone if fixed.

## Log
