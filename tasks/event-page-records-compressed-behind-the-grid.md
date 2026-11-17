---
name: "Event page records compressed behind the grid"
description: "Store each map's event page records (`pages_*`) in LZ2 and unpack them with the grid's stream, as the bytecode already is: ~125 KB freed in ABL's release; then turn `posed_events` on for the whole of ABL with that room"
type: feature
game: abl
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-11-16, after [`abl-room-for-still-events-in-the-background`](abl-room-for-still-events-in-the-background.md) (Mulita's study):

> SIII :D

to "compress the page records (~125 KB), then `posed_events` on in the
whole of ABL". The study measured the records raw at 193,376 B and 68,513
B in LZ2 piece by piece; they carry no linker symbol (their code pointer
is already `GRID_HIGH + offset`); the largest is 12,192 B and fits behind
the grid in `$7F`. Not measured: that every map fits, the cycles on the
console, that they survive a battle as the bytecode does.

Done means: the records in LZ2 behind the grid for every game, `page_ptr`
reading WRAM; measured per map (fits, load time) with the gain; ROM tests
(a map's pages after a load and after a battle); all suites green; then
`posed_events = true` in ABL's `advocate.toml`, every golden that moves
looked at, and its Known issues line for map 8's signs gone if fixed.

## Log

Mulita, from the-advocate a83c4a12 and the ports ff7ac5b, merged with
main early (cd3fecb8 / b024af2, Chajá's transparency) because the page
records are what both touch. Branches `mulita-pages-lz2` in both,
worktrees in `~/scratch/mulita/pages-lz2/`.

### The layout, from `git blame`

The page table pointed into WRAM since the bytecode went behind the grid
(`14139ad9`, 2026-10-01): its code pointer is `GRID_HIGH + offset`, so
the table itself carries no symbol for those maps. Only a map whose
bytecode stays in the cartridge (`code_in_rom`, `f747bdae`, 2026-10-15)
has symbolic pointers, and its table cannot be compressed: it stays.

### How it goes

* mapdata: `pages_in_wram(map)` —pages, bytecode in WRAM, and everything
  behind the grid fits in $7F's upper half—; `page_bytes` assembles the
  same lines `page_table_with` writes for the cartridge, with the code
  pointers as numbers (`asm::numeric_bytes`, which refuses a symbol). A
  new compressed kind, `map_pages`, joined as the second stream of the
  bytecode's block (`map_code`), so grids stay shared and
  `code_carry_after` still decompresses the bytecode alone. The record's
  `pages` points `GRID_HIGH + offset`; the runtime reads it into
  `page_ptr` as before, untouched.
* runtime: `lz2_grid` decompresses that second stream right after the
  bytecode; `back_from_battle` already calls `lz2_grid`, so the table
  comes back from a battle with the bytecode.
* ports: `active_page` in the harness reads the table where it lives;
  `test_decompressed_load.py` checks the table behind the grid on every
  map of `release` (snes9x and bsnes, and `test-msu`), the record's
  pointer, and that the battle in map 52 tramples it and it comes back.

### Measured, ABL `release` (step 1)

`just space`, before (main's tools) and after: 126 of 126 banks, 565 B of
gaps → 123 banks, 3 halves of 32 KB free, 28,226 B of gaps. The
converter's report: `map_pages 65.9 KB in LZ2, was 186.2`. All 313 maps'
tables go behind the grid; the tightest map leaves 7,269 B of $7F's half
(map 4, the cases', with a 12,224 B table); the largest table of a game
map is 214's, 6,432 B. Decompression, the converter's estimate
(`scripts/pages_frames.py` in the scratch): +0.23 frames per load on
average, +5.8 on map 4, +2.3 at most on a game map (108), inside the fade.

Red before: with the second `lz2_decompress` of `lz2_grid` taken out,
7 of the 8 tests of `test_decompressed_load.py` went red ("what is behind
the grid differs … in the page table" on all 308 maps; the battle in 52
too).

### Three things the suite found

* `test_paradise.py`'s guard test asks `active_page` every frame, and a
  battle composes its scene over $7F's half for a few frames before
  `menu_open` goes up, with the map stopped: reading the table from WRAM
  there read the scene. The harness now reads a WRAM table from the
  converter's `raw/<index>.map_pages.bin`, which `test_decompressed_load`
  checks is what the WRAM holds while the map runs.
* `test_msu_twins.py`: `test-msu` lost its "; --- n: map" comments. The
  packing carries a comment inside the piece before it, and the map's last
  piece is now its bytecode+pages stream, which leaves the text for the
  `.msu`. With `--msu` a `.segment "RODATA"` goes before each comment, so
  it stays in the text on its own; other cartridges' text unchanged.
* `test_music_ceilings.py`: human4 and rshinld clip 1–2 samples. The test
  says it itself: any ROM change moves when each DSP write falls in the
  frame (~0.2 dB); both are within `CLOSE`. On main they pass. Re-measured
  with `just ceilings` after step 2, which changes the ROM again.

### Step 1 in the other games (`just space`, release, main's tools → mine)

The converter's report, `map_pages` in LZ2 against raw, and the banks:

    game                 map_pages LZ2 / raw    banks before → after   gaps after
    book-of-three         14.6 / 41.0 KB        48 → 47                10,503 B
    desert-nightmare      69.7 / 221.5 KB       99 → 96                   119 B
    dooms2                 7.2 / 15.6 KB        41 → 41                54,565 B
    el-dorado             10.8 / 30.4 KB        21 → 21                52,380 B
    frozen-world          32.7 / 90.3 KB        68 → 67                62,072 B
    sunset-over-imdahl    16.9 / 44.9 KB        87 → 86                28,182 B
    vampires-dawn        142.4 / 526.0 KB      126 → 126 (MSU)         2,135 B (was 414)
    zounds                39.1 / 126.1 KB       68 → 67                39,855 B

`just boot` at the ports root: 153 passed. `just test`: 29 passed. ABL's
suite with step 1 alone: all green but `test_music_ceilings.py` (human4,
rshinld), re-measured with `just ceilings` in its own ports commit.

### Step 2: far RAM, not banks, was the wall

With `posed_events = true` ABL linked in banks but not in far RAM:
`FARBSS` overflowed by 701 B before merging main, 97 B after (main's
Carpintero and Chajá left release 12 B of far RAM). `posed.s` kept 841 B
there: `POSED_LAST` (104, `POSED_MAX`; ABL's most is 100, on map 214),
`POSED_REG` (716, the two regions of tilemap runs) and its scratch
(`POSED_T`, 16) and 5 more. Hornero decided, after two reports: the runs
and the inn's gold window's rows (`GOLD_BUF`, 704 B) move to the top of
$7F's upper half, `GRID_TOP`, a region written by hand with named tenants
that the converter keeps every map's grid and what lives behind it out of
(`BEHIND_ROOM`, 1,436 B less of the half, on every map of every game). Both
tenants live less than a map and rebuild themselves after a battle, which
composes its scene over the whole half.

`GOLD_BUF`'s users, grepped: only `gold_window.s` (`gold_compose`,
`gold_cell`, `gold_vblank`), all on the map, from a box's opening to its
rows going up; `gold_add` in the shop and the battle's spoils is another
routine and does not touch it. `gold_to_wram` wrote with `WMADDH` at 0
($7E), and `gold_compose` now calls `gold_to_wram::high` ($7F).
`posed_drain` and `posed_sync` look at `POSED_N` first, because on a map
without drawn-in events those bytes are stale.

With that, release links with `posed_events = true`: 121 of 126 banks, 5
halves free, 7,660 B of gaps, far RAM 607 B left.

Tests: `test_grid_top.py` (new, ABL): after a battle on map 20 (case
`inn-after-battle`, Kersh against the droid under the bum), the drawn-in
event's cell holds its block and the runs are empty; the inn's gold window
after the battle is `inn-greeting-gold`'s, pixel for pixel; maps 8 → 9 →
8, each one's cells its own. Red before: with `posed_sync`'s
`posed_empty` taken out, the runs held $FF00/$FFFF after the battle and
the gold test froze the ROM; with `gold_compose` writing to $7E, the gold
window differed in 1,077 of 2,816 pixels (and both inn goldens went red).
`test_decompressed_load.py` checks nothing behind any grid reaches
`GRID_TOP`; `test_wram_reservations.py` names its tenants.

### Step 2 on merged main (Cardón's `baked_events`, Tijereta's debug .msu)

Merged main twice more into every branch. ABL's key is `baked_events =
true`, with `baked_events_nudge` at its default (2): 83 maps draw events
into their background, the shifted chests included; 12 more map patches
(`just patches`), no golden moved by the nudge. Tijereta's debug-screen
caches live in `LZ2_BUFFER` below `ANIM_DRAWINGS_END`, far from
`GRID_TOP`.

`release`, `just space` on the merged tree: 117 of 126 banks, 9 halves of
32 KB free, 17,041 B of gaps, far RAM 607 B, bank 0 65 B.

Goldens: 14 moved, all looked at, in their own ports commit and side by
side in `captures/2026-11-16-abl-posed-on/` (taro's NAS) with a README:
11 are the wall monitor next to the save point and the mechanic, now
green as in RM2k; 3 are the debug map's tram, the hero on another frame
of his walk. The suite was rerun until no new golden went red.

Verified, with the tools of `mulita-pages-lz2` installed locally: ABL's
whole suite, 1665 passed; `test_display_accesses.py` and the race
(`test_playthrough_race_golden.py`); `just display-sweep`, 375 cases, 600
frames each, no access during display; `just test`, 29; `just crate-test
mapdata`. Map 8's monitors are green (`map8-monitor-green.png` in the
captures): its Known issue and the draft
`abl-map-8-s-signs-lose-their-green` are gone.

The tightest map per game, bytes left below `GRID_TOP` in `release`
(`scripts/behind.py` in the scratch, from each build's `raw/`):

    abl                 map 4      5,769 B  (the test cases' map)
    book-of-three       map 1     23,678 B
    desert-nightmare    map 48     6,839 B
    dooms2              map 1     28,800 B
    el-dorado           map 4     19,838 B
    frozen-world        map 76    18,023 B
    sunset-over-imdahl  map 14    23,829 B
    vampires-dawn       map 164    1,085 B
    zounds              map 75    22,018 B

`just boot` at the ports root, on the merged tree: 153 passed.

### Not covered

* No golden or test looks at a chest that the nudge moved into the
  background being opened (its pose change in the background on a battle
  map); `test_grid_top.py` looks at map 20's one drawn-in event and maps
  8 and 9.
* The cycles of decompressing a page table are the converter's estimate,
  not measured on a console; the console-side load time was not measured
  map by map.
* Vampires Dawn's map 164 is 1,085 B from `GRID_TOP`: a bigger tenant
  there, or a few more pages, and its page table goes back to the
  cartridge (and its bytecode, past that); the build says nothing when a
  page table stays in the cartridge.

### To install when merging

Rust: `mapdata` (page tables, `GRID_TOP`), and with it everything that
compiles the runtime's path —`project`, `cartridge`, `convert`,
`patches`, `rm2k-snes-audio`—, because `runtime/` changed (`decompress.s`,
`far_ram.s`, `gold_window.s`, `posed.s`). `wally` and `screens` only as
main already has them.

Branches `mulita-pages-lz2` in the-advocate, the ports and the docs.
