---
name: "Panorama tiles compressed"
description: "Store panorama tiles in LZ2 instead of raw: ~85 KB freed in ABL's release, about three frames more on the largest panorama's load, and care with a ChangePBG mid-map"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-16, after [`abl-room-for-still-events-in-the-background`](abl-room-for-still-events-in-the-background.md) (Mulita's study):

> I'd also do the panorama tile compression, honestly. 85 KB is a lot of
> gain, and 3 more frames of loading on the largest map (and I assume it
> only affects the ones with a panorama) is a more than acceptable cost.

The study measured 358,720 B raw, −84,911 B in LZ2, about three frames
more for the largest, and a buffer to watch if a `ChangePBG` swaps the
panorama mid-map.

Done means: panorama tiles in LZ2 in every game, unpacked on load and on
`ChangePBG`; measured gain and load frames per panorama map; ROM tests
(a panorama map's load, a `ChangePBG`); all suites green, goldens
unchanged or explained.

## Log

Carpintero, from the-advocate a83c4a12 and the ports ff7ac5b, branches
`carpintero-pano-lz2` in both.

### Where the buffer is

`git blame` of `pano_load`: Cardón's a67ce9c5 (2026-10-05, raw tiles by
DMA from `load_above`), Mulita's e9a9488f (2026-10-11, the `.msu` path)
and Aguará's d8b7f2cf (2026-10-19, `pano_image`, the mid-map swap). The
tiles are bounded by the layouts: 576 4-bit tiles in mode 3 (18,432 B),
768 2-bit in mode 1 (12,288 B).

* **On a load** `pano_load` runs from `load_above`, which already
  decompresses the upper layer into `LZ2_BUFFER` (cap $6000, below the
  ChipSet animation's drawings); `enter_map` and `back_to_map` rebuild
  `CODE_CARRY` and the battle animation's box after it. So the tiles go
  through `LZ2_BUFFER` with nothing new to restore.
* **On a `ChangePBG` swap** (`pano_image`) the buffer holds, on the map:
  the battle animation's two frames (`ANIMB_PREV` points into them) and
  `CODE_CARRY` —maybe the very page running the `ChangePBG`—. The ChipSet
  animation's drawings at $7F6000 are above 18 KB and stay. So after the
  swap, `anim_buf_clear` and `code_carry_after`, as `back_to_map` does:
  the carried bytecode comes back byte for byte from its stream, and
  `code_ptr` still points at the same byte. A big picture's tilemap is
  also there, but it is only read right after `big_unpack`.
* Painted maps (mode 4) keep raw tiles: they are streamed column by
  column as seen, not loaded whole. Baked panoramas are inside the map's
  tiles (already LZ2); hidden ones carry nothing.
