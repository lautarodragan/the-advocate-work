---
name: "bsnes draws every frame of the suites"
description: "The harness tells snes9x not to draw the ticks nobody looks at, but bsnes's libretro target does not ask; drawing is 40% of a bsnes frame, and bsnes is most of the emulation in the boot and the test game"
type: refactor
status: draft
author: chaja
agents: [Chajá]
links:
  relates: [how-much-of-a-test-is-the-emulator-drawing]
---

Measured by Chajá on 2026-11-22, with the-advocate at `96cec117` (branch
`chaja-emu`) and the ports at `07229dc`, in
[How much of a test is the emulator drawing](how-much-of-a-test-is-the-emulator-drawing.md).

The boot of the other games and the test game run every test on snes9x
and on bsnes. bsnes runs at ~520 fps against snes9x's ~2800 on the same
scenes, so of the boot's 925 s inside `retro_run` some 750 are bsnes'.
`retro.Console.run(draw=False)` only saves in snes9x: bsnes never asks
`RETRO_ENVIRONMENT_GET_AUDIO_VIDEO_ENABLE`, and its only frame skip,
`Interface::setFrameSkip`, is not reachable from libretro.

With a six-line patch to `bsnes/target-libretro/libretro.cpp`'s
`retro_run` —ask that question and call `emulator->setFrameSkip(skip ? 1
: 0)`—, built in `~/scratch/chaja/emu/bsnes` from `~/ref/bsnes-libretro`
at `a7e88d6` and **not installed**:

- drawing is 41.1% of a bsnes frame on abl, 39.3% on zounds and 41.2% on
  the test game (`~/scratch/chaja/emu/bench/scene.py` with
  `CORE=<that .so> SPAN=200`);
- with `bsnes_entropy=None`, skipping leaves the same screens where they
  are looked at and the same WRAM as drawing every frame
  (`bench/same_b.py`). Its audio differs from run to run in one process
  even drawing everything, so it says nothing.

What it would take, not measured: the patch beside `bsnes-wram.patch` in
`rm2k-snes/harness/cores/`, a rebuilt and reinstalled core, adding
`bsnes` to `SKIPS_DRAWING` in `retro.py`, and the suites with goldens and
`test_cores.py` on it. What skipping touches in bsnes's fast PPU: the
mosaic counter and the sprites' range and time over flags are only kept
on drawn frames.
