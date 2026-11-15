---
name: "An emulator that shows vblank overruns"
description: "Find whether ares or bsnes with their accurate PPUs reproduce what the console does to VRAM and CGRAM writes past the vblank, and if one does, run it in the suite"
type: research
status: doing
assignee: Aguará
agents: [Aguará]
---

Born from [`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md):
the layer above under a transparent message broke map palettes and lost
letter halves on a SNES with an FX Pak, and snes9x, bsnes (libretro),
Mesen-S, Mesen and Mednafen all drew it right. The cause was the window's
VRAM and CGRAM writes running past the vblank (the-advocate `7f2a0ae2`).

> Is it impossible to reproduce this in an emulator? Does no emulator
> reproduce this behaviour?

taro, 2026-11-15, and "Dale!" to trying ares and bsnes with their
accurate PPUs.

What is known before starting: ares's accurate PPU (`ares/sfc/ppu/`, the
"Pixel Accuracy" option; `ppu-performance/` is the other one) redirects a
CGRAM write during active display to the address the PPU is reading
(`writeCGRAM` in `ares/sfc/ppu/io.cpp`), which is exactly the white grass.
bsnes has a "Fast mode" PPU hack (`settings.emulator.hack.ppu.fast`); the
libretro core the suite uses probably runs it.

**What is asked**: run the ROM from before the fix (ports `82650d7`,
the-advocate `c8cab6c3`) on Core and Manta's memory, maps 5 and 6, in ares
with Pixel Accuracy and in bsnes with the accurate PPU, and say which
reproduces what taro saw, and that the fixed ROM (ports `7bbddaa`,
the-advocate `c9860b49`) draws right there. If one reproduces it and can
run headless here, measure what it costs to put in the suite.
