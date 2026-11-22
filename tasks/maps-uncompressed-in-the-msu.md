---
name: "Maps uncompressed in the .msu"
description: "Could each map's streams be stored compressed or not, per map, in the ROM and in the .msu? With MSU-1 a map uncompressed in the .msu goes up by DMA instead of through LZ2: faster loads without committing ROM"
type: research
status: doing
author: taro
assignee: Chajá
agents: [Hornero, Chajá]
game: vampires-dawn
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
