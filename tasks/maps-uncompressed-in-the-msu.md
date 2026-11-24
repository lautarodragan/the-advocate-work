---
name: "Maps uncompressed in the .msu"
description: "Could each map's streams be stored compressed or not, per map, in the ROM and in the .msu? With MSU-1 a map uncompressed in the .msu goes up by DMA instead of through LZ2: faster loads without committing ROM"
type: research
status: testing
author: taro
assignee: taro
agents: [Hornero, Chajá, Carpintero]
game: vampires-dawn
links:
  blocked-by: [a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak]
  relates: [a-save-on-the-fx-pak-waits-for-a-silent-seek, lashe-city-transitions-lag, msu-data-seek-does-not-forget-where-the-effects-left-the-port, the-sram-as-slow-wram]
---

> Technically ROM doesn't "spare". Or rather, it's debatable. The msu is
> optional, but I made arbitrary decisions about what to send to the msu vs
> what to leave in the ROM. So it isn't so much "there is room for the
> decompressed map" as "we chose to make room in ROM for decompressed maps
> by sending graphics to the msu, that is, we decided we care more about
> loading 12 frames faster than about having higher-quality graphics".
>
> So the question becomes: do I prefer to use the free ROM for better
> graphics? more maps? decompressed maps? It stops being a binary decision.
>
> I guess that when we consider the port of ABL (or any given game)
> "complete", if there is free ROM, the logical thing is to try to use every
> byte left, if that can give a better experience. But since we aren't
> there yet, I don't dare commit ROM. The msu, instead, doesn't imply much
> commitment, because it is virtually unlimited.

> Let's explore it a bit more; I think an experiment or analysis is worth
> doing right now. Given that Vampires Dawn already loads maps from the
> msu, I want to know:
>
> - how much do those maps weigh in the msu, currently, being compressed?
> - how much would they weigh decompressed?
> - how complex would it be to add the option that maps can be compressed
>   or not, decided per map, both in the msu and the ROM?
>
> In ABL's case it would still be playable without msu, but the msu would
> not only allow better graphics but also offer better load times.
>
> For a game that requires the msu no matter what, the question becomes:
> what do we gain by storing them compressed? A modern internet connection
> gives 200 Mbit/s in the worst case [...] and if the game is in a .zip, the
> zip itself will compress the maps efficiently, so it only matters for
> disk space, and it's rare for someone to have less than 1 TB nowadays.

taro, 2026-11-22, after
[`lashe-city-transitions-lag`](lashe-city-transitions-lag.md) measured
7–15 frames of LZ2 per door in Lashe City.

## Log

### 2026-11-22, Hornero: taken for Chajá, to analyse and experiment

### 2026-11-22, Chajá: what the maps weigh, compressed and raw

On the-advocate `ec672f4c` and the ports `cb9f4f5`, `release` of both
games built in my worktrees, byte for byte the same as the main
checkout's. Measured with `sizes.py` (in `~/scratch/chaja/msu-raw/`): it
reads the packed `mapdata.inc` —each block's bytes in the ROM, each
`label = $3Duuuu` the packing sent to the `.msu`—, walks the LZ2 streams
of each spilled piece in the `.msu` to its last `$FF` (22 of them checked
by decompressing them against `raw/`), and takes the raw size from the
converter's `raw/<i>.<kind>.bin`. A "piece" is a block after the
converter's dedupe: two maps with the same bytes share it, compressed or
raw alike. The grid's piece carries `map_ram` (the block table and its
passability) behind it, and the bytecode's the page table.

#### Vampires Dawn: 430 maps

The `.msu` is 32,818,176 bytes; its spill region starts at 28,842,496
and holds 405 pieces (3,921,440 bytes padded to 256), **292 of them the
maps'**. The rest of the region is 32 big pictures, 34 panoramas, 11
battlers, 4 samples and the debug screen's 32.

| kind | in the `.msu`: pieces | LZ2 | raw | in the ROM: pieces | LZ2 | raw |
|---|---:|---:|---:|---:|---:|---:|
| background tiles | 260 | 2,611,806 | 3,585,408 | 135 | 441,119 | 736,832 |
| upper layer | 3 | 15,784 | 17,824 | 336 | 370,132 | 471,776 |
| sprites | 0 | | | 402 | 533,640 | 3,320,032 |
| ChipSet animation | 3 | 16,869 | 24,320 | 104 | 132,044 | 226,944 |
| grid + `map_ram` | 25 | 185,294 | 408,052 | 381 | 536,596 | 1,095,521 |
| bytecode + pages | 1 | 7,187 | 25,113 | 422 | 308,471 | 818,281 |
| **total** | **292** | **2,836,940** | **4,060,717** | **1,780** | **2,322,002** | **6,669,386** |

So **the maps weigh 2.84 MB in the `.msu` today** (2.87 MB padded), and
**4.06 MB raw**. The packing sends the largest pieces first, which is
why it is almost only backgrounds: 260 of the 395 there are.

What the `.msu` would be:

* **Today's spilled pieces raw, the rest as today**: +1.19 MB, 32.8 →
  34.0 MB. The ROM does not change.
* **Every map stream raw in the `.msu`**, none in the ROM: +7.86 MB, →
  40.7 MB, and 2.32 MB of the ROM free —into which the packing would
  bring back pictures, panoramas and samples, so the `.msu` would end
  somewhat under that—. The spill region would be some 12 MB of the 16 MB
  its 16-bit units reach (`LAST_UNIT` in `rm2k-snes-cartridge`'s
  `msu.rs`, `$FFFE` units of 256).
* Padding to 256 per piece adds ~0.13 KB a piece on average: ~0.27 MB
  over the 2,072 pieces.

#### A Blurred Line: 313 maps, all in the ROM

Its `.msu` is 8,068,096 bytes (no map in it; its spill region is the
debug screen's 25 pieces) and the tracks next to it 2.54 GB.

| kind | pieces | LZ2 | raw | raw − LZ2 |
|---|---:|---:|---:|---:|
| background tiles | 255 | 1,521,862 | 2,373,440 | 851,578 |
| upper layer | 90 | 53,872 | 70,848 | 16,976 |
| sprites | 262 | 285,600 | 1,271,520 | 985,920 |
| ChipSet animation | 41 | 60,304 | 108,096 | 47,792 |
| grid + `map_ram` | 262 | 276,278 | 717,569 | 441,291 |
| bytecode + pages | 308 | 170,702 | 346,414 | 175,712 |
| **total** | **1,218** | **2,368,618** | **4,887,887** | **2,519,269** |

* **A raw copy of every map in its optional `.msu`**: +4.89 MB (+0.16 MB
  of padding), 8.07 → ~13.1 MB, next to 2.54 GB of tracks.
* **Raw in the ROM instead**: +2.52 MB, and `just space release` leaves
  18 halves of 32 KB, 576 KB. Not even the backgrounds alone fit (+852
  KB); the sprites are the worst ratio (4.5 to 1).

#### How a zip of the `.msu` takes it

`gzip -9` (zip's deflate) and `xz -9` over the pieces concatenated, LZ2
against raw:

| what | bytes | gzip -9 | xz -9 |
|---|---:|---:|---:|
| VD, the `.msu`'s map pieces, LZ2 | 2,836,940 | 2,477,574 | 2,135,300 |
| VD, the same raw | 4,060,717 | 2,318,974 | 1,738,880 |
| VD, every map piece, LZ2 | 5,158,942 | 4,038,558 | 3,344,552 |
| VD, every map piece, raw | 10,730,103 | 3,804,427 | 2,690,076 |
| ABL, every map piece, LZ2 | 2,368,618 | 1,846,449 | 1,570,444 |
| ABL, every map piece, raw | 4,887,887 | 1,751,454 | 1,257,248 |

**Zipped, raw is smaller than LZ2**: deflate finds more in the raw
bytes than in LZ2's output, which is already half entropy. So in a zip
the download does not grow, it shrinks a little (−160 KB for VD's
`.msu` today, −230 KB if every map went). The whole VD `.msu` zips from
32.8 to 30.2 MB today (backdrops and BRR barely compress).

### 2026-11-22, Chajá: what a per-map "compressed or not" would take

Read on the-advocate `ec672f4c`. What exists today, and what each piece
would need.

#### The converter (`rm2k-snes-mapdata`)

* **Where the bytes are made**: `materials.rs` cuts each block into its
  streams (`compressed_parts`: the grid always in two halves of 32 KB, a
  background over 32 KB in two) and `stream_of` glues their LZ2. A raw
  block is the same block without the compression: easy. The **dedupe**
  key (`(kind, bytes)`) has to carry the format too, or a raw map and a
  compressed one sharing a block would get one of them wrong.
* **The caps** (`caps_per_stream`, `check_streams`, and the runtime's
  `.assert`s against `LZ2_BUFFER`) are those of the decompressor's output
  in WRAM. A raw background or sprite bank goes **straight to VRAM** and
  never passes through `LZ2_BUFFER`, so for it they disappear: no
  32 KB split, no two streams; the limit is VRAM's layout. The grid keeps
  its two halves —they are two WRAM addresses that do not touch,
  `$7E8000` and `$7F8000`—, and the bytecode its `LZ2_CAP_CODE`, which is
  `CODE_CARRY`'s room.
* **The flag in the record**: the record is full, but each pointer's
  fourth byte is free except two (the grid's, bit 0 = narrow; the
  animation's, the wrap bits). Bit 7 of the fourth byte of `map_tiles`,
  `above_tiles`, `sprite_tiles`, `anim_tiles` and `map_cells` can say
  "raw"; `map_code`'s table (8 bytes a map) has its fourth byte free too.
  The lengths are already there for the tiles (`MAP_TILES`,
  `ABOVE_TILES`, `SPRITE_TILES` × the tile size); the grid's, `map_ram`'s,
  the bytecode's and the animation's are not, and a 2-byte length in
  front of each raw block is the simplest (it is what the prototype does).
* **`decompress_frames`**, the boot's budget model, needs a raw term
  (8 master cycles a byte).

#### Who decides: the converter or the packing

This is the hard part. **The format has to be fixed before the packing
runs** —the record's flag and the bytes depend on it—, and **which pieces
go to the `.msu` is decided after**, by `pack_with_msu`, from the largest
down until the rest fits. Three shapes:

1. **The converter decides, per map, from the project file**
   (`[maps] raw = [...]`, or a rule like "raw where the ratio is worst").
   The packing stays as it is. In a game like Vampires Dawn the raw blocks
   are the largest, so they are the first to go to the `.msu`: in practice
   "raw" ends up meaning "raw in the `.msu`" without anyone saying it.
2. **Both, and the packing chooses**: the converter emits each block
   twice —LZ2 marked as a ROM candidate, raw marked `.msu`— and the
   record's fourth byte as a symbol (`map_tiles_7_fmt`) that the packing
   defines, as it already defines `label = $3Duuuu` for what it sends.
   The rule "raw if it travels in the `.msu`, LZ2 if it stays" then holds
   by construction. Cost: the packing learns pairs (drop one of each), and
   the `.inc` doubles its map data before packing.
3. **For an optional `.msu` (A Blurred Line)**: the ROM keeps its LZ2
   untouched, and **the `.msu` carries a raw copy, used only when it is
   valid**, like the battle backdrops. The copy is a `.msu_only` piece per
   map —the kind the debug screen already uses, which the packing sends
   always and names by unit—, and a ROM table, per map, of where its copy
   is (3 bytes a map: 1 KB for ABL). The boot already checks the region's
   signature for the debug screen; the loaders ask that flag. Without a
   `.msu`, or with another build's, nothing changes. This is the cheapest
   of the three on the converter's side, and the one that commits no ROM.

#### The runtime (`decompress.s`, `load_graphics.s`, `enter_map.s`)

| loader | today | raw from the ROM | raw from the `.msu` |
|---|---|---|---|
| `lz2_backdrop` (background) | LZ2 to `LZ2_BUFFER`, DMA to VRAM, twice if > 32 KB | one DMA ROM → VRAM | seek, one DMA `$2001` → VRAM |
| `lz2_field` (upper layer, sprites) | LZ2 to `LZ2_BUFFER`; the caller DMAs | point `A1T0L`/`A1B0` at the block: the old `dma_origin` | `msu_dma0`, which already does exactly this |
| `lz2_anim` (ChipSet animation) | LZ2 to `ANIM_DRAWINGS` | DMA ROM → `$2180` | DMA `$2001` → `$2180` |
| `lz2_grid` (grid, `map_ram`, bytecode, pages) | five streams, chained | DMA ROM → `$2180`, twice (one per half) | one seek, two DMAs `$2001` → `$2180`; `map_ram` rides behind the second half |
| `code_carry_after` (the left map's bytecode again) | LZ2 to `CODE_CARRY` | DMA → `$2180` | seek + DMA |

* **The branch is one test per loader** of the fourth byte's bit 7, and
  the raw path is shorter than the LZ2 one. The paths that are new are
  DMA to `WMDATA` from the ROM and from the port; the battle scene's
  `scn_fill` already does both, for its backdrop buffers.
* **WRAM**: a DMA through `$2180` cannot read WRAM, but the sources here
  are the ROM and `$2001`, so it does not apply. `WMADD` is 17 bits and
  goes on from `$7EFFFF` to `$7F0000`, but the grid's halves are not
  contiguous, so they stay two DMAs.
* **VRAM**: the loads run with the screen off, so a DMA of any size goes;
  without `LZ2_BUFFER` in between, a raw background goes in one DMA
  whatever its size (a DMA counts up to 64 KB).
* **The DMA stops the CPU, and the IRQs with it.** A 52 KB DMA is
  ~1.2 frames (8 master cycles a byte) with `irq_music` and the NMI held. LZ2 leaves them running.
  Whether that drops a note in the SPC700's stream during a door is not
  measured; cutting the DMA in pieces of a few KB is the fix if it does.
  The battle's 32 KB DMA from the port already does it in one go.
* **Seeks**: every piece read from the `.msu` costs one, and the
  effects' `MSU_SE_NEXT` has to be forgotten on each (as `lz2_msu` and
  `msu_dma0` do). The grid's chain at unit `$FFFF` works the same raw.
  **A map's raw pieces laid out together, in the order the load reads
  them, cost one seek per load instead of one per piece** —that needs
  the copy per map without the dedupe, which the `.msu`'s room allows—.
  This matters in Mednafen (each seek 400,000 master cycles, 1.1 frames,
  and the busy bit clears at the end of the frame: one to two frames)
  and on the FX Pak (below).
* **The 16 MB of the region** (16-bit units of 256): every VD map raw
  is ~12 MB of region. A 24-bit unit, or units of 512, would lift it if
  the `.msu` grows further.

#### The tests

`test_what_travels_in_the_msu_arrives_the_same_as_from_the_rom` (ABL)
compares VRAM and WRAM after each load with `raw/`, on `test-msu` and its
twin `test-msu-rom`. A raw format needs a third twin —or `test-msu` with
some maps raw— so that each new path (raw from the ROM, raw from the
`.msu`, the fallback when the `.msu` is not valid) is run by the suite;
without it, they are paths no test runs.

### 2026-11-22, Chajá: the experiment, a background and a grid raw from the `.msu`

A throwaway prototype, not for merging: the-advocate branch
`chaja-msu-raw` (`c9eed3da`, on `ec672f4c`; diff kept in
`~/scratch/chaja/msu-raw/prototype.diff`). `lz2_backdrop` and `lz2_grid`
first seek a slot per map in the `.msu` —at `$04000000 + index ×
$40000`, written by `append_raw.py` after the build, sparse— and, if its
length is not 0, DMA from `$2001`: the background tiles to `VMDATA` in
one DMA, the grid's first half to `$7E8000` and its second half with
`map_ram` behind to `$7F8000`, both through `WMDATA`. The bytecode and
the page table stay LZ2, so `lz2_grid`'s raw time still carries them.
Upper layer, sprites and the ChipSet animation are untouched. Without
the slots (or without an MSU-1) it falls back to LZ2.

**It loads the same bytes**: `check.py` compares VRAM's background
tiles and WRAM's grid and `map_ram` against `raw/` after each jump, main
and prototype alike: 0 bytes differ on ABL's 8, 9, 38, 52, 11, 312 and
VD's 195, 164, 201, 338 —66's and 312's tiles differ in the same ChipSet
animation drawings in both ROMs, which `anim_load` overwrites—.

**Measured** with `loads.py` on Mesen2's core and its line profiler: the
harness's door jump (`go_to_map`: the same fade and load a door does)
from a fixed map, twice, keeping the second. "Load" is from `lz2_grid`'s
entry to `pano_ppu`'s, the frozen tick's work: all of the map's loads,
the window, the tint and `code_carry_after`. Frames of 262 lines.

#### A Blurred Line, `release`: LZ2 from the ROM against raw from the `.msu`

| map | background LZ2 → raw | grid LZ2 → raw | load LZ2 → raw | saved |
|---|---:|---:|---:|---:|
| 8 (Lashe sector) | 8.39 → 0.63 | 4.02 → 1.87 | 16.48 → 6.58 | 9.9 |
| 9 (Lashe sector) | 7.45 → 0.55 | 3.24 → 1.25 | 14.17 → 5.26 | 8.9 |
| 11 (Lazer Teeth HQ) | 3.59 → 0.26 | 4.38 → 2.74 | 11.80 → 6.84 | 5.0 |
| 38 (sector 34) | 10.28 → 0.74 | 3.51 → 1.08 | 16.23 → 4.25 | 12.0 |
| 66 (largest background) | 10.84 → 0.79 | 8.07 → 1.16 | 23.01 → 5.83 | 17.2 |
| 148 | 10.16 → 0.81 | 5.08 → 1.10 | 19.85 → 6.52 | 13.3 |
| 108 | 8.68 → 0.71 | 5.06 → 2.47 | 21.90 → 11.27 | 10.6 |

#### A Blurred Line, `test-msu` and `test-msu-rom`: the three paths

The twins carry the same maps; `test-msu` sends everything that may go to
the `.msu` (all six pieces of each map), and the prototype was built from
`test-msu-rom` with the slots appended.

| map | load: LZ2 from the ROM | LZ2 from the `.msu` | raw from the `.msu` |
|---|---:|---:|---:|
| 66 | 22.94 | 25.53 | 6.07 |
| 312 | 19.30 | 21.76 | 7.52 |
| 52 | 14.93 | 15.83 | 5.39 |
| 11 | 11.65 | 12.53 | 6.63 |

LZ2 from the `.msu` is 0.9 to 2.6 frames slower than from the ROM in
Mesen2 —the literals through the CPU, as the book says—, and raw is 8 to
17 faster than either.

#### Vampires Dawn, `release`: LZ2 from the `.msu` against raw from it

The eight heaviest maps; all have their background in the `.msu` today,
six their grid too (164's grid is in the ROM and its bytecode in the
`.msu`; 201's grid is in the ROM).

| map | background LZ2 → raw | grid LZ2 → raw | load LZ2 → raw | saved |
|---|---:|---:|---:|---:|
| 195 | 14.17 → 0.84 | 12.92 → 1.69 | 35.63 → 11.08 | 24.6 |
| 338 | 13.03 → 0.83 | 12.74 → 2.10 | 31.47 → 8.63 | 22.8 |
| 164 | 9.93 → 0.62 | 10.82 → 7.53 | 28.44 → 15.83 | 12.6 |
| 181 | 9.60 → 0.60 | 11.53 → 1.21 | 25.71 → 6.39 | 19.3 |
| 179 | 9.63 → 0.59 | 12.65 → 1.42 | 26.52 → 6.25 | 20.3 |
| 161 | 11.94 → 0.71 | 6.97 → 2.24 | 25.69 → 9.74 | 16.0 |
| 163 | 13.69 → 0.84 | 7.10 → 2.36 | 26.26 → 8.68 | 17.6 |
| 201 | 12.23 → 0.77 | 5.41 → 2.24 | 28.27 → 13.64 | 14.6 |

**A background goes up raw in 0.3 to 0.8 frames, against 3.6 to 14 in
LZ2**: the DMA's 8 master cycles a byte (26 KB, 0.6 frames) and the
seek. What is left of the raw loads is the rest of the map, still LZ2:
sprites 1 to 2.6 frames, the bytecode and pages inside `lz2_grid` (164's
25 KB of bytecode, in the `.msu`, is its 7.5), the animation up to 3.3,
the upper layer up to 1.3. All raw, a map would load in some 3 to 5
(estimated from those shares, not built).

#### Mednafen: computed, not run

Mednafen is the only emulator here whose seek takes time, and its model
is a constant: `MSU1_WriteDataSeek` sets the busy bit for **400,000
master cycles**, 1.12 frames, whatever the distance (`snes_faust/msu1.cpp`
in Mednafen 1.32.1, `~/ref/mednafen-src`), and the status read does not
catch up, so it clears at the end of the frame where they elapse: 1.1 to
2.1 frames a seek. Its reads and DMAs cost what the other cores'. So
Mednafen = Mesen2 + seeks × 1.1–2.1, and the seeks per load are:

* ABL, LZ2 from the ROM: none. Raw from the `.msu` (prototype): 2
  (background, grid), **+2.2 to 4.2 frames**: Lashe 9 would be 7.5 to
  9.5 against 14.2. One seek if the map's pieces are laid out together.
* ABL `test-msu`, LZ2 from the `.msu`: 6, +6.7 to 12.7.
* VD: the same pieces from the `.msu` either way (two for most of these
  maps), so the saving is Mesen2's.

Running it would have taken a ROM that measures itself into the SRAM
—Mednafen has no scripting and the harness does not drive it—, for a
number its source already gives.

#### The FX Pak: not measured here

What is known, from taro's runs of the SRAM test ROM
([`the-sram-as-slow-wram`](the-sram-as-slow-wram.md)): **a data seek
with an MSU-1 track playing costs 2 ms** (0.12 frames); with none
playing, the firmware first checksums the SRAM, ~1.5 ms per KB, ~48 ms
(3 frames) for a 32 KB SRAM. A door between maps with the same song keeps
the track playing; one that changes it stops it first (`map_song_mute`),
so its seeks are the silent kind. **What is not known is whether the FX
Pak feeds `$2001` as fast as a DMA reads it**: the FPGA serves a 16 KB
buffer in two 8 KB halves, and the MCU refills the half left behind from
the SD card (`msu1_loop` in sd2snes's `src/msu1.c`); a DMA drains 8 KB in
~3 ms. If the card cannot refill a half in that time, the DMA reads stale
bytes —it would show as broken tiles, not as lag—. The battle backdrops'
32 KB DMA from the port has the same open question since 2026-09-26.
Without a source for the card's sustained rate, no estimate.

#### The limits on the `.msu`'s size

None is near:

* **The MSU-1's data port** is seeked with 32 bits (`$2000-$2003`): 4 GB.
  So do the emulators: bsnes `uint32 dataSeekOffset`
  (`sfc/coprocessor/msu1/msu1.hpp`), Mesen2 `uint32_t _dataPointer` and
  `_dataSize` (`Core/SNES/Coprocessors/MSU1/Msu1.h`), snes9x `uint32_t
  MSU1_DataSeekOffset` (`msu1.h`), Mednafen a `uint32` seek position; all
  stream the file instead of loading it.
* **The FX Pak's SD card is FAT32**: its FatFs (`src/ff.h` in sd2snes,
  `cf7e21d`) has no exFAT and keeps the size in a `DWORD`, so 4 GB − 1 per
  file. ABL's tracks are 2.5 GB in 106 files, each far under.
* **Ours**: the spill region's 16-bit units of 256 reach 16 MB. VD with
  every map raw would use ~12 MB of it. That is the only one in sight,
  and it is ours to widen.

The largest `.msu` in play would be VD's 40.7 MB, 1 % of 4 GB.

#### Zip

Zipped, raw maps take **less** than LZ2 ones (the table in the first
entry): −160 KB for VD's `.msu` as it is, −230 KB if every map went raw.
A zip of the game does not grow.

#### A correction to [`lashe-city-transitions-lag`](lashe-city-transitions-lag.md)

Its `measure.py` turned the profiler's `(frame, scanline)` into lines as
`frame × 262 + scanline`, but the core's frame turns at the NMI's line
(225), as `Mesen2.ticks` in the harness has it. So each routine's share
there could be off by up to a frame, either way; the doors' totals, which
come from `ticks`, are right. With the right formula (`loads.py` here),
LZ2 in Lashe's load is 13.3 (9), 15.1 (8), 15.3 (38) and 10.1 (11)
frames —background, grid and sprites—: the top of that task's "7 to 15",
and a bit over it on 38.

### 2026-11-22, Chajá: recommendation

**For a game that needs the MSU-1, keeping the maps compressed buys
nothing that matters.** In Vampires Dawn it saves 1.2 MB of `.msu` (the
pieces there today) or 7.9 MB (every map), in a file of 33 to 41 MB that
**zips smaller raw than compressed**, 1 % of the MSU-1's and FAT32's
4 GB. What it costs is **13 to 25 frames per load on its heaviest maps**
in Mesen2 (35.6 → 11.1 on 195), the same in Mednafen, where the seeks
are the same either way.

**For A Blurred Line, where the `.msu` is optional, a raw copy in it
saves 5 to 17 frames per load** with the MSU-1 (Lashe's sectors 9 to 12,
66 seventeen), 2 to 4 fewer in Mednafen for its two seeks, for +4.9 MB
next to 2.5 GB of tracks and no ROM. Raw in the ROM is out for now: every
map would be +2.5 MB against 576 KB free, and the backgrounds alone +852
KB.

So, in order:

1. **First, the FX Pak**: a test ROM like the SRAM one that DMAs 32 and
   64 KB from `$2001` in one go, from far-apart places, and checks them
   against a checksum, timing the seeks with and without a track. It
   answers this task's open question and the battle backdrops' at once.
   If the card does not keep up, the raw DMAs go in pieces with a
   wait in between, or this stops here. New draft:
   [`a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak`](a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak.md).
2. **Vampires Dawn: every map stream raw in the `.msu`.** With
   `msu = "required"` the converter can decide alone —no per-map choice,
   no help from the packing—: the map's pieces go raw and `.msu_only`,
   one piece per map in load order (one seek per load), and the ROM
   gets 2.3 MB back for what spills today. Runtime: a raw branch in each
   loader (`lz2_backdrop`, `lz2_field` through `msu_dma0`, `lz2_anim`,
   `lz2_grid`, `code_carry_after`), a seek per map, `WMDATA` for WRAM.
   No fallback path: without the `.msu` the game does not boot.
3. **A Blurred Line: the raw copy, used only when the `.msu` is valid**
   (shape 3 above): the ROM untouched, a `.msu_only` piece per map and a
   ROM table of where each is (~1 KB), the loaders asking the region's
   flag the debug screen already uses. The fallback is today's LZ2.
4. **A per-map choice** in the same cartridge (shape 2, the packing
   choosing between two emitted forms) only if a game needs raw maps in
   the ROM; none does today.

What it costs, all of it:

* **Runtime**: ~150–200 lines in `decompress.s` (the prototype's two
  loaders are 180 with their comments), the fourth-byte flag or a table,
  and splitting a DMA if `irq_music` minds a 1-frame stall (not measured).
* **Converter**: the raw emission and the dedupe key by format (or no
  dedupe for the `.msu` copies, for one seek a map), the lengths in front
  of each raw block, `decompress_frames`' raw term.
* **Packing**: little —`.msu_only` already exists—; the region's 16 MB
  only if a game grows past VD.
* **Tests**: a third twin of `test-msu` with raw maps, so that
  `test_what_travels_in_the_msu_arrives_the_same_as_from_the_rom` runs
  the raw paths and the fallback; without it they are paths no test runs.
* **Size**: VD +7.9 MB of `.msu` (less zipped), ABL +4.9 MB.

#### What was run

* `just cartridges release` for ABL and VD, and `test-msu` and
  `test-msu-rom` for ABL, in a ports worktree at `cb9f4f5`: with the
  global tools (main, `ec672f4c`) and with `.local-tools` (`project`,
  `cartridge`) from the prototype's worktree. Copies in
  `~/scratch/chaja/msu-raw/rom-*`.
* `sizes.py` and `summ.py` (sizes; with `DUMP=` the concatenations
  gzipped and xz'd in `zip/`), `append_raw.py` (the slots), `loads.py`
  (the timings, `runall.sh` and `runvd.sh`, outputs in `out/`) and
  `check.py` (the bytes), all in `~/scratch/chaja/msu-raw/`.
* No suite: the prototype is not for merging and nothing else changed.
  `main` moved to `1b8825d8` (Hurón's `try_pack`, Adeleine) while this
  ran; it was not merged into the prototype, and it may move these sizes
  by a little, not the timings' shape.

Nothing to install or merge: the prototype branches stay local —the-advocate
`chaja-msu-raw` (`c9eed3da`); the ports' `chaja-msu-raw` has no commit—.

### 2026-11-22, Carpintero: what to look at

No capture: this is a research —sizes and load times measured over a
prototype that was not merged—, and no build taro plays carries anything
of it. There is nothing to look at on the console; what is left to decide
is in the log above: the sizes, the load frames, and what the per-map
choice would cost.

### 2026-11-23, Hornero: a build to play, taken for Chajá

The big DMA from `$2001` held on the FX Pak in every run since
([`a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak`](a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak.md),
done). taro, after playing the faster Lashe transitions:

> by the way, I could confirm that the transitions between maps in ABL
> are MUCH better now.
>
> anyway, I'd like to try the experiment: can you put together a build
> that has Lashe City's big maps in the msu, without compression? or
> maybe all the maps? as you think best

All the maps, with the prototype brought up to today's main.

### 2026-11-23, Chajá: every map raw, a build to play

On the-advocate `75d46e3c` and the ports `8aef866`, branches
`chaja-msu-raw-2` in both (local, not for merging).

#### What changed from the prototype

* **All five map pieces raw**: background tiles, grid (with `map_ram`),
  ChipSet animation, upper layer and sprites. The bytecode and the page
  table stay LZ2: they are small in ABL (346 KB raw over 308 pieces), and
  whether a map's bytecode goes to WRAM at all is the converter's choice
  (`code_in_rom`), which the post-processor cannot see.
* **One seek per load**: a map's five pieces go one behind the other in
  `enter_map`'s order, each at a 256-byte unit, and a loader that finds
  the port at most 255 bytes before its piece reads the padding instead of
  seeking. Where the port was left is `MSU_SE_NEXT`, which the sound
  effects already keep; `msu_data_seek` now forgets it too, so the
  backdrops and the save's flush make the next piece seek. On the FX Pak
  a silent seek costs ~48 ms with ABL's 32 KB SRAM
  ([`a-save-on-the-fx-pak-waits-for-a-silent-seek`](a-save-on-the-fx-pak-waits-for-a-silent-seek.md)),
  so this matters on doors that change the song.
* **Packed, not sparse**: the prototype's 256 KB slots at 64 MB would be
  a 144 MB file on the card's FAT32. Now the pieces go right behind the
  `.msu`, and **the directory (10 bytes a map, 3 KB) goes in the ROM**,
  in bank `$FF`, zeros as built: far RAM has 64 bytes left, and a
  directory in the `.msu` would cost a second seek per load. So the
  post-processor, `pack_raw.py`, also fills it and writes the header
  checksum again: **the delivered `abl.sfc` is not the build's byte for
  byte**.
* **Tied to the ROM**: the `.msu`'s header carries "RAWM" and the packed
  ROM's header checksum at `$FFF0`, in the zeros that pad its index; a
  `.msu` without them, or another build's, falls back to LZ2. That is
  what the suite runs.
* **The loaders live in bank `$FF`**, reached with `jsl`: `test-msu`,
  the cartridge that needs the MSU-1, had less than their 700 bytes left
  in bank 1 and did not link.

#### The bytes

`check_raw.py` (in the ports' `abl/experiments/msu-raw/`) runs the same
packed ROM twice on Mesen2's core, with the raw `.msu` and with today's
(the fallback), and after the harness's door jump from map 10 compares
the whole VRAM, the grid with `map_ram` and the ChipSet drawings in WRAM
between them, and the grid, drawings and background tiles against
`raw/`. On maps 8, 9, 11, 38, 52, 66, 108, 148, 312, 1, 2, 20, 100, 150,
200, 250, 300 and 350: **the whole VRAM identical, 0 words**, and grid,
`map_ram` and drawings equal to `raw/`. (The background tiles differ from
`raw/` on the maps with a ChipSet animation, in the drawings `anim_load`
overwrites, the same on both sides, as in the prototype.)

With `MENU=1` it also goes to the pause menu and back, which reloads
through `back_to_map` in another order —the loaders seek instead of
finding the port in place—: 8, 66 and 148 identical; 9 differs in 193
words of the sprite slots (`$0947-$0BBC`), which hold the poses the
characters show at that tick. Background, upper layer and grid equal
there too; I read it as the two sides not landing on the same tick after
the menu, not proven. A battle and back is not checked.

#### The doors, in Mesen2

`loads.py` as in the prototype —the harness's door jump from map 10,
twice, the second kept; "load" from `lz2_grid`'s entry to `pano_ppu`'s,
in frames of 262 lines—, on the packed ROM with today's `.msu` (LZ2, the
path main takes) and with the raw one:

| map | load: LZ2 | raw, all five pieces | the prototype's raw (two pieces) | seeks LZ2 → raw |
|---|---:|---:|---:|---:|
| 8 (Lashe sector) | 16.49 | 4.37 | 6.58 | 1 → 2 |
| 9 (Lashe sector) | 14.17 | 3.13 | 5.26 | 1 → 2 |
| 38 (sector 34) | 16.24 | 3.12 | 4.25 | 1 → 2 |
| 11 (Lazer Teeth HQ) | 12.06 | 5.06 | 6.84 | 1 → 2 |
| 66 (largest background) | 23.00 | 3.52 | 5.83 | 0 → 1 |
| 148 | 19.85 | 3.94 | 6.52 | 0 → 1 |
| 108 | 22.15 | 8.40 | 11.27 | 0 → 1 |

The LZ2 column is the prototype's main to a hundredth. **One seek more
per door, never more**: the one seek LZ2 already has on the Lashe maps
is not a map's (a sound effect's, I think). In raw, the background goes up in 0.3-0.9 frames,
the sprites in 0.1-0.4, the animation and the upper layer under 0.2;
what is left is the grid's DMA plus the bytecode and pages, still LZ2
(1.1-3.1 frames, 108's the most), and the rest of `enter_map`.

On the FX Pak that seek is ~2 ms with the song playing, ~48 ms (3
frames) when the door changes the song and the firmware checksums the
SRAM first. Not measured on the console.

#### The suite

ABL's whole suite with the branch's tools (`project`, `cartridge`
installed in `.local-tools`): **1692 passed, 2 skipped**, in 5 min 35 s.
It runs the fallback only: no test packs a raw `.msu`. Before it,
`test_decompressed_load.py` and `test_linter.py` alone, green.

#### Delivered

`/shared/builds/abl-msu-raw/`, copied by hand from the committed
branches (the-advocate `7794939c`, the ports `146127c`; the build's
`release`, packed again from it): `abl.sfc` sha1
`73c82d04ec30816f11dbcc272dd04ff0e5060f69`, `abl.msu` (13,519,872 bytes)
sha1 `3b4378fe2e9c79d214e7bf90aee95e367d659fe0`, `abl.sfc.dbg`,
`runtime/` and a `README.txt`. No tracks: ABL's `abl-N.pcm` from
`/shared/builds/abl/` go next to them, with the same names.

#### What no test covers

* The raw path itself: the suite runs only the fallback. `check_raw.py`
  is a script run by hand, on 18 maps and 4 menu trips.
* A battle and back (`back_from_battle` reads the grid after the
  sprites), saving and loading, and a sound effect from the `.msu`
  between two pieces of a load.
* Mednafen (each seek 1-2 frames there) and the console.
* Whether the DMA from the port, up to ~35 KB (map 66's background,
  ~0.8 frames with the CPU stopped), drops a note in the music.

#### Found and not fixed

* [`msu-data-seek-does-not-forget-where-the-effects-left-the-port`](msu-data-seek-does-not-forget-where-the-effects-left-the-port.md):
  `msu_data_seek` moves the port without resetting `MSU_SE_NEXT`, so
  after a save a sound effect from the `.msu` could read from the wrong
  place. Read, not seen. The branch fixes it for itself.

#### Branches, local, not for merging

* the-advocate `chaja-msu-raw-2`: `782daa0b` (the prototype,
  cherry-picked), `6c2b5375`, `7794939c`.
* the ports `chaja-msu-raw-2`: `59a65b4`, `146127c`
  (`abl/experiments/msu-raw/`: `pack_raw.py`, `check_raw.py`,
  `loads.py`).

Nothing to install. `main` was not merged into them, so they stay the
commits the build came from.
