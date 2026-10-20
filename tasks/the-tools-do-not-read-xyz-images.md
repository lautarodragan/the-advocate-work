---
name: "The tools do not read XYZ images"
description: "RPG Maker 2003 saves images as .xyz (a zlib stream of a 256-colour palette and indices); the finders accept the extension but nothing decodes it, so a 2003 game's build stops at its System. Zounds has 186 of them"
type: feature
status: done
assignee: taro
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**What happens**: `rm2k-snes-screens` stops with `System "Zounds_System"
is not in <game> nor in <rtp>`; the file is `System/Zounds_System.xyz`.
`resources::find` in `rm2k-snes/convert/src/scene.rs` and
`GAME_EXTENSIONS` in `rm2k-snes/cartridge/src/cartridges.rs` list `.xyz`,
but `rm2k/rm2k-render/src/source.rs` looks for `.png` and `.bmp` only and
no crate has a decoder (`grep -ri xyz` finds those two mentions).

**The format**: `"XYZ1"`, width and height as `u16` little-endian, then a
zlib stream of 768 bytes of RGB palette followed by `width * height`
indices. It is RM2k3's own, lossless, and the editor writes every image it
imports as it. Measured over Zounds: 186 files —75 charsets, 20 chipsets,
50 pictures, 16 monsters, 11 panoramas, the System, the Title, 5
backdrops, a faceset, 3 battle animations—; the 2003 RTP ships as PNG.

**What it costs**: a loader next to the PNG one in `source.rs` (and
wherever else an image is opened by extension), indexed like a PNG with a
palette. The study measured with a copy of the game converted to PNG
(`~/scratch/aguara/zounds/xyz2png.py`).

taro, on 2026-10-15: not worth supporting XYZ in the tools:

> I have no good reason to use XYZ

If some common software converts XYZ to PNG or
BMP, use it once on Zounds and be done.

## Aguará, on 2026-10-15: done without touching the tools

As taro decided: the 186 XYZ files of Zounds converted once with EasyRPG's
`xyz2png` —cloned and built in `~/ref/easyrpg-tools`; it writes
`<name>.png` in the current directory, so it ran standing in each folder—
on a `png-images` branch of taro's clone, commit `593f6ba`, author taro
with Aguará's trailer, **not pushed**. One file kept its PNG instead of its
XYZ twin: `ChipSet/Zounds_MenuChip` had both, they differ in a corner, and
RPG_RT reads the PNG first (EasyRPG's `IMG_TYPES`: bmp, png, xyz). The
tools keep reading `.png` and `.bmp` only; nothing changed in them.
