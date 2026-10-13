---
name: "The zoom, baked at run time"
description: "Compose the mode 3 screen —both layers and the sprites— into mode 7's single layer at run time, so the zoom transition can be done: every battle of every game starts and ends with it"
type: research
status: doing
assignee: Carpintero
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
