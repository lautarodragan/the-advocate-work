---
name: "Panorama tiles compressed"
description: "Store panorama tiles in LZ2 instead of raw: ~85 KB freed in ABL's release, about three frames more on the largest panorama's load, and care with a ChangePBG mid-map"
type: feature
game: abl
status: testing
assignee: taro
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

### What changed (the-advocate `carpintero-pano-lz2`)

* `panorama.rs` in mapdata: each distinct picture's tiles compressed once
  (`compress_many`), emitted as the record's +32 stream; the tilemap stays
  raw. `LZ2_CAP_PANORAMA` ($6000) is emitted and refused above; `pano.s`
  asserts it against `ANIM_DRAWINGS`.
* `pano_load` decompresses into `LZ2_BUFFER` and does its two DMAs from
  there; the `.msu` path goes through `lz2_decompress`, so its own
  `msu_dma0` path and `msu_dma0_l` are gone. `pano_image` calls
  `anim_buf_clear` and `code_carry_after` after the swap.
* Which ways store tiles: **mode 3, flattened (mode 3 with the ChipSet's
  above-hero cells in BG1) and mode 1** have a `pano_table` record, and
  all three now go LZ2. **Painted** (mode 4) keeps raw tiles in
  `paint_table` —streamed by column—. **Baked** is part of the map's own
  tiles (already LZ2). **Hidden** carries nothing.
* Test game: map 10, the lookout, and `test_panorama_swap.py`: a case
  page carried from map 1 waits there while the map's parallel swaps
  `Stars` for `Dawn`; `CODE_CARRY` must come through byte for byte. Seen
  red with `code_carry_after` taken out of `pano_image` (the bytecode came
  back as the picture's tiles), green with it; its two goldens are
  identical on the global tools (raw tiles) and on these. A first `Dawn`
  with plain bands was 3 KB of tiles, under `CODE_CARRY`'s $1100, and
  could not go red: the second has dithered band edges, 17,248 B.

### Measured

Both sides on the same base: the global tools (the-advocate cd3fecb8,
`main` merged into the branch) against `.local-tools` of the branch
(`project cartridge mapdata convert`), the ports at b024af2, every game's
cartridges built without tracks, `just space` of each. Scripts in
`~/scratch/carpintero/pano-lz2/scripts/` (`space.sh`, `compare_space.py`,
`pano_cost.py`, `measure_loads.py`, `swap_frames.py`).

```text
game              pictures  raw tiles  as LZ2    saved    release, banks used and gaps
abl                   21     289,568   218,930   70,638   126 -> 124, 656 B -> 2 halves + 20,031 B
desert-nightmare      44     461,088   352,072  109,016    99 ->  97
zounds                18     219,280   154,194   65,086    68 ->  67
frozen-world          20     312,880   268,608   44,272    68 ->  67
dooms2                 4      70,912    54,053   16,859    41 ->  41
book-of-three          1      16,160     8,893    7,267    48 ->  48
sunset-over-imdahl     3      54,752    49,696    5,056    87 ->  86
el-dorado              1      14,976     9,943    5,033    21 ->  21
vampires-dawn          1         144       119       25   126 -> 126 (its .msu carries the rest)
```

ABL frees 70,638 B of data, not the study's 84,911: today's release has
21 distinct pictures (289,568 B raw) where the study counted 358,720.
Every ABL test cartridge keeps its banks or loses one. The code: FAR2
(bank $C0) 17 B more, FAR3 ($C1) 8 B; Sunset's $C0, the tightest, has
259 B left.

**Load frames**, ABL's `release` in snes9x, hardware frames of
`go_to_map` plus 40 ticks, raw against LZ2, for the 25 arrivals of
`test_panorama_golden.py` plus 255: +2 to +6 on the 18 maps with a
panorama layer, 0 on the seven baked or hidden. **The worst is map 95,
"Into The Machine"** (flattened, `TasgardePan`, 18,432 B): 52 -> 58. The
converter's cycle model (700 per command, 60 per byte, on the high side)
gives it 7.4; the largest elsewhere are 6 to 8 by the model (Frozen
World's 137, Dooms 2's 8). All of it inside the entering fade.

**A swap mid-map**: the test game's lookout (`Dawn`, 17,248 B, and the
carried page's bytecode decompressed again), the tick of the
`ChangePBG`: 5 frames raw, 10 with LZ2, in snes9x and bsnes. Black, as
before: `pano_image` already turned the screen off for the ring.

### Tests, and what to install

With the branch's `.local-tools` (`project cartridge mapdata convert`),
`main` merged in each repo (the-advocate cd3fecb8, the ports b024af2, the
book b20cf13):

* the-advocate: `just test` 29 passed; `just rust-test` green (mapdata's
  new `the_tiles_go_compressed`); `just test-game` 67 passed, 1 skipped,
  and the 3 known reds of `test_leader_name.py`; the new
  `test_panorama_swap.py` green on snes9x and bsnes. `just lint` is red
  on rustfmt in four files the branch does not touch: the draft
  `cargo-fmt-check-flags-three-files-on-main`.
* ABL: `just tests` 1661 passed, 2 skipped; no golden moved (the
  panorama arrivals, the moving ones, the Hover-Tram's `ChangePBG`, the
  save). A first run on the ports' ff7ac5b had two reds that were the
  ports behind Chajá's merge (`screen-930`, the music in the save): gone
  with b024af2 merged.
* The ports' root: `just boot` 153 passed, Zounds' DownLoad Room swap and
  its two goldens among them.

What no test covers: a battle animation on a map while its panorama is
swapped (`anim_buf_clear` after the swap); Vampires Dawn's one panorama
picture through the `.msu` past its boot; a swap on real hardware.

Branches: the-advocate and the book `carpintero-pano-lz2`; the ports
none (nothing changed there). **On merging, `just install mapdata
convert`** —mapdata emits the streams, and convert links mapdata as a
library—. The runtime changed too, but the global cartridges already
assemble it from `~/the-advocate`'s checkout.
