---
name: "The tools' justfile"
description: "The recipes that belong to the tools move to tools/justfile; the root justfile is left for ABL"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: the first step before moving `data/`, `patches/`,
`tests/` and the engine (see `decisions/the-tools-split-from-abl.md`).
A `tools/justfile` with what belongs to the tools, and the root one
narrowed to ABL. It gets closer to having two repos without moving any path
yet.

What goes to `tools/justfile`, as discussed: `protocolo`,
`protocolo-pruebas`, `gunter-pruebas`, `ditto-pruebas`,
`ditto-vuelta-entera`, `voodoo-pruebas`, `lz2-pruebas`, `herramientas`,
`herramientas-locales`, `_instalar` and `cuales`. What puts the local
`bin/` at the front of the `PATH` and the guard stay in the root one. `datos`
and `ditto-volcado`, which dump this game, also stay.

From `tests/tooling/`, only those that need neither the game nor a
ROM move to `tools/`, confirmed test by test.

## What was done (Espinillo)

* **`tools/justfile`** with the eleven recipes on the list, plus
  `_no_en_el_principal`, which belongs to `herramientas-locales`. The paths
  lose the `tools/` because `just` runs standing in the `justfile`'s
  directory; what is outside is named from there: `protocolo` writes into
  `../rom/src/`, and the local `bin/` is built at the root
  (`parent_directory(justfile_directory())`), which is where the root's
  `PATH` looks for it. `tools/justfile` puts the same `bin/` at the front of
  its `PATH`, so that `protocolo` uses the worktree's `protocol` if it is
  being modified.
* **The root** keeps the `PATH`, the guard, `datos` and `ditto-volcado`. It
  delegates to nothing.
* **The guard's command is `just -f tools/justfile herramientas-locales`.**
  It works from the root without the root importing or delegating, and `-f`
  runs the recipe standing in `tools/`, same as from inside. The other
  option, `cd tools && just …`, says the same in two commands. The guard
  stays as the only ABL recipe that names `tools/`: the test's list goes
  from nine to that one alone, and is renamed to
  `RECETAS_QUE_NOMBRAN_TOOLS`.
* **A bug in the grep test**, fixed in its own commit: a recipe with default
  values (`datos DIR="data" …:`) was not recognised, and its comment was
  counted against `voodoo-pruebas`, which was exempted. Through there a
  `tools/rpgmaker/lcf.py` in the comment of `datos` slipped by.

### What did not fully close

* **`ditto-pruebas` and `ditto-vuelta-entera` still know about ABL**: if
  `DITTO_CORPUS` does not come, they use `ABL_GAME_DIR`. I moved them
  anyway, because they are Ditto's tests; but the corpus is the game, so
  when the repos are split someone has to pass it to them. A root recipe
  that passes it would have to call `tools/justfile`, which is what the root
  cannot do.
* **`tools/justfile` is in Spanish**, like the Python of `tools/`: it gets
  translated with it.

### `tests/tooling/`: none was moved

* `test_lz2.py` needs the built cartridges (`tanda.cartucho`): it stays.
* `test_protocolo.py` mixes: some run `protocol --check` and compare
  modules, and others read the cartridges (`tanda`) and the game
  (`GAME_DIR`). It would have to be split.
* `test_escapes.py` only imports `port.eventos` and `port.ventana`: it needs
  neither the game nor a ROM.
* Without looking at them in depth, `test_temas_heredados.py`,
  `test_sustituciones.py` and `test_musica_stream.py` do not import the
  suite or the game either; `test_leaders.py` uses `datos.DEMO`, from the
  harness.

I did not move them because it is not obvious where to: `tools/` has no
Python tests folder nor its own `pytest.ini`, and `tools/justfile` has no
recipe that runs them. That has to be decided first (`tools/pruebas/`?,
in English?).

### Verified

* `just --list` at the root: 14 ABL recipes; `just -f tools/justfile
  --list`: the tools' 10.
* `just -f tools/justfile protocolo --check`: both up to date.
* `just lz2-pruebas`, standing in `tools/`: 19 pass. It was the only Rust
  compilation. The other `*-pruebas`, `ditto-vuelta-entera` and
  `herramientas` only with `--dry-run`.
* Without the `bin/`, `just cartridges` refuses with the new command; that
  command builds it without compiling Rust, with the symlinks to the
  worktree's `tools/`, and `just cartridges` works afterwards.
  `_no_en_el_principal` exits 1 in the main checkout.
* `just tests` from the root: 973 pass. `abl.sfc` and `prueba.sfc`
  rebuilt, with the same sha256 as before.

**What not**: `herramientas` for real against the global one, the
`*-pruebas` except `lz2`, and the host.
