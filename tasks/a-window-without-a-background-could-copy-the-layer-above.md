---
name: "A window without a background could copy the layer above"
description: "A message without its background takes the layer above off its text lines across the whole screen, because both are BG2; the one path left is to copy the layer above's cells into the window's plane on those lines, aligned with the camera, at the price of moving the text up to seven pixels and of losing the layer above inside the cells with letters"
type: feature
status: draft
---

Seen by Aguará on 2026-11-02, measuring
[`a-transparent-message-blacks-out-tiles-on-its-lines`](a-transparent-message-blacks-out-tiles-on-its-lines.md),
with the-advocate `0ba09da4`, in Zounds' maps 86 and 96, in snes9x.

**What is seen**: a message without its background —`MessageOptions`
with its first parameter at 1— takes the map's layer above off the
scanlines of each of its lines of text, across the whole screen. Where
the lower layer has nothing under the layer above, those cells go black
(the backdrop). It is written as a divergence in the book,
`divergences/the-window-without-a-background-does-not-cover-the-characters.md`,
with the PPU's limit: the window and the layer above are both BG2, and
BG2 has one tilemap and one scroll per scanline.

**To reproduce**: a case in Zounds with `Teleport [86, 17, 10, 1]`,
`Wait [10]`, `MessageOptions [1, 1, 0, 0]` and any two lines of text;
open against closed, scanlines 80 to 111 lose the dark strip on the
right edge.

## The one path left, not tried

The divergence rules out the PPU's windows, a third background and
objects. What it does not weigh is **carrying the layer above inside the
window's plane** on those lines:

* The bare plane —the 320 cells below the framed one, every cell that is
  not text at 0— gets, in its cells without letters, the layer above's
  tilemap entries of the screen cells they cover. Both use BG2's tile
  base, so the entries are valid as they are, palettes included.
* For those cells to land on the map's, the window's scroll on its bands
  has to keep the camera's fine part, `camera & 7` on each axis. So **the
  text moves up to seven pixels** from where RM2k draws it, or the
  composer draws it shifted by the same amount: horizontally it already
  draws at any pixel; vertically a line's glyph would cross three cell
  rows instead of two, which is a composer with a three-row buffer and
  the text area's VRAM one row taller.
* The cells with letters lose the layer above inside their 8x8: their
  palette is the window's, and one cell has one palette.
* It is built when the window appears, by reading the layer above's
  tilemap out of VRAM in the vblank or from the map's grid, and again if
  the camera moves while the message is up (a parallel page can move
  it).

What it would cost against what the console shows today: bank 0 has
little room (the runtime's new code goes to the far banks), and every
golden with a window without its background over a map would move by
the text's shift. It is a decision for taro: the text a few pixels off
RM2k's place against the layer above back beside it.
