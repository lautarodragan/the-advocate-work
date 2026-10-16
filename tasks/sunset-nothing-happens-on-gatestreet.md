---
name: "Sunset over Imdahl: nothing happens on GateStreet"
description: "Arriving at GateStreet (map 10, under Main(Winter)) the hero can walk but the scene never starts: EV0002's autostart compiles, so either it never becomes the active page or it stops early"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, 2026-10-16, playing the delivery of that evening (the ports
`4b2d41e`, the-advocate `759aa0ba`), and the same "a few days ago": the
hero reaches GateStreet, can walk, and nothing happens. taro suspected
EV0002 is dropped.

**What Hornero checked, statically**: `just culprits release` in
`sunset-over-imdahl/` leaves out no page of EV0002; the only page of map
10 left out is event 4's (`HEJ JAG ÄR KEX`, touch trigger, two
`PanScreen`). EV0002 has two pages: page 1 is the autostart scene (moves
the boy, shows four pictures, messages "Hello?"…, sets switch 98 ON and
switch 1 OFF at the end), with no condition; page 2 is an action-button
page conditioned on switch 1. So if switch 1 is ON on arrival, page 2 is
the active one and the autostart never runs — in RM2k too, so what sets
switch 1 before this map matters. Or the autostart runs and stops on
something (a `MoveEvent` on the hero with wait, a `CallEvent` of common
event 1 or 2). Not run in an emulator.

The game blocks there.
