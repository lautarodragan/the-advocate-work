---
name: "build_oam costs a third of the frame on busy maps"
description: "With some thirty events on screen —ABL's map 11, the cones of light— building the OAM takes 83-93 of the frame's 262 lines, and whatever else the map does lands on a frame with ~60 lines spare"
type: refactor
status: draft
author: aguara
links:
  relates: [abl-lazer-teeth-s-rock-lags]
---

Seen by Aguará on 2026-11-17, measuring
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md), with
the-advocate `865163eb` plus that task's branch, in snes9x with a line
profiler (a mark at each boundary of the main loop).

**What was seen**: on ABL's map 11, standing in the stones minigame's
corridor with cone C on screen, `build_oam` is 83-93 lines of the 262 on
every frame; the parallels, after that task, 44; the rest of the loop ~50.
What is left is ~60-80 lines, so a battle animation's frame (LZ2 and copy,
~60 every other tick), a refresh (~155) or a flash (~30) loses the frame.
The row walk already discards what is off screen (`build_oam`'s comment);
what each visible row costs was not measured inside.

**To reproduce**: the profiler is not committed; the marks are a `jsl` to
a routine that reads `OPVCT` and adds the lines to a bucket, around each
`jsr` of the main loop. `tests/abl/test_stones.py`'s
`frames_lost_throwing(p, (15, 48), "up")` is the scene.
