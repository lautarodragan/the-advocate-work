---
name: "Translate the tools into English, phase 1: snes_convert"
description: "Comments, docstrings, messages and prose into English, without touching code names: tools/port/snes_convert.py, whole"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: "translate the tools into English". It's
AGENTS.md's rule for the separate projects, which now reaches all of `tools/`
(see `workflow/decisiones/las-herramientas-se-separan-de-abl.md`).

**Phase 1**, split among four agents by area: comments, docstrings, error
messages, `help=` and prose. **Code names aren't touched** —modules,
functions, variables, runtime symbols, flags—: that's phase 2, one area at a
time, because a name changes in everything that imports it. The terms come
from `tools/GLOSSARY.md`.

Scope of this part: tools/port/snes_convert.py, whole.

## How it's done

By stretches of the file, each in its own commit. For each stretch the AST of
the old file is compared against the new one, with docstrings and strings
removed: it has to come out equal, and the strings that change are listed and
looked at by hand one by one. Then `SIN_CACHE=1 just cartuchos` and the
sha256 of all of `rom/build/` except the cache, the `.o`s and the stamp,
against the baseline taken before touching anything.

## Progress

- Lines 1–2580 (from the header to the message window): done. The `.sfc`,
  `.msu`, `.pcm`, `.inc` and `.dbg` come out identical: in this stretch there
  are no comments that go into the `.inc`.
- Lines 2581–4042 (from `convert_ventana` to `bloque`): done. `.sfc`, `.msu`
  and `.pcm` identical; both `mapdata.inc` change —only in comments— and the
  `.dbg`s —only in line numbers and sizes—.
- **A comment in the `.inc` stays in Spanish because it's data**: the
  `; --- N: mapa M 'nombre' ---` of `mapa_tabla`, which `mapas_de` in
  `rom/pruebas/arnes/consola.py` reads with a regex that expects "mapa". A
  comment next to it says so.
- Lines 4043–5419 (from `tabla_de_paginas` to the middle of `emit`, with the
  `.inc`'s header): done. `.sfc`, `.msu` and `.pcm` identical. The
  `mapdata.inc` without comments come out equal except for the text of
  `TITULO_MENU_CGRAM`'s `.assert`, which is an assembler message. The `.dbg`s
  change ids as well as lines —ld65 numbers the `line`s in line order—, so
  they're compared by resolving ids: identical.
- Lines 5420–6768 (the rest of `emit`: shop, game over, texts, items,
  equipment, skills, troops, encounters, battle): done, with the same checks.
- Terms: aligned with the ones Coronillo chose
  (`scratchpad/glosario-coronillo.md`): "hornear" is *bake*, "aire"
  *headroom*, "cuadro de texto" *text box*, "cobrar" a rule *enforce*.
  "La tanda lo cobró" became *the suite caught it*.
- Lines 6769–8296 (the RAM constants, `eventos_movibles`, the `argparse`
  flags and `main` up to the music): done. Kept as data: the package names
  (`"pelea"`, `"gameover"`, `"titulo"`), the allocator's image names
  (`"fondo"`, `"encima"`) and the name of the made-up event (`"prueba"`).
- Lines 8297–9550, to the end: done. With `test_lz2.py`, which compared two
  messages from `controlar_flujos`.
- Section titles of other files in `tools/port/` remain cited in Spanish
  ("Qué fondos hay", "lo que depende del actor", "la pantalla de ítems", "las
  variables de RM2k"): Cina translates them, and they get aligned when
  merging.

## Wrap-up

Merged `main` (`5e652dc2`, with Coronillo and Palmar) and verified on the
merged tree: `SIN_CACHE=1 just cartuchos` gives the 47 `.sfc`, `.msu` and
`.pcm` identical to the baseline; `just pruebas` 874 green and
`just -f tools/justfile pruebas` 132 and 2 skipped.

What to look at: nothing plays differently —the ROM is the same byte for
byte—; what changes is the text of the converter, of `mapdata.inc` and of
what the build prints.
