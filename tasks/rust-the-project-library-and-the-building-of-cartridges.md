---
name: "Rust: the project library and the building of cartridges"
description: "The first step to Rust: tools/project/ (finding the project, the knobs, the environment, the cache key) and tools/cartridge/ with rm2k-snes-assemble, rm2k-snes-space and rm2k-snes-cartridges, replacing tools/assembly/ with the ROMs byte for byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29: take on the new tools in Rust in the order of
[`docs/research/las-herramientas-hoy.md`](https://lautarodragan.github.io/the-advocate-docs/research/las-herramientas-hoy.html). This is the first one: the common
library and `rm2k-snes-build` (which Hornero decided to split into the three
executables that already exist, with the same names, so that nobody who calls
them has to change).

- `tools/project/`: library crate, `rm2k-project`.
- `tools/cartridge/`: crate with the three executables. It replaces
  `tools/assembly/{assemble,banks,space,cartridges}.py`; `entregar.py` is
  ABL's and stays.

## What was decided, and why

**Two crates, and the split.** `rm2k-project` is what `tools/common/` is today
minus what belongs to the converter: finding `rm2k-snes.toml` (upwards or
`--project`), the knobs with errors that name the key —`missing key
cartridges.test-special.party`—, the paths of `[paths]`, the environment flags
(`environment::arguments`, `Environment::as_flags`) and the cache key, which
gives **exactly** the one from Python's `disk_cache.key` (a test compares it
against a value taken from Python), so both sides share the cache.
`parallel.py` was not ported: nobody in Rust needs it yet. The Python of
`common/` stays, because the converter is Python. `rm2k-snes-cartridge` is a
library with the three executables on top (`src/bin/`): they share the split,
the reading of the `.dbg` and that of the cartridges, and `space` needs
`cartridges` to know whether one is stale.

**The dependencies**: `toml` (with `preserve_order`, because the order of
`[cartridges]` is the order in which they are built and printed),
`serde_json` (reading `maps.json`, the cases and the new maps; writing
`--json`), `sha2` (the fingerprint and the cache key) and `clap` (with the
builder API, not derive: that way the library gives each executable only the
environment flags it uses, with the same help, as `environment.add_arguments`
did). No `regex`: what is parsed —ca65 directives, `.dbg` records, the `.cfg`—
are small formats and are read by hand.

**The bank split moved from the converter to the assembler.** Until today
`snes_convert.py` called `banks.resolve` and wrote `memoria.cfg`; now the
converter leaves everything in `RODATA` with its `.block`/`.crossbank` and
`rm2k-snes-assemble` splits, rewrites the `.inc` in place —as the Python did—
and writes the `.cfg` before running `ca65`. It is what the plan asked for
("the bank split and `ld65`'s `.cfg`") and besides it is the natural place:
the split is the other half of what `ld65` does not know how to do. Which files
to split is no longer a list of names (`mapdata.inc`, `musicdata.inc`): they are
the `.include`s found in the `-I` directory, in the order `ca65` reads them.
The same rule gives the "a covered generated file" check: one that is in `-I`
and also next to the file that includes it. Running the split twice changes
nothing (there is a test).

Consequence: the line "bank packing: N piece(s) in M bank(s)" moves from
`conversor.log` to the output of `rm2k-snes-assemble`, that is, to that of
`just cartuchos`.

**Where the runtime is.** An installed binary has no `__file__`: the crate
stores at compile time where its source was (`CARGO_MANIFEST_DIR`), and from
there come `tools/`, the root and `tools/runtime/`. It is the same thing a
script's symlink did: the binary answers for the checkout it was installed
from.

**The fingerprint** still covers what it covered —all of `tools/runtime/`,
`ca65`, `ld65`, the binaries the converter runs (`voodoo`, `gunter`, `lz2` and,
since the merge with Hurón, `rm2k-render`), the `.py` files of `tools/*/`
except `tests/`, `parches/manual/*/*`, the project file and the volume ceilings
by their value— and **adds the `rm2k-snes-assemble` binary**, because the split
lives there now: a change in the split has to rebuild. The `.py` files stay in
while the converter is Python.

**`sello.txt` changed format.** It was the fingerprint and a Python `repr` of
(flags, [(case, whole text of the JSON)]); now it is lines:

    inputs <huella>
    flags ["--party", "10", …]
    case <nombre> <sha256 del JSON>

All cartridges built before this become stale once, and rebuild on their own.

**What ABL's tests need, through the command line.**
`rm2k-snes-cartridges --list --json` (where each cartridge and its ROM are,
its flags, its cases and which ones start with `Teleport`, whether it is stale
and why, which cartridge each case runs in, the maps, what the fingerprint
covers), `rm2k-snes-space --json`, `rm2k-snes-assemble --sources` and
`rm2k-snes-assemble --memory-map` (the stack). The harness asks for it in
`rom/pruebas/arnes/cartuchos.py`, once per process. The tests of
`tools/tests/` that read the pasted runtime use `--sources` from a fixture in
`tests/conftest.py`.

**New flags**, besides the usual ones, which stay the same: `--list --json`;
`--convert-into DIR -- <flags del conversor>` and `--without-tracks`, which
are what `rm2k-snes-volume-ceilings` did by importing `cartridges.convert` and
`cartridges.build`; and in `rm2k-snes-msu`, `--quiet` and a last line "MSU-1
tracks, N made and M that were already there", which `rm2k-snes-cartridges`
prints as "release: …" in its place, same as before. `rm2k-snes-patches` takes
the test maps from the project file and the directories from `--list --json`.

**The Spanish names that remain in the crate** —`prueba.sfc`, `sello.txt`,
`conversor.log`, `memoria.cfg`, `nuevos/`, `musica/techos.toml` with its
`temas` and its `aire`, the `arbol` node of a new map, the `RESERVADO` area of
the `.cfg`— are not ABL's but conventions of the suite it shares with the
Python converter, and changing them changes what comes out. They go when the
converter is ported.

**The `install` of `tools/justfile`**: `project` and `cartridge` go into
`rust_projects`; a library is skipped when installing (it has no binary), and
the suite's symlinks are deleted before `cargo install`, because cargo does not
write over what it did not install and `rm2k-snes-assemble` was a symlink. The
three symlinks to the `.py` files being replaced leave in the same commit that
puts Rust in their place —not in the deletion one—: with the split outside the
converter, Python's `assemble.py` no longer builds a good ROM, and an
`install-scripts` that linked it again would break it.

## When merging

From the main checkout:

    just -f tools/justfile install project cartridge
    just -f tools/justfile install-scripts

The first compiles only those two (and rebuilds the symlinks); the second is
just in case, and does not touch Rust.

## What was measured

On the tree merged with `main` at `d4b766c1`, with `NO_CACHE=1 just
cartuchos` before (Python, at `53bee831`) and after (Rust), hashing all of
`rom/build/` minus the cache —1001 files—:

* **byte for byte identical**: the two `.sfc`, the `.msu`, the 43 `.pcm`
  tracks, the `.inc`, the `.sym` and everything else (`.bin`, `.png`,
  `.json`, `.toml`);
* **the `.dbg`, identical with the `mtime` field masked**. That field is each
  source's date, and it changes between two Python builds too: it was measured
  by building twice with Python, and they differ in that and in the `.o`,
  nothing more;
* **`memoria.cfg`, only the header**: `# Generated by
  tools/assembly/banks.py: …` became `# Generated by rm2k-snes-assemble: …`;
* `conversor.log` loses the line `bank packing: …`, which the assembler now
  prints; `sello.txt` changed format (above).

`just espacio` with Rust against Python's `space.show` on the same cartridges:
empty diff. `rm2k-snes-cartridges --list`: identical to Python's.

The suites, on the final tree: `just pruebas` 874; `just -f tools/justfile
test` 98 and 2 skipped (it was 132: the 34 of `test_banks.py` and
`test_assemble.py` were ported to Rust); `cargo test`: 14 in `project/`, 43 in
`cartridge/`. The exceptions list of `test_lado_de_abl.py` went from 23 to 17.

## What was not run, and what was left

* **The whole `just techos` was not run**: it is the only thing that uses
  `--convert-into` and `--without-tracks`, and no test covers it.
  `rm2k-snes-cartridges release --convert-into DIR --
  --measure-headroom 0.25` was tried by hand, and it built the copy.
* **The comments of `tools/runtime/`** (`header.s`, `main.s`, `bank1.s`,
  `enter_map.s`, `event_routes.s`) still cite `tools/ensamblado/banks.py` and
  `cartridges.py`, stale since before this task. Changing them moves the size
  of the source that ends up in the `.dbg`, so they go in a runtime commit and
  not in this one.
