---
name: "Rust: the emission"
description: "What writes mapdata.inc (mapdata, map_record, materials, blocks, vram, map_layers, compress) to Rust, with mapdata.inc identical line by line and the ROMs byte for byte"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-01: "in parallel, can we move forward with some migration
from Python to Rust?". All the domains that feed the emission are already Rust
(events, maps, screens, battle, images, music, patches); what's left
in `tools/port/` is almost all emission and glue. It was the last thing in the plan,
together with the orchestrator (`snes_convert.py`), which comes after.

Baseline: `main` at the commit that launches the task, `abl.sfc` `8f8bf5b3c5facf51…`,
`just tests` 923, `just -f tools/justfile test` 46.

Measured on the baseline, with `cartridge` installed in the local `bin/` —the
cartridges' fingerprint will name the new binary, and the `.dbg` changes depending on
which assembler builds (Mara's trap)—: `NO_CACHE=1 just cartridges`,
1035 files in `rom/build/` without the cache, the `.o` files, `stamp.txt` or
`converter.log`; their sha256 and the three `mapdata.inc` in
`<scratchpad>/timbo-emision/`.

* `release/abl.sfc` `8f8bf5b3c5facf517fdf3a758326d2fddafcfe9f16ab88fb3bf5c139c1b29c87`
* `tests/special/prueba.sfc` `007c02045ba39d719dc4e8796a6f1fce8c08e0419e3410affc836dac0cda9e6e`
* `tests/encounter-every-step/prueba.sfc` `c236bdc0e7765f8dd2f5292a6062ffe57b98da0618aaf59e867bb9e173d349c1`

## Inventory: what the Python does today

Read on 2026-10-01:

| module | what it does | what it is |
|---|---|---|
| `compress.py` | runs `lz2 compress --no-increasing` through the PATH, counts a stream's commands and refuses the two that `lz2_decompress` doesn't read | leaf; also used by `fullscreen.py` (title and Game Over), which belongs to the images |
| `materials.py` | the data blocks with their own name and their deduplication (`Materials`), which classes go in LZ2, in how many streams and with what WRAM caps (`compressed_parts`, `check_streams`), the cost of decompressing the starting map (`decompress_frames`, which goes to the music request) and the raw ones the tests read (`write_raw`) | emission |
| `vram.py` | the six VRAM layouts, which one a map gets (`vram_layout`), their hardware checks (`_check_splits`), the window's bases and the slot screen's addresses | the contract with the runtime: read by the maps (`map_convert`, to choose), the screens (`screen_stage`, BG1's banks) and the emission |
| `map_layers.py` | `layers_answer` —reads `rm2k-snes-maps`' answer in the shape of the `map_info`— and the low CGRAM constants (`CGRAM_RESERVED`, `PRIORITY_ABOVE`, `BACKDROP`, `window_palette`) | `layers_answer` is the orchestrator's glue; the constants, the emission's |
| `blocks.py` | `Substitutions`: `TileSubstitution` translated to 16x16 blocks, building the missing ones before compiling; and `substitution_triples` | it isn't emission: it's the bridge between the compiler and the map's blocks |
| `map_record.py` | each map's record (`map_table`, `offsets`), the ChipSet animation (`anim_table`, `anim_bytes`), the pages (`page_table`), each map's data blocks (`map_data`), the NPC tables (`npc_table`, `npc_bytes`), the pose and leader tables, and the events' positions (`ev_pos_bytes`) | emission; `npc_table` and `ev_pos_bytes` are called today by `map_convert` |
| `mapdata.py` | `emit`: the constants header, the poses, each map, the window and the font, the picture, the animations, the title, the screens, the menu, the items, the equipment, the battle, the skills, the troops, the scene, and the bank 0 tables | emission |

And of the four the brief asked to look at: of `sprites.py` only the
constants are the emission's (`OBJ_PRIORITY*`, `OBJ_COLORS`, `SPRITE_POSES`,
`POSE_BYTES`, `block_tile`); `separate_from_hero` and `maps_per_character`
are choice and go to the maps request. Of `picture.py`, `cells` and
`reserved_tiles` belong to the maps request and `OBJ_SIDE`/`GRID` to the
emission. Of `battle_animations.py`, `rom_animations` is choice (which
animations the cartridge carries) and `animations_asm` emission. Of
`battle_scenes.py`, `rom_scene` and the uses of patches are choice, and
`scenes_asm` emission.

## The boundary

**A new crate, `tools/rm2k-snes/mapdata/` (`rm2k-snes-mapdata`)**, with
the shape of "One stage of a converter": library and binary. It's the
emission: it receives what the other domains already decided and writes
`mapdata.inc`. It doesn't choose anything that isn't about how it's written —which blocks are
shared, how the streams are split, in which segment each table goes—.

* **It receives from the orchestrator**, in a request: what each domain answered,
  as data —the maps (tiles, CGRAM, blocks, sprites, compiled
  pages), the window and the screens, the picture, the animations, the
  scene, the battle tables, the battle model, the troop
  pages, the equipment common events— and what belongs to the cartridge —the
  starting map, the initial party, the knobs—.
* **It reads from the game itself**, with Ditto, what `emit` reads today from the database:
  items, skills, enemies, actors and troops (`rm2k-snes-battle`'s `Db`,
  and its rules for the parameters).
* **It writes** `mapdata.inc`, the raw files in `crudos/`, and a JSON with what
  the rest needs (the report of what was shared and compressed).

**Where each leaf lives**:

* `compress` and `materials` → `rm2k-snes-mapdata`. Compression uses `lz2`
  as a library, in threads. `compress.py` stays while
  `fullscreen.py`, which belongs to the images, uses it.
* `vram` → `rm2k-snes-mapdata`, which **publishes** the layouts: `vram`
  answers the table, the constants and which one each map gets. It's the
  contract with the runtime —what the `.inc` says about VRAM—, and that way
  the maps and the screens read it from a single side, as Mara asked.
* `map_layers`' constants → `rm2k-snes-mapdata`; `layers_answer`
  stays with the orchestrator.
* `blocks` (`Substitutions`) → `rm2k-snes-maps`, the map stage: it's the
  one that builds the blocks, with the same passability rules. The request
  carries the `TileSubstitution`s that can run on the map, and the
  answer brings the blocks already enlarged, the table for the compiler and
  the ones that couldn't be built. Which pairs a page asked for —`SUB_MAX`— is
  still counted by the orchestrator with what the compiler answered.

**What stays in Python**: the orchestrator (`snes_convert.py`,
`map_convert.py` and `layers_answer`), which gathers each domain's output and builds
the request; `compress.py` for `fullscreen.py`; and what the request needs
from other domains still in Python (`animation.cells`, the scene's
bytes).

## The plan

1. **The leaves**: `compress`, `materials` (compression and streams),
   `vram`, `map_layers`' constants; and `blocks` to the maps stage.
2. **`map_record`**: what's emitted per map.
3. **`mapdata`**: the rest of the tables and assembling the file.
4. **The deletion**, in its own commit, deletions only. The prose that
   named what was deleted, in another.

Each stage: `mapdata.inc` of the three cartridges identical line by line, and
all of `rom/build/` byte for byte, with `NO_CACHE=1`.

## Done, stage by stage

### 1. The leaves

* `74055585`: compression and streams (`compress.rs`, `materials.rs`), the
  VRAM layouts (`vram.rs`, which the stage publishes with `vram`) and the
  low CGRAM constants (`cgram.rs`). `vram.py` stays as a reader of
  what's published. The layouts' and the streams' tests moved to the
  crate.
* `68038577`: `Substitutions` to `rm2k-snes-maps` (`substitutions.rs`): the
  map request carries the `TileSubstitution`s and the answer brings the
  enlarged blocks, the table for the compiler and the missing ones. `SUB_MAX`
  moved to `snes_convert.py`. `blocks.py` is left unused.

### 2. `map_record`

* `260c36ed`: `rm2k-snes-mapdata maps` writes everything that goes per map
  —record, tables, pages, NPCs, poses, blocks with their LZ2, raw files— in three
  pieces that `emit` puts in their place. `pages` writes a page table
  alone, for the ABL test that looks at it. The crate's tests compare
  against the sha256 of the baseline's Python, over a hand-built request
  (`tests/maps.json`).

### 3. `mapdata`

* `ac8b075b`: `rm2k-snes-mapdata emit` writes the whole `.inc` —the
  constants header, the window and the font, the picture, the
  animations, the title and the complete screens, the slots and the menu,
  the text screens, the equipment, the battle, the skills, the troops
  and their pages, the scene, the bank 0 tables, and `timer_mask` and
  `CASE_SLOT`, which `snes_convert` added afterwards—. `mapdata.py` stays
  as the builder of the request.
* `42332816`: the tests of the whole `.inc` against the Python's hashes,
  over two built cartridges (`tests/emit-*.json`) with the database of
  `rm2k-snes-battle`'s test game: one bare and one with everything.
* `f4544820`: merge of `main` (Tangle Forest, by Tacuarita). It clashed in
  `mapdata.py`: its two new header constants, `TIMER_SLOT` and
  `COND_TIMER`, moved to the template in `emit/header.rs` and to `engine.rs`.
  From there on the tests' hashes are those of `main`'s Python
  (`601c6f9a`).

How it turned out, inside:

* **The request carries the other domains' answers as they are**:
  `rm2k-snes-screens convert`'s whole one —with its geometry—, the battle
  model's, the compiler's troop pages, the battle tables. What
  belongs to another domain still in Python arrives as bytes and numbers:
  the animations' frames with their anchor (`animations_request`) and the
  scene with its backgrounds, battlers, positions and drawing order
  (`scene_request`).
* **The stage reads the database**: items, skills, enemies, actors and
  troops, with `rm2k-snes-battle`'s `Db` and rules, which is what
  it depends on.
* **The long constant templates were copied from the Python as they were** and
  are filled by `pyfmt.rs`, a Python `%`: that way the text comes out identical character
  by character without transcribing a hundred and sixty-six arguments by hand.
* **A latent bug in the Python**, fixed: `tpage_var` and `tpage_value`
  read the fields `ranura` and `valor` of a `Trigger` that since the
  translation are called `slot` and `value`. No page in any RM2k game
  uses that condition, so it was never evaluated; it has its test.

### 4. The deletion

* `9470aba5`: before deleting, what the orchestrator still took from
  `map_record` —the `map_info`'s sprite tuple, which nobody read anymore, and
  `PARALLEL_MAX` and `ROUTE_EV_MAX`, which move to `snes_convert.py` next to
  `SUB_MAX`—.
* `36a6a8db`: **deletions only**. `map_record.py`, `materials.py`,
  `blocks.py`, `asm.py` and `color.py` whole; from `battle_animations.py` and
  `battle_scenes.py` what they wrote for the `.inc`; the constants that
  only the emission read in `map_layers.py`, `sprites.py`, `obj_extras.py` and
  `constants.py`; `commands` from `compress.py`; from `rules.py`,
  `equipped_params` and the battle terms. 1812 lines.
* `40f7527a`: the prose that named what was deleted —docstrings, comments,
  `README.md`, `tools/README.md`, `AGENTS.md`, `docs/port/maps.md` and
  `vram.md`, three ABL tests, two crates— and the crate's README.
* `0a160c4d`: the block combinations, which the `map_info` kept
  carrying without anyone reading them.
* `bf45a944`: `cartridge`'s fingerprint test, which didn't know about
  `rm2k-snes-mapdata`.

## What stayed in Python

* **The orchestrator**: `snes_convert.py`, `map_convert.py` and `layers_answer`
  —they gather each domain's output and build the requests—, `mapdata.py` —the
  emission's request— and `vram.py` —the reader of the layouts the
  stage publishes—.
* `compress.py`, which `fullscreen.py` uses for the title and the Game Over.
* What the emission's request needs from domains still in
  Python: `animation.py`'s frames and `scene.py`'s scene stuff.

## How it was verified

With the scripts in `<scratchpad>/timbo-emision/` (`base.sh`, `huellas.py`):
`NO_CACHE=1 just cartridges` with the stamps deleted, and the sha256 of all of
`rom/build/` —minus the cache, the `.o` files, `stamp.txt` and `converter.log`; the
`.dbg` without `mtime`—, with the three `mapdata.inc` separately.

* **Before the merge**, after each commit of stages 1 to 3: the 1035
  files and the three `mapdata.inc` identical to `052cb999`'s baseline.
* **After the merge**: the baseline was taken again on `main`
  (`601c6f9a`) —its Python and its `events`, `maps` and `cartridge` binaries,
  installed in the local `bin/`—, and the merged tree, with this
  branch's binaries, gave **the 1075 files identical**, after the merge and after
  each deletion commit. The `mapdata.inc` of the three cartridges,
  identical line by line: 305476, 65718 and 28581 lines before the merge.
* The ROMs, identical to `main`'s:
  * `release/abl.sfc` `19e771abd78b329153a2fc77717a87f521f1afc65a499c2abe1f67d5b7465b3c`
  * `tests/special/prueba.sfc` `4f091bfd8de4a5869d19b5bfe09dc9169f294bd48ec2a8feb9ac1ab64fcfefe9`
  * `tests/encounter-every-step/prueba.sfc` `555c3be1d826d01759473ec8e6d52c12639f079107095a453f3e4e5729d72ec2`
* **Against the Python, outside the cartridges**: the crate's tests
  compare with the sha256 of what the Python wrote over inputs
  built to go through each path —including those no cartridge
  walks: no title, no Game Over, no picture, no animations, no battle
  audio, no troop pages—. A throwaway script took them
  (`gen_record.py`, `gen_emit.py`), running the Python over the same thing; the
  outputs were identical line by line before noting the hashes.
* The suites, on the final tree: `just tests`, 934 —it was 936 on `main`;
  two from `test_lz2.py` moved to the crate—; `just -f tools/justfile test`,
  39 —it was 46; the seven from `test_vram_layouts.py` moved to the crate—;
  `cargo test -p` of `rm2k-snes-mapdata` (38), `rm2k-snes-maps`,
  `rm2k-snes-events`, `rm2k-snes-images` and `rm2k-snes-cartridge`, green.

What the converter's log changes, and isn't in the fingerprint: the line "the
map fits in N 16x16 blocks" now counts the blocks the
substitutions built, because the stage builds them before answering. And `NO_CACHE=1
just cartridges` takes the same as before, some 45 s.

## On merging

* Install in the global **`mapdata`** —the new binary—, **`maps`** —its
  request carries the substitutions and the new `map_convert` sends them— and
  **`cartridge`** —the fingerprint names `rm2k-snes-mapdata`—: `just -f
  tools/justfile install mapdata maps cartridge`. They go together with the Python:
  without `rm2k-snes-mapdata` the converter stops and says how to install it, and the
  old `maps` doesn't understand the new request. `events` and `images` only
  changed a comment.
* No Python script changed name: `install-scripts` isn't needed.
* It doesn't move the ROM or the goldens.

## What's missing

* **The engine's constants are there twice**: in `engine.rs`, from where
  the `.inc` emits them, and in `events.py`, with their long comments, because
  ABL tests read them. The same for `SUB_MAX`, `PARALLEL_MAX` and `ROUTE_EV_MAX`
  (`snes_convert.py` and `record.rs`) and `OBJ_PRIORITY*` with `block_tile`
  (`sprites.py` and `objects.rs`). They leave Python when the orchestrator
  moves to Rust, or earlier if ABL's tests read them from the `.inc`.
* **What each page draws** (`oam`, in `snes_convert`) is still built
  in Python with `where` and `block_tile`: the emission could build it, since it already
  has the map's objects.
* **What's emitted to the `.inc` still cites the Python** ("Generated by
  tools/port/snes_convert.py", "see `anim_table` in
  tools/port/snes_convert.py"), and runtime comments name files
  that no longer exist (`frame_without_gaps` in `battle_animation_frames.s`,
  `Substitutions` in `interpreter_map.s`). Both things change the `.inc` or
  the `.dbg`: they go in their own commit, when it's decided to touch what's emitted.
* `compress.py` goes when `fullscreen.py` switches to using the stage.
