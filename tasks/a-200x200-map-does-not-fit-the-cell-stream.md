---
name: "A 200x200 map does not fit the WRAM cell stream"
description: "rm2k-snes-mapdata stops the whole build at Zounds' map 30 (200x200): its map_cells stream is 47,232 bytes and 32,768 fit in WRAM; no other map of the eight ports gets near"
type: bug
status: testing
assignee: taro
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**What happens**: `rm2k-snes-mapdata: map 30: a stream of map_cells is
47232 bytes and 32768 fit in WRAM: see the LZ2 reservation in
runtime/far_ram.s`, and the build stops. Map 30, "Sueño 2 (Hover Tram)",
is 200x200 = 40,000 cells; the next largest in Zounds is 100x50, and the
limit at that rate (~1.18 bytes per cell) is about 27,700 cells. The
study excluded the map in the toml to go on.

**What to decide**: whether a map over the reservation is left out with a
warning —as events over 120 or pictures over two are— instead of stopping
the build, and whether the reservation can grow or the stream be split
for a map that size (the console's own limit is the 64 KB of a bank for
the decompressed layers, not WRAM's 32 KB half).

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: still
so —`check_streams` in `rm2k-snes/mapdata/src/materials.rs` stops the
build, and Zounds' `rm2k-snes.toml` still excludes map 30—. A correction
to the arithmetic above: `map_cells` is not compressed at ~1.18 bytes per
cell; it is the grid, two bytes per cell, cut in two streams of up to
`HALF_GRID` (32 KB) each —`compressed_parts`—, one per half of bank
`$7F`. 40,000 cells are 80,000 bytes: the first half takes 32,768 and the
second is the 47,232 of the message. The limit is then the 64 KB bank,
32,768 cells (a 181x181 map), not about 27,700.

## Defined

Todo, on 2026-10-16, by Cardón, at the-advocate `f4709d0b`: Zounds still excludes map 30
by hand. Two things, the first is the task and the second is measured:

**Done** means a map over the grid's room does not stop the build: it is
left out with a WARNING and a loss in `degradations.json`, as events over
120 are, and Zounds' `excluded = [30]` goes. Whether map 30 can be held at
all —the grid is 64 KB of bank `$7F` at two bytes a cell, so 32,768 cells;
a byte per cell, or a grid read from ROM, would be the ways— the agent
measures and writes down, without building it unless it is cheap.
**First step**: `check_streams` in `rm2k-snes/mapdata/src/materials.rs`,
and how the converter already leaves out a map it cannot hold.

**Why it matters now** (Aguará, 2026-10-17): map 30 is Zounds' dream
after sleeping in Uname's bed, and only it turns on switch 47, which the
next scene waits for: without it the story stops on map 17 —see
[`zounds-sleeping-in-unames-bed-leaves-the-screen-black`](zounds-sleeping-in-unames-bed-leaves-the-screen-black.md)—.
What it is made of, read from its `.tiles`: 15 distinct (lower, upper)
tile pairs, the upper layer all 10000, and 3,776 of its 40,000 cells not
the background tile 5143 —rails across the whole map, edge to edge, so
no crop holds it—. A byte per cell would be 40,000 bytes.

## Work (Aguará, 2026-10-17)

The goal changed when it was taken: **carry map 30 and play through it**,
since the dream is the only map that turns switch 47 on, and keep the
general part —a map over the grid's room is left out with a warning, not a
stop—. Worktrees in `~/scratch/aguara/map30/`, branches `aguara-map30` from
the-advocate `ec017cc1`, the ports `6e95630` and the book `2b05439`.

### The ways in, measured

What decides it is that the grid's offset is sixteen bits: `cell_ptr`
computes `y * row + x * 2` with the multiplier and takes bit 15 for the
bank, and `ptr_more` / `ptr_minus` walk the two upper halves as LoROM banks.
Anything past 64 KB of grid breaks that arithmetic, wherever it lives.

* **A byte per cell** (taken). The 64 KB of the two upper halves then hold
  65,536 cells less what lives behind the grid (the block table and its
  passability; the bytecode goes to the cartridge if it does not fit, see
  `code_in_rom`), for a map with at most 256 blocks. With map 30's 34
  bytes behind: 65,502 cells, a 255x255 map; wide it is 32,751, 180x180.
  Map 30 has 2 blocks once Wally fuses its 15 tile pairs: 40,000 bytes,
  397 in LZ2.
  The cost: twelve places in the runtime that read a cell or step one
  —an `and cell_mask` after each read, `cell_bytes` instead of `#2`,
  `cells_to_bytes` instead of an `asl`—, two bytes of zero page and two of
  BSS, and four cycles a cell read. Nothing moves in ROM or WRAM.
* **A grid read from ROM**: no WRAM limit, but the offset has to grow to
  seventeen bits in `cell_ptr`, `fill_window` and the steps, the grid
  goes uncompressed (80,000 bytes for map 30, against 397 in LZ2), laid out in the upper halves of the LoROM-shaped mirror
  (`$80-$BF`), whose lower halves the packing would have to fill with
  something else; and what lives behind the grid needs another home in
  WRAM. The largest map is the ROM's: RM2k's 500x500 at two bytes is
  500 KB. Not built.
* **Compressing by rows**, decompressing only what is near the camera:
  any size, but cells are asked for far from the camera —the routes of
  every event, `cell_allowed`, the terrain— so it needs random access to
  any row, an index of row streams and a decompression per question; it
  is the 4x4 chunks of the book's "The grid lives in WRAM" with worse
  access. Not built.

**Narrow whenever it can, not only when two bytes do not fit**: 305 of
ABL's 313 maps have at most 256 blocks (the largest number is 519), so the
narrow path is played by the whole suite and not by one map no test
walks, and the eight wide maps keep the other path played. `cell_bytes` in
`rm2k-snes/mapdata/src/materials.rs`; the record carries it in the fourth
byte of the grid's pointer (`M_GRID_NARROW`).

### The general part

A map whose grid fits neither way is left out by the converter, right
after Wally answers and before any page compiles —so a teleport to it is
the box "Teleport to missing map N"—, with `map N: WARNING, it is left out:
its grid of WxH cells and B blocks does not fit in WRAM…` and a
`map-left-out` loss in `degradations.json`; only the boot map still stops
the build. Zounds' `excluded = [30]` is gone.

### The dream, played

`test_the_dream_turns_switch_47_on_and_goes_back_to_the_room`, in the
ports' `tests/test_zounds.py`: from A on the bed (switch 40 by hand, as
the bed's test), tapping A through the boxes and standing still. Measured
in snes9x: map 30 at tick 893 after the bed, control at 1,041, the timer
at one second at 8,058, switch 47 on and back on map 17 at 8,299, control
at 8,657 after the room's next scene. Red with the global tools of
`ec017cc1` and the map excluded (the game never went to map 30), green
with the branch's.

What of map 30 does not work: the fog. Its autostart shows `fog2` at zoom
110, and the console only shrinks pictures, so it is not shown —and shown
as a big picture at transparency 50 it would hide the map—: draft
[`zounds-the-dreams-fog-is-not-shown`](zounds-the-dreams-fog-is-not-shown.md),
and Zounds' known issue in the book. The tint's ten-tenths gradient is
applied at once (already a listed loss). The map draws as rm2k-render
draws it, and the platform's collision holds.

### Delivered

* the-advocate `aguara-map30`: `9fea198a` the runtime, the emission, the
  converter, the mapdata hashes, and the test game's plain (200x200) and
  vast (330x200) with `test_big_maps.py`, red before (the build stopped at
  the plain); `8f568459` the plain's two new goldens; `a83da9a8` map 30's
  real numbers in `cell_bytes`' comment and test (2 blocks, 34 bytes
  behind).
* the ports `aguara-map30`: `b3e5156` Zounds' toml, the dream's test, and
  ABL's `test_decompressed_load.py`, which read the grid as two bytes a
  cell and asked map 52's grid to reach $7F's half —narrow, it is 20,000
  bytes now; the battle test checks what lives there instead—.
* the book `aguara-map30`: `e96b411` internals/maps.md, the grid's
  optimization page, the divergence of a teleport to a map not carried,
  and Zounds' known issues (map 30's line out, the fog's in).
* Captures in `/shared/captures/2026-10-17-zounds-map-30/`, with
  `README.txt` and `sheet.png`.

### What to install when merging

`mapdata`, `convert` and `cartridge` (`just install mapdata convert
cartridge`): the runtime changed, and `cartridge` is what assembles it.

### What was run, on the branches (main had not moved), with those installed locally

* `just crate-test mapdata`, `just crate-test convert`: green.
* `just test`: 29 passed. `just test-game`: 44 passed, 1 skipped.
* ABL's `just tests`: 1565 passed, 2 skipped; no golden moved. `abl.sfc`
  `505cdcb4fcac…` (sha1). `just space`: one byte of zero page left.
* `just boot` at the ports' root: 63 passed.

Not covered: a grid past 32 KB coming back from a battle —ABL's map 52 no
longer reaches $7F's half, and the plain and map 30 have no battle—; the
eight wide maps of ABL are the only wide grids any test plays.
