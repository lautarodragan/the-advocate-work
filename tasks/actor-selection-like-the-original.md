---
name: "Actor selection like the original"
description: "When using an item, actor selection with the windows, the red bar, the item's name and Owned Items, like Scene_ActorTarget"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-28, in their words, translated:

> Now let's make the character selection screen, inside use item, also
> work like RPG Maker. The simplest example is: choose Cold Sandwich. Our
> screen currently keeps the `>` indicator instead of the red background,
> and shows neither the item's name nor Owned Items on the left.

## What the original does

The capture with RPG_RT and Wine, at 320x240:
`/shared/captures/2026-09-28-items/original-eleccion-de-actor.png`, and
easyrpg's `Scene_ActorTarget`.

- **Three windows**: on the left, 136 wide, the help with the
  item's name (32 tall) and below it `Window_TargetStatus` with "Owned Items" in
  red —colour 1— and the quantity on the right; on the right, full height,
  the party.
- **The System's red bar** over the marked row, **over the actor's
  text** —the three lines—, not over the sprite.
- A uses the item and the screen stays, with both windows up to date; with the
  quantity at zero the error sounds and it stays there.
- An item with `entire_party` marks the whole party at once (index -100).

## What differed in the ROM

The screen was the menu's party panel over black, with a ">" at the
side of the row, and the left column empty: the menu's bank did not
have what it needed to write the item's name.

## What was done

- **The windows on BG1, with their own tile base** (`OBJETIVO_VRAM`,
  `$4000`) and their tilemap at `$4800`. There is no room left in BG2's base: the
  menu's bank reaches almost up to its tilemap (`$3C00`). Measured against the
  real allocations (`_controlar_objetivo`): the BG1 bank that `load_map`
  restores is, in the smallest one —`VENTANA_FONDO`—, `$1000..$4C00`, and in the
  others it reaches at least `$5000`. So `$4000..$4C00` is always
  inside and outside what the menu uses: closing the menu costs nothing more.
  64 tiles of 8bpp and the tilemap fit there; the windows use **60**.
- **BG1's colours in 128..143**, those of sprite palette 0: on
  this screen there are no sprites, and `menu_exp_cerrar` restores them when closing the
  menu. In 0..127 there is no room: they are the menu bank's eight palettes. It is
  **10** of 16.
- **The left column goes up to x = 104** and not up to 96, where
  the party row starts: the bank's faces measure 48 but what is seen
  of them starts at x = 108 (measured on all eleven). That way **eleven**
  8-pixel letters fit per row, which is what "Sandwich-HP" asks for.
- **The item's name** in two rows of eleven, split by words
  (`nombre_en_renglones`), with the menu bank's glyphs: the bank now also
  carries the letters of the medicines. It was 391 tiles and it is **411**; the
  ceiling is 448 (`$3C00`).
- **"Owned Items" baked into BG1**, in red and at the font's six pixels:
  at eight, its eleven letters filled the window and there was no room left for
  the quantity, and in BG2 there is no free palette for the red. The quantity goes with
  the glyphs, in two digits, and is repainted after using the item.
- **The bar** over the actor's three lines, from x = 148 to the edge, with the
  sprite outside, as in RM2k. Moving it is copying the rectangle of BG1 where
  something changes —6 rows by 14 columns of cells—, from the bar set or from the
  tilemap: a 28-byte DMA per row of cells.
- **A single tilemap and just what is needed of bar and names** (`d9645920`): the one for
  choosing whom to equip is the same with the 10 x 13 cells on the left
  erased when uploading it, the bar is stored only in its rectangle, and the
  names only for the medicines, with a table of one byte per item that says
  which one it is. `objetivo_compacto` checks at conversion time that the first two
  things hold.
- **The menu's bank carries the priority bit**, like the item glyphs:
  in mode 3, BG1 of priority 0 sits above BG2 of priority 0 and the bar
  would have covered the row. On the bank's other screens BG1 is off and
  not a pixel changes: no golden of the menu or of the slots changed.
- **For choosing whom to equip**, the same screen without the two windows on
  the left: there is no item.
- The new code goes in bank 1 (`eleccion_de_actor.s`); bank 0
  **gained** bytes, because the ">" was written from there.

## What does not fit

- **The left column of 136**: in 256 wide, with the party
  row as it is —the face from x = 96 and the text from x = 152—, 104 fit.
  The name goes in two rows and not in one.
- **A name of more than eleven letters without spaces** is cut where it reaches:
  "HerbSproutSalad-HP" comes out "HerbSproutS" / "alad-HP". Of the game's twenty-six
  medicines it is the only one.
- **The one-row help**: it is two, 48 tall instead of 32.
- **SP and the status in their place**: the row is the menu's, with the level, the
  status and the HP in three lines; RM2k puts the SP on the right. It was already
  declared in the menu.
- **`entire_party`**: the ROM does not read it, and marks a single row. In the game
  one medicine has it, the Pocket Shelter (8).
- **Whom to equip, from the main menu**: in RM2k it is chosen in the menu
  itself, with the orders on the left and the cursor over the party. Here it is
  this screen, with the left half in black (`equipment-a-who`), as it already
  was before with the ">". It is left for a separate task.

## Tests

- New `choice-sandwich`: the Cold Sandwich over the second row, Arden
  at 10 HP, which is taro's case. New `equipment-a-who`: the selection for
  equipping, without the item windows.
- `render_objetivo` draws the windows, the bar, the name and the quantity,
  so `test_menu_heal_drawing.py` and `test_menu_items_drawing.py`
  compare them pixel by pixel, also after using the sandwich (the quantity
  goes down from 2 to 1).
- No golden of the menu or of the slots changed, with the priority
  bit set across its whole bank.
- Before, now and the original, side by side, in
  `/shared/captures/2026-09-28-eleccion-de-actor/`.
- Verified with `just cartridges` and `just tests` on this branch with
  `main` merged (Tala's arrow repeat): all green. The
  selection computes the edges with `pad` against `pad_ant`, so it repeats
  without touching anything. Before the merge `dcbest` clipped in
  `test_music_ceilings.py`; with the merge the ROM moved again and stopped
  clipping, so `just ceilings` was not needed and **there is no ceilings commit**,
  even though the message of `714dcef2` announces it.
- `just space`, before (`main` at `1475d9da`) and after this change without
  merging: in `release` bank 0 went from 196 to 254 B free, bank 1 from
  4,380 to 3,841, and the data gaps from 21,584 to 7,456 B (some 14 KB: the
  tiles, the two tilemaps, the bars and the names table); in
  `test-special`, from 1,089 to 1,147, from 6,884 to 6,345, and from 30,545 to 18,777.
  With `main` merged, `release` is left with 224 B in bank 0 and 3,793 in
  bank 1. No cartridge uses one more data bank.
- What it added, measured block by block against `main`: 14,704 B, of
  which 7,168 were two tilemaps and two bar sets. After
  `d9645920`, in `release` the gaps go from 6,880 to 13,910 B and bank 1
  from 3,793 to 3,739; in `test-special`, from 18,201 to 23,213 and from 6,297 to
  6,243. The goldens came out identical.

## What taro has to look at

- Items, Cold Sandwich: the name in two rows, "Owned Items" in red and
  the quantity; the red bar over the actor's text, and moving it.
- Using it on someone hurt: the HP and the quantity change right there.
- B: the item list as it was; and closing the menu: the map with its usual colours
  and sprites (BG1 and colours 128..143 are restored on closing).
- Equipment: the choice of whom, with the bar and without the left
  column.
