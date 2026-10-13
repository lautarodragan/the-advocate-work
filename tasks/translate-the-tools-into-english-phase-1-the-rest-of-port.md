---
name: "Translate the tools into English, phase 1: the rest of port"
description: "Comments, docstrings, messages and prose into English, without touching code names: tools/port/, everything but snes_convert.py"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: "translate the tools into English". It is the
AGENTS.md rule for the separate projects, which now reaches all of `tools/`
(see `decisions/the-tools-split-from-abl.md`).

**Phase 1**, split among four agents by area: comments, docstrings, error
messages, `help=` and prose. **Code names are not touched** —modules,
functions, variables, runtime symbols, flags—: that is phase 2, one area at
a time, because a name changes in everything that imports it. The terms
come from `tools/GLOSSARY.md`.

Scope of this part: tools/port/, everything but snes_convert.py.

## How it is verified

Each group of files goes in its own commit, and is verified with three
things:

* each file's AST against `66152183`, without docstrings: only strings may
  change, and every string that changed is looked at by hand —message or
  data—;
* `SIN_CACHE=1 just cartridges` and the sha256 of all the `.sfc`, `.msu` and
  `.pcm` in `rom/build/` against those from before starting;
* the generated `.inc` files, with a diff that can only show comments.

## Done

* The small modules: `animation`, `asignador`, `color`, `comprimir`,
  `constantes`, `experiencia`, `fin_del_juego`, `formato_snes`, `fuente`,
  `imagen`, `msu_datos`, `paleta`, `pantalla_completa`, `reglas`, `textos`,
  `tiles_bin`, `title`, `window`. `event_opcodes.py` is generated and was
  already in English.
* The battle, the menus and the screens: `battle`, `escena`, `menus`,
  `pantallas`, `parches`.
* `eventos`, which is almost half of the scope.

## What was left in Spanish on purpose

* **The comments that `parches.py` writes inside the `.toml` files** of
  `rom/parches/auto/`. They are the game's versioned material: translating
  them here leaves those files stale in every comment until the next `just
  parches`, which would rewrite those of `rom/` —out of scope—. `--check`
  compares what is parsed, so it does not fail because of that. It is a
  decision for taro: if they go in English, it means changing those lines
  and running `just patches`, in a commit of its own.
* Everything that is data: the LDB's terms, "- Empty -", ">", the fallback
  "Yes" and "No" of End Game, the keys of the dictionaries and of the
  `.toml` files, RM2k's "(OFF)", the sentinel `FONDO_DEL_LUGAR`, the class
  names of `pantalla_ranuras` ("cabecera", "menu_opcion"…).

## What was left hanging

* `internals/the-msu-file.md` cites two sections of `escena.py` by their
  Spanish titles ("El respaldo liviano", "Qué fondos hay"); now they are
  called "The light fallback" and "Which backdrops there are, and which ones
  the cartridge carries". `docs/` is not part of this phase.
* Citations that other files make of titles that were renamed, outside this
  scope: `tools/runtime/ranuras.s` cites "lo que depende del actor" —now
  "what depends on the actor", in `menus.py`—, and `snes_convert.py`,
  already translated by Aromo, still cites "Qué fondos hay" (escena.py),
  GIRO —now TURN— and "las variables de RM2k" —now "RM2k's variables"—
  (eventos.py), and "lo que depende del actor".

## Verified

On the tree with `main` merged (`106da9f8`, with Aromo's, Coronillo's and
Palmar's work inside):

* `SIN_CACHE=1 just cartridges`: the `.sfc`, `.msu`, `.pcm` and `.sym` of
  `rom/build/` with the same sha256 as before starting. The only thing
  different is `memory.cfg`, whose header Coronillo translated. No module
  of this part writes into the `.inc` files: before merging they came out
  identical, and what changes in them afterwards is `snes_convert.py`'s.
* `just tests`: 874 pass.
* `just -f tools/justfile pruebas`: 132 pass and 2 are skipped.

## What to look at

Nothing to play: the ROM is the same byte for byte. What there is to read
is the `git diff`, above all `eventos.py`, and the decision about the
comments in the `.toml` files of `rom/parches/auto/`.
