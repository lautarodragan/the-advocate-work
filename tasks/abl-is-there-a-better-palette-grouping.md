---
name: "ABL: is there a better palette grouping?"
description: "A short study: whether Adeleine's grouping of colours into palettes has obvious room left, starting from map 3 where Core's blood comes out brown; if not, ABL keeps targeted fixes"
type: research
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-11-16, after Core's blood on map 3 came out brown
([`abl-core-s-blood-turns-brown`](abl-core-s-blood-turns-brown.md), the
targeted fix, in parallel):

> I'd like to check whether another possible colour distribution exists
> that improves this without making anything else worse. We already did an
> experiment like that in the past, and reached the best possible
> distribution. [...] maybe I'd do both things, in parallel: the map patch
> that "fixes" the colours of the blood, and a mini investigation to see
> whether it is worth investing more in the colour distribution. [...] If
> there are no obvious optimisations, I'd limit myself to targeted
> improvements in ABL, when it merits it.

Done means: on map 3 (unpatched), why that tile's reds become brown —which
palette it lands in, what the alternatives cost—; whether a different
grouping (Adeleine's objective, its tie-breaks, the weight of small but
saturated colours) would keep them without worsening the rest of the map;
the same question over ABL's maps in aggregate, measured, not argued; and a
recommendation: worth investing or not. A research page in the book if
there is something to keep.

## Log

**2026-11-16, Carpintero**, from the-advocate `705d24f5` and the ports
`299088c`. Map 3 goes in **mode 1** (its panorama, Weird, and a layer
above): the map is 4bpp, five palettes of fifteen for its places
(`mode1.rs`, `reduce_colors`), and the converter says "75 distinct colors,
36 in CGRAM of 75 available, 108 merged". In mode 3 the background is 8bpp
and never grouped, so in ABL grouping only matters on the five mode-1 maps
(3, 6, 32, 105, 255), the layer above of every map, and the sprites, which
wally splits on its own. Method: a throwaway wally that writes each
`reduce_colors` call's places with their pixel histograms, ABL's release
built through a shim that keeps the requests, and a harness that replays
each call with variants of Adeleine and measures the colour error per
pixel.

**Why the blood is brown.** Map 3's five palettes, as the release has
them: 15, **1** (white alone), 12, 15 and 15 colours, 36 distinct. The
blood's four cells go to palette 0, the dark floor's: the first grouping
places a cell by its mean colour, and its near-blacks and a teal make it
floor. Palette 0 picks its fifteen by pixels; the reds are ~120 px of the
map's 1.44 million, all in that tile, so none stays, and each goes to its
nearest by the luma distance: `[25,10,10]`, `[30,12,12]` and `[30,16,13]`
to `[20,15,10]` (20 to 24 dE2000), `[17,6,4]` and `[19,8,6]` to
`[15,10,7]` (12). **The browns are the rust specks of the teal wall
panels** (from (33, 42), 708 and 253 px a drawing): the only warm colours
palette 0 has.

**Variants**, replaying the 31 calls that merge (5 mode-1 maps, the layer
above of 26 maps, 15 of them with one palette where grouping cannot help),
error in dE2000 x pixels against the picture at 15 bits: Lab distance
−20% (4 calls worse); CIEDE2000 distance −24% (5 worse); 50 rounds 0%;
**21 starts, best by the same luma cost: −49%, mode-1 maps −62%, 0 worse**;
21 starts with Lab −53% (2 worse); sqrt weighting +52%; chroma weighting
−11% (16 worse); one more palette −34%; colours moved to their group's mean
(taro's idea, one Lloyd step in RGB, no threshold) +1%, and with 21 starts
it undoes part of their gain. On wally's own pictures with 21 starts built
into Adeleine: map 3 0.090 → 0.059 mean dE2000 per pixel, 6 0.001 →
0.000, 32 0.099 → 0.023, 105 0.057 → 0.008, 255 0.015 → 0.005; 16x16 cells
worse by more than 2: two on map 32 (+2.1), none elsewhere. The blood is
red (3.1 to 5.5 dE2000 a cell instead of 6.4 to 14.7). Cost: ~4 s instead
of 0.25 s per merging call on map 3, three calls per map; only calls that
merge repeat.

**Distances, Hornero's question**: `try_pack` none; first grouping, plain
RGB between mean colours; colour choice, reassignment and nearest, the
luma distance (30/59/11 squared, so red→brown is cheap); 8-bit background
merges, luma; a lent character's nearest, Lab since 2026-10-17. Lab or
CIEDE2000 alone leave the blood in palette 0 as a darker red-brown
`[19,8,6]`; Oklab not tried here (it lost to Lab on the lending).

**The signs** (taro): map 8's EV0006/7/18/27/31 are tile 53 of `BLchp1`,
a green-screen monitor, **lent** palette 6 (orange/brown) on a map of 28
characters: the greens go to grey and dark teal, 30 and 36 dE2000, 6.5 over
the sign. That is the characters' lending, not Adeleine's grouping: step 3
of the chests' study. Map 9's EV0024 (tile 52) and EV0026 (tile 53) have
palettes of their own and are drawn exact in wally's output; whatever
looks off there is not the palette (not captured on the console).

**Recommendation**: worth a small investment, not a new objective: more
starts in `reduce_colors` (or a better first grouping) is an obvious,
measured win with nothing worse on ABL's maps, and it fixes the blood on
its own. Not measured: the pictures, screens and battle, which call the
same function, nor the other games; it would move goldens of the five
mode-1 maps. Calandria's targeted patch stands either way. Drafts:
[`adeleine-s-grouping-settles-on-its-first-start`](adeleine-s-grouping-settles-on-its-first-start.md),
[`abl-map-8-s-signs-lose-their-green`](abl-map-8-s-signs-lose-their-green.md)
(and its line in ABL's Known issues). Book: branch
`carpintero-palette-grouping`,
`src/ports/abl/research/2026-11-16-the-palette-grouping.md`, links
checked. Captures: `/shared/captures/2026-11-16-palette-grouping/`. No
code branch: the variants were throwaway; nothing to install when merging.
