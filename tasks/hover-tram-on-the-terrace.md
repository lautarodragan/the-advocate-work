---
name: "The Hover Tram on the terrace"
description: "Draw the ship on the Warehouse roof, baked into a fork of the map"
type: feature
status: done
---

**Make the Hover Tram visible** in the cutscene on the roof of the `Sector 27 Warehouse`
(map 32), where today nothing is seen.

In RM2k it is a `ShowPicture` —`hovertram2`, event `EV0003`, page 0,
command 1, parameters `[10, 0, -90, 110, 1, 65, ...]`—. The important part: **it does not
move**. There is no `MovePicture`; it stays anchored to the map and it is the camera
that slides to it with the `PanScreen` of `EV0005`. It is erased by three
`ErasePicture` of `EV0005` and some common events.

That is why the picture system is not needed: **it is baked into a fork of the map**,
like the Auditorium's audience, with a ChipSet of its own.

Measured on 2026-09-22:

- the picture is 254x232 and is shown at **65%**: 165x151 px, **170 8x8
  tiles with something drawn** (5.3 KB at 4bpp) in **55 16x16 cells**, and 164
  colours at 15 bits;
- map 32 has **all 8 sprite palettes taken** —ten characters—, so
  as objects it does not fit; of the background it uses 58 of 103 colours, 45 remain;
- **the AGENCY CAPTAIN shows below the tram**, so it goes in the **upper
  layer**, which on the console is drawn above the sprites, and its tiles
  need the "above the hero" bit or the converter bakes them into the background;
- in the captures the tram falls entirely on the terrace's floor, with no sky
  behind.

What has to be measured before drawing anything:

1. **whether that area is seen outside the cutscene**; if not, drawing it
   fixed is enough and `TileSubstitution` is not needed to turn it on and off;
2. **how it looks with the colours that fit**, which is the artistic decision;
3. **where exactly it falls**: RM2k places it on its 320x240 screen and the
   port's camera is 256x224.

# The three answers, measured on 2026-09-22

The scripts that produce them are in `/extras/scratch/hover-tram/`.

## 1. It is not seen outside the cutscene: it goes fixed, without `TileSubstitution`

**And taro thinks that is not about this case but the rule**: on map 32 everything is
cutscene, and he thinks it happens in almost all the game's `ShowPicture`. If
so, "the picture does not coexist with free walking" stops being a
lucky coincidence and becomes what makes **baking the pictures into the
map a path and not a trick**: there is no need to turn them on and off because
nobody sees that area without them. It is unmeasured over the other maps; measuring it is
cheap —the `ShowPicture` are 11110 and the page's trigger is right there— and
it would decide whether this can be repeated.

The terrace is a **closed region of 224 cells** —`conecta.py`, with the same
passability the converter uses, `rm2k.passability_map`—: from the ground floor
you cannot get there walking, and from the terrace you cannot leave.

The only entrance is the `Teleport` to **(43,2)** of `EV0003`, which is a
**touch** event at (38,28) without conditions and which does the `ShowPicture`
**immediately before** teleporting. The only exits are the touch `Teleport`
of `EV0004` at (43,1) and the end of `EV0005`, which sends to map 33.

So **every time the camera can see those cells, RM2k has the picture
up**. There is no state where the area is seen without the tram, so there is no need
to turn it on or off.

## 2. Where it falls: map pixel (308,35), 165x150

The picture scaled to 65% with nearest neighbour ends up at **165x150** —not 151—
and its corner falls on **pixel (308,35) of the map**, which is **cell (19,2) plus
(4,3) inside**: it is not aligned to the grid.

It was measured against EasyRPG's capture 1 in two independent steps
—`ubicar.py` and `ubicar_tram.py`—: first the capture's camera, matching a
region of pure map against the rendered map, which gives **(256,16)** with 93.7% of
pixels identical; then the tram, which matches with **97.3% of its opaque pixels
exactly identical**. 65% with nearest neighbour is then what
RM2k does, and the `ShowPicture` of `[..., -90, 110, 1, 65, ...]` is the **centre** of the
picture, anchored to the map (`origin` 0 in RM2k).

The box is **cells x 19..29, y 2..11**, with **53 cells** with something drawn
—not 55—, **172 8x8 tiles** and **159 colours at 15 bits** (206 at 24). The
differences from what was noted before come from rounding the 65%.

## 3. The colours fit, and the tram survives

The real allocation is not against the background but against **the upper layer**, which is
where it goes: map 32's background uses 58 colours and **takes 5 of the 8 palettes**,
so the upper layer is left **3 palettes = 45 colours** —that is where the
45 comes from—. With the tram that layer goes from 7 to **163 colours**, and `repartir_encima`
—the converter's very code— brings them down with **146 merges**, using 2 palettes.

**It looks good**: the tram is almost all grey and desaturated brown, so the
merges fall between neighbours. The captures are in `/extras/capturas/hovertram/`:
`tram-comparado.png` is the before and after at 3x, and `port-320x240.png` has the
same framing as EasyRPG's capture 1.

# How it turned out

**The tram is visible**, at **56%** and shifted **2 px to the right**, in 42 cells of
the upper layer of ChipSet 55. The capture taken from the ROM is in
`/extras/capturas/hovertram/rom/`.

What it cost, measured: **zero bytes of bank 0** —2825 free in `abl` with and without
the tram— and zero ROM extension. What it did pay is colour: the upper
layer takes one more palette, the background goes down from 103 to 87 entries without merging
any, and the four `32-*` goldens move by 30 to 48 pixels in a line
of railing. They are **not regenerated**, waiting for taro to look at them.

What is left free in `TABLAS`, which depends on which cartridge is built:
`pruebas` 2455 B —the tightest—, `juego` 2568, `abl` 2825, `chico` 3149.

# What was learned that is not about this case

**`huella()` did not look at `juego/`**, so touching a fork did not rebuild the
test cartridges and the suite ran against the old ROM. It cost accepting
a ROM divergence that did not exist. Fixed in its own commit.

**A new test has to be seen failing.** The first two versions of the one that
checks the hero stays behind the tram were useless —one compared a set
against its own difference, empty by construction; the other ran without a party,
so there was no hero to draw— and both passed. They were fixed by breaking
on purpose the "above the hero" bit until the test caught it.

# Where it stands

Done and verified:

* the **fork of map 32 with ChipSet 55**, pruned to what the map draws.
  It comes out byte for byte identical to without the fork;
* **`from_image`**, the operation that brings in a PNG that is neither ChipSet nor
  CharSet, with its test. It is in the tree but **no recipe uses it
  yet**;
* the **rounding to 15 bits**, which is what makes the colours fit.

**A decision about VRAM** is missing, which is what holds back the drawing.

# The two axes for fitting in 128 tiles, measured

## Aligning it: it is worth 3 tiles, and fixes the wall for free

Moving the drawing across the grid brings it down from **166 to 163** tiles and nothing more —the
best of 221 shifts tried—. **Aligning it to the grid is not the optimum**:
`(320,48)`, which would be the cell corner, is not among the fifteen best.

But shifting it **2 px to the right** does help with something else: with `x0 = 310` the
tip's 9 pixels **stop falling in column 19**, which is the terrace's
wall. They go from 9 to 4 to 0 with +1 and +2. So the decision about
those 9 pixels disappears: there is no need to choose between losing the wall and losing the tip.

## Merging colours: it moves nothing

It is the experiment taro wanted first, and the curve settles it:

    colours   tiles
       17      165     <- what the allocation gives today
       13      165
       10      165
        8      165
        6      164
        4      164
        3      163
        2      130     <- and here it is already a silhouette

From 17 colours to 3, **two tiles** are gained. The reason is that **the tram's tiles
differ in shape and not in colour**: it is a detailed 3D render, and two
8x8 cells are almost never equal even in black and white. Not even with two
colours does it fit.

And the first steps all give 17 because the real cap is not the requested one
but **the packing into 3 palettes**: asking for 45, 36, 28 or 22 gives the same, the
allocator merges down to 17 anyway.

The captures of each step are in `/extras/capturas/hovertram/escalones/`.
The 6-colour one already loses the red panel on the side, and gains one tile.

# What holds it back today: the upper layer fits in 128 tiles and the tram asks for 165

With the tram baked, the converter stops:

    mapa 32: con este reparto de VRAM, encima necesita 165 tiles y entran 128

The three VRAM allocations give the upper layer **128 tiles** —8 KB of
BG2—, and none is the one that is tight elsewhere: map 32 spends **213
background tiles of 448** and **184 sprite tiles of 448**. Room is plentiful; what there is not is
room **in that layer**.

Until 2026-09-07 the upper layer had **256 tiles** and it would have been enough. It was
lowered to 128 on purpose, because over 328 maps the median usage is **1 tile**
and 326 fit in 128, and those freed 4 KB are 64 more background tiles —which is
what made map 8 fit—.

Going back to 256 is not just adding a fourth allocation, and that is measured:
**`VENTANA_TILE_BASE` is a global constant**, it comes from `LAYOUT_VENTANA` alone,
and `ventana_celdas` is emitted **only once for the whole ROM**. So the
message window knows at which BG2 index it starts and that index is the same
for all maps: a map with an upper layer of another size would draw the
text with the wrong tiles. There are three ways out, and none is free:

* **going back to 256 in all the allocations**, which takes 64 background tiles from each
  map and it needs measuring whom it leaves out;
* **making the window per map**, which costs ROM and complexity;
* **bringing the tram down to 128 tiles**, which is 23% less and is artistic.

And a fourth one that **is measured and does not work**: splitting the tram between the background and the
upper layer, leaving on top only what a character can cover. **53 of the 53**
cells of the tram are reachable by a sprite standing on the
terrace —it is drawn at `(x*16-4, y*16-16)`, so it touches the neighbouring cells—,
so not a single one is saved.

# What does not fit in today's form

The ChipSet recipe **cannot bring this picture in**, and not because of the missing
operation —`from_image` would be the same as `from_charset`— but because of the **vehicle**:
the ChipSet's PNG is indexed and has 256 entries.

    ChipSet1, the base of 11                       uses 134 indices
    overwriting the 55 upper slots that are needed 130 left free
    the tram asks, at 24 bits                      204 new indices
    the tram asks, at 15 bits                      148 new indices

130 < 148: **it does not fit**. It only fits if the fork also does two things it does not
do today, and both are decisions, not details —`paleta.py` and `techo.py`—:

* **pruning the ChipSet to what map 32 draws.** 55 is private to the map, so
  what the map does not draw is dead weight: pruned, **82 indices used
  and 174 free** remain. But that changes what a fork's ChipSet is.
* **rounding the tram to 15 bits before writing it**, which is what brings 204 down to
  148. For the console it loses nothing —the allocator quantises with `>>3` anyway—,
  but what the fork writes stops being the game's art.

With both, 148 ≤ 174 and it fits. **Both were approved on 2026-09-22 and are
done**; the why of each one stayed in the code and in `juego/README.md`.

# The rest that was measured

* **The slots**: map 32 uses 33 of the 144 upper ones, and **63..117 are 55
  consecutive free ones**. `passable_upper[0]` of ChipSet 11 is **0x1F**, so
  the tram's slots have to carry 0x1F so as not to touch passability.
* **The terrace's wall**: column x=19 has upper slot 18 —flags
  0x00— in rows 2 to 11, and **9 pixels** of the tram's tip fall there, in
  cells (19,4) and (19,5). All 9 are in the strip x 316..319, which is
  exactly the one a sprite standing in column 20 covers —it is drawn at `x*16-4`—,
  so the two possible paths diverge on those 9 pixels: leaving them out
  always loses them, and putting them in with the wall's flags draws them below the
  hero when RM2k draws them above.
* **The defect of the two pink pixels**: at 65% **only one survives**, the
  one at (199,192) —`(255,39,194)`, almost the key `(255,33,192)`—, and it falls on map
  pixel (437,159), cell (27,9). The one at (199,193) is not sampled by nearest
  neighbour and goes away on its own.
* **The captures' camera**: 1 is at (256,16) and 2 at (416,16).

Reference: `/extras/capturas/hovertram/`, three EasyRPG captures that taro
took (the FPS counter is not part of the game).

# Played

taro played it on 2026-09-23 with the build of `3e028a0`, in their words,
translated:

> it is perfect
