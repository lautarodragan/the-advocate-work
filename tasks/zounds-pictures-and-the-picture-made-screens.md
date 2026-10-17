---
name: "Zounds: the picture-made screens keep more than two pictures at once"
description: "Zounds builds its menu (map 136), its skill screen (map 190), a race's score board (map 75) and its intro (map 106 'Imágenes') out of ShowPicture; the console keeps two, the ROM does not run the picture pages, and the boot stalls on the intro with the hero stuck"
type: bug
status: testing
assignee: taro
agents: [Aguará, Tijereta]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39` and the ports `8a9ab73`.

**Measured**: 266 `ShowPicture` (56 picture files, 31 picture numbers, up
to 50), all with RM2k's 16 parameters —no RM2k3 1.12 features—. The
converter warns on three maps that pictures do not go in because "the
console keeps 2 at a time": 75 "Super Race" (three numbers over: the
digits of a score), 136 "Menu" (`Zounds_Menu_Faces_Kazar`, `Zounds_HP-
Image - N`) and 190 "Skill Screen" (`Zounds_SkillScreen_Skills`,
`Zounds_Face_*`). `ChangeMainMenuAccess` is used 30 times: the game
closes RM2k's menu and opens its own, made of pictures on map 136.

**The boot**: the measuring cartridge passes the title and the harness
says the player has control on map 106 "Imágenes" —no page running—, but
the hero does not move to any side; the map is the picture intro and its
pages use `ShowPicture`, which the ROM does not do (`ACCEPTED_UNDONE`).
Captures of both cores in `/shared/captures/2026-10-15-zounds/`.

**What to decide**: whether Zounds' screens are rebuilt the way ABL's
custom menu was (the book's "The custom menu"), or the picture system
grows past two —the book's "The picture system and the portable
console"—; and how the intro gets past without them.

**Noted on 2026-10-16 (Hurón)**: the boot stalling on map 106 had another
cause too, followed in
[`zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads`](zounds-the-intro-on-map-106-waits-for-a-key-nobody-reads.md)
(in testing). What stays a draft here is the choice above for the
picture-made screens.

**taro, 2026-10-16**: "Si sale relativamente barato implementar el resto del sistema de imágenes, intentémoslo. Si es algo que, de una u otra, nos acerca a la compatibilidad con RM, me parece bien." So the picture system grows toward RM2k's (more pictures at once), rather than remaking Zounds' screens as the engine's menu; first measured, implemented if the cost is reasonable. Taken by Tijereta.

## Phase 1: measured (Tijereta, 2026-10-16)

With the-advocate `9407d385`+ and the ports `6d5c491`, by a throwaway
script over each game's `data/` and its `Picture/` folder: it walks every
page and common event in order —following `CallEvent`s to common events,
ignoring branches—, adds a number on `ShowPicture` and takes it away on
`ErasePicture`, and counts what is up at once. "Small" is what fits the
plane of objects: 256x128 or less on the console's screen.

### How many at once

    game              ShowPicture  most small ones up at once         maps with more than 2 small numbers
    abl                   348      3 on map 95; 11 in the console     1 (95)
                                   (common 39), never done
    book-of-three          11      1                                  0
    desert-nightmare     1249      1 (its many numbers are the        5, never more than 1 at once
                                   drawn-in masks, by number)
    dooms2                 27      1                                  0
    el-dorado             113      4 on maps 8 and 12                 2
    frozen-world           18      1                                  0
    sunset-over-imdahl   1143      4 in its menu (common 5)           0 (the rest are drawn into the map)
    vampires-dawn        4274      9 on maps 9, 94, 455; 7 in its     140 —112 of them show five faces
                                   menus (commons 25 to 28, 43, 44)   at transparency 100, never seen—
    zounds                266      5 on 75, 4 on 136 and 190;          3 (75, 136, 190)
                                   14 in PickAxe (common 21), 10 in
                                   Show Mining EXP (27), 9 in the
                                   notebook (29)

**Typical is one; the screens made of pictures are four to fourteen.**

### Zounds' screens, picture by picture (size in RM2k, colours)

* **Map 75**, the race's score: digits `0`..`9` and `0Points`, 7x8 and 3
  or 4 colours, placed by variables, under numbers 20 to 24: up to five
  at once. Today two numbers go in, each digit a 32x32 object: **19
  objects in 320 tiles** for 19 images of one 8x8 tile each.
* **Map 136**, "Menu": a bar 320x15 (40 colours) that slides in from y=0
  to y=8 while it goes from transparency 100 to 0 in 8 frames —a
  `MovePicture` **that moves**—, two faces 180x59 (255 colours each), an HP
  picture 28x20 (~100 colours): four at once, all small. Today: the bar and
  one face, 18 objects in 320 tiles, two palettes; the bar never shows,
  because its move is not done and it was shown at transparency 100.
* **Map 190**, the skill screen: `Zounds_SystemBox_Pic` 320x240 (172
  colours) under everything, the skill list 167x227 placed by variables
  (it scrolls), two selectors 170x41 (one at 50 %) by variables, and a
  face 48x48. **Two of them are big** —the box and the list— and the big
  layer hides the small ones and holds one at a time: no amount of sprite
  slots shows this screen.
* **Map 106** "Imágenes" has no `ShowPicture`: the intro is its panorama;
  what stalled it is Hurón's task.
* **Common events 21 (PickAxe), 27 (Show Mining EXP), 29 and 41 (the
  notebook)**: up to 14 small ones that slide in and out with moves.
  **They are automatic or parallel common events, and those are compiled
  once without a map, so without pictures** (`pictures: None` in
  `commons.rs`): today none of them shows anything, whatever the slots.

### What limits two today, one by one

* **The slots**: `PIC_SLOTS = 2` in `far_ram.s`, `SLOTS` in the
  converter. Each slot is ten bytes of far RAM: the number is arbitrary.
* **Palettes**: each slot takes a whole sprite palette, 7 - slot, so N
  slots are N of the eight sprite palettes, which the map's characters
  share —three Zounds maps already have none left for one—. Four of
  Zounds' pictures on map 75 are 3 colours each and could share one.
* **Tiles**: every picture is cut in 32x32 objects in the map's sprite
  bank, 16 tiles each even for a 7x8 digit, and the same file under two
  numbers is converted twice. The bank is the 512 object tiles the map's
  characters also use; 5 Zounds maps lose their pictures because the
  layout does not fit (`sign`, 384 tiles).
* **Ramps**: one at a time (`PIC_RAMP`): a second move ends the first.
* **Moves do not move**: a `MovePicture` to another place is not done, so
  a picture shown off-screen or at 100 to slide in is never seen.
* **The big layer**: one picture at a time, and the small ones and the map
  go while it is up.
* **OAM and the line limit**: 128 objects, 34 slivers of 8 pixels per
  line; a 256-wide picture is already 32 of them. Not what stops any
  screen measured here.
* **CPU per frame**: `pic_oam` emits each object; a few dozen objects a
  frame are nothing next to the characters'. **WRAM**: nothing.

### The options, and what each costs

1. **More slots, palettes shared** —the converter groups the map's
   pictures into palettes when their colours together fit fifteen, and
   each image says its palette—. Runtime: arrays sized by `PIC_SLOTS`, the
   palette from the table. Cheap. Lifts 75 (one palette for every digit),
   and 136 if the map leaves four palettes.
2. **Fewer tiles**: an image identical to another one of the map (the
   same file under another number) shares its tiles, and a 32x32 block
   with four or fewer cells drawn goes as 8x8 objects. Cheap: an object
   entry says its own tile and size. Map 75's digits drop from 320 tiles
   to about 11.
3. **Moves that move**, and **a ramp per slot**: the corner computed as the
   show computes it, interpolated per frame. Moderate: one more ramp per
   slot in far RAM, the position by Bresenham steps. It is RM2k: only a
   picture fixed to the map does not move (`ignore_position` with
   `IsLegacy`). Lifts 136's bar and every menu that slides.
4. **Small pictures over a big one** (map 190): the big layer would have to
   leave the sprite VRAM and OAM alone and keep the objects on the main
   screen; and two big ones at once —190's box and its list— need a second
   layer or composing both into one at conversion time. Expensive.
5. **Pictures in the shared common events** (PickAxe, the notebook,
   ABL's console, Vampires Dawn's menus): a body compiled once needs
   pictures that do not belong to a map —a cartridge-wide table whose
   tiles are uploaded on show, with VRAM reserved for them on every map
   that can run it—. Expensive, and the biggest win after 1 to 3.
6. **Composing several pictures into one BG in WRAM at run time**: per
   pixel work on the CPU; not recommended (see the 2026-10-01 study, C).

**Decided: 1, 2 and 3**, which are cheap and general and are RM2k's
behaviour, not Zounds': phase 2 below. 4 and 5 stay as drafts with these
numbers.

## Phase 2: more pictures at once (Tijereta, 2026-10-16)

Branches `tijereta-more-pictures` in the-advocate, the ports and the book.

* **Sixteen slots**, one per number of the map, **the highest number in
  slot 0** —OAM draws the lowest index in front, RM2k the highest number—.
* **Palettes shared**: the converter puts a picture in the first palette
  that takes its colours —exact, in the room left, or within two steps of
  31 for the least used—; a number the map tones (the scan writes down
  `tinted`) shares only with itself. Each entry of `picture_data` says its
  palette; the colours go once per palette.
* **Fewer tiles**: the same pixels once —blocks and cells deduplicated over
  the map—, and a 32x32 block with four cells drawn or fewer as 8x8
  objects. Each object says its tile and size (bit 15).
* **A ramp per slot, and moves that move**: `OP_PICTURE_MOVE` carries a mode
  and x, y like `OP_PICTURE`'s; the corner walks by Bresenham's steps, the
  tone and transparency as before. A picture with the map does not move
  (RM2k 2000). The big picture keeps its own ramp.

Zounds, measured on its `release`: **map 75's score board** went from two
numbers in 320 tiles to all five, 40 objects in 12 tiles and one palette;
**map 190** carries its four small pictures —the box and the list are big,
and hide them: draft
[`small-pictures-under-a-big-one-are-hidden`](small-pictures-under-a-big-one-are-hidden.md)—;
**map 136** carries four numbers and the bar's slide, but its pictures need
512 tiles and fit no layout: draft
[`zounds-menu-pictures-on-map-136-need-512-tiles`](zounds-menu-pictures-on-map-136-need-512-tiles.md).
The common events' pictures —pick-axe, notebook— are not shown at all:
draft [`pictures-in-common-events-compiled-apart-are-not-shown`](pictures-in-common-events-compiled-apart-are-not-shown.md).

Tests: the test game's `test_pictures.py` (case `pictures`: six at once,
two slides at once, one toned without toning its neighbours; three
goldens), the ports' `test_zounds.py::test_the_race_score_board_carries_every_number`
(read from the build), the converter's, mapdata's and the event
compiler's unit tests. Red before: with the tools of `main` the converter
said of the case "the picture 'Digit3' (number 3) doesn't go in: the
console keeps 2 at a time", and four of the six were left out; Zounds' map
75 had 21 such lines.

Verified on the branches merged with `main` (the-advocate `8014fd06`, the
ports `fd7da90`): `just rust-test`, `just test`, `just test-game` (38
passed, 1 skipped), A Blurred Line's `just tests` (1563 passed, 2 skipped,
no golden moved) and the ports' `just boot` (59 passed), all with the
branch's tools. On the way, A Blurred Line's race went past the lag its
test allows (59 frames in 976 ticks against 58) while the frame's loops
walked all sixteen slots; they walk up to the highest slot shown now.
What the suite does not cover: map 136's slide is compiled but its
pictures do not fit, so no screen of Zounds plays a slide; the race's
board is read from the build, not played.

To install when merging: `events`, `convert`, `mapdata`, `wally` and
`cartridge` (the bytecode's `OP_PICTURE_MOVE` grew, and `cartridge` writes
`event_opcodes.inc`).
