---
name: "Rust: the maps domain"
description: "The converter's layers, sprites, VRAM, blocks and baking (map_layers, sprites, vram, blocks, baking, map_convert) to a domain crate in Rust, with the ROMs byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30: keep going with the migration of the converter to Rust, with
the maps domain, which already uses `rm2k-render`, Adeleine and `voodoo`. It is
a domain crate in `tools/rm2k-snes/`, shaped like
`tools/rm2k-snes/battle/README.md` ("One stage of a converter"), which the
Python orchestrator (`snes_convert.py`) calls through the PATH.

It branches off `main` at `3d83de68`. Baseline measured there: `NO_CACHE=1 just cartuchos`,
1032 files in `rom/build/` (without the cache, the `.o`s, `sello.txt` or
`conversor.log`), their sha256 in `<scratchpad>/mara/sha-base.txt`.

## Inventory: what the Python does today

The six pieces and what they use, read on 2026-09-30:

| module | what it does | which domain it belongs to |
|---|---|---|
| `map_layers.py` | quantizes to 15 bits the two layers `rm2k-render` draws, splits the low CGRAM between the background (8bpp) and the upper layer (4bpp), asks Adeleine which colours to merge and how to group them, builds the indexed images and hands them to Voodoo; and the on-disk cache of all that | the map background |
| `baking.py` | which opaque events on a ChipSet tile get painted into the upper layer, and only if that doesn't move the CGRAM split | both: it looks at the tile as a sprite and converts the layers twice |
| `sprites.py` | the characters as OBJ: which poses each graphic shows, the split of the eight palettes (`drawable_npcs`), the VRAM bank (`build_characters`), the cartridge's pose bank (`pose_bank`), which events walk (`movable_events`) and the copy of the hero's graphic that flashes | the map objects |
| `obj_extras.py` | what goes at the end of the sprite bank —timer digits, drops, the `ShowPicture` image, the battle animation's frame— and the palette cap | the objects, with pixels coming from other domains |
| `vram.py` | the six VRAM layouts, `vram_layout`, and the checks that the menu screens fall in the BG1 bank | the map picks its layout; the checks belong to the screens |
| `blocks.py` | the map as indices into 16x16 blocks with passability and terrain, and `Substitutions`, `TileSubstitution` translated to blocks | the background; `Substitutions` runs during compilation |
| `map_convert.py` | `convert_map`: assembles everything above into the `map_info`, and the parallel precomputation of the layers | the domain's orchestrator |

And what they use from outside: `rpgmaker/rm2k.py` (`collect_npcs`,
`passability_map`, `cell_passability`, `terrain_of`, `tile_name`,
`hero_start`), `render/render_map.py` (the `Renderer`, the `Charsets`,
`build_passability`), `port/adeleine.py` and `port/tiles_bin.py` (the two
binaries), `port/compiler.py` (the answer to the first call to the
compiler), `port/events.py` (constants, `MapEvents.route_target`,
`route_targets`), `port/map_record.py` (`npc_table`, `anim_bytes`,
`ev_pos_bytes`), `port/game_scan.py` (`map_start`, `images_of`),
`port/cases.py`, `port/window.py` (the System, for the timer),
`port/picture.py` and `port/animation.py`, and `common/settings.py`
(`graphics.palette_weight`).

## The boundary

**What the domain receives from the orchestrator** —decisions of the cartridge and
patches over the dump, never data the dump already has—:

* which map, and where to read what the project changed: the files of the
  map and ChipSet forks (`map_files`, `chipset_files`, as
  `rm2k-snes-events` already receives them), and where to look for the graphics (the game, the RTP
  and the built images of the fork's ChipSets);
* the leader candidates (`game_scan`), the empty event of the test page
  on the starting map, and the commands of the cases that run there;
* whether the cartridge carries a timer on that map, rain, the
  `ShowPicture` image and how many maps use each graphic (`maps_per_character`).

**What it receives from other domains, as data and not as code:**

* from the event compiler, the answer to its first call: which pages
  compile, which ones turn, which graphics commands 34 number and in what
  order (`movable_events` reads it);
* from the System, the eleven timer digits as pixels (`window`);
* from `picture`, the image's cells; from `animation`, whether any page
  of the map shows a battle animation that gets drawn and how many tiles
  its frame takes;
* from the game, where the hero starts (`tree.start_*`), which today
  `map_start` reads.

**What it returns**, which is what the `map_info` carries today and
`map_record`, `mapdata`, `materials` and `patches` read:

* the background: 8bpp tiles, the CGRAM words, the tilemap, the runs
  of the ChipSet animation with their drawings, and the summary (colours,
  budget, merges);
* the upper layer: 4bpp tiles, its CGRAM, tilemap, which palette it
  starts at and how many colours it merged;
* the indexed images of what Adeleine decided, for `rom/build/<cartucho>/adeleine/`;
* the objects: the VRAM bank, the palettes, where each slot ended up, the
  cartridge's pose bank per character, the timer's bases and palettes,
  the drops, the image and the frame, and the command 34 table;
* the blocks: the cells, the block table, passability and terrain per
  block, and the combinations `(low tile, high tile) -> block`;
* the collision, the start and the VRAM layout it gets;
* what the orchestrator needs to compile and emit: which events turn,
  change, appear, were left out.

**What belongs to another domain and stays outside:**

* **the emission** —`map_record` and `mapdata`—: the domain returns data and
  the emission writes it. `npc_table` is the edge: it builds each NPC's row
  with what the domain decided, and belongs to the emission;
* **the screens' checks** in `vram.py` (`_check_slots`,
  `_check_items_border`, `_check_target`, `_check_shop`): they look at where
  the menu, the shop and the slots fall, which belong to `menus` and `screens`, against
  the layouts. The maps domain owns the layouts, and
  publishes them; who looks at them belongs to the screens;
* **`Substitutions`**: it runs while the pages are compiled and creates
  new blocks in the `map_info` of an already converted map. It is the bridge
  between the compiler and the blocks, and it moves with the cartridge's
  orchestrator, not with the map;
* **which events get compiled, which route they carry and whom a command targets**:
  that belongs to the compiler, which is already in Rust; its answer arrives here;
* **drawing like RM2k** the layers and CharSets: it belongs to `rm2k-render`, and the
  domain uses it as a library;
* **which colours are lost and how they are grouped**: Adeleine's; **how the
  tiles are cut**: Voodoo's. Both as libraries.

## One crate or several

Three, so that Cargo guards what today only the order of the imports guards:

* `rm2k-snes/map-background/` (`rm2k-snes-map-background`, library):
  the low half of the CGRAM and BG1/BG2. The two quantized layers, the
  split between them, the conversion, and the 16x16 blocks. It doesn't know
  objects exist.
* `rm2k-snes/map-sprites/` (`rm2k-snes-map-sprites`, library): the high
  half of the CGRAM and the OBJ bank. It doesn't know layers exist.
* `rm2k-snes/maps/` (`rm2k-snes-maps`, the stage): it reads the game, applies what
  the request asks for, and does what needs both: the baking —which
  looks at the tile as a sprite and converts the layers twice— and the VRAM
  layout —which adds up what each one spends—. It depends on the two above.

The criterion: the two halves share nothing but the map, and the only thing
that crosses them —the baking and the VRAM— is exactly what today forces
`map_convert` to import from all of them. With three crates, the day someone
wants the sprites to look at a layer, `Cargo.toml` says so.

What doesn't justify a crate of its own: the VRAM (a table and a function of
three numbers) and the baking, which make no sense outside the stage.

**The global variables.** Ñacurutú noted two that touch this:
`_layers_in_memory`, which `precompute_layers` fills and `map_layers` reads, and
the hooks into `lcf`. The first exists because converting the layers in Python
is expensive and is spread across processes; in Rust, if converting a map costs
milliseconds, the in-memory cache and the precomputation go with it.
`las-variables-globales-chocan.md` is about the ROM's RAM and not about this.

## The plan

In parts, each in its own commit, with the ROMs identical:

1. **The layers**: `map_layers` to `rm2k-snes-map-background`, and the stage
   `rm2k-snes-maps layers`, which `converted_layers` calls instead of
   `rm2k-render` + Pillow + numpy + the two binaries.
2. **The blocks and the VRAM.**
3. **The sprites**: the palette split, the VRAM bank and the pose bank.
4. **The orchestrator**: `convert_map` whole, with the baking, a single
   call per map.
5. Delete the Python nobody uses anymore.

## Done

**The whole maps domain is in Rust**, in three crates, and the Python
that did it was deleted. The ROM, the `.inc`s, the `.sym`s and all of `rom/build/`
come out byte-for-byte identical to `main`'s with the Python; the PNGs in
`adeleine/`, identical decoded.

| commit | what |
|---|---|
| `90c6ff35` | the task: inventory and boundary |
| `7db8c984` | the layers: `rm2k-snes-map-background` and `rm2k-snes-maps layers` |
| `5a16e0c7` | merge of `main` (`591855c0`, Cachirla's work) |
| `f046e563` | the 16x16 blocks, with the layers |
| `d96f565d` | the task brought up to date |
| `756fe507` | the whole map: `rm2k-snes-map-sprites` and `rm2k-snes-maps map` |
| `df133150` | the Rust tests against the Python, and the whole-map one |
| `eb8624c9` | the three ABL tests that looked at the Python ask the stage (`bakeable`, `split`) |
| `dde35b1a` | the deletion, deletion only |
| `890d5587` | the prose that named what was deleted, and the READMEs |

**The crates** (`wc -l` of `src/`, without the tests):

* `rm2k-snes/map-background/`, library: `layers.rs` (the split of the
  low CGRAM, the quantization, the two conversions), `grid.rs`,
  `blocks.rs`. It depends on `adeleine`, `voodoo` and `rm2k-render`.
* `rm2k-snes/map-sprites/`, library: `character.rs` (colours, palette,
  poses), `npc.rs` (which poses each graphic shows), `split.rs` (the split
  of the eight palettes), `bank.rs` (the VRAM bank and the pose bank),
  `extras.rs` (timer, drops, image, frame). It depends on `adeleine`,
  `voodoo` and `rm2k-render`. **It doesn't depend on the background, nor the background on it.**
* `rm2k-snes/maps/`, the stage `rm2k-snes-maps`: `game.rs` (the dump and the
  forks), `events.rs` (the events and `collect_npcs`), `sheets.rs` (the
  CharSet sheets with the port's additions: baked translucents, dithered, the
  separate copy), `baking.rs`, `layers.rs`, `map.rs` (the whole map),
  `inspect.rs` (the two questions for the tests), `request.rs`,
  `main.rs`. It depends on the two above, on `ditto`, `rm2k-rules`,
  `rm2k-render`, `adeleine` and `voodoo`. Its README states the request and what it
  writes.

Subcommands: `map` —the one the converter uses, one per map, in parallel with
threads—, `layers` —only the layers; today its tests use it—, and `bakeable` and
`split`, which answer what the ABL tests look at and a screenshot doesn't
show.

**What changed from the planned boundary:**

* **`movable_events` stayed in Python.** Who walks is what the
  compiled bytecode sends walking, and that is known by walking the
  bytecode with the opcode sizes, which belong to the compiler. The stage
  receives the result —`movable`, `route_graphics`, `animates_still`,
  `turning`—. The clean way is for `rm2k-snes-events scan` to answer the route
  targets of each page; it is a change in the compiler.
* **The names of the translucent graphics and of the ones separated from the hero
  are still set by Python** (`lcf.DECORATE_TRANSLUCENT`,
  `separate_from_hero`), and they arrive in `names`, same as for the compiler.
* **The VRAM layout stayed in Python** (`vram.py`): the table is also read
  by the screens and the emission, and having it twice was worse. The
  stage returns how many tiles each thing spends, and Python picks and checks the
  animation's frame against the layout.
* **Where the hero starts moved to Rust**, with the collision.
* The `ShowPicture` image is picked and cut by Python (`events.Pictures`,
  `picture.cells`), and it travels already cut.
* `npc_table`, `ev_pos_bytes` and `Substitutions` stayed where they were:
  they belong to the emission and to the compilation.

**Ñacurutú's globals:** `_layers_in_memory` and `precompute_layers` are
gone, and with them the on-disk cache of the layers: the stage converts a whole
map without a cache, and the maps go in parallel. `NO_CACHE=1 just
cartuchos` went down from 54 s to 39 s. The hooks into `lcf` remain.

## How it was verified

With throwaway scripts in `<scratchpad>/mara/`:

* **Map by map, Python against Rust**:
  * the layers and blocks of the 93 maps of `release` —`test-special`
    uses a subset—, unbaked and with the bakings of the four that
    have them, field by field: 0 differences (`comparar_capas.py`);
  * the whole map: a throwaway `rm2k-snes-convert`
    (`convert_compara.py`) that in each cartridge converts each map with the
    Python `convert_map` and with the stage, and compares the whole `map_info`
    and what it prints: identical the 93 of `release`, the 7 of `test-special`
    and the 2 of `test-encounter-every-step`, and the output identical line by
    line.
* **The cartridges**: `NO_CACHE=1 just cartuchos` and the sha256 of all of
  `rom/build/` —minus the cache, the `.o`s, `sello.txt` and `conversor.log`;
  the `.dbg` without `mtime`—: 766 files, plus the 266 PNGs of `adeleine/`
  decoded. After each step, identical to the previous one; and at the end,
  **the whole tree against `main`'s Python (`591855c0`)** —the `.py` files of
  `tools/port`, `render`, `rpgmaker` and `common` from `main` put into the
  tree, built, and put back—: the 766 identical and the 266 PNGs identical
  decoded. With the cache on, cold and warm, identical too.
* **The sha256 of the ROMs**, identical in `main` and here:
  * `release/abl.sfc` `e97a574b5a2c8205f4a527f747499f0f122cabaacc94c36ace119ed3db2080a0`
  * `tests/special/prueba.sfc` `08862e741912ace6f6f5614c5520240b81d4973ab27c7ddb194cfe266c9162b5`
  * `tests/encounter-every-step/prueba.sfc` `ad16736073318221ae418dc7b103e18edc7a2b98d9bbd856e7d1549e27f73a30`
* **The suites**: `just pruebas`, 879 —they were 883: the four of
  `test_timer_paleta` that tested the mechanism with made-up palettes
  moved to `extras.rs`, because they don't need the game—;
  `just -f tools/justfile test`, 90; `cargo test` of the three crates and of
  `cartridge`, green.
* **The crates' tests don't depend on ABL**: those of the layers, the
  blocks and the sprites compare against the sha256 of what the Python gave
  for inputs built inside the test, taken before deleting it
  (`referencia_capas.py`, `referencia_sprites.py`); the stage's build
  a small game.

**The PNGs in `adeleine/` change in bytes and not in pixels**: they are written by
the `png` crate and not by Pillow, which compresses differently.

**A verification trap**: the `.dbg` changes depending on which
`rm2k-snes-assemble` builds, because it names the sources relative to its
checkout. With `cartridge` installed in the local `bin/` —it is needed, because
the fingerprint names `rm2k-snes-maps`— the baseline has to be built with
the local one too, or the three `.dbg`s come out different without anything changing.

## On merging

* Install globally `maps` —the new binary— and `cartridge` —the cartridges'
  fingerprint names it—: `just -f tools/justfile install maps
  cartridge`. Without `rm2k-snes-maps` in the PATH the converter stops and says
  how to install it.
* `rom/build/cache/capas/` goes stale: nobody reads it anymore, and it can be
  deleted.
* It doesn't move goldens or the ROM.

## What's missing

* **For the compiler to answer who walks** —the route targets of
  each compiled page— and for `movable_events` to leave Python.
* **The VRAM layouts in a single place**: today `vram.py` picks and checks
  them. If they move to the stage, it should publish them for the screens,
  like `rm2k-snes-cartridges --list --json`.
* **The timer colours are there twice**: `timer_colors_of` in
  Python, for the mask `snes_convert` emits, and `timer_colors` in
  `extras.rs`. It is the same rule; the mask could come out of the stage.
* **`voodoo` in the fingerprint**: the converter no longer runs the binary —the stage
  uses it as a library—, but it is still in `CONVERTER_TOOLS`. Removing it is a
  change to `cartridge`.
* **`rm2k-snes-maps layers`** is only used by its tests: decide whether it
  stays as an entry point or goes.
* The path of dithered translucents (`TRANSLUCENT_MODE=dither`) is not
  exercised by any cartridge; it is ported, with no test against the game.
* The `clippy` warnings of the three crates.
