---
name: "Mock-up: the menu in high resolution"
description: "Before touching the ROM, how the pause menu would look in mode 5 (512 wide) with RM2k's font scaled ×1.6, next to two cheap alternatives, so that taro chooses by looking"
type: research
status: done
assignee: taro
---

From taro, on 2026-09-30. The original menu shows, per actor, the **title**
(`title` in the LDB: "Agency Capt.", "Fugitive"…) and the **SP**, and ours
does not, because at 256 wide they do not fit. Adding rows stretches each entry, may
require scrolling and looks ugly.

taro's idea: the PPU's mode 5 gives 512 wide. The original menu measures
320, and 320 × 1.6 = 512, so RM2k's whole menu would fit at 80 % of the
width. What is not known is how the font looks scaled ×1.6: some
columns of each letter come out double and others single. In mode 5 the text goes
in 4 bits, and the faces would go as sprites, which are already 15 colours.

This is only the mock-up: images to look at, without changing the ROM.

## What was built (Ñacurutú, 2026-09-30)

The images are in `/shared/capturas/2026-09-30-menu-alta-resolucion/`,
with a `LEEME.txt` that says what each one is: the original, today's menu,
mode 5 with three scaling criteria, the two alternatives at 256, each one
as an emulator shows it (512x448), a sheet with all of them at the same physical
size and ×4 crops of Kersh's row. The scripts stayed in the
scratchpad; `rm2k-render` (windows, cursors, text colours,
shadow and the game's faces) and `rm2k-snes-screens render` (today's menu) were used. The
menu at 320 the scripts build was compared against the RPG_RT capture:
the positions match; what differs is RPG_RT's font, which is not
easyrpg's Mincho, and the gradients of Wine's 16 bits.

**What is seen:**

* **×1.6 by position** (02): it reads, but each letter comes out different depending on
  the column where it falls; it shows in repeated digits ("168/168").
* **×1.6 by glyph** (03): even letters —ink 2,2,1,2,2 and gap 1, 10 of
  advance—, but 10 is more than the 9.6 RM2k's layout allows, and
  where RM2k packs the text tightly it collides: "HP168" and "/168" end up
  stuck together. Fixing it would mean moving the layout.
* **×1.5 by glyph** (04): the most readable according to Ñacurutú. 2,1,2,1,2 + 1
  is 9, exactly ×1.5: even, symmetric letters without collisions. The menu
  measures 480, so there was no need to trim the layout: 32 high-resolution
  pixels are left over, which can go as margin —as it is now— or widen the party window.
* **A** (05): "HP168/168 SP168/168" fits on one line with 4-wide digits
  (it ends at x=238). The title next to the name fits for Core and Manta,
  but **not for Kersh**: the ROM composes the name one letter per 8-wide cell,
  and "Agency Capt." goes 14 px past the edge. No variant at 256 makes it
  fit for everyone: with the name at 6 it would still go over.
* **B** (06): title and SP of the selected one in a line below the party, with the
  SP composed as the HP are today. It fits without touching anything above.

**The font fits in 4 bits.** Measured over the glyphs: the System's colour 0
uses 4 colours, 1 (red) 8, 3 (grey) 8, and the shadow 1. White,
red and shadow are 13: one palette for the party panel, where the same
tile mixes "HP" and "168"; the grey of disabled items, another. The worst 16x8
block carries 7 colours.

## What each one would cost in the ROM (estimated, not implemented)

Looking at `menu.s`, `slots.s`, `screen_bank.s`, `enter_map.s`,
`screens/src/layout.rs` and `docs/port/vram.md`.

### Mode 5

* **Changing mode is cheap.** The menu already opens with the screen off and
  uploads its whole bank (`menu_upload` → `slot_bank_upload`), and on closing
  `back_to_map` rebuilds the map with `ppu_init` + `load_map`. It is a
  `BGMODE = 5` on opening, and the return already exists. Two things about the mode that
  have to be respected: in mode 5 **the even columns come from the subscreen**,
  so BG1, BG2 and the sprites go in `TS` as well as `TM`, or half
  the pixels are missing; and mode 5 without interlacing stays at 224 lines: the
  240-line menu loses 16, which come out of the party window and the gold (that is how
  the mock-up is).
* **The layers change depth.** Today the menu is mode 3 and everything goes in
  4-bit BG2 (text and faces, one palette per face) and the bar in BG1. In
  mode 5, BG1 is 4 bits and BG2 2: the text to BG1, and the windows, the
  bar and the cursor to BG2 —ablskin's windows have 4 colours with
  black, which can be the background, and the bar and the cursor, one each—.
* **The faces, to sprites.** In mode 5 sprites stay at 256: each pixel
  takes up 2 in high resolution, at even X, which is what is wanted. A 48x48 face is
  36 tiles; three, 108 tiles, some 3.5 KB. The colours are today's: 21 to
  29 per face, which Adeleine brings down to 15, and each with its sprite palette
  (there are 8; today one is used for the Ex, which in mode 5 would move to the background).
  `menu_exp_paint`/`menu_exp_close` already change and restore `OBSEL` on entering and
  leaving, so that path exists.
* **The text cannot be composed as today.** Today the name, the level and the
  HP go one letter per 8-wide cell (`layout.rs`, "composed one letter per
  cell"), and the Ex in sprites. In mode 5 a tilemap cell measures 16 high-resolution
  pixels —two 8-wide tiles side by side—, and a glyph measures 9.6, 10 or 9: it does not fall
  aligned with anything, and two glyphs share a tile. There are two paths:
  - **Bake everything in the converter.** The orders, the terms and "Normal"
    yes, because they are few. The names and titles of the 50 named actors
    add up to 548 letters: at an advance of 10 and two rows of tiles that is some 1,400
    tiles, **~44 KB of ROM** uncompressed. And the numbers (HP, SP, Ex,
    level, gold) cannot be baked: there are too many.
  - **A variable-width font in the ROM** (the "VWF" of translated SNES
    games): the scaled font stored as 1-bit masks
    —95 glyphs × 12 rows × 2 bytes, ~2.3 KB— and a routine that shifts it and
    mixes it into a buffer of 4-bit tiles in RAM, with the shadow and the
    colour of each row of the gradient, and uploads it by DMA. It is the
    realistic option: a few hundred bytes of new code, and with the screen
    off the CPU cost does not show (~150 glyphs per menu).
  - An intermediate one for the numbers: pre-built digit pairs in
    16-wide cells (100 pairs, ~6 KB of VRAM), with the digits at an advance of 8
    instead of 9.6: narrower than the letters.
* **VRAM.** Measured on the mock-up: the text takes between 515 and 560 8x8
  tiles with something in them (**16 to 18 KB**), of which 413 to 486 are distinct. Plus
  two 2 KB tilemaps and ~3.5 KB of faces: **some 25 KB**. It fits in the
  64 KB, but it overwrites more than the slots screen overwrites today
  ($2000..$4000, `SLOT_VRAM`/`SLOT_MAP` of `tools/port/vram.py`): it needs
  confirming that `load_map` restores everything the menu overwrites, sprites
  included.
* **A risk the mock-up does not show**: over composite or RF, a column of
  one high-resolution pixel is at the edge of the NTSC video bandwidth
  and blurs; over RGB, HDMI or an emulator it looks like the mock-up.
  Some emulators, moreover, blend high-resolution pixels by
  default. It is worth taro looking at it on the SNES with the output he uses.

**In summary**: the mode and the faces are cheap because the menu already turns off the
screen and rebuilds the map; the expensive part is the text, which asks for a
variable-width renderer in the ROM.

### Whether the same path would serve other screens

Yes, and it is the strongest argument in favour. Once the mode
change, the VWF and the faces in sprites exist, **any RM2k screen fits with
its whole 320 layout**: the item list in two columns (today a
single one, `layout.rs`: "RM2k's two do not fit"), the equipment with its
parameters and the list, the techniques, the shop and the slots. Each screen
still asks for its layout port, as today. What is added on those
that have a scrolling list: redrawing the row that comes in —two items in two
columns are ~80 tiles, 2.5 KB— in the vblank, which fits in what the DMA
manages to upload per frame.

### A: narrow digits

4-wide digits do not fit one per 8-wide cell: two share a
tile. They go in **sprites**, like the Ex today (`menu_exp_paint`), with 11 new
tiles (0-9 and the slash). Per actor that is 16 more sprites for the HP and
SP line, 48 for three: with the Ex, which already uses 15 per actor, it comes to ~93 of 128. What
can bite is the **limit of 32 sprites per line**: the HP line
(16) and the Ex line (15) touch in one row, the shadow's, and there they are 31.
The title: it fits only when it is short —Kersh's does not fit—, and it would be text
per actor baked or in sprites. A day of work.

### B: only the selected one

The cheapest: one more line with the title —in sprites at 6, like the Ex— and
the SP composed one digit per cell as the HP are today (`menu_hp_write`). It is
redrawn when the bar changes actor. Hours, not days.
