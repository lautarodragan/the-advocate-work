---
name: "Draw the faces and really wait on the escapes"
description: "Today ChangeFaceGraphic is accepted without drawing the face, and the escapes \\. \\! \\| in the middle of a box are discarded without waiting. Do them for real"
type: feature
status: done
agents: [Tijereta]
---

**Split**, 2026-10-12, by taro: the three things compete for different
resources —the waits for none, the colours and the speed for palettes and
the drawing pace, the faces for VRAM and palettes—, so each is a task of
its own: `waits-in-the-middle-of-a-box.md` (taken first, the cheapest),
`message-colours-and-speed.md` and `draw-the-faces.md`. What follows is as
it was.

Debt left by `faces-and-wait-escapes-in-messages.md`.

* **Faces**: `ChangeFaceGraphic` (10130) is in the event compiler's `ACCEPTED_UNDONE` and does nothing; the box comes out without a face. When doing it, remove it from that list.
* **Waits**: in RM2k `\.` waits a quarter of a second, `\|` one second and `\!` a key. The ROM only knows how to wait for `\|` at the end of the box (the header with the pauses); in the middle, `without_waits` in `tools/rm2k-snes/text/src/refit.rs` discards them. Doing it for real requires the box to be drawn in stretches.

* **Colors and speed**: `\c[n]` and `\s[n]` are discarded in `without_waits`
  (`ignore-the-color-codes-in-messages-for-now.md`); doing them for real requires a
  text palette and a drawing pace that the ROM doesn't have.
