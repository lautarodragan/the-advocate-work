---
name: "Changing the map's tiles lags"
description: "The commands that change the map's tiles —TileSubstitution and the like— take visibly longer to show than RPG_RT"
type: bug
status: cancelled
agents: [cardon]
author: taro
links:
  found-in: [still-events-that-change-pose-painted-into-the-background]
  relates: [zounds-tile-substitutions-that-do-not-compile]
  duplicates: [a-tile-substitution-sweeps-across-the-screen]
---

taro, on 2026-11-02, in their words, translated, while Cardón was
putting still events into BG2
([`still-events-that-change-pose-painted-into-the-background`](still-events-that-change-pose-painted-into-the-background.md)):

> Today the commands that change the map's tiles lag a bit. We'll have
> to look at that eventually, but for now I care about not making the
> experience of chests, doors, etc. worse.

Not measured yet. Zounds' map 59 spikes switch (three `TileSubstitution`s,
[`zounds-tile-substitutions-that-do-not-compile`](zounds-tile-substitutions-that-do-not-compile.md))
is a place to measure it: frames from the command to the new tiles on
screen, here and in RPG_RT.

## Log

### 2026-11-24, Cardón: duplicates a-tile-substitution-sweeps-across-the-screen

taro's lag with tile changes is what
[`a-tile-substitution-sweeps-across-the-screen`](a-tile-substitution-sweeps-across-the-screen.md)
took on 2026-11-20, on Zounds' same spikes, and fixed in the-advocate
`7132792b` ("A TileSubstitution changes the whole screen on one frame",
merged in `1a9331e4`): one frame instead of a 64-frame sweep. That task is
`done`; a lag left after it would be a new report.
