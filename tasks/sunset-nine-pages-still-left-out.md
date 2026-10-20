---
name: "Sunset over Imdahl: pages still left out"
description: "`just culprits` still leaves out map pages of Sunset —nine after GateStreet's fixes, four on 2026-10-20—; one is the autostart of the ruined plains, on the story's way, which would stop the game the way GateStreet's man and the statue did"
type: bug
status: todo
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

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Two of the nine are autostarts on the story's way (map 14, the statue in
summer, and map 35, the ruined plains), which is what stopped Sunset at
GateStreet, so todo. **Done** is `just culprits release` in
`sunset-over-imdahl/` leaving out none of the pages on maps 14, 29, 35, 56
and 60, or each that stays with its measured reason written here; map 39 is
the author's test map and can stay out. First step: for each culprit, the
exact form the compiler refuses —which operand of `ControlSwitches` and
`ControlVars`, why the boxes of 29 and 39, which target of the `MoveEvent`,
which `TileSubstitution`—, starting with the two autostarts.

## Checked (2026-10-20, Chajá)

Measured with the global tools, installed from the-advocate `8f290c39`,
over the `events-request.json` of the ports' `release` built that morning
(ports `68bf55b`): `rm2k-snes-events culprits --every-map` gives **1365 of
1369** map pages, so **four** are left out, not nine:

| map | event | page | trigger | culprit |
|---|---|---|---|---|
| 35 | 1 | 1 | autostart | `ControlVars [1, 1, 30, 0, 0, 0]` and `ControlSwitches [1, 1, 95, 1]`: a range from 1 set to 0, and switches 1–95 off |
| 56 | 5 | 2 | parallel | `MoveEvent` on this event, the route with a `32` ([`route-switch-commands-leave-the-page-out`](route-switch-commands-leave-the-page-out.md)) |
| 60 | 6, 7 | 1 | action | `TileSubstitution [0, 1, 0]` |

The boxes of maps 29 and 39 compile: they were refused for a `…` and an
`ô`, letters the font lacked, which since `f6c884c1` and `d620ca49`
(2026-10-16) are drawn plain or from Latin-1. Map 14's
`ChangeSpriteAssociation` compiles too; which change did it was not traced.
So of the two autostarts only map 35's is left, and the first step is
now its two range commands.
