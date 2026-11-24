---
name: "Zounds: a sign drawn with a tile lets the hero walk on it"
description: "Map 86's sign, an event drawn with a ChipSet tile on the hero's layer, is walked over on the console and does not fire with A from the cell below; in RM2k it blocks and is read by facing it"
type: bug
status: todo
author: aguara
agents: [cardon]
links:
  found-in: [a-transparent-message-blacks-out-tiles-on-its-lines]
---

Seen by Aguará on 2026-11-02, measuring
[`a-transparent-message-blacks-out-tiles-on-its-lines`](a-transparent-message-blacks-out-tiles-on-its-lines.md),
with the-advocate `0ba09da4` and the-advocate-ports `31fb291`, Zounds'
`release` in snes9x. Not looked into further: it was not that task's.

**What was seen**: map 86, event 17 "Cartel" at (17, 9): one page,
action key, layer 1 —same as the hero—, no CharSet and
`character_index` 13, so it is drawn with a tile of the ChipSet (the
plank next to the button). On the console the hero walks up from (17,
10) through (17, 9) and on, and A from (17, 10) facing up opens nothing.
taro's capture of the sign's message has the hero standing where the
plank is: they read it from on top. In easyrpg an event on the hero's
layer blocks him whatever its graphic —`WouldCollide` in
`game_map.cpp`, same layer and not through—, and the action key fires
it from the cell in front. Map 96's sign, event 14 at (14, 13), is
likely the same.

**To reproduce**: `go_to_map(86, 17, 11)` in the ports' harness —it
lands on row 10—, then tap up: `hero()` goes from y 160 through 144.

## Log

### 2026-11-24, Cardón: to todo

A bug against RM2k with its reproduction (`go_to_map(86, 17, 11)`, tap up)
and easyrpg's rule (`WouldCollide`: same layer, not through, blocks
whatever its graphic). Zounds' converter log at the ports' build of
2026-11-24 draws map 96's sign (event 14) into the background, so likely
the still event loses its object and with it its cell; the task's first
step is to reproduce at main and see which.
