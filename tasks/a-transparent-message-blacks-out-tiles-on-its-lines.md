---
name: "A transparent message blacks out tiles on its lines"
description: "In Zounds, a sign shown with the message window's transparent background turns part of the map black on the scanlines its text covers, and back when it closes"
type: bug
status: done
assignee: taro
agents: [Aguará]
---

taro, on 2026-11-02, in their words, translated, with two captures of
Zounds —a sign, "Cartel: "No pises el botón."", on a rocky cave map,
and the same screen without it—:

> Another small bug, which I don't know how feasible it is to fix: on
> this map, when showing this text (with a transparent background), some
> of the map's tiles turn black. When it closes they show fine again.
>
> They match exactly the horizontal lines where there is text, and the
> hidden tiles keep showing on other lines, so I don't think it's that
> some tiles were taken out of the SNES's RAM to show the text. Those
> tiles shouldn't be on the object layer either. I can't think of what
> the error can be.

In the capture the black band is on the screen's right edge, where the
dark strip past the map's tiles is, on the scanlines of the text only.
Hornero's guess, unchecked: that strip is the panorama or another
background, and the transparent message's text takes its layer or its
window on those lines.

**Done**: the cause, measured; with the transparent message open the map
shows as without it, as RPG_RT, or —if the console cannot— the limit
measured and a divergence. A ROM test, red before.

A second case from taro, the same day, Zounds' map 96, the sign "Cartel
Fijado: Para abrir la puerta, deben dañar la estatua…": on the text's
lines the map's left column, a block in the middle-left and the right
edge go black. In their words, translated:

> On the next map the same thing happens. It seems to affect the tiles of
> the map's upper layer...

## Measured (Aguará, 2026-11-02)

With the-advocate `0ba09da4` and the-advocate-ports `31fb291`, Zounds'
`release` in snes9x. Both signs, with their page's `MessageOptions [1, 1,
0, 0]` and their text, put in a case that teleports to the sign's cell
(the cases were only for this and were not committed; how to rebuild
them, below).

**It is the layer above, and it is a divergence already written**:
`divergences/the-window-without-a-background-does-not-cover-the-characters.md`
in the book, "The layer above the map is not visible on the lines the
window draws on", and its section "The limit: beside the text". The
window, with or without its background, is BG2, the same layer as the
map's layer above; on the lines of each band the window draws on —each
line of text, 16 scanlines— HDMA points BG2 at the window's tilemap and
scroll (`msg_hdma_build` in `runtime/message_place.s`, Chajá's
`71f5e8bd`, and before that `624050fc`), so on those scanlines the layer
above is gone **across the whole screen**, beside the text too.

* Map 86: open against closed, the pixels that change are scanlines 80
  to 111 —the middle window starts at 72; its top row, 72-79, has no
  text and stays the map's; its two lines of text are 80-95 and
  96-111—, columns 8 to 255: the text and the dark strip on the right,
  which is the layer above's tiles. Where they were it is (0, 0, 0): the
  lower layer has nothing under them, so what shows is the backdrop,
  black. That is why it reads as "tiles turned black" and not as tiles
  missing.
* Map 96: the same on its three lines of text, plus the bottom row's
  eight scanlines: the converter's log says that map keeps the message
  arrow in the window's cells —its eight sprite palettes are taken—, so
  the arrow's band is the window's too, as the divergence says.

Hornero's guess of the panorama is the same mechanism on another map:
in a map whose panorama goes in mode 3 the panorama is that BG2, and the
divergence already says Vampires Dawn's intro shows "Skip Intro ?" over a
black band. A map narrower than the screen changes nothing: past its
edge both layers are empty, with the message or without it.

**What RM2k shows there is a wooden sign**, which the console does not
draw either: both pages show picture 5 "sign", 320x80, in the middle of
the screen, and `MovePicture` it to 20 % transparency before the text.
Scaled, it would cover the console's lines 75 to 149, the whole middle
window. The converter leaves it out of both maps: "the pictures 'sign'
aren't drawn here: with their 384 tiles the map fits no VRAM layout"
(map 96 adds `Zounds_Dialogue_2`). With the sign drawn the black bands
would be under the wood, as in RM2k —but the picture is objects, and
objects go over a window without a background, so it would cover the
text: a second problem waiting behind the first—.

**Not fixed**: it is the PPU's limit the divergence measured —BG2 has
one tilemap and one scroll per scanline, the PPU's windows only hide,
mode 3 has no third background, and a line of text does not fit in
objects—. What was not tried before and is the only path left, with its
price, goes in the divergence's "When it stops being enough" and in the
draft
[`a-window-without-a-background-could-copy-the-layer-above`](a-window-without-a-background-could-copy-the-layer-above.md).
The book's Zounds page gets the line in "Known issues".

**Found on the way**, a draft:
[`zounds-a-sign-drawn-with-a-tile-lets-the-hero-walk-on-it`](zounds-a-sign-drawn-with-a-tile-lets-the-hero-walk-on-it.md):
map 86's sign, an event drawn with a tile on the hero's layer, is walked
over on the console and does not fire with A from the cell below; taro
opened it standing on it.

**To rebuild the cases**: a case in `zounds/cases/` with `Teleport [86,
17, 10, 1]` (or `[96, 14, 14, 1]`), `Wait [10]`, `MessageOptions [1, 1,
0, 0]` and the sign's `ShowMessage` lines, chosen as
`tests/test_zounds_ship_messages.py` chooses its own. Captures, before
only: `/shared/captures/2026-11-02-transparent-message/`.

**To merge**: the book's `aguara-transparent-message` (the divergence and
Zounds' Known issues line). No code changed: nothing to install, no
golden moved, and the-advocate and the ports have no branch.
