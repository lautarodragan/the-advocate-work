---
name: "Vampires Dawn fits in the cartridge, compressed"
description: "VD asks for ~11.7 MB of blocks against 7.94 MB in the 127 banks (pose_N 4.27, map_tiles_N 2.21): compress until it fits; if that is not enough, MSU-1 mandatory for VD"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Measured by Tijereta on 2026-10-11 (`los-sonidos-de-la-musica-en-mas-de-un-banco.md`), with Aguará's 82 exclusions and starting at 8: `the data does not fit: … the 127 banks the cartridge has for data are taken`.

taro's decision, on 2026-10-11: try compression. Not two cartridges —saves would have to be migrated, and nothing guarantees splitting it elegantly—. If it does not fit without compression, before two cartridges, MSU-1 mandatory for this game; a compression chip only if the numbers work out, and better not if MSU-1 is still optional in general, because of the complexity.

## The measurement, 2026-10-11 (Tijereta)

On the VD build with the 82 exclusions and starting at 8, the-advocate tools
at 6f933ff8 —the `mapdata.inc` that gets cut short—. The scripts, in
`~/scratch/tijereta/comprimido/`.

**What is already compressed.** The converter says so at the end of its log: the background
(`map_tiles`, 2268 KB of LZ2, 3196 raw), the upper layer, the initial sprite
bank, the ChipSet animation, the grid and what lives behind
it, and the bytecode: 3618 KB of LZ2 that were 7547. The battlers, the
battle backgrounds and the `big_map` are compressed some other way: LZ2 gets
nothing out of them (100%). **The poses are not**: `pose_N` are 8748 blocks of 512 raw
bytes, 4374 KB, and they are uploaded by DMA straight from ROM to VRAM.

**What LZ2 yields on what is not compressed**, block by block
—each one has to be decompressible on its own—:

    class          blocks      raw        LZ2
    pose_N           8748    4374 KB   1518 KB  (35%)   -2856 KB
    pano_tiles_N       32     517 KB    418 KB  (81%)    -99 KB
    big_tiles_N        43     428 KB    355 KB  (83%)    -73 KB
    pano_map_N         32     173 KB     90 KB  (52%)    -83 KB
    font/slot/scr_pre  24     351 KB     59 KB           -292 KB, but they are read
                                                        letter by letter: they would
                                                        have to be in RAM
    npc_table_N       341     100 KB     73 KB           -27 KB, the CPU reads it
    sprite/map_cgram, ev_pos, battler, backdrop: nothing

**What repeats across maps.**

* Poses: they are already shared across maps when they are identical byte by byte
  —`poses` in `record.rs`—: 14880 requested, 8748 distinct. What is left are
  462 banks of the same (CharSet, index) **quantized differently** in another
  map. If two poses that differ only in which palette index each
  color takes counted as one, there would be 7536: 606 KB raw, ~210 KB after
  LZ2. The rest of the difference is colors lost differently in each map:
  quantizing each character the same way in all its maps changes what is seen and
  touches Adeleine and `wally`; I am not taking that on.
* Background tiles (8 bpp): distinct within each map 3196 KB, across the whole
  cartridge 2949 KB. Sharing them across maps would give 8% raw: each map
  quantizes its own palette and the indices do not match.
* Upper layer: 359 → 247 KB sharing tiles; sprite bank: already
  353 KB of LZ2.
* The poses split into their 16 tiles: 56% are all-zero tiles (columns 0 and
  3 almost always), 43500 distinct non-zero tiles. Storing them without the zeros
  with a mask: 1932 KB; with the tiles shared across the whole cartridge:
  1633 KB. LZ2 per pose wins: 1518 KB.

**Other codecs, as a bound.** The 8 bpp background does better in "chunky" —one
byte per pixel, re-planarized on load—: LZ2 1864 KB against 2266, **-402
KB**; xz per block, 1863 planar and 1083 chunky, but xz does not run on a 65816.
In 4 bpp chunky gets worse (poses 2137 KB, panoramas 511).

**What it costs, in time and RAM.**

* Poses in LZ2: today a pose is a DMA from ROM to VRAM in vblank, without
  CPU. Compressed, it has to be decompressed to WRAM first —when it is queued, in the
  main loop— and the vblank DMA comes from there. With the converter's
  model (700 master cycles per command and 60 per byte, "on the high side")
  a pose costs 13% of a frame at the median (21 commands), 15% at p90,
  22% at the worst (69). A 512-byte copy to WRAM with `mvn` is already ~9%:
  any scheme that is not direct DMA from ROM pays almost the same.
  RAM: a ring of VQ_MAX = 8 poses, 4 KB, which has to survive from
  queuing to vblank.
* Poses without the zeros, by direct DMA: no CPU or RAM, but up to 12 DMAs
  per pose instead of 4, and vblank is the tight resource (VQ_PER_FRAME);
  it yields 414 KB less than LZ2.
* Chunky background: only when loading the map, with the screen off; re-planarizing
  8 bpp with tables is ~2000 cycles per tile: a map of 1000 tiles, ~half a
  second more of loading.
* Panoramas and images in LZ2: on load, to `LZ2_BUFFER`.

**The numbers.** Missing 11.69 − 7.94 = 3.75 MB, plus what is lost when
distributing into banks. The poses give 2.79; the chunky background 0.39; panoramas,
images and their maps 0.25. All together, 3.43 MB: **it falls short by ~0.3 MB**
even without counting the waste, and what is not poses costs much more per KB.

## What was tried: the poses in LZ2, and why it is not merged

What yielded the most, implemented in the `tijereta-vd-comprimido` branches of
the-advocate (Tijereta's commit) and of the ports. **It is not for merging**:
it stays as a record of what was measured.

* `poses` in `record.rs` (rm2k-snes-mapdata) writes each distinct pose as
  its own LZ2 stream and emits `POSE_RING`, `POSE_RING_SLOTS` and
  `POSE_BYTES`. The fingerprints in `mapdata/tests/python.rs` do not move: the
  text goes through `with_the_poses_raw`, which decompresses and gives the old one byte by
  byte.
* `vram_queue` (runtime/load_graphics.s) decompresses it when queuing it into its
  slot of a ring of 8 × 512 bytes at `$7FF000-$7FFFFF` —the tip of the
  upper half of `$7F`; `check_map` takes those 4 KB away from what lives behind
  the grid: the most VD uses of that half is 17,770 bytes (map 292) and
  ABL 12,080 (map 43)—, and the queue entry points there. One byte of BSS,
  `vq_ring`.

**VD with that**: the `.block`s go down from 11.69 to **8.91 MB** against 7.94 (poses
from 4374 to 1518 KB). **It still does not fit: ~0.97 MB missing**, plus whatever is
lost when distributing. The rest of what was measured —chunky background 0.39, panoramas and images
0.25, poses up to permutation ~0.2— adds up to ~0.84 MB in the best case: not
enough. And the 82 exclusions are maps that do not convert today: they will ask for
more.

**ABL cannot pay for it.** With everything else green, the suite ends up with 8
reds (1169 of 1177), all from CPU time:

* `test_la_carrera_entera`: the lap of 49 spends 1217 hardware frames
  in 976 ticks, 241 too many against a cap of 48. Counted per tick —with a
  temporary counter, already removed—: of the frames with 0 poses to
  decompress, 23 of 510 are lost, with 1 pose 38 of 269, with 2 **100 of 117**,
  with 3 or more **all of them** (80). The race loop has ~10-15% of a frame
  free, and each pose costs ~13%. A cap of two poses per frame improves
  nothing (286 too many).
* the six `test_batalla[batalla-*]`: the capture comes out late —the command
  menu where the golden already shows the item one—, from frames lost
  before the battle;
* `test_la_celebracion_con_la_cache_de_ranuras`: events without a slot at
  frame 65, the cache is one frame behind.

`abl.sfc` with that: `d1e666eeefe2…`. What got fixed along the way and holds
for any attempt that repeats this: the ring index has to be
masked when reading it (RAM starts with garbage and a pose landed on the
grid: `test_la_grilla_vuelve_entera_de_una_pelea` caught it); Goombario
asks for the width of A when calling `ring_place`; and two tests in the ports
—`cache_de_ranuras.py`, `test_paradise.py`— read the pose from ROM and have
to decompress it; `test_reservas_de_la_wram.py` has to allow
`POSE_RING`.

**What does not work or was not tried, and why:**

* Decompressing with DMA to `$2180` in the loop (≈2% of a frame per pose): a
  general DMA outside vblank clashes with the window's HDMA and on the
  first CPU revision hangs the console —see
  `battle_animation_frames.s`—.
* Copying with `mvn` a format without the all-zero tiles: ~7% per pose, half
  of LZ2; with the race numbers it still loses frames.
* Decompressing during the wait for vblank, with whatever is left over: it does not lose frames,
  but the pose can arrive one frame late, and the OAM already counts on it —in
  a map with turns or cache another character would be seen for one frame—.
* Uploading without the all-zero tiles by direct DMA from ROM in vblank (no CPU
  or RAM): 1932 KB in VD (−2.44 MB), but up to 12 DMAs per pose instead of
  4, and vblank is the tight part (`VQ_PER_FRAME`); it would have to be measured whether it fits
  without lowering the cap of poses per frame.

**Conclusion**: with what is reasonable VD does not fit, and the only thing that really pays off
—the poses— costs ABL frames. What comes next is MSU-1 mandatory
for VD, which Hornero opens. If that is done, compressed poses are not needed;
if one wants to shrink what goes through MSU-1, the option that does not cost
ABL CPU is the last one on the list.

## When merging

Nothing to install: only this task goes to `main`. The
`tijereta-vd-comprimido` branches of the-advocate (7d5bb4ea) and of the ports (213e1ef)
are the record of the experiment and **are not merged**.
