---
name: "Tile animations that don't fit in WRAM"
description: "A map whose anim_tiles stream doesn't fit in WRAM stops the build; have the map go without that animation, with a warning"
type: feature
status: testing
assignee: taro
agents: [Cardón]
---

From taro, on 2026-10-10, in the proposed order. From 2026-10-06: Vampires Dawn's map 1 ("a stream of anim_tiles is 27264 bytes and 8192 fit in WRAM"), one in Book of Three and one in Desert Nightmare. Same line as `degrade-instead-of-failing.md`.

## What the stream is and who sets the ceiling (Cardón, 2026-10-10)

`anim_tiles` are the drawings of the ChipSet's animation —the water, three
drawings, and the animated tiles, four— that `anim_upload` uploads to VRAM each
time the clock changes. They live in WRAM while on the map, in
`ANIM_DRAWINGS` = `$7F6000`–`$7F8000` (`far_ram.s`): 8 KB, above the
background's load buffer and below the grid, and what comes after —upper
layer and sprites, 24 KB— can't overwrite them. The ceiling is set by the runtime and
enforced by the converter: `LZ2_CAP_ANIM` in `mapdata/src/materials.rs`,
against which `check_streams` stopped the build. Enlarging it means shrinking
the sprites'; it wasn't touched.

Each family is a contiguous run of tiles at the end of the background's bank
(Voodoo numbers it), the bank already carries drawing 0 of each one, and the console
uploads the first `tiles` of each drawing. So **less than the whole animation
can be lost without redrawing anything**: cutting the run to its
first `k` tiles leaves the others still on their drawing 0.

Measured with the global tools, one map per cartridge:

| map | bytes | runs (tiles × drawings) |
|---|---|---|
| Book of Three 46 | 10432 | water 25×3, animated 22×4 |
| Desert Nightmare 182 | 9792 | water 51×3 |
| Vampires Dawn 236 | 9792 | — |
| Vampires Dawn 351 | 9152 | — |
| Vampires Dawn 1 | 27264 | water 142×3 |

Voodoo's order (the first it finds, row by row) already puts the most used
in front: on VD's map 1 the first 42 water tiles
cover almost all the map's water cells.

## Done (Cardón, 2026-10-10)

**Part of the animation is lost, not all of it**: `mapdata/src/animation.rs`
cuts each run to its first `k` tiles; the ones behind stay still on
their drawing 0, with a WARNING that says how many tiles and how many cells per
family. The `k` are the ones that leave the most map cells moving within
the 8 KB (counted by the block table; ties, more bytes and then the
first family). The run isn't reordered —it would move tile numbers in the
block table—; it wasn't needed: Voodoo's order already puts the
most used in front. "Fewer frames" isn't possible without touching the runtime: how many
drawings each family has is fixed in `chipset_animation.s`.

It goes in mapdata and not in wally because the ceiling is mapdata's and because nothing
has to be redrawn; it is written in the crate's `lib.rs` as the only
thing that decides about what is seen. A map that fits doesn't go through there.

* snes-rm2k, branch `cardon-anim-tiles`: `1bdf72a0`. New test
  `mapdata/tests/animation.rs`, seen red with `fit` doing nothing.
* ports, branch `cardon-anim-tiles`: `61e11d5`, Book of Three's 46 and
  Desert Nightmare's 182 come out of `excluded`; both whole releases
  build with the branch.
* book, branch `cardon-anim-tiles`: `fcd736f`, the divergence
  `a-chipset-animation-that-does-not-fit-in-wram.md` and a line in the
  README of each of the three ports.

Measured, each map in a cartridge with its game's start map:

| map | stays still | then it stops at |
|---|---|---|
| BoT 46 | 9 of 25 water (25 of 115 cells), 2 of 22 animated (2 of 2185) | nothing: it builds |
| Desert 182 | 9 of 51 water (44 of 1469) | nothing: it builds |
| VD 236 | 9 of 51 water (26 of 1480) | the music: 281 songs and the track goes in a byte |
| VD 351 | 5 of 37 water (9 of 674) | the music, the same |
| VD 1 | 100 of 142 water (4275 of 262866) | the grid: 180,000 bytes against 64 KB of WRAM |

A Blurred Line's suite with local `mapdata`: 1159 green; `abl.sfc` comes out identical,
`f135f6af…`. `just -f tools/justfile test` green.

**What the suite doesn't cover**: no ABL map goes past the ceiling, so the
cut isn't executed by any ROM in the suite; it is covered by the crate's test and
the BoT and Desert cartridges, which build but **nobody has looked at while playing**: whether the
cut water looks right on the console is unseen.

Install when merging: `mapdata` (`just -f tools/justfile install mapdata`).
