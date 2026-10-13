---
name: "Variable-width letters, in low resolution"
description: "Espinillo's low-variable-width font across the whole game: the message window, the menu, the battle and the shops with composed text and per-letter advance, and box layout by pixel width"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-03, after seeing `2026-09-30-fuentes` on the SNES: he
likes both variable-width ones and wants to try them in the game. This is
phase 1, the low-resolution one (256, the usual resolution). Phase 2 is mode 5
as a project knob, on top of what this one leaves: the compositor, the table
of advances, the layout by pixels and the screens in composed text are
reused by both.

The study, the sheet and what it would cost: `tasks/font-for-high-resolution-or-a-narrower-one.md`,
in ABL, and `experiments/fonts/` there.

## Done (Calandria)

### The font

The sheet `baja-ancho-variable` is now `low-variable`, a font **of the
engine**: `tools/rm2k-snes/text/fonts/low-variable.png`, with a README that
says how to edit it. The game chooses in `rm2k-snes.toml`, `[text] font`: `rm2k`
—RM2k's, which is still one more font, with fixed advance—, one of the engine's,
or the path to a sheet of its own. A sheet of its own goes into the cartridges'
fingerprint. To retouch it without reinstalling: copy it into the game and point the
key at the copy.

One more glyph in the console's tables, 95: a blank as wide as the
`>` (DEL in the text), for the `ShowChoice` and the `InputNumber`, which with a
space moved along with the cursor.

### The converter

`refit` measures in pixels (`Measure`), with the costs in letters of `n`: with
RM2k's font it gives the same as before, to the bit. The message window measures
240 pixels. Over ABL's boxes, with `rm2k-snes-screens boxes`:

    39 columns:           1245 boxes rebuilt, 299 split into several
    240 px, low-variable:    1 box rebuilt,       0 split

The only one is "Isabella!!" on map 157, which carries a trail of spaces.

### The message window

Accumulated x in `msg_x`, eight phases, and the pixel limit with `font_reach`.

**Precomposed, with the number.** Both were written and they draw identically pixel
by pixel. On map 6 with the camera moving, counting hardware frames
against ticks while composing (the case `anchored` and one with four full
rows):

    letters per loop    precomposed (8 phases)   one-bit
    5                   0 lost                   0
    6                   0                        1 (once)
    7-10                0                        0
    11-12               0                        frames lost
    16-18               0
    20 and up           frames lost

The one-bit one costs almost twice as much per letter. The tables are 117 KB; the one-bit
one, 1.1 KB and a table of 4.5 KB. The tables go in, and `MSG_CHARS` stays at 5.

### The text screens

Items, equipment, shop and battle **compose** their text: `text_layer.s`, which
explains the design (records per row, only what changed is composed, a
row that says what another said takes its tiles, the tilemap changes all at once).
The letters are precomposed as in the window (`scr_pre0..7`, 117 KB more): one
bit at a time, a description took nine frames.

**Declared debt: the text arrives after the cursor.** Measured in items with
fourteen: 4 frames for a step, 6 for one that scrolls the list. The drawing tests
wait for it to settle.

VRAM: the pool of tile pairs goes below the windows, in the bank of
`SLOT_VRAM`: 167 pairs in items and equipment (the windows at the end of the bank),
191 in shop and battle. At rest the list of fourteen items uses about 104.
RAM: `$7E3D20-$7E5FFF` (`FAR_TEXT_LAYER`), outside `FAR_PAIR_LIST` and the
battle's message buffer.

The limit of a text (`scr_cap`) is per cell, in pixels; the battle breaks its
rows (`ba_flow`, the troop page) in pixels, and the converter rebuilds
the pages' boxes for that window.

### Menu, actor selection and slots

Names are composed in strips (`tl_strip`) with the font precomposed
for the bank's text palette (`slot_pre0..7`). Numbers stay one
letter per cell: they are rewritten in the vblank. The bank of `release` goes down from
385 to 314 tiles out of 448, and the names ask for at most 78 of the 134 free ones
(the converter prints it: "menu bank").

### For mode 5

Reused: the sheet as the source of truth (with cells of any width
up to 16), the table of advances, `refit` in pixels, the compositor with accumulated
x, `text_layer.s` and `tl_strip`. What belongs to low resolution: the eight phases and
the precomposed tables per phase (in high resolution they would be different ones), and `TL_COLS`.

## For taro

Play: the messages, the menu and its screens, a shop and a battle. Look at
the delay of the text in items/equipment/shop and whether it bothers. The goldens are
side by side in `/shared/captures/2026-10-03-ancho-variable/` (with LEEME):
only letters change, and they are not blessed.

Branches: tools, Calandria's; ABL, `ancho-variable` of her clone.
On merging, reinstalling `text` is not needed (it is a library): `screens`,
`events`, `convert`, `mapdata` and `cartridge` are.
