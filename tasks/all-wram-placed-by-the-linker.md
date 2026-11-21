---
name: "All WRAM placed by the linker"
description: "Move what is still at hand-written addresses in WRAM to segments the linker places, subsystem by subsystem, each move byte for byte the same ROM; what has a real reason to be fixed —the grid's halves, overlays, alignment— becomes a declared memory area, not a number"
type: refactor
status: done
assignee: taro
author: taro
agents: [Carpintero]
---

taro, on 2026-11-16, after reading the book's
[RAM is placed by the linker](https://lautarodragan.github.io/the-advocate-docs/decisions/ram-is-placed-by-the-linker.html),
the WRAM research snapshot and "The grid lives in WRAM":

> Wouldn't the ideal be that all the WRAM is placed by the linker, and
> nothing by hand? I suspect what is currently placed by hand is legacy,
> to avoid introducing a big refactor.

It is: the decision of 2026-10-11 left what was already declared where it
was. What has a reason to be fixed: the grid's two halves at `$7E8000` and
`$7F8000` (its readers step between them by address arithmetic), the
overlays the battle shares with the map (and, since 2026-11-16, what lives
behind the grid: see `internals/wram.md` in the book, from
[`event-page-records-compressed-behind-the-grid`](event-page-records-compressed-behind-the-grid.md)),
and buffers that need alignment. `ld65` can say all three: memory areas,
segments sharing one, `align`.

Done means: no hand-written WRAM address left in `runtime/` but the
declared areas; each subsystem's move in its own commit with the ROM byte
for byte the same where it can be (or the reason it isn't); the book's
`internals/wram.md` and the decision updated.

## Log

### 2026-11-19, Carpintero: the inventory

From the-advocate `e51796bf` and the ports `4c993f4`. Every WRAM address
`runtime/` writes by hand, looked for as equates with a long number, `$7E…`
and `$7F…` literals in operands, and the stack's top; what is derived from
one of them (`X = GRID + …`) goes on its row.

| what | where | written as | who uses it | why it is where it is |
|---|---|---|---|---|
| `GRID`, `GRID_END` | `far_ram.s` | `$7E8000`, `$7F0000` | `decompress.s` (`lz2_grid`, `LZ2_BODY ^GRID`), `hero.s` (`cell_ptr`), `wrap.s`, `map_window.s`, `enter_map.s`, `battle_scene.s` | the grid's first 32 KB: the upper half of `$7E`, so its two halves look like two LoROM banks in a row (`ptr_more`); **the converter writes it as a number** too, in `posed.rs` (the drawn-in events' cells) |
| `GRID_HIGH` | `far_ram.s` | `$7F8000` | the same, and the cartridge's `.inc` (`GRID_HIGH + $…` in each record) | the grid past 32 KB, and behind it the block table, the bytecode and the page table; **the converter writes it as a number** in `record.rs`, inside the compressed page tables |
| `GRID_TOP` | `far_ram.s` | `GRID_HIGH + $8000 - GRID_TOP_BYTES` | `gold_window.s` (`GOLD_BUF = GRID_TOP`), `posed.s` (`POSED_REG = GRID_TOP + GRID_TOP_GOLD`, and `POSED_*` after it) | the top of `$7F`'s half, which no map reaches; sizes from `materials.rs` |
| `SCN_BATTLERS` | `battle_scene.s` | `GRID` | `battle_scene.s`, `enter_map.s` | the battle borrows the grid's `$7E` half |
| `SCN_CLEAN`, `SCN_SCENE` | `battle_scene.s` | `$7F0000`, `$7F8000` | `battle_scene.s`, `enter_map.s`, `decompress.s` | the battle borrows the whole of `$7F`: 32 KB each |
| `PAINT_Q` | `painted.s` | `$7EFE00`, and `$7F0000` in its `.assert` | `painted.s` | a painted map's DMA queue, at the end of the grid's half; the converter keeps such a map's grid under `0x7E00` (a number in `panorama.rs`) |
| `LZ2_BUFFER` | `far_ram.s` | `$7F0000` | `decompress.s`, `pano.s`, `big_picture.s`, `custom_menu.s`, `menu_list.s`, `battle_animation_frames.s`, `text_layer.s` (`TL_STAGE_HI`), `debug_screen.s` (`DBG_*` after it), `enter_map.s` | the load buffer; its tenants are offsets from it, each `.assert`ing the next |
| `CODE_CARRY` | `far_ram.s` | `LZ2_BUFFER + $1100` | `decompress.s`, `menu_list.s`, `big_picture.s`, `text_layer.s` | an offset in the buffer: stays one |
| `ANIM_DRAWINGS`, `ANIM_DRAWINGS_END` | `far_ram.s` | `$7F6000`, `$7F8000` | `decompress.s`, `chipset_animation.s`, `load_graphics.s`, `pano.s`, `big_picture*.s`, `battle_animation_frames.s`, `debug_screen.s` | the ChipSet animation's drawings, which last as long as the map |
| `BIG_PAL`, `BIG_WAVE_A`, `BIG_WAVE_B`, and the ten `BIG_M7_*`/`BIG_MAG*` | `far_ram.s` | `$7F6000` to `$7F650D` | `big_picture.s`, `big_picture_zoom.s`, `picture.s` | a big picture's palette, waves and zoom, over `ANIM_DRAWINGS` while it is up |
| `SCREEN_BUFFER` | `game_over.s` | `$7F0000` | `game_over.s`, `title.s` | a full screen's image: the whole of `$7F`, grid included |
| `f:$7F0000, x` (4), `f:$7F0002, x` | `big_picture.s` (the wave tables), `debug_screen.s` (5) | the bank `$7F` as a base, with a pointer in X | the same files | the tables live in `$7F`, which their `.assert`s already say |
| `$7E0000 + X` (88 operands, 4 equates), `FAR_LENGTH`, `BAT_LENGTH` | 14 files, `far_ram.s` | `$7E0000` | the screens, the shop, the text layer, the debug screen, `rain.s`, `turn_toward_hero.s`, `sound_effects.s` | not an address: `FARBSS`'s bank in front of a sixteen-bit name |
| the stack's top | `boot.s` | `ldx #$1FFF` | the reset | the top of bank 0's RAM; its size is `STACK` in `banks.rs` |
| `WMADDH` written with `#0`/`#1` | `level.s`, `text_layer.s`, `battle_scene.s`, `debug_screen.s`, 12 `stz` | the bank bit of the window | — | not an address: `$7E` or `$7F` |

Nothing else: `zero_page.s` and `low_ram.s` have no address by hand, and
`FARBSS` was whole since 2026-10-16.

**What has a reason to be fixed, and what it becomes**:

* **The grid's halves**: the converter writes their addresses into the
  data it compresses, before anything is linked, and `ptr_more` steps
  from one to the other by bank. They become two memory areas of the
  `.cfg`, at `$7E8000` and `$7F8000`, whose numbers live in `banks.rs`
  next to `FAR_POOL_START`; the converter's numbers go in its `.inc`, and
  the runtime `.assert`s they are the linker's.
* **`GRID_TOP`**: a segment of its own after the grid's in `$7F`'s area,
  each tenant a `.res` in its file, sized by the converter.
* **The load buffer and the drawings**: the area at `$7F0000`, one
  segment, `LZ2_BUFFER` and `ANIM_DRAWINGS` its `.res`; what goes over
  them keeps being an offset of the region it borrows.
* **The battle's overlays, `SCREEN_BUFFER`, `PAINT_Q`**: names of the
  region they borrow —`SCN_SCENE = GRID_HIGH`—, not numbers.

### 2026-11-19, Carpintero: the moves

Branch `carpintero-wram-linker` in the-advocate, from `e51796bf`, one
commit per move; each verified by building **ABL's eleven cartridges and
the test game's two** with the branch's tools and comparing them byte for
byte with the ones built at `e51796bf` with the same tools —all identical
in every commit—, and the painted maps' one Sunset over Imdahl's
`release` too, the only game that has them:

1. `f6c7172c` **The grid's two halves**: `GRID` and `GRID_HIGH` are the
   `GRID` and `GRIDHI` segments, in the `GRIDLO` and `GRIDHI` areas of the
   `.cfg` (`GRID_START`, `GRID_HIGH_START` in `banks.rs`). Fixed because
   the converter writes them as numbers into what it compresses: its one
   copy is now `GRID_AT` and `GRID_HIGH_AT` in `materials.rs` —`posed.rs`
   and `record.rs` had one each—, written in the `.inc`, and
   `far_ram_game.s` asserts at link time they are the linker's. Shown red
   with `GRID_AT + 1`.
2. `2f3a1a6c` **`GRID_TOP`** is the `GRIDTOP` segment after `GRIDHI` in
   its area; `GOLD_BUF` and `POSED_REG`/`POSED_T` are `.res` in
   `gold_window.s` and `posed.s`; `GRIDHI`'s `.res` is the half minus
   `GRID_TOP_BYTES`, in `far_ram_game.s`, and an `.assert` says
   `GRID_TOP` lands at the top.
3. `5aeb305a` **The load buffer**: `LZ2_BUFFER` and `ANIM_DRAWINGS`, two
   `.res` of the `LOADBUF` segment and area; the big picture's ten
   numbers, offsets of `ANIM_DRAWINGS`.
4. `b9907384` **What borrows a region names it**: `SCN_CLEAN =
   LZ2_BUFFER`, `SCN_SCENE = GRID_HIGH`, `SCREEN_BUFFER = LZ2_BUFFER`,
   `PAINT_Q = GRID + PAINT_ROOM` —the converter's room for a painted
   grid, a number in `panorama.rs` until now, in `materials.rs` and the
   `.inc`—, each with an `.assert` of what it takes.
5. `7c2fa242` **The `$7F0000, x` bases** of `big_wave_table` and the debug
   screen, and `scn_fill`'s 0, `$80` and 1, name whose bank and middle
   byte they are.
6. `eeb7e54c` **The stack**: an area of the `.cfg` with `define`, and the
   reset points S at `__STACK_START__ + __STACK_SIZE__ - 1`.
7. `c085fca0` **`WRAM_AREAS`**: the four far areas in one table, which
   writes the `.cfg` —the same text— and `--memory-map`'s `wram`, for the
   tests.
8. `5a7e35a1` The prose (judgement, after the mechanical ones): far_ram.s's
   header, the load buffer's list, `GRID_TOP`'s section, the battle scene's
   "bank $7F nobody uses"; and an `.assert` that `FARBSS` is in the bank
   `FAR_LENGTH` says.

**Not moved, on purpose: the far bank.** `$7E0000 +` before a sixteen-bit
name (88 operands), `lda #$7E` before a `plb` (35) and the zero in
`WMADDH` are `$7E`, the bank where bank 0's RAM shows again and that the
code running with the data bank there counts on: a property of the
console, not a placement. `FAR_LENGTH` names it and is now asserted
against `FARBSS`.

**Ports**, branch `carpintero-wram-linker` from `4c993f4`:
`test_wram_reservations.py` looks for any long WRAM number in the
runtime's source —equates, operands, asserts— but `$7E0000`, and checks
"falls in its area" for every area of `--memory-map`'s `wram`. Shown red
on the runtime at `e51796bf`: it lists the thirty-four of the inventory.
`GRID_AT` and `GRID_HIGH_AT` join the list of who may be in the upper
halves.

**Book**, branch `carpintero-wram-linker` from `0dcf005`:
`internals/wram.md` and the decision.

And `081ac38` in the ports: `test_jumps_between_banks.py` was red on six
cartridges once `POSED_REG` became a label —of an `=` it only looks at
what falls in the ROM or the registers, so it had never looked at it—:
`posed_queue` and what it calls run with the data bank at `^POSED_REG`,
as posed.s says, and join its `DATA_BANK` with `$7F`.

### 2026-11-19, Carpintero: verified

With the branches' tools (`just install-local .local-tools cartridge
mapdata`):

* **Every ROM byte for byte the same** as at `e51796bf` with the same
  tools: the twenty-two cartridges of the nine games and the test game
  —ABL's eleven, the other eight games' `release` and Zounds' `exits`, the
  test game's two—. ABL's `release`: `ed62c2f9…`.
* **`just space` prints the same**, in every cartridge of the nine games:
  ABL's `release` has 119 B of far RAM and 77 B of `BSS` before and after.
  The upper areas are full by construction —each segment's `.res` is its
  half—, so they print nothing.
* ABL's suite, whole, before `081ac38`: 1,716 passed, 2 skipped and the
  six of `test_jumps_between_banks.py`, `test_cores.py` and
  `test_wram_reservations.py` included; after it, that file alone, 12
  passed. The whole suite was not run again: the ROMs did not change.
* `just boot` at the ports' root: 167 passed. `just test`: 29 passed.
  `just crate-test cartridge` and `mapdata`: green.
* `just test-game`: 66 passed and **4 red, the same 4 at `e51796bf`**
  with the same tools, which already have their drafts:
  [`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md)
  (three) and
  [`goombario-reads-widths-from-an-untaken-if-branch`](goombario-reads-widths-from-an-untaken-if-branch.md)
  (the linter).

What the suite does not cover: since the ROMs are the same, nothing here
runs differently; what is new is only what the link checks —the
converter's grid against the linker's (shown red with `GRID_AT + 1`),
`GRID_TOP` at the top, `FARBSS` in `FAR_LENGTH`'s bank, the borrowers'
sizes—, and none of those has a game where it fails. Moving an area in
`banks.rs` is not tried: the grid's would need the converter's numbers to
move with it, and the rest has code that counts on `$7F`'s bank in
`.assert`s that would say so.

**To install when merging**: `cartridge` and `mapdata` (`just install
cartridge mapdata`). The ports' tests need the new `cartridge`:
`--memory-map` prints `wram`.

Branches: `carpintero-wram-linker` in the-advocate, the ports and the
book, all three from the `main` they were launched at, which has not
moved.
