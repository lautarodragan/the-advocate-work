---
name: "Translating the tools, phase 2: the lower layers"
description: "The code names of tools/common (formerly comun), rpgmaker, render and emulator (formerly emulador) into English, with all their uses"
type: refactor
status: done
assignee: taro
---

Phase 2 of translating `tools/` into English (taro, 2026-09-29): the code
names, from the bottom up, one area at a time. This is the first one:
`tools/comun/`, `tools/rpgmaker/`, `tools/render/` and `tools/emulador/`, with
all their uses in `tools/` and in `rom/pruebas/`. The folder names too:
`comun` → `common`, `emulador` → `emulator`.

## How it is done

One module per commit, and each one verified on its own: `SIN_CACHE=1 just
cartuchos` with the `.sfc`, `.msu`, `.pcm`, `.inc` and `.dbg` (without the
date) identical to those of `c60949e0`, `just tests`, `just -f tools/justfile
pruebas`, pyflakes without new warnings, and a check that each
`modulo.nombre` of these packages exists. The renames are done by a script by
tokens —not by text—, so it does not go into the strings: what is data is not
touched, and the strings that are code (a path, an `import` inside a `-c`) are
searched for separately with grep.

## Done

1. `comun/` → `common/`, the folder alone.
2. `project.py` → `project.py`, with `--proyecto` → `--project`.
3. `perillas.py` → `settings.py`.
4. `ambiente.py` → `environment.py`, with `--reemplazos` → `--replacements` and `--compartido` → `--shared`.
5. `cache_disco.py` → `disk_cache.py`.
6. `paralelo.py` → `parallel.py`.
7. `rpgmaker/recursos.py` → `rpgmaker/resources.py`.
8. `rpgmaker/fork.py`, its names.
9. `rpgmaker/lcf.py` and `rpgmaker/event_codes.py`, their names, with the Spanish attributes of the game's classes.
10. `rpgmaker/rm2k.py`, its names, and the two attributes the render puts on the map: `chipset_nombre` → `chipset_filename` and `pasabilidad_tiles` → `passability_table`.
11. `render/render_map.py` and `render/chipset.py`, their names.
12. `render/chipset_del_fork.py` → `render/chipset_recipe.py`: what it does is apply the fork's recipe to the PNG.
13. `emulador/` → `emulator/`, with `retro.Consola` → `retro.Console` and its methods.
14. What was left: `nodo` in `lcf.py`, `tools/README.md` and the pending MSU-1 task, which cited the old names.
15. The test files of `tools/pruebas/` and their functions, into English.
16. Two citations in prose that remained in `snes_convert.py` and `parches.py`.

The `.sfc`, the `.msu` and the `.pcm` come out identical to those of
`c60949e0` in each commit. The `.dbg` files change from 10 onwards in a single
thing: the `size` of `animacion_del_chipset.s`, whose comment cites a name
from here.

## What was left untranslated, on purpose

It is all data or belongs to another area:

* **The keys and values that are in the game's files or that something else
  reads**: those of `rom/data/`, those of the fork's ChipSet recipe (`podar`,
  `from_image`, `cabeza`…), the `arbol` of a new map, the cache categories
  (`capas`, `brr`, `muestras`, `msu`), the CharSet suffixes (`~trama`,
  `~horneado`, `~aparte`), the names of the patterns (`damero`,
  `cinco_de_ocho`…), the families `agua` and `animado`, the output folder
  `patches-manual/`.
* **The keys of each NPC's dictionary** that `rm2k.collect_npcs` builds
  (`event`, `cambia`, `graficos`, `tile_pasa`, `velocidad`…): they are the
  interface with the converter, which reads them in `port/`. They change with
  that area.
* **The environment variables** `SIN_CACHE`, `TRAMA_PATRON` and
  `MODO_TRANSLUCIDO`: they are an interface like a flag, but `SIN_CACHE` is
  used by `AGENTS.md` and by the verification of all this. Left to decide.
* **`envolvente`** in `test_music_stream.py`: it overrides the method of
  `snes_music.Banco`, which belongs to `audio/`.
* **The variables and constants inside the tests of `tools/pruebas/`**: the
  request asked for the files and the functions.
* **The homonyms from other areas**: `battle.py` has its `self.activos`,
  `eventos.py` its `estado.lider()` and its `self.donde`, `Partida` its
  `correr` and `imagen`, and the runtime its routines `cargar_mapa` and
  `grafico_de_pagina`.

## For taro

* `AGENTS.md` still names `tools/comun/cache_disco.py` (now
  `tools/common/disk_cache.py`), the flags `--reemplazos` and `--compartido`
  (now `--replacements` and `--shared`) and
  `test_ningun_opcode_comparte_numero_con_otro` (now
  `test_no_opcode_shares_a_number_with_another`). I did not touch it: it is
  the rules file.
* None of this is played: the `.sfc` are the same bytes.
