---
name: "Desert Nightmare: lit cells over a tinted night"
description: "The night maps that scroll are a tint since 2026-11-19, with no lamps and no lit windows. Draw the cones and windows into the cells the tint misses, in palettes the tint skips; then, maybe, light the characters with colour math"
type: feature
status: todo
author: huron
game: desert-nightmare
links:
  relates: [desert-nightmare-light-masks-placed-by-an-anchor, desert-nightmare-nights-with-a-tint-of-their-own]
---

What [`desert-nightmare-nights-with-a-tint-of-their-own`](desert-nightmare-nights-with-a-tint-of-their-own.md)
recommended and did not build, because it is not small. The measurements
and the other ways, in the book: Desert Nightmare's research "Nights with
a tint of their own" (2026-11-19), section 3.

**What**: on the eight night maps that scroll (32, 59, 61, 62, 66, 68, 69,
70), whose forks in the ports' `desert-nightmare/patches/manual/` replace
the night's two pictures with a `TintScreen`:

1. The converter resolves a picture placed at an anchor event's screen
   position —the same thing
   [`desert-nightmare-light-masks-placed-by-an-anchor`](desert-nightmare-light-masks-placed-by-an-anchor.md)
   needs—, and knows the original pictures of each night (a project knob
   naming them, since the forks no longer show them).
2. The painted map's cells where the tint misses RM2k's night most —a
   mean over 1 of 31, 112 to 281 per map— are drawn as that night, cone
   or window composed in, in one or two of the painting's palettes that
   `apply_tint` stops short of: a per-map number in the runtime. Measured
   in software: 0.1 to 0.25 of 31 over the cones with 30 colours.
3. Measure it on the console against EasyRPG, as the study did for the
   tint.

What it leaves out: a character walking into a cone stays as dark as in
the street. Colour math adding a 2-bit layer over the tint is the only
way the study found that lights them (option b), and it needs VRAM the
painted layout does not have and object palettes 4 to 7 that four of the
eight maps do not leave free: a later step, if taro wants it.
