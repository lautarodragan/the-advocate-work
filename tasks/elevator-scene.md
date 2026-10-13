---
name: "The elevator scene"
description: "A case of its own in the suite for the elevator scene on map 2"
type: test
status: done
---

# What

Give the elevator scene on map 2 **a case of its own** in the suite.

# Status

Noted and **free**: what blocked it got unblocked by itself on 2026-09-16.

It is worth trying **before anything else in this folder**, precisely because
it costs nothing: it is writing the case and seeing whether the golden comes
out.

# Why

The Python reference didn't model the frames the loop loses at its peaks, so
the ROM ran N frames behind and could only be compared with the screen still.
That was the only thing this scene lacked to have a case of its own.

**Against a golden there is no N**: the capture has the lost frames inside it.

What remains true of the limit that kept it out: the peaks exist, and the way
out is not a hand-tuned offset —a number adjusted until it goes green— but
easing them, or reading `lost_frames`, which already travels in the output
of each capture.

## Closed

Closed by taro on 2026-10-12, as already done: the elevator scene on
map 2 has its own case, `elevator`, in `abl/tests/abl/test_scenes_golden.py`
of the ports, since 2026-09-16 (f572532d in the-advocate, when the scenes
moved to pytest).
