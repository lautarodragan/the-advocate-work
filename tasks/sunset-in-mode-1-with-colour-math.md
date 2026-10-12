---
name: "Sunset in mode 1, with colour math"
description: "Sunset's painted maps aren't playable in mode 3: try mode 1 with colour math —exact roofs, lights and shadows that reach the characters, the panorama without the mosaic of the large maps—"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

It follows from `sunset-the-pictures-over-the-map.md` and from its research in the book ([`ports/sunset-over-imdahl/research/2026-10-11-the-pictures-over-the-map.md`](https://lautarodragan.github.io/the-advocate-docs/ports/sunset-over-imdahl/research/2026-10-11-the-pictures-over-the-map.html)), which already wrote what mode 1 would give.

taro, on 2026-10-11, after seeing the captures: "it really isn't playable. It isn't a good game to port to SNES, but I'd try Mode 1 and Color Math before anything else." And he clarified that **there never was a decision forbidding another mode or colour math**: mode 3 was what suited ABL, and colour math was discarded for something specific. The book said it as a rule and was corrected (`cartridge/mode-3.md`, `decisions/translucent-events-dont-use-color-math.md`).

## Mulita's log

Base: the-advocate `origin/main` 06b8321f, ports `main` 36adb9a, book
`origin/main` 96483dc. Branches `mulita-sunset-modo-1` in the three, in the
worktrees in `~/scratch/mulita/` (`the-advocate`, `ports`, `docs-wt`).
Scripts, in `~/scratch/mulita/modo1/`.

### The design (2026-10-11)

What weighs the most is the mosaic, and no number of tiles that fits
fixes it: the plazas have 4,670-4,800 distinct cells out of 4,800, and in
VRAM no more than 1,024 per layer fit. What does fit is **what is seen**:
33x29 cells, 957 4-bit tiles. So a painted map goes **painted**,
a new path (`Way::Painted` in Wally, knob `[graphics]
painted_maps`):

* mode 1, BG1 = the painting at 4 bits, **one tile per cell, ungrouped**;
  the ROM uploads the column or row coming in, from the cartridge, in
  vblank. Cell (x, y) in slot `(y mod 29) + 29 (x mod 33)`; the
  cartridge carries them column by column, so a column is one DMA (or
  two) and a row 33.
* the tilemap is the usual map window: `build_column` and
  `build_row` build it, and `paint_column`/`paint_row` overwrite BG1's part with
  the painting. The blocks are still the map's (passability, upper
  layer).
* VRAM `VENTANA_PINTADA`: sprites 256, 33x30 = 990 slots + a blank one
  at $1000, tilemap $5000, `window_map` $5800, BG2 at $6000 as always;
  free $5C00-$5FFF.
* A column is one or two DMAs and goes when needed; a row is 33, and
  with 29 rows of slots the row and the column in the same vblank reached
  line 262 (measured with a `$213D` probe at the end of vblank). With
  a spare row (30) the upcoming one is uploaded ahead, 11 tiles per
  frame: vblank ends at line 250-251.
* What goes in front of the hero, through the priority of BG1's cells,
  as in the flattened map (with BG1's mask under the window).
* All the new runtime is inside `.ifdef paint_table`: a cartridge
  without painted maps comes out byte for byte the same. ABL doesn't move.

New RAM: `$7E7900-$7E791F` (the state) and `$7EFE00-$7EFF3F` (the DMA
queue, at the end of the grid's bank: the converter checks that a painted
map's grid doesn't reach it).

### What each part contributes (measured 2026-10-11)

Mean error per pixel (sum of the three channels at 5 bits) against the
panorama, and % of cells with more than 8 wrong pixels, with the real Adeleine and Voodoo
(`~/scratch/mulita/modo1/medir_mosaico.rs`, a Wally example
that isn't committed):

    panorama            576 grouped     960 grouped     one per cell
    TownSquareSpring    10.53  85.6 %    9.45  82.1 %    2.30  20.7 %
    TownSquareWinter     8.59  72.7 %    7.57  66.3 %    2.12   8.9 %
    TownSquareSummer    10.83  89.4 %    9.92  84.7 %    2.56  21.7 %
    TownSquareAutumn     8.59  78.2 %    7.71  70.6 %    1.88   6.5 %
    TheStatue (320x480)  4.91  42.9 %    3.24  26.8 %    0.92   0.4 %
    GateStreet (320x480) 5.15  40.0 %    3.37  24.7 %    0.94   0.3 %
    InnSpring (320x240)  3.36  30.7 %    1.62   6.2 %    1.59   4.6 %
    BarSpring (320x240)  3.06  28.7 %    1.35   3.0 %    1.35   2.7 %

960 is what mode 1 would give with BG1 at 4 bits without streaming (almost
double 576). In the plazas **it isn't enough**: from 10.5 to 9.4. What
fixes them is streaming: 2.3, and what remains is the reduction to 7 palettes of
15 colours. In the one-screen interiors 960 is already almost enough; with
streaming they stay the same. So only streaming is done, for the 60
painted maps.

What was verified: `modo1/chequear.py` runs a cartridge and in each frame
compares the VRAM slots of the visible cells against the tiles of the `.inc`
(snes9x, which blocks VRAM accesses outside vblank). On 2, 13, 33, 7
and 28, walking in the four directions, diagonals and going back over
the steps: no wrong cell outside the loading frames (screen off) and
the lost frames. One extra lost frame on 2 (turning back with the
row half uploaded: it is uploaded whole in the tick). `abl.sfc` comes out the same,
`24dd24adb52f…`.

### The roofs, exact (2026-10-11)

The cells the roof covers entirely, through BG1's priority; those it
covers partly, in BG2 at priority 1: the painting's cell with only the
roof's pixels, in its palette. 127 tiles; the edges that don't fit go
by whole cell. Over the 60 maps: 34,895 of 1,586,793 pixels on the wrong
side (2.2 %); in the spring plaza 2,250 of 84,145 (before 5,831).
Seen in the bar (28): the hero passes between the beams.

### Colour math: measured, it doesn't go

* It doesn't reach all the characters: the hardware does colour math on
  objects only with palettes 4 to 7, and in the spring plaza there are objects
  with palettes 0, 3, 6 and 7 on screen.
* There is no VRAM for the mask: with the slots, 1,024 words remain
  ($5C00-$5FFF): a 32x32 tilemap without tiles, or tiles without a tilemap.
* The painting doesn't need it: shadows, lights and fogs go blended in, and with
  one tile per cell they come out as they are.

To do it, the converter would have to give the characters on those maps
palettes 4 to 7 and the roof edges would have to give up half of BG2's
tiles. Written in the book: [`ports/sunset-over-imdahl/research/2026-10-11-mode-1-for-the-painted-maps.md`](https://lautarodragan.github.io/the-advocate-docs/ports/sunset-over-imdahl/research/2026-10-11-mode-1-for-the-painted-maps.html).

### Captures

`/shared/capturas/2026-10-11-sunset-modo-1/`: original / main / mode 1 on
2, 13, 28, 33, 7 and the scene on 22, with its `LEEME.txt`.

### To merge

Branches `mulita-sunset-modo-1`: the-advocate `0bb1120a` (with `origin/main`
e9a9488f merged; the merge required importing `block` in mapdata's `panorama.rs`,
which Tijereta had changed to `msu_block`), ports `6048425`
(with c1a3966), book `5d696e9`.

Reinstall: **`project`, `wally`, `mapdata`, `convert` and `cartridge`**
—the runtime changed and `cartridge` and `convert` carry it compiled in; `project`
because of the merge, not because of this—.

On the merge, with those tools: A Blurred Line's suite **1202 passed**, and
`abl.sfc` **24dd24adb52f…**, same as main. The painted maps part isn't
run by any test: ABL has none, and Sunset has no cases. What
covered it is `modo1/chequear.py` (VRAM against the `.inc`, frame by frame) and
the captures.

What remains:

* A turn back of the camera with a half-uploaded row uploads it whole in
  that tick, and in the plaza that cost a lost frame.
* Plazas and streets with more than 127 roof edges: the rest goes by cell
  (2.2 % on the wrong side in total). 256 could be given by moving the base
  of BG2 and the window to index 256.
* The colours: 7 palettes of 15 per map.
* The characters without shadow or light (see colour math, above).
* If a game with painted maps asks for `[rom] msu = "required"`, the painting's
  tiles stay in the ROM (they are ordinary `.block`s, not `msu_block`):
  not tried.
