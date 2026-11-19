---
name: "Desert Nightmare: the game's menu draws nothing"
description: "B opens the game's own menu —Inventory, Keys, Notes, Maps, Quit, made of 320x240 pictures— and the console draws none of it: the map stays on screen while the menu takes the buttons"
type: bug
status: draft
game: desert-nightmare
agents: [Hurón]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**: on the motel (map 16) and in the warehouse (map 26), B
turns on switch 5 (the menu), A turns on 6 (the inventory) and sets
variable 8 to the first item: the menu works, blind. Nothing is drawn: the
map stays, the hero stands. With nothing in it, A on the invisible
"Inventory" prints "You have no items" over the map. RPG_RT 2015 under
Wine draws the burning face, the five options and the item grid with its
description.

**What it is made of**: common event 4, a parallel `KeyInputProc` on
switch 1, and 5 to 14, which show **155 different pictures**, every one
a 320x240 canvas: `Introauswahl` behind, `Optionen1..5` over it, and
`Inventar`, `Gegenstand1..`, `Schlussel1..`, `Notiz1..`, `KarteG1..` and
the cursors in the grid. `degradations.json` lists them as
`picture-not-shown` (503 of the 584 are the commons'). The notes are
where the game writes its safe codes.

**To reproduce**: the stage `use_bulb` of `~/scratch/huron/dn/stages.py`;
captures in `/shared/captures/2026-11-19-desert-nightmare/menu.png`.
