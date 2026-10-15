---
name: "The Book of Three: looking at the map shows nothing"
description: "Common event 23 shows a full-screen picture of the land and waits for a key; the port does not show the picture, so the player gets a blank wait"
type: bug
status: draft
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
