---
name: "LZ2 where it goes raw"
description: "Compressing with LZ2 what today goes raw and is uploaded on loading: the block table, the bytecode, the battlers, the cutscenes' animations, the font and the light battle backgrounds; some 470 KB in the whole game, without losing anything"
type: feature
status: done
assignee: taro
---

Phase 1 of the plan of [`docs/research/2026-10-01-el-juego-entero-sin-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-el-juego-entero-sin-msu-1.html)
(Tucu-tucu), measured by Lechuza in
[`docs/research/2026-10-01-los-mapas-por-el-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-los-mapas-por-el-msu-1.html), section 5. From taro, on
2026-10-01, after moving to 8 MB (`decisiones/el-cartucho-pasa-a-8-mb.md`). The
poses and the music sequences cannot be: they are read while in use, and why is
in the study.

## How it is going (Quirquincho, 2026-10-01)

Base: `cd3dce0d`, `abl.sfc` at `ccdf1191…`. Each step, with `NO_CACHE=1 just
cartuchos`, `just pruebas` and `just -f tools/justfile test`; the load time
with the method of `_cargar` in `test_carga_descomprimida.py` —the hardware
frames of the loop iteration that loaded— over the 97 maps of `release`, and
the battle with `SCN_FRAMES` in the case `pelea-en-52`.

### 1. The block table and its passability: done

They can be: the CPU reads them only through `blocks_ptr`, `blocks8_ptr` and
`pass_ptr`, 24-bit pointers that `enter_map` builds from the record. They now
live in WRAM **behind the grid**, in a third LZ2 stream stuck to the grid's two
(`map_ram` in `materials.rs`): `lz2_grid` decompresses it where the second one
ended, and that is why they come back on their own with `back_from_battle`. The
record brings the WRAM addresses, which the converter computes; the ROM does
not compute them, and `test_carga_descomprimida.py` checks that they match and
that the content is that of `crudos/N.map_ram.bin`, on loading each map and on
returning from the battle on 52.

* In `release`: 119.2 KB raw, 61.7 KB in LZ2 (the converter's report). `just
  espacio`: from 62 data banks to 61, and the gaps from 7,406 B to 0.
* Load: +39 frames over the 97 maps, +0.4 on average, median 0, maximum +2. The
  battle does not change.
* No golden moved; both suites green.
* The hashes of `tests/python.rs` of `rm2k-snes-mapdata` changed on purpose:
  they are the cartridge's bytes.

### 2. The battlers: done

They can be, but not "at the start and that's it": the CPU reads them again
**throughout the whole battle** —`scene_tick` redraws the ones still alive on
top of an erased enemy, and a hidden enemy is drawn when it appears—, so they
have to stay in WRAM. They go to the half of the grid in `$7E` (`SCN_BATTLERS =
GRID`): the battle does not read the map, and `back_from_battle` already
decompressed the whole grid. `scn_battlers_load` decompresses the troop's
distinct battlers —those of `SCN_PAL_BAT`— one after the other and notes where
each one landed per palette slot (`SCN_BAT_PTR`, `$7E6650`); the converter
stops if a troop's go over 32 KB (in `release`, the heaviest is 15 KB).
`scn_terrain`, which reads the grid, runs before.

* In `release`: the gaps of `just espacio` go from 0 to 62,525 B (147 KB of raw
  battlers).
* The droid battle on 52 composes in 11 frames instead of 10; the maps do not
  change. The entry to the battle is to black, so it is not seen.
* `test_reservas_de_la_wram.py` lets `SCN_BATTLERS` through, and the grid's
  decision says so.

### 3. The battle animations (the cutscenes' ones): done, frame by frame

They can be, but not "at the start of the battle", as the study said: they are
drawn by `ShowBattleAnimation` **on the map** —the troop pages do not compile
it— and `anim_frame_build` builds them in the main loop, with the screen on.
Each frame goes in its own LZ2 stream and is decompressed when its turn comes
into one of two places of `LZ2_BUFFER` —free on the map once loaded—, the one
that does not have the previous frame, whose tiles are erased first. The battle
overwrites `LZ2_BUFFER`, so `scene_upload` calls `anim_buf_clear`.

**I tried first the whole animation in one stream**, decompressed when building
its first frame: it saved more —67,696 B to 28,171, against 37,354 frame by
frame—, but the animation's first tick took up to 4 hardware frames (148, of
13.7 KB) and 2 for most: the map stalled at the start of each animation. Frame
by frame, measured over the 21 animations of `release` on map 6 with the
method of `test_animacion_cuadros.py`, no tick goes over one frame.

* In `release`: 67,696 B raw, 37,354 in LZ2. `just espacio`: from 61 data banks
  to 60.
* `test_animacion_cuadros.py` builds each frame of each animation through the
  game's path and compares it with the uncompressed count.
* **A path slipped past me**, and I fixed it in a separate commit: coming back
  from the menu, the shop, the slots or a battle goes through `back_to_map`,
  which uploads the map's tiles through `LZ2_BUFFER` and overwrites the
  previous frame; erasing it read background tiles as box numbers, left old
  tiles and wrote beyond `ANIMB_BUF`. `back_to_map` now calls
  `anim_buf_clear` (instead of `scene_upload`), and
  `test_la_caja_vuelve_entera_del_menu` enforces it: red without the fix
  (frames 4 and 5 of 148), green with it.

### 4. The light battle backgrounds: done

They can be: the CPU reads the light fallback only once, in `scn_double`, which
enlarges it into the scene's two buffers at the start of the battle. Now it is
decompressed beforehand into the half of the grid in `$7E` (`SCN_BATTLERS`),
and the battlers are decompressed afterwards, on top: `scn_battlers_load`
moved from before `scn_backdrop` to after. The suite runs without MSU-1, so
the fallback's path is the one the goldens and `test_batalla_escena_dibujo.py`
look at.

* In `release`: 73,728 B raw (18 backgrounds of 4 KB), 55,331 in LZ2. The gaps
  of `just espacio` go from 27,331 B to 45,728.
* The droid battle composes in 12 frames instead of 11 (10 at the base), to
  black.

### 5. The events' bytecode: done, with what keeps running on another map

It is read from the ROM while it runs —`[code_ptr], y`—, so it goes to WRAM:
behind the block table, in an LZ2 block of its own that the `map_code` table
names (placed stuck to the grid, two maps with the same grid and other events
stopped sharing it: it was 6 KB). The page table points to WRAM. A page's jumps
are relative to where it starts.

**The problem was what keeps running after a `Teleport` to another map**: the
new map puts its bytecode in the same place. In `release` there are 282 pages
that continue after jumping (counted over the dump, with the `CallEvent`s
inside), and besides **each case of the suite** starts by jumping and
continues. And the hero's forced route points to the bytecode of the page that
gave it and keeps walking on the new map (`Game_Player::PerformTeleport` does
not cut it). What is done:

* `code_carry_before`, at the start of `enter_map_no_events` and with the old
  map still in `map_current`: if the foreground page is in that map's
  bytecode, its pointer moves to `CODE_CARRY` (in `LZ2_BUFFER`, above the
  battle animation's frames); and the hero's route, if it points to the
  bytecode's bank, is copied whole to `ROUTE_CARRY` (`$7E7F00`, 256 B).
* `code_carry_after`, at the end of the load and of `back_to_map` —which
  uploads the tiles through `LZ2_BUFFER`—: it decompresses there the bytecode
  of the carried map (`CARRY_MAP`, `$7E7EF0`).
* Everything else that points to the bytecode does not survive the map change:
  the parallels, the events' routes and the animation's timeline start over
  with the new map.

The first version forgot `back_to_map`: with the menu, the slots or a battle in
the middle of a carried page, the page read background tiles. Seven tests of
the suite caught it —`test_guardar_golden.py`, `test_curar.py`,
`test_experiencia_dibujo.py`—, and it uncovered the same error in the battle
animation (the separate commit above).

* In `release`: 124.7 KB of bytecode, 80.2 in LZ2. `just espacio`: from 60 data
  banks to 59, and the gaps from 45,728 B to 25,045 —44,853 B less—.
* Load: +0.4 frames on average over the 97 maps, +6 on 4 (which in `release`
  carries the 262 cases). Carrying costs another decompression inside the
  fade.
* The race, which is the tightest on CPU, does not lose frames from reading the
  bytecode from WRAM (8 cycles per byte against 6): driving, 49 loses 35 frames
  in 976 ticks before and after, 52 5 and 4, 54 0 and 1.
* `test_carga_descomprimida.py` checks the bytecode in WRAM against
  `crudos/N.map_code.bin` and `map_code` against where it ended up;
  `test_la_ruta_del_heroe_sigue_entera_en_el_mapa_nuevo` checks the route's
  copy, which no case runs.

### 6. The font: it cannot be

The CPU reads it **every time it composes text** (`messages.s`, `font_pre_lo`
and `font_pre_bk`): the four pre-shifted phases, 59,280 B in `release`, would
have to live decompressed in WRAM all the time, on the map and in the battle,
and there are not 58 KB free at any moment —on the map `LZ2_BUFFER` is left,
24 KB, and in the battle not even that—. A single phase and shifting it at run
time would be another format, not LZ2. And the texts are Guayacán's.

## What is left (Quirquincho, on delivering)

The commits, on `cd3dce0d`:

    86343e26  the block table and its passability, behind the grid
    25f90404  the battlers, to the half of the grid during the battle
    496a0f25  the frames of the battle animations, one by one
    c3c958ab  the light battle backgrounds
    6b7569ce  fix: the animation's box is cleared on returning to the map
    14139ad9  the events' bytecode, behind the grid, and carried

What was saved in `release`, in ROM bytes used (banks × 64 KB minus the gaps of
`just espacio`):

    block table + passability        58,130
    battlers                         62,525
    battle animations                30,342
    light backgrounds                18,397
    bytecode                         44,853
    total                           214,247   (209 KB)

`just espacio`, before and after:

    release                62 banks, gaps 7,406 B      ->  59, gaps 25,045 B
                           bank 0 269 B, bank 1 4,241 B -> 247 B and 3,890 B
    test-special           16 banks, gaps 57,838 B     ->  15, gaps 21,304 B
    test-encounter-every-step  7 banks, 30,784 B       ->  7, 36,716 B

The load time, in hardware frames of the iteration that loads (the method of
`_cargar`), over the 97 maps of `release`: **+76 among all of them, +0.8 on
average, median +1, maximum +6** (4, which carries the suite's cases). The
droid battle composes in 12 frames against 10, to black. The screens (title,
Game Over) do not change: they touch none of this. Coming back from the menu,
the shop or the slots with a carried page costs one more decompression of the
bytecode.

No golden moved. `just pruebas`: 936 (934 + the two new ones); `just -f
tools/justfile test`: 39; `cargo test` of `rm2k-snes-mapdata`.
`test_musica_techos.py` passes.

**When merging**:

* Install `mapdata`: `just -f tools/justfile install mapdata`. Nothing else in
  Rust changed, and no Python script.
* **It clashes with Guayacán** in `rm2k-snes-mapdata`: I touched
  `materials.rs`, `record.rs`, `scene.rs`, `emit.rs` (the animations section)
  and the hashes of `tests/python.rs`, which are the bytes of the `.inc`: with
  both changes together they have to be taken again, on purpose.
* Far RAM taken: `$7E7EF0-$7E7FFF` (`CARRY_MAP`, `ROUTE_CARRY`) and
  `$7E6650-$7E665F` (`SCN_BAT_PTR`, inside the scene's range). If Guayacán took
  something in `$7E7A50-$7E7FFF`, they clash without git saying anything.
* Bank 0 went down 22 B: the tightest is still `release`.
