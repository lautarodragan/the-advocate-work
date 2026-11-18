---
name: "ABL: Dessen walks without turning or stepping"
description: "Arriving at Delcentric Factory (map 17), RunFactoryScene walks Dessen to Talan: he moves, but keeps one pose, no turn and no step animation; talking to him afterwards turns him fine. It used to work"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
game: abl
---

taro, on 2026-11-18, playing the build of the ports `d91f170` and
the-advocate `78d2a560`, translated:

> A small bug, of something that worked fine in the past and broke at some
> point: in ABL, arriving at Delcentric Factory (map 17), Dessen walks
> toward Talan. The event `RunFactoryScene` does a `Move Event: Dessen,
> Move Left, Move Left, Move Left, Move Down...`. The movement works, but
> Dessen walks without turning and without animation. The odd thing is
> that, after the cutscene, when I talk to him, he does turn toward Talan.

A regression: bisect it over the merges of the last days —suspects, in
order: poses only when an event can show them (2026-11-17), still events
spilling out of their cell (2026-11-18, the Hover-Tram's stage 1),
baked events, the cache slots' turn fix (Arden, 2026-11-17)—, fix it, and
add a ROM test of the scene that holds Dessen's facing and step pattern
while he walks.
