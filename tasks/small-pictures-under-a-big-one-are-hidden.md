---
name: "Small pictures over a big one are hidden, and two big ones are one"
description: "Zounds' skill screen (map 190) puts its selectors and a face over a full-screen picture and a tall skill list: the background layer holds one big picture and hides the map and the small ones"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Seen by Tijereta on 2026-10-16, with the-advocate `9407d385` plus the
branch `tijereta-more-pictures`, while measuring
[`zounds-pictures-and-the-picture-made-screens`](zounds-pictures-and-the-picture-made-screens.md).
Read from the converter's log, not played.

**What it is**: Zounds' map 190, the skill screen, shows
`Zounds_SystemBox_Pic` (320x240) under everything, `Zounds_SkillScreen_Skills`
(167x227, placed by variables, which scroll it) and over them two
selectors of 170x41 and a 48x48 face. The box and the list are too big for
the objects and go to the background layer, which holds one at a time and,
while it is up, hides the map and every small picture
(`divergences/what-large-pictures-do-not-model.md` in the book). The four
small ones go in since the branch above —"the pictures 'Zounds_SysSelector,
Zounds_SysSelector_Bright, Zounds_Face_Unamë, Zounds_Face_Kazar', 49
objects in 192 tiles, 4 palettes"— but are not seen over the box.

How to see it: build Zounds' `release`; the converter's log says "map 190:
the picture 'Zounds_SkillScreen_Skills' is 133x211 on the console: bigger
than the plane of objects". The book's research "More pictures at once",
option 4, weighs what it would cost.

## Defined (2026-10-20, Calandria)

At the-advocate `3bc68ac4`, the-advocate-ports `b5cfc1e`.

**Seen, both sides.** The console, on map 190 with the skill screen's
common event (59, switch 294) turned on: the left panel's frame alone, over
black —no panorama, no list, no selectors, no face—. RM2k 2003 under Wine,
the same copy with the start moved to map 190 (9,6) and the hero hidden as
the common event does: the panorama `Zounds_SystemBox` (both panels on
stone), "Simitarra Kashar" and "El Puñal Punzante" in the left one, the
selector over the first, and Unamë's face in the right one. Captures in
`/shared/captures/2026-10-20-zounds-skill-screen/`.

**What the screen is made of**, measured on the files:

* the map is 20x15 —one RM2k screen, which its display never scrolls—, its
  panorama `Zounds_SystemBox` is the whole screen, and the hero is hidden;
* `Zounds_SystemBox_Pic` (48), 320x240, has 6,011 opaque pixels of 76,800,
  and **every one is the panorama's own pixel under it**: it is the left
  panel's frame and the stone around it, cut out so that the list (47),
  under it, is clipped when it scrolls. It is shown once, with the screen,
  never moved;
* the list (47) is 167x227 with two lines of text at its top, placed by
  variables (182, 181); it scrolls only with seven skills or more
  (variable 183), and the page sets 183 to 2, so in the game it never
  moves;
* the two selectors (49, 50) and the face (46) are small, and go in since
  Tijereta's pictures.

**Why it is not seen.** Two things. The frame is a big picture —too big for
the objects— so it goes in BG1 in mode 1 over black, its tiles from VRAM
word 0 over the sprite bank, and the sprites off. And the list is left out
by the converter: 133x211 on the console, taller than the 128 the objects
took (`HEIGHT_MAX`), from when every block was a whole 32x32 object.

And a third that a fix has to respect: the map is not scaled —the console
shows a 256x224 window of it— and the pictures that go with the screen
are. Over this map's panorama the selectors would not frame its panels;
any answer has to draw the panels and the pictures at the same scale.

**Done**: the skill screen shows on the console as in RM2k, scaled to the
console's screen: the panorama, the list, the selectors —the bright one
blended—, the face; a golden of it in the ports, red before; nothing else
of the nine games changes.

**First step** (the design, decided and implemented —taro prefers that to
waiting—): on a map of one screen with a still panorama, a big picture
shown still with the screen is **drawn over that panorama** when the
cartridge is built, so its layer is what RM2k shows there —its holes
filled—, scaled like every picture; and such a layer **keeps the small
pictures over it**: its tiles go from word $2000, past the 512 sprite
tiles, the sprites stay on and the OAM carries only the pictures. And a
picture that is not big —placed by variables— goes in the objects up to
256 tall, the byte of an object's place: what it costs is its tiles, which
Wally weighs.

What this leaves out, on purpose:

* **the numbers are not kept over the big one**: every small picture goes
  in front of it, while in RM2k the ones under its number are behind its
  drawn pixels. On map 190 that is the list under the frame, which only
  scrolls with seven skills. Doing it is BG1's priority bit on the cells
  the picture draws and the lower pictures at OBJ priority 2; it is not
  done because in mode 1 BG1 priority 1 goes in front of the message
  window, BG2, and the window would need BG1 masked on its lines.
* **the map's tiles are not drawn under it**, only its panorama: a map of
  one screen whose ChipSet draws over its panorama would show the
  panorama there while the picture is up.
* **map 136** —[`zounds-menu-pictures-on-map-136-need-512-tiles`](zounds-menu-pictures-on-map-136-need-512-tiles.md)—
  is not this: it has no big picture, and its faces do not fit the sprite
  tiles. It does share the third point above: its panorama is not scaled
  and its pictures are, so even fitting, its faces would not frame its
  panels. That is written in its draft.

## Work (2026-10-20, Calandria)

Branches `calandria-skill-screen` in the-advocate (`66d602ec`), the ports
and the book, from the starting points above with main merged in the last
two. **Install when merging**: `just install cartridge convert images
mapdata` —`cartridge` for the runtime, which changes—.

**The screen shows**, as the golden `zounds-skill-screen.png` of the
ports' `tests/golden/` and the captures in
`/shared/captures/2026-10-20-zounds-skill-screen/` say: the panels on
stone, both skills, the selector's frame on the first —on the second after
Down, `zounds-skill-screen-down.png`— and the face, scaled to the
console's screen; and B erases the five pictures and goes back to where
the player was. What it took, beyond the definition's first step:

* **The selector's fill is left out, by the port**: a fork of map 190 in
  the ports, `zounds/patches/manual/maps/Map0190.json`, with its four
  `ShowPicture`s of picture 49 as `Comment`s; the why in
  `zounds/patches/manual/README.md`. Two reasons, measured: on the
  selected skill's lines the frame, the fill, the name and the face are
  about 284 pixels of objects, past the 272 —34 slivers— a line draws,
  and the PPU dropped the frame and half the fill; and the console's
  colour math mixes every picture in the top four sprite palettes, so with
  a translucent one up the list and the face came out half transparent
  too. The fill over the panel's blue is one step of 31.
* **A thin block goes as 8x8 objects** —up to eight cells in no more than
  two of its rows, not two whole rows side by side—: as 32x32 blocks the
  frame, the two lines and the face were 38 slivers on 37 lines; with it,
  35 slivers on three lines and 33 objects on two, measured by simulating
  the cut with Pillow (`as_cells` in `pictures.rs`). Nothing on screen
  shows those lines short.
* **Only a picture with holes is drawn over the panorama** —a quarter of
  it or more, the rule of `map_pictures`—: without it Sunset's
  `RaspberryAccident`, opaque, on map 39, also qualified, and the small
  pictures under its number would have come out in front of it.

**Measured, every game built with the global tools (the-advocate
`3bc68ac4`) and with these**: bank 0 the same in every cartridge, bank 1
53 bytes less (ABL's test cartridge 295 left, Vampires Dawn 272). The
only layer drawn over a panorama is map 190's. The converter's logs move
only where pictures are thin —Desert Nightmare's picture text box, 84
objects in 320 tiles to 92 in 272; The Book of Three's credits on 68 and
El Dorado's 13, 10 objects to 15—, in what the maps that do not fit would
take, and in two pictures now admitted that still do not fit —ABL's
`hovertram2` on 32 and El Dorado's `Ufostrahl` on 5—, one more line in
ABL's `degradations.json`.

**Run**, with these tools first in the PATH: the-advocate's `just test`
(29), `just lint`, `just rust-test`; the ports' `just boot`, 101 passed
and the two new goldens missing, then the new file green, three tests;
ABL's `just tests`, 1578 passed and 2 skipped, `abl.sfc` `4d32dddc783ec5f1`
(sha256). Red before, with the global tools: the three tests of
`test_zounds_skill_screen.py` —the list in `degradations.json`, and the
two goldens off by 54,613 and 54,591 of 57,344 pixels—.

**Not covered by any test**: a big picture with holes over a panorama
whose small pictures' tiles reach past what the layer leaves —the layer
keeps the 512 object tiles whole, so there is none today—; the menu on 136
leading here, which it does not yet; and the order of the numbers over the
layer —every small picture goes in front of it—, which the game does not
exercise because the list never scrolls.

**What was found and not fixed**, as drafts:
[`a-small-picture-s-fifteen-colours-lose-a-whole-hue`](a-small-picture-s-fifteen-colours-lose-a-whole-hue.md)
—Unamë's face after Down, green hair to orange—, also in Zounds' known
issues; and the scale of map 136's pictures against its panorama, written
into [`zounds-menu-pictures-on-map-136-need-512-tiles`](zounds-menu-pictures-on-map-136-need-512-tiles.md).
