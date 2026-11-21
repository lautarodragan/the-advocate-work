---
name: "A transparent window over a flattened panorama shows striped edges"
description: "On ABL's map 1 (Night1 panorama, mode 3, flattened) a transparent message in the middle shows a red-and-white striped column at both screen edges on its text lines, where the panorama's night sky is with the window closed"
type: bug
status: draft
author: aguara
---

Seen by Aguará on 2026-11-16, measuring
[`a-window-line-cannot-wait-forever`](a-window-line-cannot-wait-forever.md),
with the-advocate `d1ad3fa4` (the same on `705d24f5`: the change does not
touch the window's tilemap nor the layout) and the ports `299088c`, in
snes9x, bsnes and bsnes with its accurate PPU.

**What was seen**: A Blurred Line's map 1, "Introduction", with `EV0002`'s
`MessageOptions` changed to transparent and middle —a copy of the game,
not the game: ABL shows those boxes with the window, at the bottom—. On the
sixteen-line bands of the box's text lines:

* at the screen's left edge, some 12 pixels, and at its right edge, some
  8, a column of red and white stripes, where with the window closed the
  panorama's night sky is (left) and black (right, past the red pillar);
* the night sky between the edge and the map's walls turns black. That
  part is the known divergence —the panorama in mode 3 is BG2, which the
  window takes on its lines: [The window without a background does not
  cover the characters](https://lautarodragan.github.io/the-advocate-docs/divergences/the-window-without-a-background-does-not-cover-the-characters.html)—;
  the stripes are not in it.

The converter's log says of map 1: `its panorama goes flattened` and
`Night1 in mode 3`; in a flattened map `pano_ppu` turns on channel 6's
mask for BG1 on the window's lines (`runtime/pano.s` in the-advocate).
Not looked into further.

**To reproduce**: a ports worktree with
`abl/data/maps/Map0001.json`'s event 2, page 0, `MessageOptions` (code
10120) from `[0, 2, 1, 0]` to `[1, 1, 1, 0]`; build `release` (or a
cartridge with start map 4 and map 1), boot "Begin the Story" and press A
on each box of the opening. Captures —each box up, and box 1 next to the
same screen a tick after it closes— are in the shared folder,
`captures/2026-11-16-wait-ceiling/`.

## Log

### 2026-11-16, Aguará: not in the test game

**Not in the test game** (Aguará, 2026-11-16): its terrace, map 9
—flattened, mode 3, a panorama that scrolls on its own and a transparent
box in the middle, `test-game/tests/test_terrace.py` in the-advocate—
shows no stripes on snes9x or bsnes, with the camera against the map's
left edge (the map 20 wide) or inside it (30 wide). So they come from
something ABL's map 1 has and the terrace has not: a camera far into a
100x100 map, its rain, a ChipSet whose cells near the screen's edges are
not blank, or what VRAM holds past the window's tilemap. Captures of the
terrace in the shared folder, `captures/2026-11-16-test-game-pano/`.

### 2026-11-16, Aguará: not the rain, and on BG2

**Not the rain, and on BG2** (Aguará, 2026-11-16, measuring
[`the-test-game-s-terrace-in-the-rain`](the-test-game-s-terrace-in-the-rain.md)).
The map has the rain on while `EV0002`'s boxes are up —`EV0001` sets it
weak, `WeatherEffects [1, 0]`, 15 drops—. With the-advocate `3f3eede3`
and the ports `4e3bfac`, the same stress copy built twice, one with
`EV0001`'s two `WeatherEffects` turned to none: on the first box, at 15
bits, the screen's 12 left and 12 right columns on the box's rows are
**identical** with the rain and without it, the stripes in both; and
without rain snes9x and bsnes agree on the whole screen. The terrace
shows none, dry or with the rain strong (75 drops). So the rain is ruled
out.

And which layer: with snes9x's layer switches, the stripes stay with BG1
off, with the objects off and with the clip windows off
(`snes9x_gfx_clip`), and go with BG2 off, the text with them. They are
**BG2's tiles**: the window's own tilemap on its lines, at the screen's
edges —its first and last columns, or what its scroll brings in past
them—. Left: what that map's window plane holds at those cells, or the
plane's horizontal scroll on its lines, against the terrace's, whose
edges are blank. Captures —dry and wet side by side, and the four layer
switches— in the shared folder, `captures/2026-11-16-terrace-rain/abl/`.
