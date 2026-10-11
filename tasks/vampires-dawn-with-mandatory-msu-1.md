---
name: "Vampires Dawn with mandatory MSU-1"
description: "VD doesn't fit in the 127 banks even with the reasonable stuff compressed (~1 MB short with the poses in LZ2, more without them): let a project ask for mandatory MSU-1 and carry to the .msu what doesn't fit"
type: feature
status: testing
assignee: taro
agents: [Hornero, Tijereta]
---

It follows from `vampires-dawn-fits-in-the-cartridge-compressed.md`, where Tijereta measured everything: the poses in LZ2 are the only thing that really pays off (−2.86 MB) and they cost ABL frames —eight reds because of CPU—; with them VD stays at 8.91 MB against 7.94, and the rest adds at most ~0.84 MB. The experiment is in the local branches `tijereta-vd-comprimido` of the-advocate and the ports, unmerged.

taro's decision, on 2026-10-11: rather than two cartridges, mandatory MSU-1 **for this game**; ABL and the others stay playable without it ([[sin-msu-jugable]] in the memory). Not a compression chip, as long as MSU-1 remains optional in general.

There is already a path: the battle backgrounds travel in the `.msu` and the ROM reads them if it finds its signature (`internals/msu-datos.md` in the book). What it would take: a project knob that asks for it as mandatory, the split of what goes to the ROM and what to the `.msu` —the poses, which are uploaded on the fly, call for looking at how long the MSU-1 takes to deliver them—, and a screen that says the MSU-1 is missing if it isn't there. Tijereta noted an option without CPU that wasn't tried: the poses without their zero tiles, by direct DMA in vblank (−2.44 MB in VD), which would shrink what has to go to the `.msu`.

## What taro asked for when confirming it, on 2026-10-11

"Let's go with the msu, but let's keep the runtime and tools code as generic as possible, always aiming for all games to have optional msu." That is: nothing that is "VD's mode"; the mechanism —what data can travel in the `.msu` and how the ROM reads it— is the same for all, and the mandatory part is only that a game doesn't have enough ROM without it. The underlying goal is still that every game fits without MSU-1.

## Done, on 2026-10-11 (Tijereta)

On the-advocate `origin/main` 2fc37808 and ports `main` f8407dc, branches
`tijereta-vd-msu` in both. VD is built as always in this task: with
Aguará's 82 exclusions and starting on 8 (`~/scratch/tijereta/vdmsu/vd.py`).

**The mechanism, generic.** A project asks for `[rom] msu = "required"`; without
the key it is `"optional"`, as always. The converter does **not** decide it on its own:
needing the MSU-1 changes what the player needs, and one more map shouldn't
change that without anyone deciding it. With the knob:

* the emitter marks with `.msu` the pieces the ROM only reads through a path
  that knows how to read the `.msu`, and that are read when loading a map or a battle, not
  per frame: each map's LZ2 streams, those of the battlers and battle
  fallbacks and the maps of the large pictures (`lz2_decompress` → `lz2_msu`),
  the tiles of panoramas and large pictures (`msu_dma0`), and the samples
  (`upload_sample` → `msu_sample_l`). Not the poses: they are uploaded on the fly;
* the packing (`pack_with_msu`) sends to the `.msu` as few as possible, from the
  largest to the smallest, until the rest fits; in a region at the end
  of the `.msu`, with its signature, and each label stays as bank `$3D` and a unit of
  256 bytes;
* the ROM, on starting, checks MSU-1, the `.msu` signature and the region's signature, and
  if something fails it shows a screen (drawn by the converter with the
  game's font) and stays there.

All the new runtime is under `.ifdef MSU_REQUIRED`: `abl.sfc` comes out
`24dd24adb52f…`, same as in the base.

**VD builds**: 13241 pieces in the 127 banks and **1533 pieces, 5.26 MB, in the
`.msu`** (19 MB the whole `.msu`, with the backgrounds and the sound effects). What
went: 313 `map_tiles`, 293 samples, 280 `map_cells`, 236 `sprite_tiles`, 127
`above_tiles`, 102 battlers, 49 `anim_tiles`, 43 `big_tiles`, 36 fallbacks,
31 `pano_tiles`, 16 `big_map`, 7 `map_code`: almost everything that can go, because
what stays —4.27 MB of poses, 0.91 of music in `.crossbank`, 0.39 of
pages…— is 7.10 MB for 7.94. It starts in snes9x and in Mednafen
(`snes_faust`) with its `.msu`, on 8, and without it shows the screen.

For it to fit something else was needed: the `.crossbank` chain went last,
and by then the whole pieces had taken all the whole banks; if
it doesn't fit, the packing now tries with the chain first. ABL fits the
first way and doesn't change.

**How long it takes**, in snes9x, which doesn't delay seeks: loading from the `.msu` costs
each map 1 to 8 frames more than from the ROM (map 66, with the largest
background, 94 against 86), because the LZ2 literals go one byte at a time through
the CPU. **In Mednafen each seek is one or two frames** (measured on
2026-09-26, see `internals/msu-datos.md`), and a VD map does 0 to 5 for
its streams —most 3 or 4— plus one per panorama and one per each sample
from the `.msu` its package uploads: I didn't measure that frame by frame.

**What stops VD next**: nothing when building; playing it is another task. The 82
exclusions remain —they are maps that don't convert for other reasons— and when
they get in they will ask for more ROM: what's left to send is little, because what
stays is the poses. That's where what is already noted above helps: the poses
without the zero tiles, by direct DMA.

**The tests.** ABL fits, so the path is run by two new cartridges
of its suite: `test-msu`, with `--msu-everything` —everything that can go, to the
`.msu`, even if it fits— and `test-msu-rom`, its twin with everything in the ROM. What
is loaded with each map, against the converter (`test_carga_descomprimida.py`);
the boot frame by frame with map 6's panorama, a battle with its
battlers and the envelope of map 66's music, against the twin
(`test_msu_gemelos.py`); and the screen, without `.msu` and with another
build's region (`test_msu_obligatorio.py`, new golden `msu-falta`). The suite: **1202
green**, with `abl.sfc` = `24dd24adb52f…`. Captures in
`/shared/capturas/2026-10-11-msu-obligatorio/`.

**What the suite doesn't run**: a large picture read from the `.msu` —no map
of `test-msu` shows one—, a battle background's light fallback read from
there —with MSU-1 the battle uses the quality one—, the wait for seeks —no
core in the suite delays it; Mednafen does, and I didn't measure it—, the real console,
and VD played beyond its first map.

New RAM: none. Opcode: none.

## When merging

Branches `tijereta-vd-msu` in the-advocate (e9a9488f), in the ports (3a6ca29,
with the golden in its own commit, 6dc0ca2) and in the book (1d5a4f8).
Reinstall `just install cartridge rm2k-snes-audio mapdata convert` —it didn't touch
`project`—, and run A Blurred Line's suite, which now also builds `test-msu` and
`test-msu-rom`.
