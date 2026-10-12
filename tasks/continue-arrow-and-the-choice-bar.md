---
name: "The continue arrow and the choice bar"
description: "What the message window is missing to look like RM2k's: the arrow that says there is more text, and the choice with the System's highlight bar instead of '>'"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-04: "Go ahead", to carry on with the two differences
Quirquincho found comparing against the original under Wine
(`tasks/message-window-at-the-top-in-the-middle-and-without-background.md`; the captures in
`/shared/capturas/2026-10-04-ventana-de-mensajes/original/`).

## Done (Tijereta)

Tools worktree from `69289619`; ABL in the clone
`/extras/scratch/tijereta/abl` from `5b29ba9`, branch `flecha-y-barra`.

### What was measured in the original (Wine, 2015 runtime)

* **The arrow** is the System's 16x8 piece at (40,16), at the bottom
  centre and over the window's border —easyrpg's `Window::Draw`—. It
  blinks: about 20 frames on and 20 off, and starts on when the page ends
  (`SetPause` sets the counter to zero). It also appears without a
  background.
* **The bar** is the System's cursor —the piece at (64,0)—, 16 high and as
  wide as the text minus 4, shifted 2 to the right (`UpdateCursorRect`);
  each option's text goes 12 pixels further in. Measured: bar at x 11..308
  and y 89..102 of 320x240 —ABL's System leaves the first pixel
  transparent—, "Yes" starts at x 20. Without a background too.
* **ABL's bar does not blink**: its two System drawings, (64,0) and
  (96,0), are identical pixel for pixel —a dark red, (83,0,0)—, and 40
  consecutive captures of the title and of the choice give the same colour.
  In a System with two different drawings RM2k alternates them every 10
  frames.

### The arrow

The converter draws it over the empty window and over nothing, and cuts it
into two more tiles of the window's bank: at 256 wide the piece falls
exactly on cells 15 and 16 of the bottom row. The console turns it on and
off by writing those two cells of the window's tilemap, in the visible
plane —with frame or without background—, from vblank and only when it
changes (`msg_arrow`, in `message_arrow.s`). HDMA already puts the window
at the top, middle or bottom, so the arrow follows it by itself. It shows
when RM2k would set `pause`: page composed, without choice or digits,
without `\^`, with the `\|` already waited.

### The bar

Composed in the window like the text: `prime_line` primes the
`pick_sel` line with `window_bar` —the background with the cursor— instead
of the bare background, and the letters go on top, which is RM2k's order.
The options go twelve pixels further in. The compiler stopped putting the
">": the options' boxes are a single one, and the `OP_CHOICE` table did not
change.

The System's cursor over a rectangle, for other screens:
`rm2k_render::system::cursor_over`.

### What did not change, and is different in RM2k

* **`InputNumber`** keeps ">": in RM2k the cursor is a box around the
  digit, and the precomposed bar is a whole line. It would need another
  piece —a box one digit wide over the digits' line—; it is not expensive,
  but it is another drawing.
* **The pause menu and the save and load slots** keep ">": their rows come
  from another mechanism (`tl_strip` and the per-cursor rows of
  `slots.rs`). Items, equipment, shop and battle already had the bar.
* **The bar does not alternate the cursor's two drawings**: see
  `divergences/the-choice-bar-does-not-alternate-its-two-drawings.md`.
  In ABL they are identical.

### What it uses

* **CGRAM: five more colours in the window's palette**, thirteen instead of
  eight, taken from the background of every map. Eleven ABL maps merge
  between one and five colours. It is what most needs looking at:
  `divergences/the-window-takes-thirteen-colors-from-every-background.md`.
* VRAM: four more tiles in the window's bank —with ABL's System that leaves
  exactly 256—. Tilemap, sprites, OAM: nothing.
* RAM: `MSG_ARROW_T`, `MSG_ARROW_WAY` (two bytes) and `MSG_ARROW_UP`, at
  `$7E3620`-`$7E3623`, after the battle animation.
* ROM: `window_bar` (7.5 KB) and `window_bar_bare` (1.9 KB) in data;
  `msg_arrow` and `msg_bar_source` in the far bank; in bank 0, a few
  comparisons.
* Dropped frames: over map 6 with the camera moving, composing and with
  the message at the top, none more than before. One more on arriving at
  the map, with the screen off.

### Verified

* ABL's suite with `screens`, `wally`, `mapdata`, `events`, `convert` and
  this tree's runtime: green twice in a row, with the new test, 56 goldens
  moved and 7 new.
* The red before: the new test with the global tools, 5 of 6.
* `cargo test` of the touched crates and `just -f tools/justfile test`.
* Against the original under Wine: the arrow blinks 20 and 20 and also
  appears without background; the bar falls where RM2k's does, with the
  text at the same x.

## For taro

Play a choice —Talan's Insta-Shave, or the one about staying in Lashe— and
look at a message waiting for the key. Look above all at the eleven maps
that lose colours (Lashe Area and the Paradise interiors): if it shows, the
alternative is the divergence's. Side by side, with the original and a
LEEME, in `/shared/capturas/2026-10-04-flecha-y-barra/`.

When merging, reinstall `cartridge` —it brings the runtime—, `screens`,
`wally`, `mapdata`, `events` and `convert`. `rules` and `rm2k-render`
changed but they are libraries, inside those. And in ABL, the branch
`flecha-y-barra`: it brings the test, the patches and the goldens.
