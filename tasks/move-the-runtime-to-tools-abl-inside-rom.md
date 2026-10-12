---
name: "The move: the runtime to tools/, ABL inside rom/"
description: "rom/src becomes tools/runtime; data/, parches/, pruebas/, pytest.ini and ABL's justfile move inside rom/, with the ROMs byte for byte identical"
type: refactor
status: done
assignee: taro
---

Decided by taro on 2026-09-29 (see
`decisions/the-tools-split-from-abl.md`): the generic
runtime is distinguished from the A Blurred Line project. The root is left with
`rom/`, `tools/`, `docs/` and `workflow/` (plus the usual loose files:
`AGENTS.md`, `CLAUDE.md`, `README.md`, `DITTO.md`, `.gitignore`…).

It goes after step 2 of the plan (`comun/proyecto.py`, Tipa, `e257bca3`), so
moving each folder is changing one line there. Hornero decides the details with
taro's authorisation to decide without waiting for him.

- `rom/src/` → `tools/runtime/`
- `data/` → `rom/data/`, `parches/` → `rom/parches/`, `pruebas/` →
  `rom/pruebas/`, `pytest.ini` → `rom/pytest.ini`
- the root `justfile` → `rom/justfile`
- `rom/build/` stays where it is.

## What was done (Algarrobo, 2026-09-29)

Four commits: `3b3f8db6`, only `git mv` and it does not build; `78a5d27e`,
what makes it work; `1bf580f3`, the prose; `539ba681`, five comments that the
mechanical pass over the prose changed inside strings that the converter
writes to the `.inc`, and that say `rom/src/` again (see below).

- **`proyecto.py`**: `runtime()` hangs from `herramientas()`, and a new
  function, `abl()` —`rom/`—, from which `build`, `data`, `parches` and
  `pruebas` hang. `raiz()` is still the repo's: `ca65` and `ld65` run there,
  and the paths of the `.inc` and `.dbg` files are written against it. That is
  why the `.inc` come out identical and the `.dbg` change only in the sources'
  names. `entregar` adjusted on its own: its `RUNTIME` comes from `proyecto`,
  and `HUELLA_MSU` gives the same text because `rom/build/` did not move.
- **`ensamblar.py`** looks at the directory of the source it builds, so the
  refusal moved to `tools/runtime/` on its own. Tested with an empty
  `mapdata.inc` there: it refuses.
- **`.gitignore`**: `rom/pruebas/snapshots/`. `.git-blame-ignore-revs` stays at
  the root and unchanged: `git blame` looks for it there, and its commits hold
  for the whole repo.

## The decisions, and why

**Where ABL's recipes are run from: from the root, same as before, or from
`rom/`.** The root has a two-line `justfile` that only does `import
"rom/justfile"` with `set working-directory := "rom"`. That way:

- taro keeps writing `just cartuchos`, `just entregar "…"` and
  `mednafen rom/build/release/abl.sfc` from the root, as always;
- the recipes run standing in `rom/` whoever calls them —from the root, from
  `rom/`, from `rom/pruebas/abl/`, or with `-f` from `/tmp`—, so their paths
  are relative to ABL and not to the repo;
- the root one has no recipes nor names `tools/`, and neither of the two
  `justfile`s below knows it exists: it is the repo's, and the day it is split
  it gets deleted.

Discarded: `mod rom`, which forces writing `just rom cartuchos`, and taro
running from `rom/`, which changes his habit and the `mednafen` command.

A detail that took effort: imported, `justfile_directory()` is the root, not
`rom/`. `rom/justfile` uses `source_directory()`, which is its own in both
cases. Tested in a toy tree before touching the repo.

**The local `bin/`: `herramientas-locales <destino> [proyectos…]`, with the
destination mandatory.** Neither side can know where the other lives, so the
one that consumes says it. `rom/justfile` looks for its own in
`rom/.herramientas-locales/`, and its guard, when it is not there, gives the
whole command with absolute paths —it comes from `git rev-parse
--show-toplevel` and from `source_directory()`—, so it can be pasted from any
directory. A relative destination is relative to where `just` was run
(`invocation_directory()`), not to `tools/`. `tools/justfile` looks for its own
in `tools/.herramientas-locales/`, so that `protocolo` and its tests use the
worktree's `protocol` if someone modifies it. Mandatory and not with a default
because `herramientas-locales lz2` would be ambiguous.

**The paths in the prose of `rom/` are from `rom/`**: `build/release`,
`pruebas/`, and the runtime as `runtime/<archivo>.s`, without `tools/`, which is
what `test_lado_de_abl.py` enforces. Outside `rom/`, from the repo's root.

## Verified

- **ROMs**: `SIN_CACHE=1 just cartuchos` before touching anything (from the
  root) and after the second commit (from the root): of the 1001 files of
  `rom/build/` —without `cache/`, `.o` or `sello.txt`—, all identical except
  the two `.dbg`. `abl.sfc` `7a3c6483…6a66552`, `prueba.sfc`
  `fb6db844…ae2d877`, `abl.msu` `905decd2…6b83cee`, and the `.pcm` and the
  generated `.inc`, identical. The `.dbg` differ in 95 `file` lines each and in
  nothing else, and the only difference is `rom/src/` → `tools/runtime/` in
  the name.
- **And again at the end**, `SIN_CACHE=1 just cartuchos` from `rom/` on the
  four commits, against what there was before the move: all identical except
  the two `.dbg`, which add to the name change the `size` of the 16 `.s` whose
  comments the prose touched, and nothing more.

  **That run was the one that caught the prose's error**: the first time,
  after `1bf580f3`, the four generated `.inc` came out different. The
  mechanical pass had changed `rom/src/` to `tools/runtime/` in five strings of
  `snes_convert.py` and `snes_music.py` that are comments the converter writes
  to the `.inc`. The decision says that what is emitted is not touched yet, so
  they went back to `rom/src/`, with a comment next to them. No test compares
  the `.inc` against the ones from before: without this run, it would have got
  through.
- **Suites**: `just pruebas` from the root, 866 before and after; from `rom/`,
  after the prose, 866. `just -f tools/justfile pruebas`, 117.
- **`test_lado_de_abl.py`**: without touching the code. It computes its root
  three folders above itself, which is now `rom/`, and its relative paths
  —`justfile`, `parches`, `data`, `pruebas`, `pytest.ini`— still point at the
  same things. The 23 exceptions are the same: `rom/pytest.ini` names
  `../tools`, and it was already on the list.
- **From other directories**: `just espacio release` from `rom/pruebas/abl/`;
  `just -f <raíz>/justfile parches-check` and `just -f <raíz>/rom/justfile
  cartuchos` from `/tmp`; `just parches` leaves the tree the same;
  `pruebas/arnes/video.py --help` from `rom/`.
- **The guard**: this worktree without `bin/` refuses, and the command it
  gives, pasted from `/tmp`, builds the `bin/` and lets it through. Without a
  destination, `herramientas-locales` states its usage; with a relative one,
  it builds it relative to the directory it was run from.
- **Mesen2**: I put together what `just entregar` would leave in a scratchpad
  directory —`abl.sfc`, `.dbg`, `.msu` and the `git archive` of
  `tools/runtime/`— and ran Mesen2's reimplemented search (next to the `.dbg`
  and going up): it finds the 95 sources and is missing `mapdata.inc` and
  `musicdata.inc`, same as before. From `rom/build/release/` in the clone it
  finds the 97.
- **`git blame -C --diff-algorithm=histogram`**: of `tools/runtime/` at `HEAD`
  against `rom/src/` at `4ab92fd0`, line by line, the same commit in the 4223
  lines of `main.s`, `heroe.s`, `interprete.s`, `batalla.s`, `registros.s`,
  `paquete_de_audio.s` and `event_opcodes.inc`. And `blame` without options on
  `rom/pruebas/arnes/consola.py`, identical across its 1133.

**Not run**: `just entregar` for real, `datos`, `datos-vuelta`, `techos`, nor
`video` beyond `--help`.

## What taro has to do on the host

- **Nothing to run the recipes**: `just cartuchos`, `just pruebas`, `just
  entregar "…"` keep working from the root. They also work from `rom/`.
- **The ROM is still at `rom/build/release/abl.sfc`.** `rom/build/` did not
  move, and the MSU-1 tracks in `/shared/msu/` are still valid: the
  fingerprint is the same.
- **`just -f tools/justfile herramientas` does not need to be run again.** The
  global symlinks point at the `.py` files of `tools/`, which did not move, and
  those scripts read the paths from `proyecto.py`, which is the new one as soon
  as it is merged. Rust did not change.
- **The builds that `just entregar` delivers from now on bring
  `tools/runtime/`** next to the `.dbg`, instead of `rom/src/`. Mesen2 finds it
  all the same.
- **The IDE**: if JetBrains had `rom/src/` or `pruebas/` marked as a folder of
  something, `tools/runtime/` and `rom/pruebas/` have to be marked.
- **Sub-agents**: the startup command changed —`just -f tools/justfile
  herramientas-locales rom/.herramientas-locales`—, and it is in AGENTS.md.
  Old worktrees with `.herramientas-locales/` at their root stop using it: the
  guard refuses and gives the new command.
