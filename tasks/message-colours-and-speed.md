---
name: "Message colours and speed"
description: "\\c[n] and \\s[n] in a message box are discarded today: coloured words come out in the plain colour and the text goes at one speed"
type: feature
status: todo
---

Split from `draw-the-faces-and-really-wait-on-the-escapes.md` on
2026-10-12, by taro.

`\c[n]` and `\s[n]` are discarded in `with_wait_marks` —`without_waits`
until `waits-in-the-middle-of-a-box.md`, which also left `\.` at the 16
frames of speed 1: in RPG_RT a speed past 16 lengthens it—
(`rm2k-snes/text/src/refit.rs`;
`ignore-the-color-codes-in-messages-for-now.md`). Doing them for real
requires a text palette —the System's twenty text colours, against the
window's CGRAM entries— and a drawing pace that the ROM doesn't have.
