---
name: "Let the linker place the far RAM map"
description: "Move the 24 KB of $7E2000-$7E7FFF written by hand into segments the linker places, sized by the game: 3.5 KB (ABL) to 5.6 KB (Sunset) of slack and holes become one pool, and just space says what is left in total"
type: feature
status: draft
---

Suggested by Hurón on 2026-10-15, in the study
[`the-wram-and-sram-map-measured`](the-wram-and-sram-map-measured.md),
with the-advocate `6fa69781` and the ports at `f015801`. It is the plan
the book's decision "RAM is placed by the linker" already names as the way
`FARBSS` grows, done once for everything.

**What was measured**: the map of `$7E2000`–`$7E7FFF` holds, in ABL's
release, 21,049 B in regions written by hand, with 3,218 B of slack inside
regions whose cap was chosen for any game (`FAR_EXP` 504 B for 92 used,
`FAR_SKILL` 256 for 32, `FAR_ENCOUNTER` 256 for 9…) and 309 B of holes
between them —the same ten holes in every game—. In Vampires Dawn the
slack is 3,720 B, in Sunset 5,293. `FARBSS`, the 832 B the linker hands
out today, has 12 B left in ABL.

**What it costs**: 198 constants with the bank in front, 88 sixteen-bit
ones read with the data bank at `$7E`, and 238 derived from them, in
eleven files of the runtime; the blocks that are walked as a range
—`clear_variables` wipes from `FAR_MSG_OPTIONS` to the inventory's end in
one pass through the `WMADD` window; each line of `save_table` is a DMA—
have to stay contiguous and in order, as one segment each or one `.res`
with offsets. The ROM changes everywhere and the behaviour nowhere: the
goldens are the net, with `test_wram_reservations.py`, which has to learn
the new segments, and `test_decompressed_load.py`.

**What to decide**: whether to do it whole or subsystem by subsystem, and
in which order the segments go so that what is saved as a block and what
reset clears stay contiguous.
