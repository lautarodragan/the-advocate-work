---
name: "Scrolling the item list redraws the whole screen"
description: "Going down the item list the screen goes black for a frame and the window borders get redrawn too, not just the text"
type: bug
status: done
assignee: taro
---

From taro, on 2026-09-30, playing, in their words, translated:

> scrolling in the item menu seems to cause a full redraw of the screen,
> and it flashes for a second. I think the main problem is that it goes
> black for a frame, and that the window borders get redrawn too and not
> just the text

Done means: going from one page of the list to the other, only the list's text
changes, without any black frame or redraw of the borders, measured
frame by frame in a test.

## What was done (Hurón, 2026-09-30)

**The cause.** `move` in `items.s`, when the cursor went past the ten
rows, turned the screen off (`INIDISP = $80`), uploaded the whole bank again
—`items_screen_upload`: the font, the blank tilemap, the palettes, the
tiles and the windows' tilemap— and repainted the list letter by letter
straight into VRAM. It was on purpose and had been declared since the screen was born
(`0b060661`, 2026-09-11: "one black frame"); the windows were
added to that path on 2026-09-28 (`f3b0cc90`), when `items_screen_upload`
started uploading them too. The equipment screen and the shop no longer did it: they compose the
whole screen in `text_buf` and upload it with one DMA per vblank.

**The fix.** The item screen does the same as those two: it composes the
whole text in `text_buf` with the writers in `text_screens.s`
(`scr_text`, `scr_glyph`, `scr_number`) and uploads it with `scr_upload` at the
start of each vblank, after reading the controller. Moving the cursor or scrolling
the list only recomposes the buffer; the screen is turned off only on entering and on
returning from the actor choice. `glyph_pair`, `text_write`,
`items_desc_upload` and the `item_row_vram` table are gone; the converter emits
`ITEM_LIST_POS` in their place.

**What was measured** (a separate instrumented ROM, which read the line counter;
snes9x and bsnes give the same ±1): the 1,792 B DMA ends on line 239,
the cursor's two bars on 243, and the vblank lasts until 261.
Recomposing the screen ends around line 145–170 of the next frame:
it fits in one frame, so nothing needed splitting in two.

**The test**: `test_scrolling_the_list_changes_only_the_text` in
`test_menu_items_drawing.py` looks frame by frame at a scroll down and one
up, and requires each frame to be wholly the screen from before or the one from
after. Against the old ROM it's red: the first frame after pressing
differs in 7,479 pixels —black except for the last row—, in snes9x and in bsnes.

**The equipment screen and the shop** don't have the problem: they only turn the screen off on
entering (the shop also when switching from one mode to another, which is changing
screen and not scrolling a list).

**Goldens**: none changed. The strip of frames, before and after, is in
`/shared/captures/2026-09-30-scroll-de-items/`.

**Space**: bank 0 of `release` gained 422 B (from 182 to 604 free on the
baseline `69164d82`, with `just space`; after merging `d94ec1b8`, from 159 to
581). `NO_CACHE=1 just cartridges` and the cached build give the same ROMs.

**On merging**: nothing in Rust to install for this branch;
`tools/port/mapdata.py` changed in content, with no renames.

**For taro**: go down and up a list of more than ten items; the list
scrolls without a flash.
