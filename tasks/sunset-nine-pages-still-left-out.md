---
name: "Sunset over Imdahl: nine pages still left out"
description: "After GateStreet's fixes, `just culprits` still leaves out nine map pages of Sunset; at least two are autostarts of story maps, which would stop the game the way GateStreet's man and the statue did"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-16, with the tools of the branch
`tijereta-gatestreet` (the-advocate `a2141de2` and on), ports `4b2d41e`:
`just culprits release` in `sunset-over-imdahl/` says 1360 of 1369 map
pages compile. The nine left out, map / event / page / trigger, with what
keeps each out:

| map | event | page | trigger | culprit |
|---|---|---|---|---|
| 14 | 32 | 3 | autostart | `ChangeSpriteAssociation` |
| 29 | 3 | 2 | action | `ShowMessage` (the box) |
| 35 | 1 | 1 | autostart | `ControlSwitches`, `ControlVars` |
| 39 | 4, 5, 10 | 1 | action | `ShowMessage` (the box) |
| 56 | 5 | 2 | parallel | `MoveEvent` |
| 60 | 6, 7 | 1 | action | `TileSubstitution` |

Map 39 is "TheLegendaryTestMap", the author's own, and no door leads
there as far as was looked. **Not played** past the statue in spring (map
13): which of these stop the game is not measured. Map 14 is the statue in
summer and 35 the ruined plains, both on the story's way, and an autostart
left out there is what GateStreet's man and the statue were —the scene
does not happen and nothing else moves the story—.

How to see it: build the release with the branch's tools, `just
cartridges` and `just culprits` in `sunset-over-imdahl/`, and read
`build/release/culprits.json`.
