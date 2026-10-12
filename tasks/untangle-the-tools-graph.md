---
name: "Untangle the tools/ graph"
description: "Step 1 of the research's plan: break the cycles and layer violations of tools/ by moving functions, without changing logic and with the ROMs byte for byte identical"
type: refactor
status: done
assignee: taro
---

Step 1 of the plan in [`research/the-map-of-the-python-tools.md`](https://lautarodragan.github.io/the-advocate-docs/research/the-map-of-the-python-tools.html)
(§4), approved by taro on 2026-09-28. taro authorized Hornero to move ahead
with the mechanical steps without waiting for his feedback on 2026-09-29.

In scope: items 1.1, 1.2, 1.3, 1.5 and 1.6 of the research, and 1.7 (splitting
`titulo.py`) if everything before it ended up merged and green.

Out of scope: 1.4 (`cartuchos` stops importing `port/` and `audio/`), because
what to do with `cartuchos.py` is an open question for taro (see
`decisions/the-tools-split-from-abl.md`).

## What was done (Lapacho)

One commit per item, each one a move with no new logic:

- **1.1** `GAME_DIR`, `RTP_DIR` and `find_resource` to `rpgmaker/recursos.py`.
  `audio/` stops importing `render/`.
- **1.2** `TILE`, `caja_de_terreno`, `caja_de_comun`, `SPRITE_*` and
  `OFFSET_*` to `rpgmaker/rm2k.py`. `render/charset.py` was left empty and
  deleted.
- **1.3** `lcf`↔`fork`: the image part of `fork` moves up to
  `render/chipset_del_fork.py`, the option the research preferred. The other
  one —having `fork` receive the `Map`— changed a signature; this one is only
  a move. `rpgmaker/` no longer loads PIL.
- **1.5** The seven moved ones, to four new modules of `port/` that import
  nothing from the port (except `paleta`, which imports `constantes`):
  `reglas`, `constantes`, `color` and `paleta`. Importing `eventos` no longer
  loads PIL, numpy or `render_map` (measured with `sys.modules`).
- **1.6** `pack_tile`, `cgram_word` and `entry` to `port/formato_snes.py`.
- **1.7, half of it**: `titulo.py` is cut into `titulo.py` (the title screen)
  and `menus.py` (slots, pause, items, choosing whom). Neither half uses
  anything from the other, measured in the AST.
- Prose: `tools/README.md`, the layers and the cycles.

Verified on each item: `SIN_CACHE=1 just cartuchos` gives identical the files
of `rom/build/release/` and `rom/build/tests/special/` that are compared —the
`.sfc`, the `.msu`, the tracks, the `.inc`s, the `.sym`, the
`conversor.log`, and the `.dbg`s without the sources' `mtime`s—. Not compared:
the `.o`s, which carry inside them the `mtime`s of the regenerated `.inc`s,
nor `sello.txt`, which carries the fingerprint of the `.py`s and changes on
purpose. `just pruebas` and `just -f tools/justfile pruebas` green on every
commit from 1.3 on; on 1.2, only the ROM.

Appendix D's script, on the final tree:

    ## VIOLACIONES DE CAPA
    ensamblado.cartuchos:31 -> audio.muestras_brr [import]
    ensamblado.cartuchos:33 -> port.tiles_bin [import]
    ensamblado.cartuchos:34 -> port.comprimir [import]
    ensamblado.cartuchos:148 -> rpgmaker.lcf [lazy]
    ensamblado.cartuchos:260 -> audio.snes_music [lazy]
    ensamblado.cartuchos:482 -> audio.msu [lazy]
    ensamblado.cartuchos:416 -> port.snes_convert [ruta]

    ## CICLOS
    import + lazy + ruta SCC: ensamblado.cartuchos, port.parches, port.snes_convert

Without the `ruta` class no cycle remains, and all the violations are
`cartuchos`'s, which is 1.4.

### The cache key

**One** file went into `_version_capas`'s list: `rpgmaker/recursos.py`,
because `render_map` finds the ChipSet with `find_resource`, and that code
was part of the key by living in `render_map.py`. The other new modules
don't go in: either they come from files that weren't in the list (`fork`,
`eventos`, `titulo`, `pantallas`, `batalla`), or what's cached doesn't use
them (`formato_snes`: measured by walking `capas_convertidas`'s calls in the
AST). `cartuchos`'s fingerprint covers them on its own, with its glob of
`tools/*/*.py`.

### What didn't go in, and what was left to look at

- **1.4**, for the reason stated above.
- **The other half of 1.7: the menus' font separately.** It isn't a move.
  The items screen's font (`pantalla_items`, `texto_de_item`,
  `ITEM_BLANCO`…`ITEM_ROJO`, `ITEM_PRIMER_CARACTER`, `ITEMS_TILES_MAX`) and
  the frames (`marcos`, `ITEM_MARCO_CGRAM`) are intertwined with that
  screen's geometry in the same comment blocks, they're called `ITEM_*`, and
  `_bloque_de_celdas` is also used by the slots. Separating them requires
  deciding where each constant goes and probably what it's called: it's
  judgement.
- **`BA_TERMINOS` went to `reglas` with `terminos_batalla`**, because the
  function walks it. But it's also the order in which the ROM reads the terms
  (`ba_vic_mensaje`), so where it lives is debatable.
- **`pack_tiles`**, the numpy one, stays in `snes_convert`: it didn't close
  any cycle. It's a candidate for the next cut of `snes_convert`.
- **Two comments name the old thing** and weren't touched: the one
  `snes_convert` writes into `mapdata.inc` ("lo que depende del actor' en
  titulo.py"), because changing it changes the `.inc` that was being
  compared byte for byte, and the one at `rom/src/registros.s:39`
  (`eventos.tenir`, which is now `color.tenir`), because `rom/src/` wasn't
  being touched. Two tasks of `wishlist/` also name the old thing:
  `declarative-tests` and `inventory-images-to-tiles-in-python`.
- **Three unused imports that were already there before**: `ELEGIR_CURSOR`
  in `pantallas`, `collections` in `imagen` and `load_image` in
  `snes_convert`.
