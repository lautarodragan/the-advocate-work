---
name: "The Book of Three: the closing pictures are not drawn"
description: "The pictures the game shows over its last two maps (69 and 72) do not fit any VRAM layout and are left out: those moments of the ending are a plain or black screen"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Mulita on 2026-10-15, comparing the port with the original under
Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is seen**: on map 69 the original shows a full-screen picture
(`credits3`) and on map 72 five in a row (`quote1` to `quote4`, `theend`),
each moved in and out; in the port the screen stays as it is under them
—black for most of map 72's—, and the page waits as long as the original.
The game then returns to the title as in the original.

**What the build says**: the converter warns —"the pictures … aren't drawn
here: with their 1280 tiles the map fits no VRAM layout" (384 for map
69)— and `degradations.json` has them as `pictures-not-drawn`,
`picture-not-shown` and `picture-move-not-done`. Nothing in the tasks
covered them.

**How to see it**: the ports' `tests/test_book_of_three_milestones.py`,
`test_the_end`, plays up to them; it does not photograph map 72's last
scene because it is black.

## Defined (2026-10-16, Carpintero)

The game's ending is missing: part of the whole game. **Done**: maps 69
and 72 show `credits3`, `quote1`–`quote4` and `theend` with their moves,
and `test_the_end` photographs map 72's last scene. Two ways, the agent
picks and measures: a VRAM layout for a map with nothing else to draw (a
plain or black map gives the picture all of BG1), or loading the pictures
one at a time as each is shown. **First step**: what else those two maps
draw, and how many tiles each picture takes alone. Related:
[`book-of-three-the-map-item-shows-nothing`](book-of-three-the-map-item-shows-nothing.md).

## Chajá, 2026-10-19

Taken together with
[`book-of-three-the-map-item-shows-nothing`](book-of-three-the-map-item-shows-nothing.md):
**not the same limit**, but the same way out. The map item's picture was
left out because a common event had no pictures at all; these are left
out by the VRAM layouts, as the converter said.

**What those two maps draw, and what each picture takes alone** (the
converter's log, at the-advocate `9592b88b`):

* map 69: its background alone overflows every layout —544 distinct
  tiles, 210 fused into others to fit the 543 the layouts leave—, so its
  sprite bank has no room even for `credits3` alone, 320 tiles. Seven
  characters, 56 sprite tiles.
* map 72: 259 background tiles, 116 sprite tiles; the five pictures,
  `quote1` to `quote4` and `theend`, 924 tiles together.

Neither of the task's two ways was needed. **Both scenes tint the screen
black first** —map 69's command 44, map 72's 29, `TintScreen` to 0, 0, 0—
and then show each picture centred, fading it in and out with
`MovePicture`s of its transparency. Over black, the big pictures' layer
—BG1 in mode 1, the same in every VRAM layout, with the map hidden— is
exact: the map and its characters are not seen anyway, and the layer's
transparency darkens, which over black is what RM2k shows. So the
converter now carries as big pictures **the small ones a map shows over a
black screen, when the map has no room for its pictures in the sprites**
(`over_black` in `pictures.rs` of rm2k-snes-convert): a `ShowPicture`
after a `TintScreen` to black in its own page, with no other tint between,
placed by a constant and with the screen. A map whose pictures fit keeps
them in the sprites, as before. The rule does not see a tint from another
page or from before the map: it only takes what it can be sure of.

On the build: the log says "the pictures … are shown in the background
layer instead" for maps 69 and 72, the cartridge carries 8 big pictures,
and `degradations.json` has no picture loss left. `test_the_end`, in the
ports, photographs each of the six once it has faded in, in snes9x and
bsnes; compared with the original under Wine —a case over map 1 that tints
black and shows each, Mulita's recipe— they are the same pictures in the
same places.

**To install when merging**: `events` and `convert` (rm2k-snes-events and
rm2k-snes-convert); the runtime is not touched. SAVE_BYTES does not change.
