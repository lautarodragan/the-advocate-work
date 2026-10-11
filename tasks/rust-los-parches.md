---
name: "Rust: the patches"
description: "tools/port/patches.py (rm2k-snes-patches: writes and checks the TOML of rom/parches/auto/) to Rust, with the same executable and the same files byte for byte"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, in the converter's migration to Rust. `patches.py`
is already an executable of its own (`rm2k-snes-patches`, called by `just
parches` and `just parches-check`) with clear input and output.

## Where it ended up and why (Yacutoro, 2026-09-30)

A crate of its own, `tools/rm2k-snes/patches/` (`rm2k-snes-patches`, the
justfile's `patches` project), and not one more binary of `cartridge`. The
layer is `rm2k-snes/` because it knows about both things —RM2k map ids,
animations and battlers, 15-bit colors and CGRAM—. A separate crate because
it's another responsibility: `cartridge` builds cartridges, and this writes,
copies and compares decisions; the only thing it asks of `cartridge` is the
list of cartridges and where each one is built, for `--check` without
arguments, and it takes that as a library (`Cartridges::load`, `names`,
`directory`) instead of running `rm2k-snes-cartridges --list --json` like the
Python did.

## The boundary with the converter

The converter imported `patches.py` in the same process: `write_maps`,
`write_animations` and `write_battlers` built the TOML text from what the
converter decided, and `write_uses` wrote `parches/usos.json`.

* **What travels is the decision**, in a JSON request: the converter runs
  `rm2k-snes-patches --request <pedido> <build>` —`stage.hand_over`, new,
  next to `stage.run`—, and the executable empties and writes
  `<build>/parches/auto/{mapas,animaciones,battlers}/` and prints the same
  three lines the converter used to print. The request is built by
  `patch_of_map`, `patch_of_animation` and `patch_of_battler` in
  `snes_convert.py`. Of a battler, **how many** merges travels, which is the
  only thing that gets written, and not the list.
* **`usos.json` is still written by the converter**, which is the one that
  knows who asked for each thing: `write_patch_uses` moved to
  `battle_scenes.py`, next to `patch_uses`, and the executable only reads it.
  That way the file also comes out byte for byte identical without
  reimplementing in Rust the order of `sorted(..., key=str)` over Python
  pairs.
* `--request` is a new flag; the earlier ones —`--project`,
  `--test-cartridges`, the directories and `--check`— stay the same, so `just
  parches` and `just parches-check` don't change. `--request` doesn't look
  for the project: it only writes into the build what it's given.
* `rm2k-snes-patches` goes into the cartridges' fingerprint
  (`CONVERTER_TOOLS` of `cartridge`): what it writes goes next to the ROM and
  the check reads it from there.

## The comparison

Throwaway scripts in the scratchpad (`yacutoro/`): `base.sh` builds with
`NO_CACHE=1 just cartuchos` and takes the sha256 of all of `rom/build/`
(except the cache, `.o`, `sello.txt` and `conversor.log`; the `.dbg` without
`mtime`); `salidas.sh` runs `just parches-check` clean, `just parches-check`
with five TOML edited by hand —a map's `colores`, an animation's size and
sheet, a battler's color, hue and merges, a versioned map deleted and an
extra one— and `just parches` on an edited battler and an extra map, and
saves output, error, exit code and the sha256 of the 137 TOML.

* Python against the Rust executable on the same builds: all identical,
  error output included.
* With the converter already passing the request (`NO_CACHE=1`): the 1032
  hashes identical except the `.dbg` of the three cartridges, and
  `salidas.sh` identical to Python again.
* The crate's `cargo test` compares against what `patches.py` answered,
  before deleting it, for the game in `tests/game/` (`tests/python.json`):
  the sha256 of the ten TOML, what it copies and deletes, what's versioned,
  the check's complaints and what belongs to each cartridge.

## When merging

* `just -f tools/justfile install patches cartridge`, from the main checkout:
  `patches` is new, and `cartridge` changed the fingerprint. That recipe
  first deletes the `rm2k-snes-*` symlinks and rebuilds the Python ones, so
  the global symlink from `rm2k-snes-patches` to `port/patches.py`, which is
  left dangling, gets replaced by the binary. No separate `install-scripts`
  needed.
* All cartridges become stale (the fingerprint changed): `just cartuchos`.

## The suites

On the tree with `main` merged (`550ccfeb`): `just cartuchos`, `just
parches-check` green, `just pruebas` **878** —it was 880: the two that didn't
depend on the game, that building again doesn't leave stale patches and what
is "suite-only", moved to the crate—, `just -f tools/justfile test` **85**
(`main` removed five), and `cargo test` of `patches` and of `cartridge`. The
ROMs, identical to the ones from before starting.

## What was deleted

`tools/port/patches.py` whole (792 lines) and its symlink in `install`. Of
what it did, `write_uses` didn't go away: it moved to `battle_scenes.py` as
`write_patch_uses`. The two tests of
`rom/pruebas/herramientas/test_parches.py` that didn't depend on the game
moved to `tools/rm2k-snes/patches/tests/`; the other two stayed, calling the
executable and reading the TOML with `tomllib`.

No README of its own for the crate: its documentation is `lib.rs`'s `//!`,
which carries `patches.py`'s docstring.
