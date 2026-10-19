---
name: "The Book of Three: looking at the map shows nothing"
description: "Common event 23 shows a full-screen picture of the land and waits for a key; the port does not show the picture, so the player gets a blank wait"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Mulita on 2026-10-15 in the build's `degradations.json`
(the-advocate `362d3765`, the ports `0ca371b`) and in the event data; not
played in the port.

**What is expected**: common event 23, "Looking at the Map", runs when
switch 38 comes on —the game's map item—: a sound, a full-screen picture
`bo3map`, a `KeyInputProc` that waits for a key, and the picture erased.

**What the build says**: `picture-not-shown`, "picture 2 "bo3map" is not
shown here", for common event 23. So in the port the item plays the sound
and waits for a key over the map as it was.

**How to see it**: turn on switch 38 from a case on any map, or use the map
item from the pause menu once the party has it.

## Defined

Todo, on 2026-10-16, by Cardón: an item of the game that, when used, waits for a key over
nothing.

**Done** means switch 38 on shows `bo3map` full screen until a key, on the
maps where the item can be used, with a case and its golden, and the
`picture-not-shown` loss for common event 23 gone. **First step**: why
the converter leaves it out —a common event's picture has no map of its
own, so it needs a layout on every map where switch 38 can come on—, which
`degradations.json` and `map_pictures.rs` should say.

## Chajá, 2026-10-19

**Why it was left out**: no VRAM layout and no picture limit. Common
event 23 is automatic, and an automatic common event is compiled once, as
a shared body **without a map** —`commons.rs` in the event compiler—, and
without a map it had no pictures at all: `body_of` gave its `Ctx`
`pictures: None`, so `compile_picture` answered "not carried" and the
`ShowPicture` was accepted without being done. The copies of
`common_pages.rs` in the converter —automatic common events with pictures pasted into each map as an extra
event— do not take it either: they only copy the ones a `ControlSwitches`
can turn on, and switch 38 is turned on by item 112, the Map of Prydain
(a switch item), from the menu.

But `bo3map` is 640x480 at zoom 50, the whole screen: a **big** picture,
BG1 in mode 1, which the cartridge carries once and the console shows the
same in every VRAM layout (`runtime/big_picture.s`). Nothing about it is
a map's. So the fix is to give the bodies without a map the big pictures:

* the scan gathers what the automatic and parallel common events show
  (their calls pasted), as `commons_pictures`;
* the converter makes their big layers, numbered after every map's so no
  map's numbers move, and hands them back as `common_pictures`;
* the shared bodies and the parallel ones compile with them.

The small ones are still each map's: a common event without a map shows
none, as before.

**What was measured**: with the change, the converter's log says the
cartridge carries 2 big pictures instead of 1, the build's
`degradations.json` has no `picture-not-shown` for common 23, and the
new case shows the map on the world map (70) until A, in snes9x and
bsnes —`tests/test_book_of_three_map_item.py` in the ports, red with the
tools before the change: "no big picture up in 1200 frames"—. Compared
with the original under Wine, with the same case written over map 1 of a
copy (Mulita's recipe): the same picture. **Its place names read worse**:
white strokes a pixel or two wide, averaged into the land by the scale to
256x224 and the layer's palettes; that is a draft of its own,
[`book-of-three-the-maps-place-names-are-hard-to-read`](book-of-three-the-maps-place-names-are-hard-to-read.md).

On which maps it cannot show: none. The big picture's place is the same
in every VRAM layout, and a common event runs its body on any map. The
suspected exception of the layer, a mode 3 panorama whose BG2 base is
where the picture's tilemap goes —the wishlist
[`big-picture-over-a-mode-3-panorama-may-show-its-tilemap-in-bg2`](big-picture-over-a-mode-3-panorama-may-show-its-tilemap-in-bg2.md)—,
is The Book of Three's map 43; the map item shown there with a throwaway
case came out whole. Its place names differ from the world map's, which is
the draft below.

**The ending's pictures fell out of the same idea**, not of the same fix:
see
[`book-of-three-the-last-pictures-are-not-drawn`](book-of-three-the-last-pictures-are-not-drawn.md).

**What the suite does not cover**: using the item from the menu —the case
turns switch 38 on, which is what the item does; that the menu's switch
items turn their switch on is the runtime's `item_switch`, not looked at
here—; and the other games' common events, which the rule changes only
in Zounds —its notebook, common 29, shows its background, alone—: see
[`pictures-in-common-events-compiled-apart-are-not-shown`](pictures-in-common-events-compiled-apart-are-not-shown.md),
where it is measured game by game. A common event whose big pictures are
under more than one number keeps them out: the layer holds one, and each
it shows takes the screen off —Desert Nightmare's picture menus would
have shown hundreds, one at a time, and passed the 255 the table's byte
names—.

**To install when merging**: `events` and `convert` (rm2k-snes-events and
rm2k-snes-convert); the runtime is not touched. SAVE_BYTES does not change.
