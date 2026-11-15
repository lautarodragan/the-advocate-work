---
name: "An emulator that shows vblank overruns"
description: "Find whether ares or bsnes with their accurate PPUs reproduce what the console does to VRAM and CGRAM writes past the vblank, and if one does, run it in the suite"
type: research
status: testing
assignee: taro
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

## What the emulators' code says (Aguará, 2026-11-15)

Read before running anything: ares at `4cb8d92b`, bsnes-libretro at
`a7e88d6`.

**All four PPUs block, not only ares's accurate one.** ares's two —`ppu/`,
"Pixel Accuracy", and `ppu-performance/`, its default— and bsnes's two
—`ppu/` and `ppu-fast/`, the libretro core's default— have the same three
lines in their `io.cpp`: a VRAM write with the display on and `vcounter()
< vdisp()` is dropped, a VRAM read there gives `0x0000`, and a CGRAM write
on lines 1 to 224, dots 88 to 1095, goes to `latch.cgramAddress`, the entry
the PPU is reading. bsnes's fast PPU drops VRAM writes unless its "No VRAM
blocking" hack is on, and its core option defaults to off. snes9x does not
block at all.

So the question is not which PPU models the console's rule —all of
bsnes's and ares's do— but whether the ROM's writes ever land past line
261 in that emulator's timing. The probe answers that; the screen says
what it costs to look at.

## Both accurate PPUs reproduce it (Aguará, 2026-11-15)

**BEFORE** is the ports `82650d7` with the-advocate `c8cab6c3`'s tools and
runtime (`release`, sha256 `eb8a37e3…`); **AFTER** is the ports `7bbddaa`
with the-advocate `c9860b49`. Both run the `manta` case with
`test_memory.py`'s A presses, 3900 ticks, a capture every ten, through the
suite's own harness (`session(..., core=...)`), on five cores: snes9x,
bsnes with its fast PPU (the libretro default) and with it off
(`bsnes_ppu_fast=OFF`), and ares with each of its two PPUs.

**ares has no libretro core and its desktop UI was not in `~/ref`**, so
it got one: a 230-line libretro wrapper around ares's core and mia, built
with cmake and ninja from a full clone of ares at the same commit
(`~/scratch/aguara/emulator/ares/headless/`; cmake from pip, the mirror
did not answer pacman). `ares::Video::Threaded` is false there so the frame
is drawn before `retro_run` returns. It loads ABL's 8 MB ExHiROM without
help, takes the PPU from an `ares_pixel_accuracy` option, and hands frames
the harness reads as it reads snes9x's.

**What was seen**, BEFORE:

* **bsnes with the accurate PPU and ares with Pixel Accuracy break it the
  same way, on the same tick**: between ticks 1500 and 1520, after Manta's
  box that starts "Core... my name is Manta.", map 5's water goes almost
  white and its grass red, and stays so until map 6. Later boxes lose
  letter tops. It is more than taro saw on the TV —the whole of two
  palettes—, but it is the same thing: the window's colours written to
  CGRAM on the screen's first lines, landing on the entry being drawn.
* **The fast PPUs do not**, and the reason is in their code: bsnes's
  `ppu-fast` and ares's `ppu-performance` redirect the CGRAM write to
  `latch.cgramAddress` like the accurate ones, but nothing ever sets it
  there, so every misplaced write lands on entry 0, which the next upload
  rewrites. They do drop the VRAM writes, which is the few dozen pixels
  bsnes-fast differs from snes9x by. That is why "bsnes draws it right"
  last session: the harness runs bsnes with its default, the fast PPU.
* snes9x draws it right, as known.

AFTER, on the same five: no broken palette anywhere. bsnes's accurate PPU
differs from snes9x on 7 of 390 captures, by up to 182 pixels, the same 7
as its fast PPU (a frame of the water's or a sprite's phase); ares differs
from snes9x much more, on BEFORE and AFTER alike, because its timing is a
frame off around fades and boxes (tick 1130, the fade out of map 4, is a
whole screen of difference), so **ares's captures cannot be compared with
snes9x's goldens**; bsnes's can.

**The probe says the ROM's timing is the same in all of them.** BEFORE
with the probe (the-advocate `ce69b86f`, the ports `4bec555`, the
`test-vblank` cartridge, case `vblank-memory`): 62 frames whose window
writes end past line 261 in snes9x, bsnes (both PPUs) and ares (both),
worst line 269 in all five. So no emulator here is faster than another
where it matters; what differs is only whether the PPU minds.

## An emulator that says where (Aguará, 2026-11-15)

Seeing it needs someone to look at the right capture. So ares's accurate
PPU was given an audit (`DisplayAccessAudit` in `ares/sfc/ppu/`, a dozen
lines in `io.cpp`): it counts the `$2118/$2119` writes it dropped, the
`$2139/$213A` reads that gave 0, the `$2122` writes it put on the entry
being drawn and the `$2104` ones, with the line and dot of the last; the
libretro wrapper exposes them as a memory id of its own (`0x8000`), which
the host zeroes before each frame.

BEFORE, `release`, the memory: **6 frames**. Tick 1508, 64 VRAM writes
dropped and 12 CGRAM writes misplaced, the last on line 11 —the white
water—; ticks 384, 2132, 2516, 2636 and 3116, 102 VRAM reads each on lines
5 and 6 —the layer above's rows read ahead, the missing letter halves—.
BEFORE with the probe: 27 frames, mostly VRAM writes on line 0. AFTER,
`release` and `test-vblank`: **0**. No pixel compared, no golden, no probe
in the ROM.

The same audit went into bsnes's accurate PPU too
(`bsnes-display-audit.patch`, on top of the WRAM one, in the ports'
`tests/harness/emulator/`), and gives the same counts, frame for frame:
BEFORE 6 frames, 64/510/12; with the probe 27; AFTER 0.

**main has no other.** Every case of AFTER's `release`, 373, run 600 ticks
without input on ares with the audit: **0 frames with an access during
display**. 331 reached tick 600; the other 42 stop the game's clock (the
menu, the battle, the shop…) and ran the harness's limit, 36,000 hardware
frames each, also with 0. 1,568 s on 12 processes, 17,300 s of CPU.

## What it costs

The `manta` case, 3900 ticks, one process alone, boot included:

    snes9x                   1.8 s
    bsnes, fast PPU          8.8 s
    ares, performance PPU   11.5 s
    ares, Pixel Accuracy    21.7 s   (with the audit read every frame)
    bsnes, accurate PPU     26.5 s

**bsnes needs nothing new**: the suite already builds bsnes-libretro from
source with a patch (`tests/harness/emulator/README.md`); the audit is a
second patch, 46 lines, and `make -j16` builds the core in 13 s. **ares
needs cmake (3.28 or later) and ninja, which the image does not have**
(they came from pip here), a clone, the 40-line patch and a 230-line
libretro wrapper of our own (`~/scratch/aguara/emulator/ares/`, commit
`7bab2f11` on ares `4cb8d92b`, and `ares-headless.patch` next to it): 29 s
to configure and build. ares's captures do not match snes9x's goldens (a
frame off around fades), bsnes's do but for a sprite's or the water's
phase on a few frames —and its accurate PPU hands 512-wide frames, which
`test_cores.py` would have to halve—.

## The proposal (not wired in)

**bsnes, not ares**: same answer, nothing new to build, and it is the
second core the suite already has. ares is what taro uses to look, with
Pixel Accuracy on (in the book, `reference/snes/emulators.md`, "Writes
past the vblank").

1. Install bsnes with `bsnes-display-audit.patch` too (Hornero, or taro:
   it replaces `/usr/lib/libretro/bsnes_libretro.so`, which every
   suite running at the time loads; nothing changes for them while
   `bsnes_ppu_fast` stays at its default).
2. `retro.Console.display_accesses()` reading id `0x8000`, and a test
   —`tests/rpgmaker/test_display_accesses.py`— that runs a few scenes on
   bsnes with `bsnes_ppu_fast=OFF`, zeroes the audit every frame and
   asks for 0: the memory (`vblank-memory`, ~27 s), and the heaviest
   vblanks of other paths —the opening's walkthrough, a battle, the
   title—. Each one is about 15 times its snes9x time.
3. The sweep (every case, 600 ticks) took 4.8 h of CPU on ares, and bsnes
   is ~20% slower (estimated, not run): not for
   every run. As a `just` recipe for when the vblank's work changes, it
   fits; on 12 processes ares took 26 minutes.

The probe stays: the audit only says whether a write landed past the
vblank **in that emulator's timing**, and the console with an FX Pak's
hooks in the NMI is slower; the probe's three lines of margin are for
that. The audit catches what the probe does not: any code, not only the
window's steps, with no flag in the ROM. The same measurement says the
ROM's timing does not depend on the core here: the probe saw the same 62
frames, worst line 269, on snes9x, both bsnes and both ares.

**What is not known**: whether ares and bsnes do on the console's lines
what the console does in every case —the redirected CGRAM entry is
`latch.cgramAddress`, the pixel the PPU last fetched, which matched what
taro saw only in kind (the console's broke fewer entries)—; and OAM
during display, which the audit counts and nothing here exercised.

## Delivered

* The BEFORE ROM, for taro to see it in their ares (Pixel Accuracy on):
  `/shared/builds/abl-before-vblank-fix/` —`abl.sfc`, its `abl.msu`
  without tracks, a `README.txt` with the two commits—. Throwaway: delete
  it once seen.
* Captures, before and after, five cores side by side on the same ticks:
  `/shared/captures/2026-11-15-emulator-vblank/`.

## To merge

* The ports, `aguara-emulator-vblank`: `d4367f3` the bsnes audit patch
  and its README (applied nowhere), `576a9c4` `test_vblank_budget.py`'s
  docstring, which said no emulator shows it.
* The book, `aguara-emulator-vblank`: `c39357a`, "Writes past the
  vblank" in `reference/snes/emulators.md`.
* Nothing in the-advocate; nothing to install.

## Into the suite (taro, 2026-11-15)

Hornero proposed the small test in the suite —a few heavy scenes with
bsnes's accurate PPU, asking for zero late accesses— and the full sweep
as a recipe run on demand, not on every run. taro:

> Go ahead.

## Wiring it in (Aguará, 2026-11-15)

Branches `aguara-display-audit` in the ports and the book, from ports
`2c9b736` and book `400db17`; nothing in the-advocate.

* **The core**: `just audit-core`, in `abl/` of the ports, fetches
  bsnes-libretro at a pinned upstream commit (`260f523`, the one the two
  patches apply to), applies `bsnes-wram.patch` and
  `bsnes-display-audit.patch` with `git apply`, builds it and installs it
  in `AUDIT_CORE` —`machine.just`, by default under `/usr/local/lib/libretro/`
  as `bsnes_audit_libretro.so`—. The plain `bsnes_libretro.so` is not
  touched. 16 s here.
* **The harness**: `retro.Console` zeroes the audit on load (ctypes keeps
  the `.so` for the whole process, so a console would inherit the previous
  one's counts) and `watch_the_display()` zeroes it before every frame and
  lists the frames with something refused; `Session` and `suite.session`
  take the core's `options`, for `bsnes_ppu_fast=OFF`.
* **The test**: `tests/rpgmaker/test_display_accesses.py`, four scenes on
  `release` with `bsnes_ppu_fast=OFF`, each asking for no frame with a
  count. Chosen by measuring eight candidates on main (all 0): the memory
  (`manta`, 3900 ticks, 27.5 s alone), the opening from the title to map
  1's cinematic (1500 ticks, A every 30, 12.6 s), `battle-113` two turns
  (5.2 s) and the items screen with 14 items scrolled down (2.9 s). Left
  out: `choose`, `close`, `transition-mosaic` and `big-picture-photos`,
  4 to 6 s each and no path the four do not walk. **Cost: 28 s of wall
  time for the file alone with 8 processes, 51 s of CPU**; in the whole
  suite it is the memory's 27 s on one worker.
* **The sweep**: `just display-sweep [cartridge] [frames]`, every case of
  the cartridge, 600 hardware frames without input by default (hardware
  frames, not ticks: the menu, the battle and the shop stop the clock),
  `PROCESSES` at once, one case per process. The script is
  `tests/harness/display_audit.py`, which the test also imports.

**Red before, green after.** The test on `release` built with the-advocate
`ce69b86f` (the probe, before the window's fix) and today's ports: **the
memory red, 6 frames** —the first, frame 559, 102 VRAM reads on line 5—,
the same 6 as measured before; the other three green there too, so they
guard other paths and were never seen red. On main, all four green.

**The sweep on main**: `just display-sweep`, `release`, 373 cases, 600
hardware frames each: **0 with accesses, 0 that did not run, 375 s on 8
processes** (6 min of wall time).

What it does not cover, as before: bsnes's timing, not the console's (the
probe's margin covers the FX Pak's NMI); OAM during display, which it
counts and nothing here exercised; and the 600 frames without input of
the sweep reach no box that needs a press.

## To merge (second round)

* The ports, `aguara-display-audit`: `1ac044d` the vblank test's
  docstring, `ebe3367` the core's recipe, the harness, the test and the
  sweep.
* The book, `aguara-display-audit`: `030279f`, "Writes past the vblank"
  says the suite counts it.
* Nothing in the-advocate. **To install**: nothing to reinstall, but the
  suite's machine needs `just audit-core` once, in `abl/` (already run
  here: `/usr/local/lib/libretro/bsnes_audit_libretro.so`); without it
  the test skips.
* Verified on the branch, with the global tools: ABL's `just tests`,
  1656 passed and 2 skipped (none of them this one), 215 s; `just boot`
  at the ports root, 151 passed. `release`'s `abl.sfc` sha256 `e228edad…`.
