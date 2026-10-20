---
name: "Zounds: the pick-axe screen and the notebook fit beside no map"
description: "The common events' small pictures go up when shown since 2026-10-20, beside the loaded map's characters; Zounds' pick-axe screen (400 object tiles, seven sprite palettes) and notebook (704 tiles) fit on none of its maps, so using the items still shows nothing"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-20, with the-advocate's branch
`carpintero-ce-pictures` (from `3bc68ac4`) and Zounds' `release`, building
[`pictures-in-common-events-compiled-apart-are-not-shown`](pictures-in-common-events-compiled-apart-are-not-shown.md).

Since that branch a common event compiled without a map shows its small
pictures from a table the cartridge shares, and their tiles go up past the
loaded map's sprite bank when one is shown, if the map leaves room for
them —see "The common events' small pictures go up when shown" in the
book's `internals/vram.md`—. Two of Zounds' do not fit on any map, and the
converter's log says so:

* **The pick-axe screen**, common event 21 with the body it calls, 27
  ("Show Mining EXP"): six pictures and the digits of three numbers, cut in
  400 object tiles and **seven sprite palettes**. `Zounds_Dialogue_4`, the
  320x80 gradient box it fades in under its messages, is 384 of the tiles.
  The layouts give the sprites 256 to 512 tiles, and a map's characters
  take some of them and of the eight palettes. The desert, where the
  pick-axe is used (map 34), has no room even for its own `sign`. And its
  104 entries —a digit is a picture under each of its numbers— would take
  most of the 127 the common table names: the converter leaves the set out
  after the smaller ones.
* **The notebook**, common event 29 with 30 and 41: 704 tiles, its five
  lines of notes 190x20 each. Its own background, `Zounds_Notas_Fondo`, is a
  big picture, which hides the map and the small pictures while it is up
  anyway —[`small-pictures-under-a-big-one-are-hidden`](small-pictures-under-a-big-one-are-hidden.md)—.

How to see it: `just cartridges` in `zounds/` of the ports and, in
`build/release/converter.log`, the lines "common events 29, 30, 41: …fit on
none of the 189 maps" and "common events 21, 27: WARNING, their 104 small
pictures aren't shown"; in the game, the item "Hacha de Pico" (23) or
"Cuaderno de Notas" (35) from the item screen shows nothing.

What it would take, as far as it was looked at —not measured—:

* **The characters giving the plane up while the screen is up**: the
  set uploaded from the start of the sprite bank with all eight palettes,
  the characters not drawn, and the map's bank uploaded again when the
  last of its pictures is erased, as after a battle. A divergence the
  player sees —the map's people vanish under the pick-axe's bar—, and
  still short for the pick-axe on a layout of 256 or 384 sprite tiles.
* **The box under the messages as the message window**: `Zounds_Dialogue_4`
  is a window background the game draws as a picture; a port patch that
  leaves it out —the console's own window under the same messages— would
  leave the pick-axe screen some 16 tiles and four or five palettes. A
  decision for taro: it changes how the screen looks.
