---
name: "Animated tiles"
description: "The two families of animated tiles of the ChipSet"
status: done
---

### The water moves, and it costs a DMA of 1664 bytes

RM2k animates two families of ChipSet tiles, with different clocks and
without the map having anything to say about it: the water autotiles A/B/C,
which go through three drawings every 24 frames in the cycle 0,1,2,1, and the
"animated tiles", four drawings every 6. Both calculations are easyrpg's
`TilemapLayer::Draw`, `tilemap_layer.cpp:289`, and the two default cadences
—the ChipSet's `animation_type` and `animation_speed`— are the ones this
whole game has: of its 52 ChipSets only two override them, and neither of
the two is used by a map of the port.

**How it is done: overwriting the tile's data, not the tilemap.** A map of
100x75 cells has 30000 tilemap entries and only a few distinct tiles that
move: on map 5 they are **26 8x8 tiles** of the bank's 157, on 2 they are
7 of water plus 12 animated, on 3 they are 8 and on 6 they are 2. So
animating is uploading those tiles again and touching nothing else — and the
converter leaves them **in a contiguous run at the end of the bank**, so that
a step is a single DMA: 1664 bytes on map 5, 128 on 6.

For that to be correct two more things are needed, and both are decided by
`convert()`:

* **A tile that animates is not shared with a still cell.** If it were
  shared, overwriting it would make the still one flicker too. Measured: in
  the four maps there isn't a single collision, so separating them costs no
  tiles.
* **Flipping is tested on the drawings together.** The PPU flips the tile,
  not each drawing on its own, so two cells share a tile only if the four
  orientations match in *all* the drawings.

And the palette is allocated counting the colours of all the drawings: the
water on map 5 brings three colours that aren't in the drawing seen on
entering, and without them step 1 couldn't be written.

**On the console it doesn't spend a byte of RAM.** Not out of elegance: the
BSS was at 7680 of 7680 and the direct page at 255 of 256, so there was no
room for either a counter or a pointer for `lda [puntero], y`. Where in the
cycle each family is comes from **dividing `vueltas` by its cadence with the
hardware divider**, and the remainder of that same division says whether
this tick is the one of the change, which is the only thing that needs to
be asked to know whether the DMA is needed. Where the tiles and the drawings
are is brought by `anim_tabla`, which the converter builds with the VRAM
address already resolved.

What is paid is that `vueltas` is sixteen bits: every eighteen minutes the
count wraps around and the cycle skips a drawing. It is declared in
`assets/LIMITACIONES.md`, and no test reaches it: eighteen minutes is much
more than the longest case runs.

**And the ROM's clock is not the game's tick.** Inside the black of a
teleport the world is frozen and the tick doesn't advance, but the console
keeps going around the loop: that is 70 per fade. The count that held was
the tick plus `FUNDIDO_TOTAL` for each fade, and without that the scene of
Core and Manta went off by one drawing from the first teleport. The two
counters that kept it belonged to the reference and went away with it; on
the ROM side what remains is `FUNDIDO_TOTAL` and `fundido_tick`, which is
where the 70 go by.
