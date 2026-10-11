---
name: "Rust: the orchestrator and the game reader in Python"
description: "The last part of the migration: snes_convert.py and what's left in tools/port/ (some 7,000 lines) as a Rust binary, and the game readers in Python (tools/rpgmaker/lcf.py, rm2k.py, fork.py) replaced by Ditto and the dump"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02: the last step of the migration, after the
repeated rules (Cachirla). All the domains are already Rust; in
`tools/port/` what's left is the orchestrator —which builds each stage's requests and
hands out what they answer— and some leftovers, and `tools/rpgmaker/lcf.py`,
`rm2k.py` and `fork.py` still read the game in Python. They're used by 10 modules
of `tools/port/`, 2 of `tools/render/`, one of `tools/tests/` and 15 ABL
tests.

It comes from `main` at `8db96253`. There, `NO_CACHE=1 just cartuchos` gives 1418
files in `rom/build/` —without the cache, the `.o` files, `sello.txt` or
`conversor.log`; the `.dbg` without `mtime`—, identical to those of the brief's
baseline: `abl.sfc` `35c765009320d436…`. The sha256 and the three
`mapdata.inc`, in `<scratchpad>/chuna/`.

## Inventory: what each file does today and who uses it

Measured on 2026-10-02 with a grep of the `import`s in `tools/` and
`rom/pruebas/`.

### `tools/port/`

| file | what it does | who uses it | what it is |
|---|---|---|---|
| `snes_convert.py` | `main`: the order, the checks on the compiled pages, the second round (each map's code, `draws`), the requests to patches and audio, Adeleine's images | the script; 8 tests import it only for the `lcf` hooks it installs, one for `SUB_MAX` | orchestration |
| `options.py`, `cases.py`, `stage.py` | the flags, `--case`, running a stage | the converter; `stage.run` the harness too | orchestration; `stage.run` is used by the harness |
| `map_convert.py`, `map_layers.py`, `sprites.py`, `obj_extras.py`, `window.py`, `vram.py` | `wally map`'s request and the `map_info` from its answer; `separate_from_hero`, `maps_per_character`; the timer's System; the layouts reader | only the converter | orchestration |
| `game_scan.py` | possible leaders, items, members, rain, the timer's reach | the converter; `test_lideres`, `test_timer_paleta`, `test_destello_paleta` | orchestration: what the converter deduces to build the requests |
| `compiler.py` | `rm2k-snes-events`' two requests and its answer; `loose_page`, `slots`, `troop_triggers` for the tests | converter; harness (`datos`, `etapa_mapas`) and 3 tests | orchestration, plus a client of the stage for the tests |
| `screen_stage.py` | `rm2k-snes-screens convert`'s request and its answer; `layout`, `render`, `equip`, `refit` for the tests | converter; harness (`pantallas`, `modelo`, `batalla`) and `test_textos_del_juego` | orchestration, plus a client for the tests |
| `image_stage.py`, `battle_stage.py`, `mapdata.py` | the requests of `rm2k-snes-images`, `rm2k-snes-battle model` and `rm2k-snes-mapdata emit` | only the converter | orchestration |
| `picture.py` | which `ShowPicture` images each map carries, cut into objects; the large ones, numbered | only the converter | the images domain, on the request side |
| `animation.py`, `battle_animations.py` | which animations the cartridge carries (the bytecode is walked), the anchor, the frames in tiles | converter; `test_parches` (`fit_size`, `BOX`), `test_animacion_cuadros` | the images and emission domains |
| `scene.py`, `battle_scenes.py` | which backgrounds and battlers the cartridge carries, their bytes, where each one stands; `compose` | converter; `test_batalla_escena_dibujo`, `test_msu_datos` | the scene domain |
| `fullscreen.py`, `palette.py`, `compress.py`, `snes_format.py` | title and Game Over: the stage's image, in tiles, compressed with `lz2` | converter; `pack_tile` in `test_msu_datos` | the images and emission domains |
| `constants.py`, `engine.py`, `event_opcodes.py` | engine numbers and opcodes | converter and many tests | constants |
| `events.py` | command constants, records, `MapEvents`, `walk_code`, `PartyState`, `Encounters`, `key_value`, `named_backdrops`, `index_animations` | converter and 25 tests and harness modules | mix: the converter's part is orchestration; the rest are the tests' models |
| `experience.py` | RM2k's curve | `lcf.py` (no), 4 tests, `test_rm2k_rules` | the tests' model |

### `tools/rpgmaker/`

| file | what it does | who uses it |
|---|---|---|
| `lcf.py` | reads the dump in Python: `Map`, `Database`, `TreeMap`; the hooks `REFIT_TEXTS` and `DECORATE_TRANSLUCENT` | 10 modules of `port/`, 2 of `render/`, `test_rm2k_rules` and 15 of ABL's tests |
| `rm2k.py` | the rules in Python: passability, `page_graphic`, `collect_npcs`, the decorated names (`~horneado`, `~aparte`, `@tile:`) | converter, `render/`, `test_rm2k_rules`, 6 of ABL's |
| `fork.py` | `rom/parches/manual/`: validates the forks and the new maps | `lcf`, `compiler`, `chipset_recipe`, `test_fork_mapas` |
| `resources.py`, `event_codes.py` | where the game is; the codes' names | converter and tests |

`test_dump_readers.py` only looks at the Rust: that no `src/` outside Ditto
names the dump's files. `lcf.py` is still alive because the converter is
Python, and in Python there's no Ditto: what reads the game in Python is that.

### `tools/render/` and `tools/emulator/`

* `render_map.py` is the `Renderer`: it holds the database, the tree and where
  images are looked for, and when constructed **builds the images of the fork's
  ChipSets** (`chipset_recipe.py`) in `rom/build/parches-manual/`, which
  `wally` reads. It's converter.
* `chipset_recipe.py` is the recipe of `rom/parches/manual/chipsets/`: it copies
  blocks, prunes, pastes poses and an image. It belongs to the maps domain: it goes to
  Rust with the orchestrator (the PNG it writes is intermediate and goes into the
  fingerprint of `rom/build/`).
* `emulator/retro.py` is the emulator harness, through ctypes: **it stays in
  Python**. It isn't the converter's and only the tests use it.

## The plan

**I change the brief's order**, and the why: the game readers in
Python (step 1) exist because the converter is Python. Moving them to Ditto
before moving the converter means the Python asks a
binary for what it reads today —each map's pages, the names, the database—,
requests that get thrown away when the converter is Rust and reads with Ditto
itself. So:

1. **The orchestrator to Rust**: a new crate,
   `tools/rm2k-snes/convert/` (`rm2k-snes-convert`), with the same flags,
   which replaces `snes_convert.py` without `rm2k-snes-cartridges` changing
   anything but the fingerprint. It reads the game with Ditto (with
   `rm2k-snes-events`' `Game` where that's enough), and calls the stages through the PATH with
   **the same requests**: it's verified by capturing each request from the Python and
   from the Rust and comparing them, and then all of `rom/build/` byte for byte.
   With that the converter stops reading with `lcf`/`rm2k`/`fork`.
   What belongs to a domain and the Python does today over a stage's
   answer —the scene's bytes, which images a map carries, the
   ChipSet recipe— goes to that domain's crate when it's a pure function that
   can be called as a library without changing any request, and otherwise, to an
   orchestrator module with the domain's name, noted below.
2. **The tests without the Python readers**: what only ABL's tests
   read —`events.py`'s constants, `Encounters`, `key_value`,
   `experience.py`, `scene.compose`, the stages' clients— moves to
   `rom/pruebas/arnes/`, reading the dump in JSON (which is ABL's) or
   asking the binaries, as `modelo.py` and `musica.py` already do.
3. **The deletion**, in its own commit, and the prose in another.

Each step, with all of `rom/build/` identical with `NO_CACHE=1` and both suites
green. If it doesn't all fit, step 1 is delivered finished.

## Done, stage by stage

### How it's verified

Two safety nets, in `<scratchpad>/chuna/`:

* **The requests**: `capture.sh` runs the converter over the three cartridges
  with the stages behind a shim that copies each `--request`, and
  `compare.py` compares one converter's requests against the other's
  —as JSON, with the key order— and everything each one wrote
  next to the output. The call lines (`argv-*.txt`) were taken
  from `rm2k-snes-cartridges` with a wrapper that logged them.
* **All of `rom/build/`**: `base.sh`, with `NO_CACHE=1 just cartuchos`, the
  sha256 of everything except the cache, the `.o` files, `sello.txt` and `conversor.log`
  —the `.dbg` without `mtime`—, and the three `mapdata.inc` separately.

**The baseline was taken twice**, because of Mara's trap: with the global
assembler the `.dbg` files come out different than with the local one, and stage 1 touches
`cartridge` (the fingerprint), so the local one is the one that builds. The one that counts is
`sha-base2.txt`: the Python converter with the branch's `cartridge`.

### 1. The orchestrator to Rust

`tools/rm2k-snes/convert/`, `rm2k-snes-convert`, with the same flags
—except `--charset` and `--charset-index`, which the Python assigned and nobody
read since the hero's graphic comes from the party—. It reads the game with
Ditto and calls the stages through the PATH with **the same requests**: those of
the three cartridges, identical to the Python's as JSON, except:

* `rm2k-snes-mapdata vram` and `engine`, which are no longer called: the layouts,
  the checks and the engine's numbers are read from `rm2k-snes-mapdata`
  as a library, where they came from;
* `test_graphics` in the `compile` request goes by map number and not in the
  order in which Python walked a `set`; the stage reads it one map at a time.

What the Python did over the answers, which belonged to a domain, ended up
in modules of the crate with the domain's name: `pictures.rs` (which images
each map carries, the objects), `animations.rs` (the frames in tiles, the
anchor), `scene.rs` (which backgrounds and battlers, their bytes, where each one
stands, who asks for each thing), `fullscreen.rs` (the title's and
Game Over's stream), `chipsets.rs` (the recipe of the fork's ChipSets, which was
`render/chipset_recipe.py`) and `fork.rs` (the validation of
`parches/manual/`). Moving them to their stages changes requests and the hashes of
those crates' tests: it's noted below.

Measured on the branch, with `convert` and `cartridge` in the local `bin/`:

* **All of `rom/build/` identical** to `sha-base2.txt` —1418 files— **except
  the three PNGs in `parches-manual/ChipSet/`**, which the Rust writes with
  a different compressor from Pillow's: decoded they're identical —mode, size,
  palette, indices and info, `pngcmp.py`—, and `wally`, which reads them, answers
  the same. The three `mapdata.inc`, identical line by line: 336442,
  63556 and 27325 lines. The ROMs, the baseline's.
* `release`'s `conversor.log`, identical line by line to the Python's.
* `just pruebas`, 1008; `just -f tools/justfile test`, 39;
  `cargo test` of `rm2k-snes-convert` (25), `rm2k-snes-cartridge` and
  `ditto`.

Things that changed along the way:

* The cartridges' fingerprint names `rm2k-snes-convert` and no longer `lz2`, which
  nobody runs: the converter compresses the title with `lz2` as a library,
  through `rm2k-snes-mapdata`.
* Ditto gained `dump::layers_path` and `dump::is_dump`: the fork's validation
  needs to know where a map's layers go, and `test_dump_readers.py`
  —rightly— doesn't let another crate write it.
* The hero flash check counts the NPCs `wally` answered and
  not its own `collect_npcs`: the Python one counted differently an event with
  a page conditioned on the timer. It doesn't change any cartridge.

### 2. What the tests read

**The converter's queries.** ABL's tests asked the
compiler and `game_scan` through the Python converter's modules
—`compiler.scan`, `loose_page`, `slots`, `troop_triggers`,
`possible_leaders`, and how `etapa_mapas` builds `wally`'s request—. Now
they ask the binary, which is the one that decides how it asks:
`rm2k-snes-convert scan | compile | leaders | map-context | boxes`
(`src/queries.rs`), each with its answer in JSON. Compared against the
Python over the game (`queries_check.py`): the scan of all maps, with
one extra variable and with a case; the opening's leaders; the context
of maps 2, 11 and 32 —with forks and fork ChipSets—; a loose page;
a troop's triggers; the boxes. All identical.

**What the tests read, to their harness.** What only ABL's tests read
from the Python in `tools/` was moved with `git mv` to `rom/pruebas/arnes/`, which
is theirs, without translating it —it's in English and stays in English—:

* the dump reader (`lcf.py`), the forks (`fork.py`, which now only says
  where each file is: validating them is the converter's job) and the rules the
  tests use as an oracle (`rm2k.py`, `render_map.py`, `experience.py`),
  without the hooks the converter put on them —`REFIT_TEXTS`,
  `DECORATE_TRANSLUCENT`— or what only it used;
* the models and constants (`events.py`, `engine.py`), the bytecode
  (`event_opcodes.py`, which an ABL test now generates from the
  declaration: `test_el_modulo_de_los_opcodes_esta_al_dia`), and the clients
  of the stages the tests use (`stage.py`, `screen_stage.py`,
  `image_stage.py`, `scene.py`, `animation.py`, `snes_format.py`,
  `resources.py`, `parallel.py`).

What they asked the compiler and `game_scan` moved to `arnes/conversor.py`,
which asks the binary. The tests that imported `port.snes_convert`
only for its hooks stopped doing so; the one that checked that the reflow
hook was in place now checks that the converter gives the compiler
map 2's long boxes rebuilt (`test_textos_del_juego.py`).

Tests that moved to Rust, because they look at what the converter does with
any project and not at the game:

* from `test_fork_mapas.py`, the seven about the half-done fork, the changed id, the
  map that doesn't exist and the new maps → `fork.rs`; the three about the
  ChipSet recipe —pruning respects what only an event names, it's planted with
  `TileSubstitution`, `desde_imagen` at fifteen bits and composed— →
  `chipsets.rs`;
* `tools/tests/test_substitutions.py` → `convert.rs` (`SUB_MAX` against
  `low_ram.s`).

And one that went away: `tools/tests/test_rm2k_rules.py` held the Python
copy of the rules against the Rust one for the converter; the converter's
rules are the Rust ones, and what's left in Python is the tests' oracle,
which is compared against the ROM. `rm2k-rules` still holds its
answers with `tests/python.json`.

Measured after stage 2: `rom/build/` as in 1; `just pruebas`,
999 —the ten from `test_fork_mapas.py` went to Rust and the opcodes one
came in—; `just -f tools/justfile test`, 36 —
`test_rm2k_rules.py` and `test_substitutions.py` went away, and one that looked at the
protocol's `snes_convert.py`—; `cargo test -p rm2k-snes-convert`, 28.

### 3. The deletion and the prose

`b21352e6` deletes `tools/port/`, `tools/rpgmaker/`, `tools/render/` and
`tools/common/disk_cache.py`, plus whatever in the modules moved to the harness
only the converter used. `ae217a97` fixes the prose that named them:
AGENTS.md, README.md, DITTO.md, `tools/README.md` —the section on the
Python layers becomes "The Python that is left"—, `docs/port/` and the
harness's docstrings. `test_lado_de_abl.py` loses five exceptions.

Measured on `ae217a97`, with `convert` and `cartridge` in the local `bin/`:
`rom/build/` identical to `sha-base2.txt` except the usual three PNGs;
`abl.sfc` `35c765009320d436…`; `just pruebas`, 999;
`just -f tools/justfile test`, 36. `main` hasn't moved since `8db96253`:
there was nothing to merge.

## What's left in Python

* `tools/common/` (project, settings, environment), `tools/emulator/`
  (`retro.py`, the emulator harness, which stays in Python on purpose) and
  `tools/assembly/entregar.py`, which is ABL's.
* The tests' harness, `rom/pruebas/arnes/`, with what moved: the
  dump reader and the rules as an oracle. It belongs to the tests, and leaves
  with them when they're split off.

## Pending, on purpose

* The comments `rm2k-snes-mapdata` writes inside `mapdata.inc`
  still name `tools/port/snes_convert.py`, `events.py`, `scene.py` and
  `animation.py` (`emit/header.rs`, `record.rs`, `scene.rs`, `emit.rs`).
  Changing them changes the `.inc` —and perhaps the `.dbg`—, so it goes in its
  own commit, with the baseline taken again.
* The comments in `tools/runtime/` that cite the converter's Python:
  touching them changes the `.dbg`.
* The converter's modules that belong to a domain —`pictures.rs`,
  `animations.rs`, `scene.rs`, `fullscreen.rs`, `chipsets.rs`— can go to
  their stages (`rm2k-snes-images`, `wally`), but that changes requests and the
  hashes of those crates' tests.
* The dated material in `docs/research/` and `workflow/` still names the
  Python: it's a record.

## On merging

* `just -f tools/justfile install convert cartridge`: `convert` is new
  —without it nothing builds— and `cartridge` changed the fingerprint. `ditto` gained
  two functions, but it's a library: it goes in compiled into those two. Those of
  `events`, `mapdata` and `rm2k-snes-audio` only changed comments: not
  needed.
* A separate `install-scripts` isn't needed: the
  `rm2k-snes-convert` symlink points to `port/snes_convert.py`, which no longer exists, and
  `install` deletes the suite's symlinks before installing, so
  `cargo install` writes the binary in its place.
* With that, `NO_CACHE=1 just cartuchos` and `just pruebas` on `main`.
