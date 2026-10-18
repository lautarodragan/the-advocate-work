---
name: "Scrolling a list shows the last row repeated for a moment"
description: "On the screens that list items, the rows that come in while scrolling repeat the last row that was on screen for one or two seconds before showing their item"
type: bug
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-18, an old bug never prioritised: on the screens that
list items, when scrolling, the rows that come into the screen repeat the
last row that was on screen instead of the name of the item really in that
slot, for one or two seconds; then it fixes itself. It shows most holding
the arrow down, which scrolls fast. taro's guess: the visible part moves up
or down, but the rows left free are not redrawn at the same time, and keep
what was there.

Before this, `scrolling-the-item-list-redraws-the-whole-screen` (done,
2026-09-30, Hurón) moved the item screen to composing in `text_buf` and one
DMA per vblank. Since then the screens' text takes tiles only where it has
ink, shared by rows that say the same: a stale tile or a late upload of
those tiles is a suspect, as is the arrow repeat.

Done means: holding the arrow over a long list, every frame shows in each
row the item of its slot, measured frame by frame in a ROM test, on every
list screen that has the bug (items, and whichever others: skills,
equipment, shop, battle).

## Log
