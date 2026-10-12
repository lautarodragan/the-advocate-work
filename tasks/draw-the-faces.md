---
name: "Draw the faces"
description: "ChangeFaceGraphic is accepted without drawing the face: the message box comes out without it"
type: feature
status: todo
---

Split from `draw-the-faces-and-really-wait-on-the-escapes.md` on
2026-10-12, by taro.

`ChangeFaceGraphic` (10130) is in the event compiler's `ACCEPTED_UNDONE` and
does nothing; the box comes out without a face. A face is 48x48 with its
own palette: it competes for VRAM and for CGRAM with the window and the
map. The research on the windows
([`2026-10-11-the-windows-made-cheaper`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-11-the-windows-made-cheaper.html),
section 4) measured a face's palette written by HDMA on the window's lines.
When doing it, remove it from that list.
