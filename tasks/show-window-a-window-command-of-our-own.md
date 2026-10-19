---
name: "ShowWindow: a window command of our own"
description: "An RPG Maker 2000 PLUS command like ShowPicture that draws a window from the System and composes its text at run time, so a menu made of pictures can be a window that fits every map"
type: feature
status: todo
agents: [Mulita]
---

Asked by taro on 2026-10-19, while Frozen World's B menu was blind on 22
maps
([`frozen-world-the-b-menu-is-blind-on-the-maps-without-room`](frozen-world-the-b-menu-is-blind-on-the-maps-without-room.md)):
the limit was the menu being `ShowPicture` at all. That menu became RM2k's
own `ShowChoice` —the cheap path—; this is the real one, to design and
measure, a sibling of the wishlist's
[`a-window-system-for-rm`](a-window-system-for-rm.md). It belongs with
RPG Maker 2000 PLUS (the book's `decisions/rm2k-plus.md`): any game can
use it, and the game still runs in RPG_RT.

**What it is**: like `ShowPicture`, a numbered thing put up and taken
down by events, but its pixels are not a file: the console draws the
window's frame and background from the System graphic in use, and
composes its text with the message window's font, at run time. A menu of
three pictures that differ only in which row is lit becomes one window
whose lit row is a variable.

## What was measured (Mulita, 2026-10-19)

With the-advocate `hornero-integ` (`0c9de576`) and its `runtime/`.

* **The message window owns a BG2 tile bank of 256 tiles in every one of
  the VRAM layouts** —`window` in `rm2k-snes/mapdata/src/vram.rs`, at
  `$6800`, `$6000` or `$5000` depending on the layout—, and its own 32x32
  tilemap. That is why `ShowChoice` fits on every map: it never competes
  with the map's sprites, which is what the pictures did. Measured on
  Frozen World's 22 maps that had no room for the menu's pictures: see the
  captures of that task.
* **The text area takes 240 of those 256 tiles**: 30 cells by 8, one tile
  per cell and not deduplicated, composed a line at a time into a 1,920
  byte buffer and uploaded in the next vblank (`runtime/messages.s`, "the
  text composer"). The other 16 are the frame. **So a window that coexists
  with an open message has no tiles in BG2**: the bank is full with the
  message's text, whatever the message says.
* **BG2 is also the map's layer above**: on the window's lines an HDMA
  points BG2 at the window's tilemap (`msg_hdma_build` in
  `runtime/message_place.s`), and the roofs and treetops are not drawn
  there. A second window would take more lines from the layer above, the
  same way.
* **A font of one character per tile would not change any of this**: the
  glyphs are 6 px wide and composed pixel by pixel because they do not
  align to 8 px cells, but what limits is not the font, it is which bank
  the window's tiles live in. The message window was never the limit on
  those 22 maps.
* **The gold window is the precedent for a second window**: RM2k's inn
  opens an 88x32 `Window_Gold` next to its message, and the console draws
  it as 44 8x8 objects, past the map's sprite bank and in the sprite
  palette nobody takes, composing the number into it at run time
  (`runtime/gold_window.s`, decided per map by `arrow_obj` in
  rm2k-snes-mapdata). A map without that room shows no gold window. That
  is the cost of a window that coexists with a message: tiles in the
  sprite bank —Frozen World's menu window, 88x56, would be 77 8x8 tiles
  against the 320 its three pictures took, but on the same bank— and one
  sprite palette.

## The design this leaves

1. **Without an open message, in the message window's own bank**: a
   ShowWindow takes the window's tilemap and its text area while no
   message is up, as `ShowChoice` does. It fits on every map, as the
   window does, and costs no sprite tile. It cannot be up at the same time
   as a message; RM2k's own menus cannot either.
2. **With an open message, as objects**, like the gold window: only where
   the map leaves the tiles and a palette, and the build says where not.
   Second stage, only if a game asks for it.

**Where its text is composed**: the same composer as the messages
(`MSG_CHARS` letters a pass), so a window of four lines appears in about
as long as a message of four lines —a quarter of a second, measured for
the messages in `messages.s`—. Re-lighting a row is redrawing two lines,
not the window.

**How a game authors it**: RM2k's editor has no new commands, and the game
has to keep running in RPG_RT. The proposal is a `Comment` (code 12410)
whose first line is a directive the event compiler reads —`@window 1, x,
y, w, h` with the lines of text after it, `@window_erase 1`, and the lit
row by a variable—: RPG_RT skips comments, so the game runs there without
the window. The other way, a `ShowPicture` of a name that marks it, would
show nothing in RPG_RT either, but it leaves a missing file there.

**Opcodes**: one or two new event opcodes, numbered when the task is
taken.

## Not measured

What it costs in bank 0 and in the runtime's banks, and how a window's
line is lit —a row's background redrawn, or a cursor as the choice's—.

## A strict requirement (taro, 2026-10-19)

The message window's HDMA takes BG2 —the map's layer above— for the
**whole width** of the lines it covers. A message is the whole width
anyway; a narrow window like Frozen World's menu (88 px) would make the
roofs and treetops beside it vanish while it is up, which the pictures it
replaces —objects over the layers— did not do. taro noticed the
difference playing the picture menu, and made it a strict requirement:
roofs cut off while a window is up would be too disruptive. **A
ShowWindow narrower than the screen keeps the layer above beside it**,
however it is done: e.g. its tiles laid into
BG2's own tilemap instead of swapping the line's, or the console's
windows limiting the swap to its columns.
