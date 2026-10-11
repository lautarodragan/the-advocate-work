---
name: "Test ROM: the menu in mode 5, on the SNES"
description: "A minimal ROM that shows the mockup of the menu in mode 5 (×1.5) as a still image, so taro can see on the SNES with the FX Pak whether high resolution reads well through its video output"
type: research
status: done
assignee: taro
---

From taro, on 2026-09-30, after the mockup
(`mock-up-the-menu-in-high-resolution.md`, Ñacurutú). Mode 5 with the
×1.5 font per glyph is what reads best in the mockup, but there is a risk
that only shows on the console: one-pixel high-resolution columns are at the
limit of NTSC's bandwidth and may look blurry over composite or RF. This ROM
answers that before investing in variable-width text.

taro, about the font: if needed, one can be made by hand, with the ×1.5
thought out letter by letter —the L and the I, for example, treated
separately—.

It isn't the game: it goes through neither the converter nor `cartuchos`.

## What was built (Carancho, 2026-09-30)

The ROM is in `rom/experimentos/menu-modo-5/` and is built with `just
menu-modo-5`, which then runs it in snes9x, bsnes and mesen-s and compares
each screen with its mockup at 15 bits. It goes in `rom/justfile` and not in
the `tools/` one because what it shows is ABL's menu. The delivery, with a
`LEEME.txt` of what to look at, is in `/shared/experimentos/2026-09-30-menu-modo-5/`.

Three screens: 1 the ×1.5 (mode 5), 2 the ×1.6 by position (mode 5), 3
today's menu (mode 3). Right or A goes to the next one, left to the previous
one, B hides the number in the corner.

**Identical to the mockup in all three emulators**, pixel by pixel, without
the number. The comparison catches what matters about the mode: with BG1 off
the subscreen it gives fourteen thousand differing pixels per screen (tested
by hand, it isn't kept as a case).

What was learned along the way, for the real menu:

* **The faces don't fit in the background**: a 16x8 cell that crosses a face
  carries up to 19 colors. As sprites they fit whole, without Adeleine losing
  anything, by cutting each face into bands of rows of up to 15 colors with a
  palette each.
* **The rest fits in BG1's eight palettes** without losing a color, so
  Adeleine wasn't needed; the script does the grouping.
* **Voodoo doesn't know about mode 5's 16x8 cells**: it numbers the tiles one
  by one and reuses them mirrored, and in mode 5 a tilemap entry names a
  consecutive pair. For this test the script solves it; the real menu, if it
  bakes anything in mode 5, will ask Voodoo for that mode.
* In mode 5 the empty subscreen shows COLDATA, so it goes in black.
* **Reading the controller has to wait for auto-read to start**, and not just
  for it to finish: on entering vblank it hasn't started yet, and reading
  JOY1L while it fills made bsnes lose a press or count two.

When merging there's nothing to install: it doesn't touch Rust nor add
scripts to the PATH.

**Pending**: that taro look at it on the SNES with the FX Pak, through its
video output, and say whether the one-pixel columns are readable and whether
×1.5 beats ×1.6.
