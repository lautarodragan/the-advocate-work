---
name: "Picture zoom in mode 7"
description: "A large picture that shrinks or grows with ShowPicture/MovePicture is done in mode 7, with the texture of 255 similar tiles (vq); when still it stays in mode 1 at full resolution"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-03, after seeing the pilot on the SNES: "mode 7 is
definitely the way to approach the photos", and he chose variant 4, the
**vq hybrid**: the still photo at full resolution in mode 1, as today, and
when the zoom starts mode 7 with a texture of 255 tiles chosen by
vector quantization. The pilot, what was measured and the cost of bringing it to the
game: `tasks/el-piloto-del-modo-7.md`, in ABL. It belongs to the engine:
any large picture with zoom, from any game.

Done by Chajá, from `main` at `2c05f8a0`; ABL in a clone, branch
`fotos-en-modo-7` from `30d916c`.

## The plan

* **The texture comes from the mode 1 layer, not from the photo**: the same
  CGRAM indices (the seven palettes above the window), so the
  mode change does not touch CGRAM and the picture's tone keeps working in
  mode 7 with `big_palette_build` as is. The pilot used 239 colours
  of its own; here they are the layer's ≤105.
* **When still, the photo with texture goes to `$4000`** (tiles) and its tilemap to
  `$7C00`, 32x32: mode 7 owns `$0000`-`$3FFF` and the texture is
  uploaded in the vblank while it is still. That overwrites the window and the tiles
  of BG2: with the photo still there can be no message (in the four scenes
  there is none). In mode 7 the upper half is no longer needed, and the window
  is restored there during the zoom.
* **When the zoom ends at 0**, mode 1 with BG1 off: the messages that
  follow (the widow's, on 212) see the window. If it ends at another
  size, it stays in mode 7.
* `irq_music` multiplies with the PPU's multiplier, which in mode 7 is
  the matrix: with mode 7 on screen it multiplies by hand.
* RAM: the picture's bytes at `$7F6500`, inside `ANIM_DRAWINGS`,
  which belongs to the picture while it is there (like its palette and its waves). Opcode:
  `OP_BIG_ZOOM`, `0x43`.

## What was done

* **The converter** (`c30ea5b0`): the pass that gathers the pictures notes
  to what size each `MovePicture` takes its number; the large picture that
  some movement on its map takes to another size asks for its texture from
  `rm2k-snes-images` (`mode7.rs`), which cuts it from the same mode
  1 layer. It goes there because it shares the layer and its CGRAM entries; it is not a
  separate format. k-means over the tiles averaged 2x2, seeded
  without randomness, and the medoid of each group. Only if the layer fits in the upper
  half: 960 tiles and 32 rows; if not, it keeps being turned off as before.
  `OP_BIG_ZOOM` (0x43) replaces `OP_BIG_MOVE` for those pictures.
* **The ROM** (`e14c8912`, `tools/runtime/big_picture_zoom.s`): still at
  $4000/$7C00, the texture uploading to $0000-$3FFF 3 KB per vblank; the
  zoom in mode 7 without black frames; the window back in the upper
  half during the zoom; zoom to zero → mode 1 with the layer off and the
  messages visible. Sprites are off as with any large
  picture. And `irq_music` multiplies with a table of squares while there is
  mode 7, because the PPU's multiplier is the matrix.
* **ABL**, branch `fotos-en-modo-7` of Chajá's clone: two new cases and one
  new test, and the goldens (one changes: `imagen-grande-foto-140`).

The four Diff photos carry a texture —and with them the montage on 217, which
uses the same layers—: 16 KB of tiles and 3.5 KB of rows each, 78 KB.
The mode 1 layers: 664 tiles PhoneCallDiff and 897 the other three.

## The numbers

* `just pruebas` in ABL: **1037** (the 1035 from before and the two new ones).
* `abl.sfc`: `ef1bf110a5e1bf1b…` (before `35ce63c5…`).
* `just -f tools/justfile test`: 27; `cargo test` of the six projects
  touched, green.

## What taro has to see on the console

Captures, the video and what to look at: `/shared/capturas/2026-10-03-modo-7/`,
with its `LEEME.txt`. **The golden `imagen-grande-foto-140` awaits his
approval.** In the game: the scenes on 212, 213, 214 and 216 —the jump when
the zoom starts, the speed, the centre, and the widow's message on
212 after the zoom—.

## On merging

* Install `bytecode cartridge events images mapdata convert`. 0x41 and
  0x42 are reserved in `events.rs` and in `interpreter.s` for Yaguareté:
  when merging his branch, his opcodes replace the reserved ones.
* Bring in ABL's branch first, since without it the suite goes red on the golden
  of 140.

## What no test covers

A message with the photo still (it would not show: the window is not there), a zoom
that grows again from zero, one that ends at another size and stays
in mode 7, and one that arrives before the texture finished uploading (it uploads
the rest with the screen off).
