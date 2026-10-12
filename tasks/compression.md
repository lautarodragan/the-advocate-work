---
name: "Compression"
description: "Compress what travels in the ROM: measured, 75% less"
type: feature
status: done
---

What can be expected from compressing, measured: the used part of
`abl` —3.12 MB when it was measured; today it is less, since the battle scene
stores each background once— deflates to **791 KB, 75% less**. The bulk of the
cartridge is graphics, which is what compresses, and decompressing when loading a
map is the console's technique.

Careful not to measure it wrong: the whole `.sfc` gives
97% because the million padding zeros compress to nothing, and `mapdata.inc`
gives 89% because it is **text** —decimal numbers with commas—, not the bytes that
travel in the ROM.

What the map already saves without compressing, so as not to redo it: what is stored is not the
tilemap but **RM2k's 16×16 cell**, with its four background cells,
its four of the upper layer and its passability together —512 distinct
blocks in the whole game—. On map 52 that is 40,000 B against 160,000, and
**it erased the whole collision table**. Measured separately: **85.3% of the upper
layer is the empty tile**, so if more were needed, the first place
to look is an RLE over the block grid, not the zeros of the layer.

Compressing maps has an extra challenge, because we stream them live from the
cartridge, and changing their format would affect random access.

**Measured by class and algorithm, with the cost of decompressing each thing and the
order in which it is best done**: `tasks/compression-of-maps-and-graphics.md`,
from 2026-09-26. The battle animations are already stored without their empty tiles,
the maps' tiles and grids go in LZ2 —the grid is decompressed
whole to WRAM, so random access stayed the same— and identical poses
are stored once.

## Closed

Closed by taro on 2026-10-12, as superseded: the compression this asked
for was measured and done in `compression-of-maps-and-graphics.md` —maps'
tiles and grids in LZ2, identical poses stored once, battle animations
without their empty tiles—. What compression is still needed is asked for
by each game's task, measured.
