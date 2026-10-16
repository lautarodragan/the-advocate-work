---
name: "Fused windows can redraw the blank cell"
description: "When a System's windows do not fit their 8bpp bank, fit merges the cells that show the least, and the blank one can be among them: the screens over nothing —the menu's bar and cursors, the slot cursor— then draw every empty cell"
type: bug
status: draft
---

Seen by Chajá on 2026-10-16, while doing
[`the-system-cursor-in-the-main-menu-and-the-slots.md`](the-system-cursor-in-the-main-menu-and-the-slots.md);
tools of the-advocate branch `chaja-system-cursor` (`193fd075`), and the
same before it with the global tools of that day.

**What was seen**: `rm2k-snes-screens render` of The Book of Three's pause
menu and slot screen **without `--window-background`** —Royal's gradient
drawn whole, so the actor choice's windows ask for many more than 64
tiles— draws the whole background of the menu brown before the change,
and in vertical orange stripes after it, where it is black. With the
project's `[windows.background]`, as the converter and the tests ask, it
is right, and the cartridges build.

**Why, probably**: `fit` (`fit.rs`) redraws a fused screen by mapping each
cell to its nearest, and nothing keeps the blank cell —the one the menu's
BG1 is cleared with, tile 0— out of the merge. In the cartridge it would
not draw stripes: `alone` and `compact_target` in `borders.rs` refuse a
screen over nothing whose background is not empty, so the conversion would
stop instead.

**To reproduce**: the request `{"screen": "menu", "slots": 4, "party":
[1, 2, 3], "font": "low-variable", "letter_spacing": 0, "chosen": 1}` to
`rm2k-snes-screens render` with The Book of Three's dump and game folder
and the RTP, and no `--window-background`.

**When it matters**: a game whose System, with its configured background,
still fuses enough that the blank cell is merged —today Book of Three,
Dooms 2 and Zounds fuse the actor choice's windows (82, 85 and 81 tiles of
64 since the cursors) and none merges it—. Then the converter stops on
that game.
