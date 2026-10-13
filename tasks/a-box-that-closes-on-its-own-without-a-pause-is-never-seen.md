---
name: "A box that closes on its own without a pause is never seen"
description: "A ShowMessage whose tail is \\^ without any \\| closes before the composer finishes it, so the window never shows; RM2k types it out and then closes it"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-12, reading the code while doing
`waits-in-the-middle-of-a-box.md`; tools `e08f95c0` (branch
`tijereta-esperas`), not seen in an emulator.

**What happens**: `events_tick`, in `runtime/event_pages.s`, closes a box
with `\^` as soon as its `\|` pauses are over, and with no pause that is
the frame after the page asks for it: the comment there says it closes
"before it finishes composing", and stops the composer so the window does
not turn on afterwards. The text is never on screen. In RM2k `\^` closes
the box **at the end of the message** (easyrpg's `kill_page`, in
`Window_Message`), after typing it, so it is seen for as long as the
typing takes.

A box with waits in the middle no longer does it: since
`waits-in-the-middle-of-a-box.md` it holds its tail until its last
stretch is on screen. The plain ones still do.

**How many**: boxes whose tail has `\^` and no `\|`, in each game's
`data/` (pages and common events, repeated boxes counted each time): ABL
2, Dooms 2 9, Sunset Over Imdahl 13, the other five 0.

**To reproduce**: a test case with a `ShowMessage` ending in `\^` and a
`TintScreen` after it, like `auto-close-1` without its `\|`, captured
every frame from the page's start: the window never appears.
