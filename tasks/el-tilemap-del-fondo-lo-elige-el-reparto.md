---
name: "The layout picks the background's tilemap"
description: "A fourth VRAM layout that moves BG1's tilemap down to $1800 and makes room for map 38"
type: refactor
status: done
---

Option (d) of question 2 about map 38 in `lashe-city-hasta-la-carrera.md`:
that the converter pick BG1's tilemap address per map, as it already picks
`OBSEL` and `BG12NBA`. Measured and implemented on 2026-09-25 on `dd73115`.

## What was measured

**Map 38 asks for 476 background tiles and 347 sprite tiles** (the converter
prints it with `--map-id 38`). The three layouts there were gave 448/448,
480/256 and 384/512.

**The ceiling, enumerating every base the hardware allows** —sprites in steps
of $2000 words, backgrounds in steps of $1000, tilemaps in steps of $400;
overlay and window together on BG2; the overlay's tilemap fixed at $7800—.
The script was throwaway; what comes out:

    sprites                           256   320   384   448   512
    background, free tilemap          544   512   480   448   416
    background, tilemap at $5800      544   512   480   448   416
    same, respecting the slots        544   512   448   448   416

"Respecting the slots" means that `RANURA_VRAM..RANURA_MAP+1024`
($2000..$4000) doesn't overwrite anything `volver_al_mapa` doesn't restore
(sprites, BG2, the tilemaps).

So **moving the tilemap doesn't shift the ceiling**: for 347 sprites the
maximum is 480 wherever it is. What changes is the third row. With the tilemap
pinned there's a 480/384 —sprites at $4000, background at $0000, the window's
tilemap at $3C00— but that tilemap lands right on `RANURA_MAP`, and coming back
from the menu or the slots would leave it overwritten. With the tilemap free,
the 480/384 that respects the slots is:

    sprites     $0000  384 tiles     mapa        $1800  BG1's tilemap
    tiles       $2000  480 tiles     ventana_map $5C00
    encima      $6000  128 tiles     ventana     $6800  256 tiles
    overlay tilemap $7800

**Map 38 has 4 background tiles and 37 sprite tiles to spare.** 480 and not
the ~483 of the count in bytes because the window's tilemap needs a base that
is a multiple of 1024 words after the background: the background ends at
$5C00 at most.

The alternative without moving the tilemap —sprites at $4000 and having
`volver_al_mapa` upload the window's tilemap again when it lands on
`RANURA_MAP`— would give the same, with the cost in `volver_al_mapa` and not
in the streaming. It wasn't chosen because what was asked for was (d), and
because its cost would be paid by another contract (`_controlar_ranuras`)
instead of an addition.

**Two of today's layouts are below the ceiling**: "+fondo" could give 544 and
"+sprite" 416. Raising them changes the layout of the maps that already use
them, so it doesn't go here; it's noted in `docs/port/vram.md`.

## Who assumed $5800

Everything in `rom/src/`, plus the harness:

| where | what it did | how it ended up |
|---|---|---|
| `arranque.s`, `ppu_init` | `lda #>VRAM_MAP \| MAP_LAYOUT` to `BG1SC` | no longer writes it: the map sets it, like `BG12NBA` |
| `cargar_mapa.s`, `puesto` | — | copies `M_VRAM_MAP` to `FAR_VRAM_MAPA` and builds `BG1SC` |
| `cargar_mapa.s`, `volver_al_mapa` | `BG1SC` came from `ppu_init` | builds it from `M_VRAM_MAP + 1` (the battle leaves it at its scene's) |
| `ventana_del_mapa.s`, `build_column` | `adc #VRAM_MAP` | `adc f:FAR_VRAM_MAPA` |
| `ventana_del_mapa.s`, `build_row` | `adc #VRAM_MAP` | `adc f:FAR_VRAM_MAPA` |
| `ventana_del_mapa.s`, `limpiar_tilemaps` | `ldx #VRAM_MAP` | reads it from `FAR_VRAM_MAPA` |
| `vblank.s`, `push_una_columna` | `adc #(VRAM_ABOVE_MAP - VRAM_MAP)` | `and #$07FF` / `ora #VRAM_ABOVE_MAP` |
| `vblank.s`, `push_una_fila` | `lda #(VRAM_ABOVE_MAP - VRAM_MAP - 1024)` | `and #$03FF` / `ora #VRAM_ABOVE_MAP`, and enters through `fila_en_a` |
| `pruebas/arnes/consola.py`, `ventana` | read the `VRAM_MAP` symbol | reads `FAR_VRAM_MAPA` from WRAM |

No precomputed table nor hidden arithmetic: they were seven uses of the
constant in the ROM, two of them as the distance between the two tilemaps.
Everything else that touches tilemaps doesn't look at the background's: the
battle scene has its own (`ESCENA_MAPA`, $3800) and `volver_de_batalla`
restores it with `fill_window`; the title, the menu and the slots use
`TITULO_MAP` and `RANURA_MAP`; the message window already read its tilemap
from the record (`M_VRAM_VENTANA_MAP`); the HDMA and `vblank.s` only rewrite
`BG2SC`.

The steps to the overlay layer mask instead of adding a distance, which would
depend on the map. That requires both tilemaps to start at multiples of 2048
words: an `.assert` in `vblank.s` for the overlay's, `_controlar_repartos` for
the background's, which also refuses a tilemap at $0000 (`col_addr` at zero
means "no column").

**The map record was at exactly its 128 bytes**, so `M_VRAM_MAP` takes the
place of `M_VRAM_ABOVE`: BG2's base is the high nibble of `BG12NBA_VALUE`, and
`load_above` takes it from there. It was $6000 on every map.

**`FAR_VRAM_MAPA` is $7E6B80**, the word that follows the spare strips: the
BSS and the direct page are full. **It's a far RAM address chosen by looking
at this copy**: when merging, check that no other branch has taken $6B80.

## The cost in cycles

With the accumulator in sixteen bits:

* `build_column` and `build_row`: `adc #imm` (3) becomes `adc long` (6), **+3
  cycles per row or column built**, one more byte each.
* `push_una_columna`: `clc` + `adc #` (5) becomes `and #` + `ora #` (6), **+1
  cycle per column uploaded**, in vblank.
* `push_una_fila`: `lda #` + `jsr` + `clc` + `adc abs` (16) becomes `lda abs`
  + `and #` + `ora #` + `jsr` (17), **+1 cycle per row uploaded**, in vblank.
* Per map load, some forty cycles between `puesto`, `limpiar_tilemaps` and
  `load_above`; in `volver_al_mapa`, eleven, minus the six `ppu_init` stops
  spending.

The worst frame builds two rows and two columns: **twelve cycles in the loop
and four in vblank**.

## How it was verified

* **No map of the cartridges changed layout.** Diff of the `mapdata.inc`s of
  `release`, `test-main` and `test-special` against those of `dd73115`: the
  only thing that changes in each record is field +18, which was
  `VRAM_ABOVE` = 24576 and is `VRAM_MAP` = 22528 in the 76 records; no other
  field, neither `OBSEL_VALUE`, nor `BG12NBA_VALUE`, nor `VRAM_VENTANA_MAP`.
* **The ROMs don't come out byte for byte identical, and can't**: code that
  reads a variable instead of a constant is different code, and it shifts
  everything that comes after it. What enforces it is the suite: `just
  cartuchos` + `just pruebas` green, without touching any golden.
* **Map 38 in a test cartridge in the scratchpad** (`--map-id 38
  --sin-titulo`): it converts, takes `LAYOUT_VENTANA_AMBOS` and the ROM leaves
  `FAR_VRAM_MAPA` at $1800. Running in snes9x: the screenshot looks right,
  without shifted tiles; walking, the camera moved 112 px in x and 32 in y,
  and `Partida.celdas_mal_dibujadas` gave 0 of 957; after opening the menu and
  saving through the slots —`volver_al_mapa`—, 0 differing pixels and 0
  wrongly drawn cells. With a test `ShowMessage` the window is drawn right.
* Map 38 doesn't have a baked-events problem like `PawnDoorTop`'s on 37: it
  converts on its own.

## What wasn't verified

* **No case of `just pruebas` runs the new layout**: map 38 isn't in any
  cartridge. The above is by hand, in snes9x, and nothing will run it again
  until 38 goes in (the Lashe City stage).
* **A battle on 38**: `volver_de_batalla` restores `BG1SC` through
  `volver_al_mapa`, which did run along the menu path; the battle itself
  didn't.
* **bsnes**: `test_cores.py` runs on the usual cartridges, at $5800.
  `FAR_VRAM_MAPA` is written when the map loads, before any read, so WRAM
  garbage shouldn't reach it.
* **Real hardware.**
