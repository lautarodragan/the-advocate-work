---
name: "Changing the map's tiles lags"
description: "The commands that change the map's tiles —TileSubstitution and the like— take visibly longer to show than RPG_RT"
type: bug
status: draft
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
