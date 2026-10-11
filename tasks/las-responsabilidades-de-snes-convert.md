---
name: "The responsibilities of snes_convert.py"
description: "snes_convert.py split into eighteen modules by console resource, without changing the ROM; main() remains"
type: refactor
status: done
assignee: taro
---

`tools/port/snes_convert.py` is huge (how many lines and functions: `wc -l`
and `grep -c '^def '`). taro wants to go over its responsibilities, on
2026-09-26, with no urgency.

First an inventory: what parts it has (the conversion of maps, graphics,
palettes, events, audio, the VRAM layout, writing the `.inc`s, the test cases,
the command line, …), which already have their module (`eventos.py`,
`escena.py`, `asignador.py`, `batalla.py`, `tools/audio/`) and what was left
in the big file that belongs to something else. Then, a partition proposal
with the criterion of the `main.s` cut: first the mechanical part (moving
without changing), verified with the cartridges byte for byte identical, and
then the judgement part.

**It goes after the converter's time optimization** (in progress on
2026-09-26), which mustn't refactor anything so as not to mix the two things.

Related: taro wants all the tools to end up in Rust, not for speed; when that
is tackled, it'll be decided which parts make sense.

The inventory by sections, with line ranges and what is engine and what is
RM2k tooling, is in `docs/research/el-mapa-de-las-herramientas-de-python.md`
(§2), with a snapshot from 2026-09-28.

## Taken on 2026-09-29

For step 4 of the road to Rust (`docs/research/las-herramientas-hoy.md`): the
converter is migrated in parts, and first it has to be split. The time
optimization that was holding it back has happened. The file is still called
`tools/port/snes_convert.py`, but it's now in English and uses `rm2k-render`
and `rm2k-snes-audio` from the PATH.

## The inventory

On `d4811ece`: 9,680 lines and 135 top-level functions. The dependencies come
from an AST script that looks, for each function or constant, at which other
names in the file it refers to; it was thrown away. The ranges are from that
commit.

| lines | part | what it does | depends on | who uses it |
|---|---|---|---|---|
| 1-101 | imports and hooks | sets `DECORATE_TRANSLUCENT` and `REFIT_TEXTS` on `lcf` **on import** | — | the whole process, and any test that imports `snes_convert` |
| 102-386 | the background layers, 1 | the CGRAM split between the 8 bpp background and the 4 bpp overlay layer, the quantization to 15 bits, the overlay layer as an indexed PNG | `allocator`, `tiles_bin` | `_convert_layers`, `convert_window`, `emit` (constants) |
| 387-723 | the character as a sprite | colors, poses, each CharSet's palette, which poses each graphic shows on the map, the weight for the allocation | `allocator`, `rm2k`, `settings` | `drawable_npcs`, `build_characters`, `convert_map`, `emit` |
| 724-940 | baked events | which opaque events get painted onto the overlay layer, and only if they don't move the CGRAM | the converted layers, `render_map`, `events` | `convert_map`, `_map_layers`, `test_horneados` |
| 941-1338 | drawable NPCs and the sprite bank | which NPCs fit in the eight OBJ palettes and the VRAM pose bank | the character part | `convert_map`, timer and flash tests |
| 1339-1716 | the sprite bank's extras | timer, rain, the `ShowPicture` image, the battle animation box, and how many palettes are left; `npc_table`, `maps_per_character` and `has_rain` stayed here by proximity | the character part, `picture`, `animation` | `convert_map`, `main` |
| 1718-2121 | the background layers, 2 | the palette, the conversion of both layers with Voodoo, and the on-disk and parallel cache of the layers | the 102-386 part, `render_map`, `tiles_bin`, `disk_cache` | `convert_map`, `main` (`precompute_layers`) |
| 2123-2612 | the tilemap window and the VRAM layouts | the six layouts, the save slots, and the checks that each screen lands where the ROM assumes | `menus`, `screens` | `convert_map`, `main`, `emit`, `test_vram_layouts` |
| 2613-2812 | the message window and the font | the window's tiles, palette and cells, the font and its per-phase prerender | `window`, `font`, `constants` | `main`, `emit` |
| 2814-3088 | the 16x16 blocks | the map as indices into blocks with passability, and `TileSubstitution` translated into blocks | `rm2k`, `events` | `convert_map`, `main`, `test_substitutions` |
| 3089-3340 | each map's record | the fields of the 128-byte record, their offsets, and the map table | the NPC, event and terrain sizes | `emit`, `main` |
| 3341-3417 | the ChipSet animations | the runs of water and of the animated families, per map | `FAMILIES` | `convert_map`, `emit` |
| 3418-3572 | the battle animations | which animations the bytecode asks for, and their frames as the cartridge stores them | `animation`, `events` | `main`, `emit`, `test_animacion_cuadros` |
| 3573-3654 | experience | the experience tables per actor | `experience`, `lcf` | `emit` |
| 3655-4069 | the backgrounds and the battlers | which ones the cartridge carries, who asks for them, and their emission with the lightweight backgrounds | `scene`, `events` | `main`, `emit`, `test_msu_datos` |
| 4070-4100 | `block` | the emission primitive: a `.byte` block with its `.block` or `.align` | — | almost everything that emits |
| 4101-4246 | the pages table | a map's event pages, with the pointer to their code | `events` | `map_data`, `test_paginas` |
| 4247-4500 | the material and the compression | the blocks with their own identity (`Materials`), what goes compressed, in how many streams, the WRAM caps, and the raw ones | `compress` (the `lz2` from the PATH) | `emit`, `main`, `test_lz2` |
| 4501-4633 | each map's data, encounters, identity | a map's blocks, the random encounters, the header's title | the NPC and pages parts, `settings` | `emit`, `main` |
| 4634-6868 | **`emit()`** | the whole `mapdata.inc`, in a 2,234-line function | almost everything above | `main` |
| 6869-7288 | NPC and event tables | NPC and event sizes, the drawing order, the map order, which events move, the save signature, the sine, the NPC and actor tables | `events`, `rm2k` | `emit`, `convert_map`, `main` |
| 7289-7396 | the command line | `flags_parser` | `environment`, `project` | `main` |
| 7398-8360 | **`main()`** | orchestrates everything | everything | the executable |
| 8361-8692 | the music | the job for `rm2k-snes-audio`, the separate themes, the boot cap, the data `.msu`, which themes the packages inherit | `msu_data`, `settings`, `project` | `main`, `test_inherited_songs` |
| 8693-9012 | the analysis of the game | where the hero starts, which actors can lead, which items and members can be there, what each troop drops; with the global `args_game_dir` | `events`, `lcf`, `resources` | `main`, `convert_map`, `test_lideres` and the timer and flash ones |
| 9013-9133 | the test cases | splitting the command line into `--case`, each case's page, which map it runs on | `events`, `lcf` | `main`, `convert_map` |
| 9134-9677 | **`convert_map()`** | a whole map: layers, sprites, blocks, layout | almost everything of the layers, sprites, blocks, VRAM and cases | `main`, `_map_layers` |

What already has its module and is **not** here: the bytecode (`events.py`),
the scene (`scene.py`), the allocator (`allocator.py`), the battle
(`battle.py`), the menus and screens, the title, the picture, RM2k's window
(`window.py`), the fonts (`font.py`), the animations as images
(`animation.py`), RM2k's rules (`rules.py`), the PPU format
(`snes_format.py`), and the music itself (`rm2k-snes-audio`).

What was left here and belongs to something else: **three parts that convert
nothing** —the analysis of the game, the test cases and the command line—,
**the emissions that aren't the map's** —experience, backgrounds, battle
animations, music and `.msu`—, and **the resource plans** —CGRAM, VRAM, sprite
bank, compression— mixed in with their emissions.

## The proposal

One module per piece that can be replaced on its own when migrating to Rust:
each one with an input that can be written as data —the map read, the images,
the plan's numbers— and an output that can too. `snes_convert.py` keeps
`main()`, the `lcf` hooks and the imports.

The line counts come from simulating the whole move on a copy, with the same
script that does it. All in `tools/port/`, in English.

| module | what it has | input | output | lines |
|---|---|---|---|---|
| `snes_format.py` (already exists) | `COLORS_PER_PALETTE` and `BYTES_PER_TILE` | — | — | +2 |
| `asm.py` | `block` and `pointer`, the emission primitives | bytes | ca65 text | 38 |
| `map_layers.py` | the two background layers: the CGRAM split, the quantization, the conversion with Voodoo, and their cache | the drawn layers | tiles, CGRAM, tilemaps | 615 |
| `sprites.py` | the characters as OBJ: poses, palettes, which NPCs get drawn, the pose bank, what moves, the hero that flashes | the map, the CharSets, the leaders | the sprite bank and its palette allocation | 897 |
| `obj_extras.py` | what goes at the end of the sprite bank: timer, rain, picture, battle animation, and the palette cap | the System, the picture, the animation | each one's tiles and palette | 315 |
| `baking.py` | the events baked into the overlay layer | the map and its render | the map with the tiles set | 224 |
| `vram.py` | the VRAM layouts, the slots, and their checks | how much each layer spends | which layout it gets | 472 |
| `message_window.py` | the message window and the font | the System, the font | tiles, palette, cells, prerender | 238 |
| `blocks.py` | the 16x16 blocks and the substitutions | tilemaps and passability | indices and the block table | 280 |
| `materials.py` | `Materials`, what goes compressed, the streams, the WRAM caps, the raw ones | each map's data | LZ2 streams and the raw ones | 245 |
| `map_record.py` | each map's record, pages, NPCs, actors, ChipSet animations, and a map's data blocks | what `convert_map` returns | ca65 text | 865 |
| `battle_animations.py` | the battle animations | the emitted bytecode | frames and their text | 161 |
| `battle_scenes.py` | the backgrounds and the battlers | troops, maps, tree | what the cartridge carries and its text | 429 |
| `battle_tables.py` | the experience and the encounters | the database, the maps | tables | 137 |
| `music.py` | the job for `rm2k-snes-audio`, the themes, the inheritance, the boot and the data `.msu` | the maps and the tree | the job, and the `.msu` | 348 |
| `game_scan.py` | what's deduced from the whole game: leaders, items, members, start, rain | the maps and the database | sets of ids | 294 |
| `options.py` | `flags_parser` and `map_order` | `argv` | `args` | 127 |
| `cases.py` | the test cases | `argv` and the case files | the pages and their maps | 158 |
| `mapdata.py` | `emit()`, with the ROM's identity, the save signature and the sine | the converted maps and everything else | `mapdata.inc` | 2,366 |
| `map_convert.py` | `convert_map()` and its parallel precomputation | a map id and `args` | the `map_info` | 627 |
| `snes_convert.py` | `main()` and the `lcf` hooks | — | — | 1,077 |

**The why of the cut.** It follows the stages that
`docs/research/inspeccion-integral-del-repo.md` proposed —input and options,
planning, emission, diagnostics—, but doesn't group them into four modules: it
groups them by **console resource**, because that's what a Rust piece can take
whole. The background's CGRAM and VRAM are `map_layers`; the objects' CGRAM
and VRAM, `sprites` and `obj_extras`; the VRAM ordering, `vram`; the WRAM of
the compressed stuff, `materials`. And the emissions go separately from the
plans when what crosses between the two is data: `map_record` and `mapdata`
only read what `convert_map` already left in the `map_info`. Diagnostics don't
have their own module because they aren't a stage: they're each part's
`SystemExit`s and `print`s, and they go with it.

**What isn't split now, on purpose:** `emit()`. Its stretches share dozens of
locals, so splitting it means deciding what passes from one to another, and
that's judgement. It moves whole to `mapdata.py`, and splitting it is left for
another commit. The same for `main()` and `convert_map()`.

**How it's moved.** A script that cuts the top-level nodes with the comments
above them, builds the new module's imports by copying `snes_convert`'s, and
adds to the latter a `from port.<módulo> import …` with what it ended up
missing. The order of the commits is the dependency order —a module only
imports from the earlier ones—, so no cycle can remain, and none imports from
`snes_convert`. No re-exports: the tests import from the new module. The names
don't change, neither do the private ones that cross modules (`_check_slots`,
`_tile_alphas`): renaming them is another commit.

**What can already be seen can't be split without changing logic**, and gets
noted instead of fixed:

* **the `lcf` hooks** are set when importing `snes_convert`. A test that
  imports only `sprites` or `game_scan` reads the maps without them. The ones
  that today import `snes_convert` and stop using it keep importing it because
  of that;
* **`_layers_in_memory`** is a `map_layers` dictionary filled by
  `precompute_layers`, in `map_convert`: mutable state between two modules;
* **`args_game_dir`** is a global list in `game_scan` that `main` writes;
* **the `.inc` texts that name `snes_convert.py`** —the header, `anim_table`,
  `escribir_msu`— still say that: correcting them changes the `.inc`, and each
  of these commits leaves it the same.

## Done, on 2026-09-29

The proposal, as is, in one commit per module and in dependency order:
`snes_format` (+2 constants), `asm`, `map_layers`, `sprites`, `obj_extras`,
`baking`, `vram`, `message_window`, `blocks`, `materials`, `map_record`,
`battle_animations`, `battle_scenes`, `battle_tables`, `music`, `game_scan`,
`options`, `cases`, `mapdata` and `map_convert`. Then, a prose commit guided by
the diff of those. How many lines each has is told by `wc -l
tools/port/*.py`; `snes_convert.py` was left with a single function, `main()`.

**How each commit was verified:** `NO_CACHE=1 just cartuchos` with
`rom/build/release` and `rom/build/tests` deleted, and the sha256 of all of
`rom/build/` except the cache, the `.o`s, `sello.txt` and `conversor.log`
—`.sfc`, `.msu`, `.pcm`, `.inc`, `.sym`, `.dbg` without `mtime`, `.json`,
raw ones—: the 999 files identical to `d4811ece`'s in all twenty. Also `just
pruebas` and `just -f tools/justfile test`, green on all of them. With the
cache on, cold and warm, also identical, in the two commits that touch the
cached stuff (`map_layers` and `map_convert`). And a check with `symtable` that
no new module uses a name it doesn't define or import. The merge of `main`
with Hocó's work didn't move any of the 999.

**The layers' cache key** adds `port/snes_format.py` and
`port/map_layers.py`, in the commit that moved what they use.
`port/snes_convert.py` stays in the list even though it no longer has anything
of the layers: removing it is a separate decision —it would stop invalidating
the cache every time `main()` is touched—, and `_layers_version`'s docstring
says so.

## What couldn't be split without changing logic

* **The `lcf` hooks.** `snes_convert` sets `DECORATE_TRANSLUCENT` and
  `REFIT_TEXTS` on `lcf` when imported, so a process that imports only
  `sprites`, `game_scan` or `map_record` reads the maps without them. The six
  tests that imported `snes_convert` and no longer use anything from it
  —`test_horneados`, `test_paginas`, `test_lideres`, `test_timer_paleta`,
  `test_destello_paleta` and `test_msu_datos`— keep importing it because of
  that, with a comment. The clean thing would be for `lcf` to receive them as a
  parameter or for a port module everyone imports to set them; both change
  when they're set.
* **`_layers_in_memory`** is a `map_layers` dictionary filled by
  `precompute_layers`, in `map_convert`. They couldn't stay together:
  `_map_layers` prepares the map like `convert_map` —bakes, separates from the
  hero, reads the cases— and that above `map_layers` is a cycle.
* **`args_game_dir`** is a global list in `game_scan` that `main` writes and
  `_game` reads. It was already like that; now it crosses modules.
* **The private ones that cross modules**: `main` calls `_check_slots`,
  `_check_items_border`, `_check_target`, `_check_shop` and `_check_splits` of
  `vram`; `mapdata` uses `message_window`'s `_columns`; `map_convert` uses
  `baking`'s `_bake_unless_cgram_moves` and `map_layers`'s
  `_layers_in_memory`; `test_horneados` uses `_tile_alphas`. Renaming them is a
  separate mechanical commit.
* **`emit()`, `main()` and `convert_map()` whole**, of 2,234, ~960 and ~540
  lines. Their stretches share locals, and splitting them means deciding what
  passes from one to another. The table of `emit()`'s stretches is in
  `docs/research/el-mapa-de-las-herramientas-de-python.md`, §2.
* **The `.inc` texts that name `snes_convert.py`**: the header of
  `mapdata.inc`, the comment of `anim_table` (which also names `rom/src/`) and
  the `.msu`'s (which says `escribir_msu`). Correcting them changes the `.inc`s
  and not the ROM; it goes in a commit that accepts that.

## For taro

There's nothing to play: the ROM comes out byte for byte identical. What needs
looking at is whether the cut is the one you want for the migration to Rust;
the proposal's table says what goes into and out of each module.
