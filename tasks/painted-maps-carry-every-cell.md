---
name: "Painted maps carry every cell"
description: "A painted map stores each of its 8x8 cells in the cartridge, repeated or not: Desert Nightmare's 135 maps that could go painted take 86.5 banks of cells, and only 29.5% of those cells are distinct"
type: feature
status: done
assignee: taro
game: desert-nightmare
agents: [Cardón]
---

Seen by Cardón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-can-the-towns-be-baked`](desert-nightmare-can-the-towns-be-baked.md).

**What was seen**: a painted map —`Way::Painted` in Wally, `painted.s`
in the runtime— carries every cell of the map, 32 bytes each, column by
column. With `painted_maps = true` and the throwaway prototype of that
study (branch `cardon-dn-towns` in the-advocate, every map), 135 of
Desert Nightmare's maps go painted: 177,156 cells, 86.5 banks. The
release takes 91 of the cartridge's 126 data banks without them, so the
cartridge does not link ("the 126 banks the cartridge has for data are
taken"). Cut into 8x8 cells by their colour-memory entries, 52,187 of
those cells are distinct within their map (29.5%, 25.5 banks), 49,985
across maps.

With only the 28 towns painted, the release takes 100 banks and links.

Sunset Over Imdahl's 60 painted maps are stored the same way; how many
of their cells repeat was not measured.

**To reproduce**: the prototype's Wally (`just install-local .local-tools
wally` in that branch), `painted_maps = true` in
`desert-nightmare/advocate.toml`, and `TOWN_BAKE=1 TOWN_FOLD=1 just
cartridges --force` with that `bin/` first in the PATH.

## Desert Nightmare requires the MSU-1 instead (2026-11-19)

taro's decision, for [`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md): Desert Nightmare requires the MSU-1, and the
load-time data goes to the `.msu` so that the painted cells fit the ROM
(95 maps painted, 112 pieces of 1.1 MB to the `.msu`). The cells stay
stored whole. This draft is still what would make the game's `.msu`
optional again, and Sunset Over Imdahl's 60 painted maps smaller.

## Measured again on the cartridge that is built (2026-11-20, Carpintero)

On Desert Nightmare's `release` at the-advocate `16081af9` and the ports
`1177cbc`, read from the ROM's bytes: the 93 painted maps carry 126,756
cells, 4,056,192 bytes (their attributes and tables add 140,072); 43,935
of them are distinct within their map (34.7%, 1,405,920 bytes), 41,569
across maps. Stored once with a two-byte index per cell, about 1.66 MB
instead of 4.06. See
[`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md).

## Taken (2026-11-20, Cardón)

From Carpintero's study (`ports/desert-nightmare/research/2026-11-20-where-the-room-goes.md`,
recommendation 4): only ~30-35% of Desert Nightmare's painted cells are
distinct; stored once with an index, ~4.2 MB become ~1.8 MB. taro,
translated: "Do you want to launch an agent in parallel to get as far as
possible with deduplicating those tiles, as far as it can go without
clashing with the rest?"

**Done means**: painted maps keep each distinct 8x8 cell once (per map,
or shared across maps if it pays) plus an index, the streaming in
`runtime/painted.s` builds columns and rows from it within the vblank
budget (measured on the worst walking frames), every painted map drawn
the same (goldens, Sunset and Desert Nightmare), `just space` before and
after, and whether Desert Nightmare then fits without `.msu`
(`msu = "required"` kept until taro decides).

## Working (2026-11-20, Cardón)

Branches `cardon-painted-cells` in the-advocate and the ports, from
`3043b395` and `09d9b0d` (main after Chajá's copies).

**Measured** on Desert Nightmare's `release` (the ports' build of
2026-11-19, the same 93 painted maps Carpintero counted), from its
`mapdata.inc`: 126,756 cells, 43,935 distinct within their map, 41,569
across maps; flipped cells would save 0.3% more (41,462), so they are not
looked for. The biggest map, 171 (80x56), has 4,414 distinct cells of
4,480 —a photograph—, and its worst 33x30 window has 990 distinct cells of
990.

**Decided**:

* **One dictionary for the cartridge**, not one per map: 75 KB less, and a
  cell's number says where it is with one table of pieces of 1,024 cells
  (32 KB, the most a `.block` may be): piece `n >> 10`, cell `n & 1023`.
  A word per cell, so up to 65,536 distinct cells; the converter refuses
  past that.
* **No VRAM cache.** A cache of distinct cells on screen pays only where a
  window repeats, and the worst window of map 171 has 990 of 990: VRAM
  would have to hold the 990 slots anyway. The slots stay by position.
* **A column is gathered before the vblank**: in `paint_tick`, one DMA a
  cell from the pieces to WRAM through `$2180` (`PAINT_COL`, behind the
  queue in the grid's bank; `PAINT_ROOM` goes from `$7E00` to `$7700`), so
  in the vblank it is still one run, one DMA or two as before. A row's
  tiles were already one DMA each, and go straight from the pieces. So the
  vblank does the same DMAs as today; what the dedup costs is CPU in the
  tick, outside it.

**Changed on the way: one dictionary a map, not one for the cartridge.**
Sunset Over Imdahl's paintings are drawn pictures: its 60 maps have
107,280 cells, 93,671 distinct within their map and 90,746 across maps,
more than a word numbers ("map 41: the painted maps have more than 65536
distinct cells"). So each map numbers its own cells (at most 4,800 a map
today, 65,536 by construction), its pieces go in the cartridge's
`paint_pieces`, and the record carries where its first piece is (+16,
`PAINT_STRIDE` 18; `PAINT_PB` in the runtime, set by `paint_find`). Desert
Nightmare loses the 2,366 cells two maps shared, 75 KB.

**And `painted.s` moved from `FAR2` to `FAR3`** (bank `$C1`): with the
gathering, Desert Nightmare's `$C0` overflowed by 123 bytes.

**Space**, `just space`, the-advocate `3043b395` against the branch, ports
`09d9b0d`:

| `release` | data banks used, before | after | free after |
|---|---:|---:|---|
| Desert Nightmare | 126 of 126 (25 pieces, 217,805 B to the `.msu`) | 82 (22 pieces, 143,341 B) | 26 whole, 18 halves |
| Sunset Over Imdahl | 81 | 77 | 31 whole, 18 halves |

**Desert Nightmare fits without the `.msu`**: built with `msu =
"optional"` in a throwaway copy of its `advocate.toml`, it links in the
same 82 banks, and `test_boot` and `test_desert_nightmare_towns` pass with
no `.msu` next to the ROM. Its 22 pieces still in the `.msu` are what a
game whose MSU-1 is optional sends there anyway, as Sunset's 13 (which
ones was not looked at piece by piece). `msu = "required"` stays until
taro decides.

## Done (2026-11-20, Cardón)

Branches `cardon-painted-cells`: the-advocate `4662f046` (`painted.s`
goes to `FAR3`) and `d5ad305e` (the cells once a map), the ports
`3e4cc78` (only the comment over Desert Nightmare's `msu`), the book
`e2c41b3` (the VRAM split, the converter's stages, the MSU-1 decision).
**To install when merging: `just install mapdata`**; the runtime comes
from the checkout.

**The vblank**, Mesen2's line profiler (`wait_vblank`, `paint_tick` and
`message_tick` watched), walking the eight directions from where each map
starts the hero, main against the branch:

| Desert Nightmare map | `paint_tick`, most lines | free lines on a column crossing, median / worst | worst while moving |
|---|---|---|---|
| 172 | 5 → 28 | 155.5 / 111 → 151 / 111 | 86 → 86 |
| 3 | 5 → 28 | 195 / 156 → 172 / 133 | 151 → 133 |
| 60 | 5 → 28 | 168 / 129 → 146 / 105 | 72 → 72 |

A column's 30 cells cost the tick about 23 lines; the vblank does the same
DMAs as before. Not measured: more than two pixels a frame, where a tick
may gather two columns (about 46 lines) besides a row.

**Drawn the same**: against main's build, at 15 bits, on snes9x, every
painted map entered like a door on a grid of points and walked the four
ways (Desert Nightmare 641 points, 32,691 captures; Sunset 510, 25,347),
and wandered for 640 ticks from where the map starts the hero (Desert
Nightmare 71 maps, 68 scrolling, 22,720 captures; Sunset 54, 51, 17,280;
the rest left the map or kept the hero in a scene): no capture differs.
A Blurred Line's `release` and the test game's ROM are byte for byte
main's.

**Run**: the mapdata crate's tests (a new one reads a table back);
`just test`; the ports' `just boot`, 172 passed; ABL's `just tests`, 1722
passed; the test game, the same 4 reds as main at `3043b395` (drafts
`the-test-games-leader-name-goldens-are-red-on-main` and
`goombario-reads-widths-from-an-untaken-if-branch`).

What is left, if it is wanted: a column's cells whose numbers are
consecutive (the first time a stretch is seen, they are) gathered in one
DMA, which would take back most of those 23 lines on a map like Desert
Nightmare's; and a map that repeats nothing (Sunset's map 3, 4,799
distinct of 4,800) pays a word a cell for nothing, 9.6 KB.
