---
name: "Plan: the maps via the MSU-1"
description: "Neither 6 nor 8 MB are enough for the whole game: how much it weighs, what can be read from the .msu, how long loading a map that way takes and what happens without MSU-1, so taro can decide how far the cartridge goes"
type: research
status: done
assignee: taro
---

From taro, on 2026-10-01, when asking about more maps. Already decided: the
cartridge stays at 4 MB (`decisiones/el-cartucho-se-queda-en-4-mb.md`), and
taro said on 2026-09-27 that "at this rate, neither 6 MB nor 8 MB will
let us cover the whole game". The battle backgrounds already go through the `.msu`
(`docs/port/msu-datos.md`). This is a study with numbers, without
implementing: it's what defines how far the cartridge goes, and it's worth doing
before adding more chapters. Later taro's question about
decompression chips (S-DD1, SPC7110, SA-1) was added.

# Done

Lechuza, on 2026-10-01. **The study is
`docs/research/2026-10-01-los-mapas-por-el-msu-1.md`**; what's below is what
has to be decided and what was left loose.

* **The whole game is 8,514 KB of data**: 266 banks against 124. It doesn't
  fit in 8 MB either. Measured by converting the 328 maps in eleven runs.
* **With the maps and the music through the `.msu`, the whole game's ROM drops to
  3.0 MB** and fits with 0.9 MB free. The music alone is 3.4 MB, and what a
  map uploads on entering, 1.9.
* **Reading a map from the `.msu` is faster than decompressing it**: the port gives
  42 KB per frame on the harness's three cores (`just msu-puerto`), and the
  typical map's load goes from ~5 frames to ~0.4; 66's, from 22 to 1.5.
* **Without MSU-1 a third of the game can be reached**, roughly what there is today.
* **The S-DD1 ties with LZ2 on the tiles** (57 against 58 %); what it gives is
  decompressing the poses without CPU (32 % against 41 %). **The FX Pak has no
  SPC7110** (`MENU_ERR_NOIMPL` in its firmware).

# What taro has to decide

* **One or two cartridges.** The recommendation is two from the same converter:
  `release` without MSU-1 as today, and a `completo` one that requires MSU-1. The
  single-ROM option leaves what's playable without MSU-1 at less than half of today's.

# What taro has to test

* **The port's ROM on the FX Pak** (phase 0 of the study): `just
  msu-puerto` builds `rom/build/msu-puerto/msu-puerto.sfc` and its `.msu`; on the
  console, **green** if the 576 KB arrived right, **red** if not, **blue**
  without MSU-1. It decides whether loading reads at full speed or 8 KB per frame.
  In Mednafen it can be looked at with `-force_module snes_faust`.

# What was left loose, for separate tasks

* **Five maps don't fit in VRAM** (108, 127, 148 and 250 without room for
  the window; 285 with the battle animations box).
* **`rm2k-snes-battle` indexes the encounters' troops with a byte**, and
  the whole game has 365.
* **The leader candidates with all the maps**: 207 asks for 9 graphics of
  order 34 (ceiling 8) and 288 adds actor 34, without a CharSet.
* **A panic in `rm2k-snes-audio`** (`msu.rs:116`, "no entry found for
  key") with maps 120 and 122 in the same cartridge.
* **The whole game's text block is ~255 KB** of the 256.

# When merging

Nothing to install: neither Rust nor the runtime was touched, and the ROM doesn't change. It's
a new recipe, `msu-puerto`, with its experiment in
`rom/experimentos/msu-puerto/`.
