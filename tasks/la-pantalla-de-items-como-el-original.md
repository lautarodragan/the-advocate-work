---
name: "The items screen like the original"
description: "The original's text colors and window separators on the items screen, within what the SNES's resolution allows"
type: feature
status: done
assignee: Jacarandá
---

From taro, on 2026-09-28: "improve the look of the items screen a bit. the
snes's resolution limit complicates things, but we should be able to use the
text colors the same as in the original, and the same separators".

The closest thing already done: `el-menu-como-rm2k.md` (Tero), which took the
colors from the game's skin and compared against screenshots of the original
with Wine.

## What the original does

Looked at with the 2015 RPG_RT running under Wine, on a copy of the game
whose map 4 starts with Kersh and Core in the party and nine items in the
inventory —usable, equipment and switch ones—, and in easyrpg-player
(`Scene_Item`, `Window_Item`, `Window_Help`, `Window::RefreshFrame`,
`RefreshBackground` and `RefreshCursor`). The screenshots, at 320x240, are in
`/shared/capturas/2026-09-28-items/original-*.png`.

- **Two adjoining windows**: the help one on top, 32 tall, and the list one
  below. Each is a `Window` with the game's System (`ablskin`): the
  background is the 32x32 box at the top left **stretched** to the window
  —`message_stretch` at 0—, which is black with two barely lighter stripes
  (15,15,15) at row 27-28 and column 29; and the frame is two pixels, a gray
  one (67,67,67) outside and a dark one (29,29,30) inside. The separator
  between the two windows isn't a separate drawing: it's both frames
  together, four pixels.
- **The cursor is a red bar** (83,0,0), the System's box at x=64, with a
  transparent pixel around it; there's no ">".
- **Text colors**: the name, the ":" and the quantity in color 0 if the item
  can be used and in 3 —the gray— if not (`Window_Item::DrawItem`). The
  description in 0. The skin's colors 0 and 3, measured in the screenshot,
  are **the same** the ROM already gave at 15 bits: the white gradient
  (239/231/247/255) and the gray one (181/156/123/99/74), with the shadow.
- The list goes in two columns of 144 pixels with the font at 6.
- The actor choice (`Scene_ActorTarget`) has the item's name on the left and
  "Owned Items" in red —color 1— with the quantity, and on the right the
  party with the chosen row in the red bar.

## What differed in the ROM

- Text colors: **nothing**, they already came from the skin
  (`pantalla_items`).
- What goes in gray: materials, books and specials go in gray and in the
  original in white, because the ROM doesn't know how to use them yet. It
  isn't a color: it's `item_usable`, and changing it without implementing
  them would be lying. It stays that way.
- **No windows or separators**: everything on black.
- **The cursor was a ">"**.
- One column of eleven rows from y=48, with the font at one letter per cell.

## What was done

- The two windows with the game's System, on **BG1**, which on this screen
  was off: the text stays on BG2 without knowing anything about them. The
  glyphs already had the priority bit (because of the battle), so the text
  stays above the background's stripes. The tiles, 8bpp, go in the font's
  bank behind it and the tilemap at $3800; the converter checks that they fit
  (`_controlar_marco_de_items`). Deduplicated, mirrored too, they are 17
  tiles.
- The cursor is the System's bar, four pixels wider than the text on each
  side. Moving it means copying two rows of BG1 cells —from a tilemap with the
  bar or from the one without it—: 128 bytes by DMA in vblank.
- The help is 48 tall —two lines— and the list starts at y=56 with **ten**
  rows and not eleven: with eleven the last one touched the bottom frame.
- The new code goes in bank 1 (`banco_de_la_pantalla.s`); bank 0 gained
  bytes, because the ">" was written from there.

## What doesn't fit

- The two columns: with eight-pixel letters two twenty-letter names don't fit
  in 256. It stays one column.
- The font at six pixels: that was already declared.
- The "Owned Items" window in the actor choice: that screen is the menu's,
  with its own bank, and wasn't touched.

## Equip and skills

**Not touched.** What's useful for them is the mechanism —`ventana.cursor`,
`marco_items` from a list of windows, BG1 behind the text and the bar by DMA
of rows—, but it isn't free: equip has another layout —the actor, the
parameters, the slots and the list—, so it takes its own set of windows and
its own tilemap, and it composes the whole screen in `texto_buf` every frame,
so the bar would be done differently. The tiles of its windows would fit in
the same VRAM place, because the two screens aren't open at the same time.
Skills doesn't have a screen yet ("Tech Skill" is grayed out in the menu).
The shop, which uses the same font, same as equip.

## Tests

- `items` and `items-2` change: the windows, the bar instead of the ">", and
  the list one cell lower. New `items-gris`: the cursor on the Club, in gray,
  with its description. The actor choice doesn't change: it's the menu's
  screen.
- `render_items` draws the windows and the bar, and
  `test_la_lista_se_corre_cuando_el_cursor_se_sale` counts with `ITEM_FILAS`.
- Before, now and the original, side by side, in
  `/shared/capturas/2026-09-28-items/`.
- Verified with `just cartuchos` and `just pruebas` on this branch: all green.
  `just espacio release`: bank 0 went from 175 to 205 B free.

## What taro has to look at

- Open the items: the two windows with their gray frame, and the barely
  lighter stripes of the background —on the right and at the bottom—, which
  are also in the original and are hard to see.
- Move the cursor: the red bar follows, and also when the list scrolls.
- Use a potion and go back with B: the list comes back with the windows.
- Close the menu: the map with its usual colors and scroll (BG1 is turned on
  on this screen and the map restores it on returning).
