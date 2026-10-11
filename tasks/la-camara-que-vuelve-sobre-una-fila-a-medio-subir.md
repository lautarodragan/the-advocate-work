---
name: "The camera turning back over a half-uploaded row loses a frame"
description: "On a painted map, if the camera turns around while a row of the painting is being uploaded ahead, it uploads it whole in that tick and a frame is lost"
type: bug
status: draft
---

Measured by Mulita on 2026-10-11 (`sunset-en-modo-1-con-color-math.md`),
with `modo1/chequear.py` —VRAM against the `.inc`, frame by frame— on
map 2 of Sunset Over Imdahl: the upcoming row is uploaded ahead, 11
tiles per frame, and "a turn back of the camera with a half-uploaded
row uploads it whole in that tick, and in the plaza that cost a lost
frame". It was left in "Lo que queda". The code for painted maps
(`runtime/`, `.ifdef paint_table`) hasn't changed since then
(the-advocate `fc6f7456`); not checked today.

**What you see while playing**: a one-frame hitch when turning around while
walking in a plaza in Sunset. Nobody has said they noticed it.

**How to see it**: Mulita's script, `~/scratch/mulita/modo1/chequear.py`,
on Sunset's release, walking in the plaza (map 2) and going back over
one's steps.
