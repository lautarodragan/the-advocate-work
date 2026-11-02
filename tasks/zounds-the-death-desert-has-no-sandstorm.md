---
name: "Zounds: the Death Desert has no sandstorm"
description: "From map 34 into the Death Desert (50, 14, 111, 112, 113) RM2k blows a sandstorm over the screen; the port shows clear sand"
type: bug
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Seen by Mulita on 2026-11-02, with the ports at `1e6663b` and the tools
from the-advocate `3656d606`, taking the debug room's maze door (map 113,
`tasks/zounds-a-debug-door-to-the-desert-jail.md`): the sand is clear.

34's jumps into the Death Desert (events 55, 83 and 84) run
`WeatherEffects` with type 4, the sandstorm, at strength 2, and its way
out and the desert's cave mouth (113, event 1) turn it off. The compiler
accepts the command and the ROM draws only the rain, type 1 —see
`WEATHER_EFFECTS` in `rm2k-snes/events/src/compile.rs` in the-advocate,
and `tasks/weather.md`—, so the sandstorm is left out without a word.

To reproduce: "New Game", the sixth door of the room, "Go"; or play from
map 34 north into map 50.

## Asked

taro, on 2026-11-02, in their words, translated:

> Meanwhile: could you implement the sandstorm? I don't know how feasible
> it is... if it can't be done, it can't be done.

Taken by Tijereta, launched by Hornero the same day.
