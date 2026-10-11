---
name: "Inventory: images to tiles in Python"
description: "Which image-to-tiles conversions are still in Python and which ones Voodoo can do"
type: refactor
status: wishlist
---

**Count which image-to-tiles conversions are still done in Python**, and for
each one, whether Voodoo can do it with its current contract: an indexed PNG
going in, tiles, palette and tilemap coming out, without deciding colours.

Voodoo already converts the maps' upper layer, since step 8c. What
is known to still be in Python: the battle scene builds its tiles in
`tools/port/escena.py`. There are probably more —sprites, font, window,
title, animations—, and they haven't been counted.

It is only measuring: for each one, what it does, whether it fits Voodoo's contract, whether
the ROM comes out byte for byte the same when going through Voodoo, and how much Python would go away.

## What was measured

Measured on 2026-09-22 on `deaf3be`. **The numbers are from that day**: they
are redone with the probe and the two prototypes, which stayed in
`/extras/scratch/inventario-voodoo/` and not in the repo:

    sonda.py                wraps each conversion, lets it do its thing, and
                            passes its same cells through `voodoo` to compare
                            tiles and tilemap. It runs with the arguments of
                            `just cartuchos release` and writes nothing in the tree.
    prototipo-menu.diff     the title menu through Voodoo
    prototipo-titulo.diff   the title picture through Voodoo
    comparar.sh             `just cartuchos release` + `just cartuchos` and `md5sum -c`
                            against the four ROMs of `deaf3be`

The maps' two layers —the lower one with its animations, the upper one— already
go through Voodoo (`tiles_bin.convertir`, in `_convert_layers` and
`convert_above`), so they aren't in the table. Everything else that writes tiles
ends up in `pack_tile` in `snes_convert.py`, which has **eleven callers**:
those are the rows of the table, plus three encodings that aren't tiles.

### What Voodoo lacks, by class

What comes out of the probe is that the conversions split into three classes, and the
class says more than the row:

* **Deduplicate with a tilemap**, which is Voodoo's model. They differ in details
  that don't change a pixel: Voodoo **reuses a mirrored cell** with the tilemap's
  flip bits, and Python never does; and in the slot screen and
  the items screen Python **shares a tile between two palettes** —it deduplicates by
  index, not by colour—, and Voodoo at 4bpp requires the same palette. Only one
  fits as is today: the title menu.
* **Fixed order, without deduplicating**: poses, timer digits, sign,
  battle animations, scene background, the run of the window's text
  area. There each cell has to be its own tile, in a place the
  ROM already knows —a pose is uploaded with four 128-byte DMAs, an
  animation frame is 64 fixed tiles, the scene composes the battlers over the 512
  tiles of the background—. **Voodoo lacks a non-deduplicating mode**: one cell, one
  tile, in row order, without a reserved tile 0 and without flips. It isn't a
  decision that shows —it is bookkeeping, and `render` would keep returning the
  same indices—, so it doesn't clash with "doesn't decide colours". Where each
  tile goes in OAM's grid of 16 is still the caller's, which is what
  Voodoo's README says in "What is deliberately not here".
* **They aren't tiles**: the battlers, the font and its prerender. Those don't go to
  Voodoo in any mode.

And a separate one, only for sprites: **at 4bpp Voodoo rejects palettes 8 to
15**, because a tilemap has three palette bits. The sprites live right there
—CGRAM 128 to 255—, so a sprite PNG with its real CGRAM entries
doesn't fit. The probe passed them with indices from 0 to 15, which is what `pack_tile`
receives, but that breaks "the indices are CGRAM entries". For objects
Voodoo would need to know that an object's palette goes in OAM, not in a
tilemap.

### The table

Ordered by what is worth doing first. "Cells → tiles" is what the
probe gave: how many cells Python passed to `pack_tile` and how many tiles Voodoo gets
from the same ones. "Python that goes away" is lines of code without comments, blanks
or docstrings, counted with `ast`: **net** where there was a prototype, and where there
wasn't, those of the cut that would disappear, knowing that building the PNG eats part of it.

| # | Conversion | Where | Class | Fits today? | What it lacks | ROM through Voodoo | Python that goes away |
|---|---|---|---|---|---|---|---|
| 1 | Title menu: the two variants with the cursor, one bank | `titulo.menu` | dedup | **Yes** | nothing | **Same** in the four ROMs (prototype) | −7 net (18 in, 25 out) |
| 2 | Title picture, 8bpp | `titulo.convertir` | dedup | **Yes**, with `--no-blank-tile` | that `tiles_bin.convertir` pass that flag | **Different**: 496 → 486 tiles, 22 flipped cells; `abl` and `juego` change. The 4 title goldens, **pixel for pixel the same** | +1 net (12 and 11); saves 640 bytes of ROM |
| 3 | Message window: the frame | `convert_ventana` | dedup | Yes, the frame | nothing for the frame | Different: the probe, with the whole window, gives 11 flipped entries | part of the cut's 29 |
| 4 | Message window: the 240 tiles of the text area | `convert_ventana` | fixed | No | non-deduplicating mode: 240 cells give 3 tiles | — | part of the cut's 29 |
| 5 | Slot screen and pause menu, with the faces | `titulo.pantalla_ranuras` + `_bloque_de_celdas` | dedup | Almost | sharing tiles between palettes; 244 empty cells that Python writes with their palette Voodoo writes as 0; the many-layer blocks have to be stacked in one image and the tilemap cut again | Different: 344 → 341 tiles (3 flips beat what it loses on palettes), 404 of 3890 entries change | up to 24 (`_bloque_de_celdas`), shared with 6 |
| 6 | Items screen: the font in white and in grey | `titulo.pantalla_items` + `_bloque_de_celdas` | dedup | Almost | sharing tiles between palettes: without that it's 307 → 315 tiles; 10 empty with a palette | Different | same as 5 |
| 7 | CharSet poses, VRAM and cartridge bank | `pose_tiles` (`build_characters`, `banco_de_poses`) | fixed | No | non-deduplicating mode **and** object palettes (8 to 15) | — (with the mode, 32,928 cells; Voodoo today merges them into 17,209 tiles with 995 flips) | up to 20; the colour mapping stays |
| 8 | Timer digits, 11 glyphs of 8x16 | `digitos_del_timer` | fixed | No | non-deduplicating mode, object palettes | — (638 → 522, 87 flips) | up to 14 |
| 9 | `ShowPicture`'s sign | `imagen.celdas` + `cartel_de_imagen` | fixed | No | non-deduplicating mode, object palettes | — (96 → 89) | up to 19 + 3 |
| 10 | Battle animation frames | `animacion.celdas` + `animaciones_asm` | fixed | No | non-deduplicating mode, object palettes | — (15,744 → 1,252 in 246 frames) | up to 13 + 4 |
| 11 | Battle scene background, 512 8bpp tiles | `escena.tiles` | fixed | No | non-deduplicating mode | — (1,536 → 1,515 in 3 backgrounds) | up to 7 + 4 |
| 12 | Raindrops, 6 tiles | `gotas_de_lluvia` | fixed | By chance | there is no image: the pixels come from `eventos.lluvia_pixeles` | The 22 groups give identity and the same bytes, but because the 6 cells are distinct, not by contract | ~0: a PNG would have to be fabricated |
| 13 | Scene battlers | `escena.battler_bytes` | not tiles | Doesn't go | mask and 4 planes per row, reversed, so the ROM overlays them | — | 0 |
| 14 | The font: 1bpp per row and the tables per phase | `fuente_bytes`, `fuente_prerender` | not tiles | Doesn't go | — | — | 0 |

`pack_tile` (9 lines) goes away only when its last caller goes away, that is,
with the non-deduplicating mode and rows 4 and 7 to 11 in.

What was run for each column:

* **Rows 1 and 2**: the prototype applied in the tree, `just cartuchos release` and `just
  cartuchos` —the four rebuilt, `armado` in the three test ones—, and
  `md5sum` against the four ROMs of `deaf3be`: `abl`, `pruebas`, `chico` and
  `juego`. Of those, the ones with a title are `abl` and `juego`. For 2,
  also, `pytest pruebas/rpgmaker/test_tanda_pantallas.py -k titulo`: 4
  green against the goldens, which are compared exactly.
* **The rest**: only the probe, on the arguments of `just cartuchos release`. Where the
  probe already gives different tiles or tilemap, the ROM comes out different without building it;
  where a mode is missing, there is nothing to build.

### Two things that came out along the way

* **That the menu comes out the same is a fact of the data, not of the contract.** Today
  no cell of the menu is a mirror of an earlier one; if a new text had
  one, Voodoo would flip it and the ROM would change, with the same pixels.
* **`titulo.render` and `titulo.informe` have no callers**: `grep` in
  `tools/` and `pruebas/` finds none. They are from the reference's era;
  that's why the row 2 prototype didn't have to teach flips to `render`.

### Where to start

1. **The title menu**: it fits as is, the ROM comes out the same and code goes away.
2. **The title picture**: it fits with a flag that `tiles_bin` almost has already,
   the screen is the same and it saves ROM. It changes the ROM, so it goes with the
   title goldens in view.
3. **The non-deduplicating mode in Voodoo**, which is the one that unblocks most: 4,
   7 to 11 and finally `pack_tile`. It is work in `tools/snes/voodoo/`, in English, and
   for sprites it goes together with object palettes.
4. **Sharing tiles between palettes**, for slots and items. It is the one that pays
   off least: the tile count hardly moves and stacking blocks in one
   image is new code on the caller's side.
