---
name: "Desert Nightmare: light masks placed by an anchor are not drawn"
description: "On 17 maps that scroll —the motel's rooms, the warehouse, the dream, the mines, the workshop's cellar— the light mask is placed at an anchor event's screen position, read into variables, and the console leaves it out: the rooms are lit as by day"
type: bug
status: todo
agents: [cardon]
author: huron
game: desert-nightmare
links:
  found-in: [desert-nightmare-nights-with-a-tint-of-their-own]
  relates: [desert-nightmare-lit-cells-over-a-tinted-night]
---

Seen by Hurón on 2026-11-19, in
[`desert-nightmare-nights-with-a-tint-of-their-own`](desert-nightmare-nights-with-a-tint-of-their-own.md),
on the ports `aa850b4` with the tools of the-advocate `4f38ea03`.

**What was seen**: the game lights its rooms with a `Lichteffekt_*` mask
the size of the map. On a map that scrolls, its parallel page reads an
anchor event's screen position into variables 14 and 15 (`ControlVars`,
operand 6, fields 4 and 5), adds or subtracts a few pixels and shows the
picture at those variables, with the map. `placed()` in `map_pictures.rs`
of the converter refuses a place "by a variable", and the mask is not
drawn: `degradations.json` of the `release` build lists them as
`translucent-picture-hides-the-map`, "its place is by a variable", on 25
maps. Eight are the nights, which the ports' manual patches now tint (the
task above); these 17 are not nights:

    16, 17       Lichteffekt_Motel_Innen1/2, at 35 %
    22           Lichteffekt_Lager2, at 60 %
    48           Lichteffekt_Untergrund4, at 55 %
    58           Lichteffekt_Traum2, at 60 %
    102 to 106   Lichteffekt_Mine1 to 5, at 60 %
    136, 137     Lichteffekt_Werkstatt_Innen, _Innen2, at 60 %
    138, 143,    Lichteffekt_Keller1_1, _6, _7, at 65 %
    144
    157          Lichteffekt_Keller2_8, at 60 %
    182          Lichteffekt_AlteMine6, at 70 %

The same mask on a one-screen map, placed by constants, is drawn into
the map, as the divergence "Pictures drawn into the map" in the book
says. A page on its own map that reads an event's screen position knows
that event's cell, so the variable's value is the event's cell plus the
constants, wherever the camera is: what `night.py`'s composition did to
measure the nights (the scripts are in the task above's log).

**To reproduce**: `just cartridges` in `desert-nightmare/`, then
`degradations.json` for "its place is by a variable"; or enter map 102
with the harness's `go_to_map` and compare with EasyRPG Player on the same
cell.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `placed()` in
`rm2k-snes/convert/src/map_pictures.rs:460` and `:492` still answers "its
place is by a variable". Towards the original —the rooms are lit as RPG_RT
lights them— with the way already said: on its own map the anchor's cell
is known, so the variable is the cell plus the constants, and the mask is
drawn into the map as the constant ones are (the book's divergence
"Pictures drawn into the map"). If a mask does not fit, that is the
question, then.
