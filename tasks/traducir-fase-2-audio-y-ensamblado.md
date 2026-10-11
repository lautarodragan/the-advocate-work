---
name: "Translating the tools, phase 2: audio and assembly"
description: "The code names of tools/audio and tools/ensamblado into English, and the recipes of tools/justfile"
type: refactor
status: done
assignee: taro
---

Phase 2 of the translation of `tools/` into English, second area: `tools/audio/`,
`tools/ensamblado/` (which gets renamed `tools/build/` or similar) and the
recipes of `tools/justfile`, with all their uses. They go together because
`cartuchos.py` imports from the audio.

`ensamblado/entregar.py` (`abl-entregar`) belongs to ABL and stays in Spanish.

A way to install only the Python scripts into the
PATH is also needed, without compiling or reinstalling Rust: today `herramientas` without arguments
reinstalls the five projects, and each rename of a script requires re-linking.

## How it is done

One module per commit, with Mburucuyá's token-rename scripts
adapted —now they also look at `docs/` except `docs/research/`,
which are dated studies, and they do not touch `musica.json`, `techos.toml` and
other file names that look like `módulo.atributo`—. Between commit and
commit: `SIN_CACHE=1 just cartuchos` with the fingerprints of `rom/build/`
against those of 2bd3cf64 (995 files), the two suites, pyflakes and each
executable run by its name from /tmp with `--project`.

## Where it stands

- `audio/musica.py` → `audio/music.py`.
- `techos.py` did not read `--project` before importing, and outside the game
  `rm2k-snes-volume-ceilings --project rom --help` broke: fixed in
  its own commit.
- `audio/muestras_brr.py` → `audio/brr_samples.py`, with its names.
- `audio/sdsp.py` and `audio/midi.py`: the names; the files were already
  in English.
- `audio/snes_samples.py`: the names.
- `audio/snes_music.py`: the names, with the attributes of `Bank`,
  `SoundEffect`, `Constraint`, `Group`, `NoteSetup` and `_Voice`. Left in
  Spanish, on purpose, are the keys of the dicts it builds —`leido["voces"]`,
  `tema["sonidos"]`…—, which the converter and the tests read and end up in
  `musica.json`; the labels of the SPC700 driver; and what goes inside
  the text of `musicdata.inc`, which has to come out the same: it still names
  `lugares_de_efectos` and `build_efectos`.
- `audio/efectos_msu.py` → `audio/msu_effects.py`, with its names. The
  comment in `tools/runtime/efectos_con_msu.s` that names it keeps
  the old path: touching a `.s` changes the `.dbg`, and the runtime is the last
  area.
- `audio/msu.py`: the names, and `--ganancia` becomes `--gain`.
- `audio/techos.py` → `audio/ceilings.py`, with its names, and `--medir`
  becomes `--measure`. The symlink of `rm2k-snes-volume-ceilings` changes its
  target: the global one stays broken until the scripts are reinstalled.
- `tools/ensamblado/` → `tools/assembly/`, and not `tools/build/`: see the
  commit. The comments in `tools/runtime/*.s` that cite it keep the
  old path, for the same reason as the one in `efectos_con_msu.s`.
- `assembly/bancos.py` → `assembly/banks.py`, with its names.
- `assembly/ensamblar.py` → `assembly/assemble.py`, with its names, and
  `--simbolos` becomes `--symbols`.
- `assembly/espacio.py` → `assembly/space.py`, with its names and the
  keys of `measure`, which `test_espacio.py` reads.
- `assembly/cartuchos.py` → `assembly/cartridges.py`, with its names, and
  `--lista` becomes `--list`.
- The recipes of `tools/justfile`, into English: `herramientas` → `install`,
  `herramientas-locales` → `install-local`, `protocolo` → `protocol`,
  `pruebas` → `test`, `*-pruebas` → `*-test`, `ditto-vuelta-entera` →
  `ditto-round-trip`, `cuales` → `which`. Its local directory,
  `tools/.herramientas-locales/` → `tools/.local-tools/`; ABL's,
  `rom/.herramientas-locales/`, belongs to ABL and stays.
- `install-scripts`: the Python symlinks alone, into the global one, without compiling
  anything. It refuses in a worktree. Incidentally, the guard of `install-local` did not
  recognise the main checkout: it compared `--git-dir`, absolute, with
  `--git-common-dir`, which from `tools/` comes out relative (`../.git`), so
  they were never equal. Now both ask for `--path-format=absolute`, like the
  one in `rom/justfile`.
- `tools/runtime/interprete.s` cites `just protocolo` in a comment: it stays,
  for the same reason as the other `.s`.
- The citations the script did not reach, in their commit, after a grep of
  each old name.

## For whoever merges

- The global symlinks point to paths that no longer exist —`techos.py`,
  `ensamblado/*.py`—: after the merge, from the main checkout,
  `just -f tools/justfile install-scripts`. It compiles nothing.
- A worktree that already had its `bin/` rebuilds it with `just -f tools/justfile
  install-local rom/.herramientas-locales`: the recipe's old name no longer
  exists.
- The two `memoria.cfg` in `rom/build/` change their first line —the path of
  `banks.py`—; the rest comes out byte-for-byte identical to 2bd3cf64.

## New terms for the glossary

- aire de medida → measuring headroom.
- lugar (of the samples directory) → place: `effect_places`,
  `SE_PLACES_MAX`. Not "slot", which is the ranura.
- copia (of a sample) → copy: `copies`.
- restricción → constraint.
- viejo (a cartridge) → stale, from "al día / viejo".
- `BANCO`, the size of a bank → `BANK_SIZE`, so as not to confuse it with
  `BANKS`.
- pieza del acomodo (`_Unidad`) → piece (`_Piece`).

## What is left for taro

Nothing to play: no byte of the ROM changed. Look at the diff of
`AGENTS.md` —only recipes and paths, plus the point of what whoever
merges reinstalls— and decide whether the glossary adds the terms above.
