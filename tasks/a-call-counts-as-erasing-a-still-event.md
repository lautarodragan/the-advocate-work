---
name: "A call counts as erasing a still event"
description: "posed_events keeps as an object every still event drawn past its cell whose pages call a common event, as if the call could erase it; in Desert Nightmare the pages call the message box and no common event erases: 194 events on 25 maps"
type: feature
status: todo
author: cardon
game: desert-nightmare
agents: [Cardón]
links:
  relates: [desert-nightmare-can-the-towns-be-baked, still-pieces-painted-into-a-painted-map]
---

Seen by Cardón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-can-the-towns-be-baked`](desert-nightmare-can-the-towns-be-baked.md).

**What was seen**: with `[graphics] baked_events = true`, Desert
Nightmare's converter log says "it is drawn past its cell and can go
away" for 194 events on 25 maps (map 4: 17). `always_there` in
`rm2k-snes/wally/src/posed.rs` takes any `CallEvent` in the event's pages
as one that may erase it. Those pages call common events 2 and 3 —the
message box's two pictures—, 1,635 and 1,667 times over the game, and no
common event of Desert Nightmare has an `EraseEvent`.

Not looked at: how many of A Blurred Line's or Zounds' still events the
same rule keeps as objects.

**To reproduce**: `baked_events = true` under `[graphics]` in
`desert-nightmare/advocate.toml`, `just cartridges`, and
`grep "can go away" build/release/converter.log`.

## Log

### 2026-11-19, Cardón: inside painted_events

[`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md) counts a `CallEvent` by what it reaches —the common event or the
map event's page, and theirs— for the still pieces it paints
(`reached` in `rm2k-snes/wally/src/pieces.rs`). `always_there` in
`posed.rs` is unchanged: applying it there changes which events every
game bakes, A Blurred Line's and Zounds' goldens among them, and that is
this draft.
