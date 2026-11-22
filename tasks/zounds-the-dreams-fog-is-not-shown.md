---
name: "Zounds: the dream's fog is not shown"
description: "Map 30's autostart shows fog2 at 110% zoom, and the console only shrinks pictures, so the dream plays without its reddish fog"
type: bug
status: draft
author: aguara
agents: [Aguará]
---

Seen by Aguará on 2026-10-17, while bringing map 30 into the cartridge
—[`a-200x200-map-does-not-fit-the-cell-stream`](a-200x200-map-does-not-fit-the-cell-stream.md)—,
with the-advocate `ec017cc1` and the branch `aguara-map30`.

**What happens**: in the dream after Uname's bed, map 30, the reddish fog
over the screen is missing. `degradations.json` says it: `picture 1 "fog2"
is not shown here` on event 1, page 1, command 3.

**Why**: that `ShowPicture` is `fog2` (320x240) at zoom 110, transparency
50 and tone (90, 50, 50, 100). `picture_shows` in
`rm2k-snes/events/src/compile.rs` takes a zoom of 1 to 100 only —"the zoom,
which only shrinks"— so the scan does not gather the picture and the map
carries none. On map 17, before the jump, the bed's page shows the same
`fog2` at zoom 100 and it is shown, as a big picture.

**What it would take**: a big picture over 100% is a layer drawn bigger,
which the conversion could do —`images::background` takes the zoom, and
refuses over 100: see `rm2k-snes/images/src/background.rs`—; the console
does nothing different for it. But a big picture at transparency 50 hides
the map under it —the divergence "What large pictures do not model" in the
book, and `translucent-picture-hides-the-map` in `degradations.json`—, so
shown that way the dream would be the fog over black,
which is worse than no fog: the fog has to be drawn into the map, as the
pictures `map_pictures` takes.

**To reproduce**: build Zounds' `release` and look at `degradations.json`,
or play `test_the_dream_turns_switch_47_on_and_goes_back_to_the_room` in
the ports' `tests/test_zounds.py` and look at the screen on map 30.

## Log

### 2026-11-22, Carpintero: still so, and 100 % alone is not enough

taro asked whether it can be done without much complexity, showing the
fog at 100 % instead of 110 %. Checked against the-advocate `0ae40e0a`
and the ports `89f77b4`.

**Still so**: Zounds' `build/release/degradations.json` has
`picture 1 "fog2" is not shown here`, `picture-not-shown`, on map 30,
event 1, page 1, command 3; `picture_shows` in
`rm2k-snes/events/src/compile.rs` still takes a zoom of 1 to 100 only.

**At 100 % alone** —a fork of map 30 in `patches/manual/maps/` with that
`ShowPicture`'s zoom at 100— the compiler takes it, and it is a big
picture: at transparency 50 it hides the map ("The map is not visible
while it is there", in the book's "What large pictures do not model"),
so the dream plays as the fog over black. Not built: it is what the code
says.

**At 100 % and drawn into the map**, which is what the fog needs, the
rule exists: with `[graphics] map_pictures = true`, `map_pictures.rs` in
rm2k-snes-convert takes a translucent picture that goes with the screen,
on a map that scrolls, unmoved and at 100 %, as a mist repeated over the
map, with its tone; its wave is not done. Built with both changes —the
fork and the switch— on a ports worktree, `just cartridges` in
`zounds/`, and thrown away:

    pictures drawn into their map: 4 in 4 of the 189 maps
    map 17: drawn into the map: 'fog2' at 80 %
    map 30: drawn into the map: 'fog2' at 50 %
    map 86: drawn into the map: 'sign' at 80 %
    map 190: drawn into the map: 'Zounds_SystemBox_Pic' at 100 %
    map 30: wally: the picture needs more than 1024 distinct tiles; a tilemap entry has ten bits for the tile number

It does not build: map 30 is 200x200, and the mist blended over all of
it makes more distinct tiles than a tilemap entry can number. And the
switch is the project's, not the picture's: it would also draw map 17's
`fog2` —the bed's, shown during the erased screen just before the
teleport to map 30— into the ship's cabin for good, and take map 86's
sign and map 190's skill-screen box, which are pictures today.

**Answer**: not without some complexity. The zoom is the easy part, a
fork; what is missing is a way to show a translucent fog over a big map:
a rule that takes this one picture and not Zounds' other three, and a
way to draw it that does not multiply map 30's tiles.
