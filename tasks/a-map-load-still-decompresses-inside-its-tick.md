---
name: "A map load still decompresses inside its tick"
description: "Inside a teleport's fade, the grid, the background, the ChipSet animation, the upper layer and the sprites still decompress in the load's own tick: some four to nine frames a load, every game"
type: refactor
status: draft
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
