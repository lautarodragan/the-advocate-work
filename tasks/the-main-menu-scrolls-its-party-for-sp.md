---
name: "The main menu scrolls its party, to fit SP"
description: "The main menu's party boxes get a fourth line with SP and show three actors at a time, scrolling to the fourth, since four boxes of four lines do not fit"
type: feature
status: testing
assignee: taro
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

## Done, measured

As planned. The menu rows are nine cells —`MENU_LIST_ROWS`, `MENU_SHOWN`,
`MENU_SP_ROW`, `MENU_ARROW_X/Y` in `layout.rs`—, the actor choice keeps
`TARGET_BAR` and four rows of seven, and the console side is
`runtime/menu_list.s`. "Normal" stays where it was, in the row's fixed
block on the level line at `MENU_STATUS_DX`: whoever puts the condition
there finds the same cells, on both screens.

**A VRAM read-back needs a word thrown away.** The first capture had every
row one cell to the right: writing VMADD prefetches the word, and the
first read loads the prefetch again from the same address before
incrementing —fullsnes calls it a glitch of the hardware, snes9x follows
it—. `keep` reads one word by hand before each row's DMA; the comment is
on the line.

**The scroll is one frame.** `test_the_scroll_has_no_frame_in_between`
looks at every frame from the press: the before screen, then the after
one, no black and nothing half moved. On the emulator; the vblank budget
on the console is estimated, not measured: some 50 DMAs —the bar erased
and painted, 27 cell rows, the OAM— about 2.7 KB, against the 6 KB or so
a vblank moves.

**The arrow** is the System's, in sprite palette 2, still, both at the
bottom: see the divergence.

**Space** (`just space`, before at main's integration and after on this
branch): bank 0 gains what `menu_party_paint` took, about 209 B —ABL
`release` 118 → 327 B, Sunset 35 → 244 B, every game 240 B or more now—;
bank 1 gains the choice and the bar, `test-msu` 574 → 856 B. What went to
`FAR3` shows in `release`'s gaps: 10,282 → 10,058 B. `release` stays at
126 of 126 banks, as before.

## Tests and goldens

New in ABL, `tests/rpgmaker/test_menu_party_scroll.py`, on the debug
map's first full-party NPC with Core at 5 SP and Manta at 30: the menu
against `render` —three rows, the down arrow—, the bar past the third and
back, the wrap both ways, B leaving it scrolled and the next choice at the
top, the frame-by-frame scroll, and the golden `menu-full-party-scrolled`.
`screens.menu` takes `sp` and `top`.

**Red before**, honestly: on main's tools the file is 1 failed, 5 passed.
The comparisons are against the render of the same tools, so with main's
both sides are four rows without SP; what is red is the golden. During
the work, the frame-by-frame case is what caught the rows one cell right.

Goldens that moved, side by side in
`/shared/captures/2026-11-01-menu-party-scroll/` with a contact sheet:
`menu`, `menu-2`, `menu-party`, `equipment-a-who`, `console-menu`,
`console-menu-cursor`, `console-menu-without-item`,
`console-menu-without-item-cursor`, `console-returns-to-menu`,
`skills-returns-to-menu`, `debug-screen-menu-option`,
`debug-screen-back-to-menu`, `picture-menu-open`; and the test game's
`renamed-menu`. All the same change: rows of nine with SP, three shown,
the arrow when there is a fourth.

The screens crate's render hashes for the four menus and the converter's
answer moved —looked at—; mapdata's Python comparison gets the arrows and
the list's numbers in and out like the SP line before it.

## What to install when merging

`just install screens mapdata cartridge` in the-advocate —the runtime
comes with the merge—.

## Branches and what was run

Branches `tijereta-menu-scroll`: the-advocate `790185b7` + `74429692`
(the test game's golden), the ports `e1382bd` + `45f7348` (the goldens),
the book `6fa7bd8`. `main` did not move in any of the three while this
ran, so there was nothing to merge.

With `just install-local .local-tools screens mapdata cartridge`: ABL's
`just tests`, repeated until no new golden went red and then once more
on the final commits, green (`abl.sfc` md5 `a6df25eb…`); the ports' `just
boot`, 129 passed; `just space` on the nine games; `just test`, `just
test-game` (63 passed) and `just crate-test` of `screens` and `mapdata`.
Not run: `just lint`'s clippy.

**What the suite does not cover**: a scroll with Tech Skill —it is the
same `menu_choose` as Equipment, which is what is tested—; coming back to
the menu from a custom menu or a screen with the list scrolled —it is
painted again at the top—; a full party with an actor the ROM does not
know; the scroll on bsnes and on the console, where the vblank budget is
an estimate.
