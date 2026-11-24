---
name: "A map load still decompresses inside its tick"
description: "Inside a teleport's fade, the grid, the background, the ChipSet animation, the upper layer and the sprites still decompress in the load's own tick: some four to nine frames a load, every game"
type: refactor
status: draft
assignee: taro
agents: [cardon]
author: cardon
links:
  found-in: [maps-load-faster-without-losing-anything]
  relates: [lashe-city-transitions-lag]
---

Seen by Cardón on 2026-10-18, measuring
[`maps-load-faster-without-losing-anything`](maps-load-faster-without-losing-anything.md),
with the-advocate `c7360e6e` (the package's uploads and the window already
moved to the fade's frozen ticks), in snes9x.

**What was seen**: what is left of a load inside its tick is mostly LZ2
—decompressing at some 7 KB a frame—, then the samples of the song the map
turns on and the refresh. Means per load, in frames, from the table of that
task, measured before the change, which did not touch these:

    game                 grid   background + animation   upper layer   sprites
    A Blurred Line        1.1          3.1                   0.2          1.2
    Desert Nightmare      5.2          3.4                   0.3          2.2
    The Frozen World      0.9          2.4                   0.2          2.9
    Sunset Over Imdahl    1.1          0.2                   1.1          2.3

The 19 black ticks after the load have room for them when the package is
small, which is the common case between two neighbouring maps; but each
stream is decompressed whole by one `lz2_decompress`, from one to eight
frames, which does not fit in what a tick has left.

**To reproduce**: the probe and the scripts described in that task's log
—`PROBE` marks around `lz2_grid`, `lz2_backdrop`, `lz2_anim` and the
`lz2_field` of `load_above` and `load_sprite`—.

## Log

### 2026-10-20, Tijereta: checked

Still so at the-advocate `8f290c39`: `maps-load-faster-without-losing-anything`
is in `testing` and its "What was left" says the same, with its cost —a
decompressor that can stop and go on next tick, some 400 bytes in a far
bank and its state in far RAM—. Whether that is worth four to nine
frames a load is the open question.

### 2026-11-22, Chajá: three quarters of a Lashe City door

Measured in
[`lashe-city-transitions-lag`](lashe-city-transitions-lag.md), at
the-advocate `ec672f4c`, on Mesen2's core: with the audio out of the
fade, the LZ2 is most of what a door into Lashe's big maps still costs.
Load tick of 16 to 19 frames on the sectors (maps 8 and 9, 75x75, 418 and
361 8-bit tiles): background + animation 7.5 to 8.4, grid with its
blocks, bytecode and pages 3.3 to 4.0, sprites 2.6 to 2.7; map 38 (492
tiles, 31 KB): 10.3, 3.5 and 1.6. About 3.5 to 4 KB of output a frame.

Another way out besides the resumable decompressor, measured for its
cost: storing those streams raw and DMAing them. Backdrop, grid and
sprites raw are 28 to 30 KB more than their LZ2 per sector map, 206 KB
for Lashe's nine maps; `just space` leaves 18 halves of 32 KB in
`release`. All maps' backdrops raw would be ~1 MB more, which does not
fit, so it would be a per-map choice for the biggest.

### 2026-11-24, Cardón: a question for taro

Still so (Tijereta 2026-10-20, Chajá 2026-11-22: 16-19 frame load ticks on
Lashe's sector maps, LZ2 most of it). It is in ABL's Known issues (Lashe's
doors). Both ways out have a cost to choose:

* (a) a decompressor that can stop and go on in the next tick, inside the
  19 black ticks: some 400 bytes in a far bank and its state in far RAM,
  every game gains;
* (b) the biggest maps' streams stored raw and DMAed: ~206 KB for Lashe's
  nine maps, a per-map choice, does not scale to every map (~1 MB);
* (c) leave it.

**Recommendation**: (a): it costs little ROM, helps every game, and is
what the measuring task already proposed.
