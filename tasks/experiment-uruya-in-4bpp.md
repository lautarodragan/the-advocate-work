---
name: "Experiment: Uruya in 4bpp"
description: "A throwaway ROM that only shows Uruya (Vampires Dawn, map 165) in mode 1, with its two layers at 4bpp, to see how much color is lost in exchange for fitting in VRAM"
type: research
status: done
agents: [Calandria]
assignee: taro
---

**Done**, 2026-10-12. Superseded: the ROM was a throwaway, and what it showed was followed by `adeleine-palettes.md`.

Measured by Hornero on 2026-10-06 with `wally layers`: Uruya is 817 background
tiles of 8x8 at 8bpp (60x60 cells, 95 in the upper layer), and the largest VRAM
split gives 544. At 4bpp about 2000 fit. It is throwaway: what
matters is the ROM to look at and what was measured, not the code.

taro, on 2026-10-06: "as a 100% throwaway experiment, could you build me
a ROM that only has that map, in 4bpp mode".

## Done, on 2026-10-06 (Calandria)

Two ROMs in `/shared/builds/otros-juegos/`, to look at in an emulator, and
side-by-side captures in `/shared/capturas/2026-10-06-uruya-4bpp/`: each sheet
has RM2k's original, wally's 8bpp, and the two ROMs. The experiment's
code (conversion, `uruya.s`, the `ld65` cfg, the captures) stayed in
the scratch, outside the repo, on purpose.

- `uruya-4bpp.sfc`: mode 1, BG1 the lower layer, BG2 the upper one (with
  tile priority at 1, which is what puts it in front), 8 palettes of 15
  colors decided by `adeleine reduce` as is, over the color sets
  of each 8x8 tile of the two layers together.
- `uruya-4bpp-clustered.sfc`: the same tiles, but the palettes come from
  grouping the tiles into 8 by color closeness and keeping in each group the
  15 colors that cost the least error; each pixel goes to the closest one in its
  tile's palette. It is not Adeleine: it is a 150-line script, to see
  how much of what was lost was the algorithm's and how much the format's.

D-pad to walk around it (2 px per frame; with B, 5). The 120x120-tile map
is scrolled with a 64x64 window per layer in VRAM, and the NMI writes the
column or row that comes in (≈124 words in the worst case, diagonal, in
vblank). It works in snes9x, bsnes and mesen-s with the same frame.

### What was measured

- **8x8 tiles at 4bpp**: 878 with Adeleine, 896 with the clustering (counting
  the empty one; the two layers share the tile set). Looking for mirrors
  found not a single one. With wally's 8bpp it was 817 (the lower layer alone,
  without animations). At 4bpp they take 28 KB of the 64 KB of VRAM; with the two
  64x64 tilemaps (8 KB each) about 20 KB remain free, another 600
  tiles. It fits with plenty to spare, and there is room left for animations.
- **Colors**: the map has 157 colors at 15 bits (all 157 are in the lower
  layer; the upper one uses 74, all among the same ones). Wally's 8bpp had already
  brought them down to 98. The 8 palettes of 15 are 120 slots.
  - Adeleine: **19 distinct colors** remain (the 119 slots full, but
    almost all repeat the same ones), 138 merges, 33.5 % of the pixels
    change color. It shows: the red roof of the house loses its pinks and its
    light tones, the water and the cobblestones go flat.
  - Clustering: **73 distinct colors** remain, 17.7 % of the pixels
    change color, and the red of the roof, the green of the treetops and the blue of the
    water stay almost like the original; the roof is what shows most.
- **Why Adeleine leaves so few**: `reduce` merges globally, one color at
  a time, until `try_pack` (a greedy best-fit) fits all the tiles;
  it cannot choose that two neighboring tiles paint the same
  hue with different palettes. The palette is per tile, and the merge is per color of the whole map: that is
  where it is lost. A choice per palette, like the clustering's, keeps four times as many
  colors. It would be an improvement to `adeleine` if this were
  pursued; it was not touched.
- **Check**: the ROM against the render its own palettes promise, at 15
  bits, at 9 camera positions (odd, diagonals, edges): 0 pixels of
  difference in the three emulators. The only thing that is not exact is the last
  line of the south edge, which the PPU draws one row lower than the map
  has.

### What it does not do

No hero, no events, no water or tile animations, no
baked tile-events (I did not try them: with 20 KB of VRAM free and the upper
layer already in BG2, they fit without asking for anything new). No message window: the
palette 0 that the engine reserves for it is here one more for the background.
