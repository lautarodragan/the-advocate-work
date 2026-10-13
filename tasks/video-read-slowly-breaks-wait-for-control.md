---
name: "A slow-read video breaks wait_for_control"
description: "video.read_slowly swaps Playthrough.wait for a wrapper without its press-if parameter, which wait_for_control passes, so a recording with slow reading fails with a TypeError at the first wait for control"
type: bug
status: draft
---

Seen by Calandria on 2026-10-12, reading the code, with the ports at
`4b15e20`, in ABL's harness; not run.

**What is seen**: `read_slowly` in `abl/tests/harness/video.py` replaces
`Playthrough.wait` with a wrapper that takes `(que, cond, tope, a_cada,
mirando)`. `Playthrough.wait_for_control`, in `playthrough.py`, calls
`wait` with one more keyword, `tocar_si=` (`press_if=` after the step 2
translation). With slow reading on, the first `wait_for_control` of a play
should raise `TypeError: unexpected keyword argument`.

**How to reproduce it**: record a play with slow reading —the `video`
recipe of `abl/` with a read value— whose script reaches a
`wait_for_control`. No test runs `read_slowly`: `test_video.py` covers the
factory, not this path.
