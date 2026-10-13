---
name: "Translating the tools, phase 2: port/"
description: "The code names of tools/port/ (the converter in Python) into English, with all their uses"
type: refactor
status: done
assignee: taro
---

Phase 2 of translating `tools/` into English, third area: `tools/port/`,
the converter in Python —`snes_convert.py`, `eventos.py`, `battle.py`,
`menus.py`, `screens.py`, `parches.py` and the rest—, with all their uses in
`tools/` and `rom/pruebas/`. The constants and symbols that the converter
emits to the assembler (what it writes into the `.inc`s) do **not** go in: they belong to the
last area, together with the runtime.

## How it goes

One module or a small group per commit, from the leaves towards
`snes_convert.py`. Each commit: `SIN_CACHE=1 just cartridges` with all of
`rom/build/` (except `cache/`, `.o`, `stamp.txt` and the mtime of the `.dbg`s)
byte for byte the same as at `a6fd0d19`, `just tests` and
`just -f tools/justfile test` green, pyflakes with no new warnings and the
`rm2k-snes-*` executables working from `/tmp`.

1. `constantes` → `constants`, `formato_snes` → `snes_format`, `comprimir` →
   `compress`, `fuente` → `font`, `reglas` → `rules`, and the names in
   `color`.
2. `asignador` → `allocator`, `msu_datos` → `msu_data`, `paleta` →
   `palette`, `experiencia` → `experience`, and the names in `tiles_bin`.
3. `window` → `window`, `imagen` → `picture` (the `ShowPicture` sign),
   `pantalla_completa` → `fullscreen`, `title` → `title`, `fin_del_juego` →
   `end_game`.
4. `escena` → `scene`. `snes_convert` also uses it through a local alias
   (`E = escena_mod`), which no rename by import sees: only the
   build caught it.
5. `parches` → `patches`, the one behind `rm2k-snes-patches`: its symlink in
   `tools/justfile`, and the namedtuple `Clase` → `Kind` with its fields. Its
   flags were already in English. The TOMLs it writes don't change: `just
   parches` rewrites them the same.
6. `eventos` → `events`, the page compiler: its ~440 names, its
   classes (`Temas` → `Songs`, `Eventos` → `MapEvents`, `Mensajes` →
   `Messages`, `Imagenes` → `Pictures`, `Tropas` → `Troops`,
   `PaginasDeTropa` → `TroopPages`, `Encuentros` → `Encounters`, `Estado` →
   `PartyState`, `NoSePuede` → `CannotCompile`, the namedtuple `Disparo` →
   `Trigger`) with their attributes and methods, renamed only on the bases
   that really use them (`temas.`, `mensajes.`, `del_mapa.`…), because
   `.mapa`, `.nombre` or `.paso` also belong to other objects.

   The constants that have the same name as an assembler
   symbol (`ORO_MAX`, `TECLA_DECISION`, `TRIGGER_AUTOMATICO`…) were also
   translated: the `.inc` writes them with a string, which doesn't change. The
   runtime keeps calling them in Spanish until the last area, which can
   use the Python names as a guide.
7. `animation` → `animation` and `textos` → `texts`.
8. `battle` → `battle`, the battle model the tests compare
   against: `Batalla` → `Battle`, `Combatiente` → `Combatant`, `Azar` →
   `Rng`, with their attributes and methods also on the side of ABL's
   tests (`esperado.jugar_turno` → `esperado.play_turn`). Three things that
   no rename by import sees and the suites caught: the local alias `B =
   batalla_mod` in snes_convert, a `**extra` in the harness that passes
   `paginas=` to `Battle`, and a `getattr(enemigo, "botin_item")`.
9. `menus`: its names into English (`pantalla_ranuras` → `slots_screen`,
   `render_objetivo` → `render_target`, the constants `ITEM_*`, `MENU_*`,
   `OBJETIVO_*` → `TARGET_*`…), also through the local alias `T = menus_mod`
   in snes_convert.
10. `pantallas` → `screens`: equipment, shop and battle (`pantalla_tienda` →
    `shop_screen`, `Texto` → `TextGrid`, the constants `BA_*`, `EQ_*`,
    `TI_*` with their prefix), also through the local aliases `P` and `PM` in
    snes_convert.
11. The converter's flags: `--relleno-de-textos` → `--text-padding`,
    `--sin-titulo` → `--no-title`, `--aire-de-medida` →
    `--measure-headroom`, `--hp-de-enemigos` → `--enemy-hp`, `--sin-timer` →
    `--no-timer`, `--grafico-de-prueba` → `--test-graphic`,
    `--encuentros-de-prueba` → `--test-encounters`, `--heroe-encima` →
    `--hero-above`, `--grupo` → `--party`, `--comandos-de-prueba` →
    `--test-commands`, `--mapas` → `--maps`, `--inicial` → `--start-index`
    and the separator `--caso` → `--case`, with whoever passes them: `cartridges.py`,
    `ceilings.py` and the `flags` of `rom/rm2k-snes.toml`. The key
    `aire_de_medida` of `ceilings.toml` belongs to the TOML and stays.
12. `snes_convert`: its ~750 names, the classes `Sustituciones` →
    `Substitutions` and `Materiales` → `Materials`, the attributes it
    hangs on `args` (`imagenes` → `pictures`, `casos` → `cases`…) and the
    module aliases (`escena_mod` → `scene_mod`…). What the
    build and the suite caught, and no mechanical rename sees: a `dict(nombre=…)`
    whose key is data from the patch TOMLs, and the `mapa` attribute of
    each case, which is a copy of `args` and which, when called `map_id`, overwrote
    the cartridge's `--map-id`: it's called `run_map`.

13. The quotes left with the old names in comments, docstrings
    and error messages of `tools/`.
14. The paths of `tools/port/` in the comments of `tools/runtime/*.s`.
    No `.sfc`, `.msu`, `.pcm` nor `.inc` changes; the two
    `.sfc.dbg` do, since they record the size of each source.

## What remains, on purpose

- **What the converter writes into the `.inc`**: the symbols and the comments
  it quotes (`; See tools/port/imagen.py.`, `; Temas: …`). Changing them changes
  the `.inc`: they go with the last area, together with the runtime.
- **The Python constants and the assembler symbols are no longer named
  the same**: `events.GOLD_MAX` is written as `ORO_MAX`, `KEY_DECISION` as
  `TECLA_DECISION`. The last area can take the Python ones as a guide.
- **The keys of the dictionaries** that travel between modules or to disk —those
  of `collect_npcs` (`event`, `cambia`, `graficos`, `tile_pasa`…), those of
  `scene` (`clave`, `chico`, `alto_rm`), those of each converted map—, the
  TOMLs of `rom/parches/auto/` with their comments (the battlers'
  `asignador.merge_least_visible` is written by `patches.py`) and
  the file and directory names the tools produce
  (`rom/build/<cartucho>/asignador/`, `patches/auto/maps/`).
- **The proper names of ABL's tests**: `rom/pruebas/` stays in
  Spanish, including its aliases of the `tools/` modules
  (`from port import battle as modelo`).
- Some prose describes tuples or dictionaries with the names of their
  fields in Spanish (`(tiles, filas, fila0, paletas)`), which are data.

## For whoever merges

- `patches.py` changed its name: the global symlink of `rm2k-snes-patches`
  is left pointing at nothing until `just -f tools/justfile
  install-scripts` is run in the main checkout.
- Any branch that still uses an old name from `port/` —a `from
  port import eventos`, a `--sin-titulo` flag in `rom/rm2k-snes.toml`—
  merges cleanly and breaks when building: it has to be searched for with grep.
