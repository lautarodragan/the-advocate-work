---
name: "Lashe City's transitions lag"
description: "Going from one sector of Lashe City to another, or into and out of a house, costs many frames of lag; measure where they go —the audio package, the map's tiles, events, graphics— before choosing what to fix"
type: bug
status: doing
author: taro
assignee: Chajá
agents: [Hornero, Chajá]
game: abl
---

> In ABL, in Lashe City, going from one sector to another, or entering and
> leaving a house, costs many frames of lag. If the sound package is part
> of the cause, it should be able to improve a lot, because they usually
> have the same effects, but the relation between teleports is not a closed
> cycle, so a naive static analysis would not find it.
>
> On the other hand, Lashe City is huge, so the loading time may be in the
> map's tiles themselves, events, graphics...

taro, 2026-11-22, before trying the build with
[`frozen-world-every-turn-re-uploads-the-battle-screens-audio`](frozen-world-every-turn-re-uploads-the-battle-screens-audio.md),
which already moved every game's effects out of the teleport's fade.

## Log

### 2026-11-22, Hornero: taken for Chajá, to measure first
