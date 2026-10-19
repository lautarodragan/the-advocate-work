---
name: "The Book of Three: looking at the map shows nothing"
description: "Common event 23 shows a full-screen picture of the land and waits for a key; the port does not show the picture, so the player gets a blank wait"
type: bug
status: doing
assignee: Chajá
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
