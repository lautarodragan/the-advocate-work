---
name: "Waits in the middle of a box"
description: "The escapes \\. \\| \\! in the middle of a message box are discarded today; RM2k waits a quarter of a second, a second, or a key there"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Split from `draw-the-faces-and-really-wait-on-the-escapes.md` on
2026-10-12, by taro: the cheapest of the three, because it competes for
neither palettes nor VRAM.

In RM2k `\.` waits a quarter of a second, `\|` one second and `\!` a key.
The ROM only knows how to wait for `\|` at the end of the box (the header
with the pauses); in the middle, `without_waits` in
`rm2k-snes/text/src/refit.rs` discards them. Doing it for real requires the
box to be drawn in stretches. When done, `\.`, `\|` and `\!` stop being
discarded, and the debt of `faces-and-wait-escapes-in-messages.md` no
longer covers them.
