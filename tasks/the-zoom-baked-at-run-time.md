---
name: "The zoom, baked at run time"
description: "Compose the mode 3 screen —both layers and the sprites— into mode 7's single layer at run time, so the zoom transition can be done: every battle of every game starts and ends with it"
type: research
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-10-12: the Diff photos already zoom in mode 7, from
screenshots baked by the game's author. "Could we 'bake' the screen we are
showing in mode 3 into mode 7? I think there is nothing like a frame
buffer, so we would have to compose everything with tiles in mode 7's only
BG layer, merging all the layers at run time (objects included?)… without
going over VRAM or tiles… and without the process taking more than .5 s so
that it is not too disruptive… I don't see it very feasible, but not
impossible either. Maybe it's worth exploring?" And: "could the SA-1 do it
in its own RAM without interrupting the main CPU, and then upload it to
VRAM?"

## Why it is worth it

The database of **all eight games** erases the map with the zoom (16) to
start a battle, and shows it with the zoom (16) when the battle ends. Today
both are the fade: see `divergences/the-teleport-transitions.md` in the
book. The command transitions are a minor case next to that.

## What was measured before starting

By Hornero, on 2026-10-12, over ABL's goldens (256x224, comparing 8x8
cells pixel by pixel at 15 bits):

* **49 map screens** from the walkthroughs: unique 8x8 tiles, median 170,
  p75 251, p90 326, max 538. **38 of the 49 fit in mode 7's 256 tiles
  exactly**; 48 fit in 512.
* At half resolution (128x112, 2x2 pixels per texel), 224 cells: **always
  fits**, with no quantisation.
* No capture has more than 240 colours. In mode 3 BG1 is 8bpp over CGRAM,
  BG2 4bpp over 0–127 and sprites over 128–255, so a composed pixel is
  already a CGRAM index: mode 7 would read the same CGRAM with no remap.
  To be checked.

## Questions

* What composing costs on the 65816, per 8x8 cell: two layers in planar
  formats and the sprites with priorities, into mode 7's chunky 8bpp. With
  tables; at full and at half resolution. And where the sources are read
  from —VRAM cannot be read back during display; the map's tiles and
  sprites' poses are in ROM, compressed or not, and the map's state in
  WRAM—.
* Dedup and, when there are more than 256, what to merge, in what time.
* VRAM: mode 7 lives in the low 32 KB, where the map is. How it gets there
  without a visible black frame: what can be written while mode 3 is
  still shown, how many vblanks the rest takes.
* Message window, pictures, the timer, weather: what is on screen when a
  battle starts.
* **The SA-1**: a 65816 at 10.74 MHz in parallel. It does not see the
  console's WRAM nor VRAM; it sees ROM, its I-RAM and BW-RAM, and the main
  CPU can DMA from BW-RAM. Its BW-RAM bitmap modes are chunky, like mode
  7. What it would buy here, and what it costs: the memory map against
  ExHiROM at 8 MB, MSU-1, the FX Pak, the emulators —see
  [`expansion-chips-sa-1-and-s-dd1`](expansion-chips-sa-1-and-s-dd1.md),
  which already studied it on 2026-09-26— and taro's devices.
* The zoom as RM2k draws it (easyrpg's `Transition`): its duration, its
  centre, whether it fades too.
* A recommendation with a measured limit, and phases.

## Log

### 2026-10-12, Carpintero

From the-advocate `65885882`, the ports `0bf10fd`, the book `49c0421`.
The answer is the research page
[`research/2026-10-12-the-zoom-baked-at-run-time.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-12-the-zoom-baked-at-run-time.html)
in the book, branch `carpintero-zoom-research`. Nothing changed in the
runtime, the converter or the ports.

**Verdict: doable on the plain CPU; the SA-1 is not worth it for this.**

* **The pieces, timed** with the H/V counters in a throwaway cartridge,
  snes9x and bsnes equal to the cycle, output checked against a model of
  the planar formats: an 8bpp planar tile into chunky **31,245 master
  cycles (23 lines)**; a 4bpp overlay 20,319; at half resolution 12,527
  and 8,330; a chunky flip 5,913; hash and compare 4,687; a cell's key in
  a hash table 478; MVN of 64 bytes 3,142; DMA ROM to WRAM 977.
* **126 map screens** of ABL's `release` (teleported to each map, captured
  with each layer alone): distinct tiles at full res median 140, p90 259,
  max 627, **113 of 126 fit in 256**; at half res max 203, **all fit**.
  What goes over is a message with text, then panoramas.
* **Time per screen**, adding the pieces: full res median 15.9 frames, p90
  31, max 88.6; half res 10.5 / 14.9 / 37.3; full if it fits, half if not,
  14.8 / 25 / 37.3.
* **Into battle** RM2k spends 20 frames of flashes before the zoom, with
  the main loop frozen: composing there, 98 of 126 screens add nothing,
  the worst adds 17 frames. **Out of battle** it is black time: 15 frames
  median, 37 worst.
* **Sources: VRAM, read back by DMA in vblank** (the map tiles are LZ2 in
  ROM, the poses are uploaded on the fly): two or three vblanks, eight on
  the worst screen. A chunky copy of the map tiles in ROM would halve the
  cost but is 1.25 MB of the ~2 MB free.
* **VRAM swap**: 17.3 KB at full res, 14.6 at half — three vblanks, but
  into the half the mode 3 screen is using. In one go it is 64 lines of
  black in one frame (48 at half). Without black it needs free 128-byte
  windows in that half: likely at half res, **not measured**.
* **The composed pixel is already a CGRAM index**: no remap. What does not
  carry over is colour math: pictures at half transparency.
* **More than 256**: merging by nearest tile changes 7-18% of the pixels on
  the dense screens but is unaffordable on the 65816; nearest mean colour
  ~9 frames, a bit worse; keep the tiles nearest the zoom's centre or the
  hero is the first to go. Half resolution changes 21-53% (it loses detail
  everywhere, nothing in particular). Recommended fallback: half res.
* **SA-1**: ~3.3x faster composing (5 frames median), but it hides behind
  the flashes anyway, it cannot read VRAM, its BW-RAM is the save (an SD
  write per battle on the FX Pak), and the ExHiROM 8 MB map does not exist
  on its board.
* **RM2k's zoom**: 41 frames, no fade, magnification `40 / (40 − f)`,
  centre the hero clamped to the middle half, nearest neighbour.

**Phases** proposed: 1, the way back from battle (black at the start, so
the upload is free); 2, the way into battle, which replaces taro's mosaic
—theirs to decide—; 3, `ChangeScreenTransitions`/`EraseScreen`/`ShowScreen`;
4, merging instead of half res if half res is not good enough.

**Not measured**: the compositor with the message window's HDMA lines and
the sprites' priorities; the free VRAM windows on real screens; the black
band on the console; the 1,500 cycles per half-res tile assembled from
quarters (estimated).

Mock-ups and numbers for taro: `~/scratch/carpintero/captures/2026-10-12-zoom/`
—`README.txt` says what each panel is; the scripts and the prototype
cartridge's source are there too—.

Nothing to install when merging: only the book and this task change.

