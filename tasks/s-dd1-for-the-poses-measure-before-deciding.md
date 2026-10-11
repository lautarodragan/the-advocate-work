---
name: "The S-DD1 for the poses: measure before deciding"
description: "Compressing the poses with LZ2 costs ABL frames; the S-DD1 decompresses on the DMA path, with no CPU. Measure how much it yields, whether it coexists with the cartridge's memory map and what the hardware supports, without touching the cartridge"
type: research
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-10-11, after seeing what the poses in LZ2 cost (`vampires-dawn-entra-comprimido.md`): "would the S-DD1 let us compress them without introducing lag?". And: "on the fx pak star ocean runs, so it has to support that chip. what I never tried is msu + another chip".

Earlier, the same day, he had said he would avoid another chip as long as the MSU-1 is optional, because of the complexity: this is for deciding with numbers.

## The measurement, 2026-10-11 (Carpintero)

Everything in `~/scratch/carpintero/sdd1/`. There is no free S-DD1 compressor at hand
(neither in `~/ref` nor on GitHub): I wrote a disposable one, `src/sdd1c.cpp`, the
exact inverse of Andreas Naive's decompressor. Each compressed block is
decompressed with **bsnes's decompressor untouched**, included from
`~/ref/bsnes-libretro` (`src/ref.cpp`), with garbage after the block, and it
comes back byte for byte identical: 0 differences in the ~60,000 pieces of ABL and VD.
`medir.py` builds the table; `carga.py`, what the background costs at load time.

ABL's data comes from `build/release` in the ports (b499ab4, tools
6f933ff8, `abl.sfc` 24dd24adb52f3187); VD's, from Tijereta's `vd-bloques/`
(tools 6f933ff8).

**What it yields** (raw → LZ2 → S-DD1; the poses, in four streams of 128
because each row of the 4x4 block is a separate DMA and each DMA starts a
stream):

    ABL poses       752 KB →  317 (42%) →  245 (33%)
    ABL background 1165 KB →  710 (61%) →  691 (59%)
    VD  poses      4374 KB → 1604 (37%) → 1232 (28%)
    VD  background 3196 KB → 2268 (71%) → 2172 (68%)

The sprite bank and the ChipSet animation do better in LZ2. Adding up
where it wins: ABL ~641 KB (it uses 86 of 127 banks: it doesn't need it), VD ~3.46 MB
against the 3.75 it is short, before the waste and the 82 excluded
maps: **VD doesn't fit either**. No lag: the DMA moves the same 512
bytes per pose in vblank, plus one `sta $4801` per DMA. When loading a map,
the background goes from 3.1 frames of LZ2 (median) to 0.2 of DMA.

**The memory map**: the S-DD1 takes away banks `$40`–`$7D`; the upper 4 MB are seen
only through four 1 MB windows at `$C0`–`$FF`, with registers. The FX Pak and
Mednafen reach 8 MB (bsnes, Mesen2 and snes9x, 16): it makes nothing bigger. It is
a new mapper, with window switches in the runtime and pages per map in
the packer; that is the expensive part.

**The hardware**: the S-DD1 core in the FX Pak firmware instantiates the MSU-1, and
the firmware turns it on for any ROM with a `.msu`; the v1.10.2 changelog
fixes the MSU-1 volume "in Cx4, OBC1, SuperFX, SA-1, S-DD1". On Zeldix
they report SFA2's MSU-1 hack working on the sd2snes Pro (it doesn't say whether the
hack still uses the chip). Nobody tried it with our ROM: the hardware test
is in the research. The four emulators load the MSU-1 with
any board.

**Recommendation: not now.** ABL doesn't need the space and VD doesn't fit anyway.

All of it, in the book: `src/research/2026-10-11-el-s-dd1.md`, branch
`carpintero-s-dd1` of the-advocate-docs (7aaaa6f).

## On merging

Nothing to install. Merge `carpintero-s-dd1` of the book. No code
in the-advocate or the ports was touched.
