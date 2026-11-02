---
name: "The main menu scrolls its party, to fit SP"
description: "The main menu's party boxes get a fourth line with SP and show three actors at a time, scrolling to the fourth, since four boxes of four lines do not fit"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Follows [`sp-in-the-menu-and-the-item-target-picker`](sp-in-the-menu-and-the-item-target-picker.md):
Tijereta put SP in the item and skill target picker but not in the main
menu, where four boxes of five ink lines do not fit the 224 lines and the
Ex already takes 120 of the 128 sprites. Of the ways out —drop "Normal",
drop the Ex, the 512-wide mode— taro asked, on 2026-11-01, in their words,
translated:

> Hmmm, darn. Isn't vertical scrolling for the characters an option?

and, after Hornero's answer:

> Go ahead! Let's go with vertical scrolling then, once Tijereta finishes.

**Done**: each actor's box in the main menu has a fourth line with SP
(the database's term); three boxes are seen at a time and the list
scrolls a whole row when the cursor goes past them, with a sign that
there is more; the Ex's sprites fit for the three rows seen; a
divergence in the book —RM2k shows four at once—; goldens moved, red
before, with the debug map's full party.

Waits for the merge of
[`bank-1-overflows-when-merging-2026-11-01`](bank-1-overflows-when-merging-2026-11-01.md),
which is integrating the same menu code.

## The plan

Tijereta, from the-advocate `f40fbee1`, the ports `615b09e` and the book
`a0abdd9`, on branches `tijereta-menu-scroll` of the three.

**The row.** On the menu each row grows from seven cells to nine, 72
pixels: name, level, HP and **SP as four lines of cells** —the SP term
and `"%3d/%d"` one letter per cell under the HP's, like the HP—, and the
experience in sprites eleven below the SP. Three rows are 216 lines, and
the eight left at the bottom take the sign. The SP do not go in sprites
like the actor choice's: 3 x (30 + 18) objects is 144, and there are 128;
the experience alone is 90.

**The actor choice keeps its four rows of seven** and its SP in sprites:
it has no experience, so its four lines fit. The two panels stop sharing
a geometry —the row's block, yes—.

**The scroll without a black frame.** Nothing of VRAM can be written
outside the vblank, and repainting three rows —names composed into
tiles— does not fit in one. So when the menu opens each actor's row is
painted once, in the first row's cells, and read back to WRAM —the load
buffer, which is free while the menu is open, below `CODE_CARRY`—; a
scroll uploads the three rows shown from there, 27 DMAs of 40 bytes, and
the OAM with their experience, in one vblank. The names are composed once
per actor, as before.

**The sign** is the System's arrow, `Window::Draw`'s, in the eight lines
under the third row, centred on the panel: the down one when there is
someone below, the up one when there is someone above —with four actors,
always one of the two—. In sprites, in their own palette. It does not
blink, as RM2k's does every twenty frames: a golden of a blinking arrow
depends on the frame it was taken on.

**Where the code goes**: the panel's painting leaves bank 0 for `FAR3`,
with three `jsl` doors to the bank 0 routines it uses; the choice and the
bar leave bank 1 for `FAR3` too.
