---
name: "All WRAM placed by the linker"
description: "Move what is still at hand-written addresses in WRAM to segments the linker places, subsystem by subsystem, each move byte for byte the same ROM; what has a real reason to be fixed —the grid's halves, overlays, alignment— becomes a declared memory area, not a number"
type: refactor
status: doing
assignee: Carpintero
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
