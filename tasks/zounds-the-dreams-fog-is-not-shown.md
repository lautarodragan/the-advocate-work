---
name: "Zounds: the dream's fog is not shown"
description: "Map 30's autostart shows fog2 at 110% zoom, and the console only shrinks pictures, so the dream plays without its reddish fog"
type: bug
status: draft
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
