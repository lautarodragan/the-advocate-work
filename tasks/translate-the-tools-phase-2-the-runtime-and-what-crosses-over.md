---
name: "Translate the tools, phase 2: the runtime and what crosses over"
description: "The runtime's symbols, labels and files into English, together with what the converter writes into the .inc files, the tests that read symbols by name, and the data that had stayed in Spanish"
type: refactor
status: done
assignee: taro
---

The last area of phase 2 of the translation of `tools/` into English. It's the most
coupled one: the converter writes symbols into the `.inc` files, the runtime uses them
by name, and ABL's tests read the runtime's symbols by name.

Hornero decided (with taro's authorisation to decide without waiting for him)
that the data that had stayed in Spanish because it was the
interface between two programs also goes here: the `; Temas:` line of `musicdata.inc` and whoever
reads it, the keys of `rm2k.collect_npcs`, the `aire_de_medida` key of
`ceilings.toml` (by hand, without re-measuring), the comments that
`patches.py` writes into `rom/parches/auto/` (with `just patches`), and the
variables `SIN_CACHE`, `TRAMA_PATRON` and `MODO_TRANSLUCIDO`. What goes into the
ROM and what belongs to the game isn't touched: the `.sfc` comes out the same.

## How it was done

With an old → new mapping of the ~4300 assembler identifiers
that had some Spanish word (runtime and generated `.inc` files), built
word by word with a dictionary and corrected by hand where the
result didn't read well or clashed. The replacement is per `ca65` token
—code, without touching strings or `.include`— and, in comments, only what goes
between backticks, has a `_` or is in capitals. In Python and in the
tests, only inside strings and comments; a lone lowercase word
only if it's the lookup of a symbol (`simbolos["oro"]`,
`.palabra("vueltas")`), because in a Spanish docstring it can be something
else.

Each commit was verified the same way:

* `SIN_CACHE=1 just cartridges` with `rom/build/release` and `rom/build/tests`
  deleted beforehand: `.sfc`, `.msu`, `.pcm` and everything else in `rom/build/`
  identical byte for byte to `319a322a`'s, except `.inc`, `.sym`, `.dbg`,
  `memory.cfg` (the name of a segment) and the dumps
  `crudos/N.map_celdas.bin`, which were renamed `N.map_cells.bin` with
  the same content;
* the `.dbg` of the two cartridges: the same symbols, with the same scope,
  value, type and size, changing only the name according to the mapping; the `.sym`,
  the same addresses; the `.inc` files, the same code tokens under the
  mapping —which is what proves the Python emits exactly the name
  the runtime expects—;
* both suites green and pyflakes with no new warnings.

## Done

1. The global symbols, one subsystem at a time: the interpreter, the battle, the
   audio, the menus and screens, the map and the rest, the memory (low RAM,
   far RAM, zero page, registers).
2. The `BA_` and `TI_` prefixes stay, because the converter's Python
   keeps them (`screens.BA_COMMANDS`, `screens.TI_COUNT_BUY`): a first
   attempt had turned them into `BT_` and `SHOP_`, and a commit brought them back.
3. What the converter writes into the `.inc` files, on both sides. The names
   built in Python (`M_%s`, `PANTALLA_%s`, `fuente_pre%d`,
   `ranura_bloque_%s`, `BA_TXT_%s` from `rules.BATTLE_TERMS`) were done by
   hand; the battle terms went into English in `rules.py` and whoever
   reads them.
4. The local labels and the macro parameters.
5. The ones the dictionary missed (`BA_MQUIEN`, `dest_tab_r`…).
6. `.bloque` → `.block`, `.cruza` → `.crossbank` and the `TABLAS` segment →
   `TABLES`.
7. The 82 `.s` files with a Spanish name, with `git mv` and without touching a line;
   the `.include` list in `main.s` in the same order. Afterwards, in its
   own commit, the citations by file name in comments and
   documentation, and those of Python modules with names from before phase
   1 (`eventos.py`, `titulo.py`…).
8. The symbols cited by AGENTS.md, README.md, tools/README.md, docs/ and
   the decisions and divergences in workflow/.

9. The data that was interface: the `; Temas:` line of musicdata.inc
   (`; Songs:`, with `no music` and `none`) and whoever reads it; the `; --- N:
   mapa M` line of mapdata.inc (`map`) and the regex of `consola.maps_in_inc`; the
   NPC keys of `rm2k.collect_npcs` (`event`, `speed`, `animates`,
   `changes`, `graphics`, `layers`, `tile_pass`), which events.py's pages
   share in three of them.
10. The comments `patches.py` writes into `rom/parches/auto/`,
    regenerated with `just patches`: the 137 TOML files read with `tomllib` give the
    same before and after, and `just patches-check` passes. `aire_de_medida` →
    `measuring_headroom` by hand in `ceilings.toml`.
11. `SIN_CACHE`, `TRAMA_PATRON`, `MODO_TRANSLUCIDO` → `NO_CACHE`,
    `DITHER_PATTERN`, `TRANSLUCENT_MODE`, with their values (`baked`/`dither`;
    `checkerboard`, `columns`, `rows`, `five_of_eight`, `three_of_four`).
12. The columns that the renames shifted (only spaces; `git diff -w`
    empty), and the runtime's citations that pointed to Python names from
    before phase 2 or to Spanish aliases.

The protocols (`events.toml`, `music.toml`) were already in English: there was
nothing to regenerate. No script changed name: `install-scripts` isn't
needed.

## What stays in Spanish, on purpose or for later

* The other keys of events.py's pages and of `map_info` in the
  converter (`pagina`, `codigo`, `ruta_propia`, `graphic`, `gira`,
  `frecuencia`, `ordenes`, `cambian`, `aparecen`, `afuera`, `celdas`…),
  and those of the music dictionaries (`nombre`, `temas`, `escrituras`,
  `largo`): they're internal to the Python, from the previous areas.
* The keys of the TOML files in `rom/parches/auto/` and of `ceilings.toml` (except
  `measuring_headroom`), and the Spanish header of `ceilings.toml`, which
  comes out in English the next time `just ceilings` runs.
* The CharSet suffixes (`~trama`, `~horneado`, `~aparte`) and the name
  `capas` of the on-disk cache.
* The tasks that say `SIN_CACHE=1` or name old routines: they tell what
  was run that day.
* Some local labels came out word by word and read oddly
  (`a_faces_a`, `sia_yes`); they're local and nobody from outside sees them.
* The dumps `rom/build/*/crudos/N.map_celdas.bin` are now called
  `N.map_cells.bin`: the name comes from the same string as the label.

## `git blame`

The commit that renames the files changes nothing: `git blame -C
--diff-algorithm=histogram` of cells.s, music.s, battle_scene.s,
interpreter.s, far_ram.s and shop.s gives, line by line, the same as that of
their old names right before.

What **did** change is due to the symbol renames, and it's the limit that
AGENTS.md describes for the `main.s` split: each edited line splits in
two the chunk of identical lines around it, and the chunks left are
shorter than `-C`'s minimum, so they stop crossing the split and
stay at `391930c4` ("Partir main.s"). Measured against `319a322a`, over the
lines the translation didn't touch: in shop.s 538 give the same commit and 449
moved to the split's; in cells.s, 98 and 179; in far_ram.s, 550 and 4; in
interpreter.s and main.s, all the same. `-C3` recovers part of it (cells.s:
197 the same, 80 to the split); `--ignore-revs-file` with these commits, doesn't.
