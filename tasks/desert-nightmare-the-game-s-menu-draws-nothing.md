---
name: "Desert Nightmare: the game's menu draws nothing"
description: "B opens the game's own menu —Inventory, Keys, Notes, Maps, Quit, made of 320x240 pictures— and the console draws none of it: the map stays on screen while the menu takes the buttons"
type: bug
status: doing
assignee: Mulita
game: desert-nightmare
agents: [Hurón, Mulita]
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

## The menu and the inventory, as windows (Mulita, 2026-11-20)

Since [`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)
the options and the inventory are RPG Maker 2000 PLUS windows: common
events 4, 5 and 7 forked with a `@window` comment in front of each picture
(`desert-nightmare/patches/manual/commonevents/`, made from
`desert-nightmare/windows/menu.toml` in the ports). The burning face
behind them is a drawing, and is the big picture it was. **What is still
drawn as nothing**: the keys, the notes and the maps screens (commons 9 to
14), which are the same grid with other pictures. The keys and the notes'
names and descriptions read as text too, but the windows' text tiles are
counted per window id for the whole game, and the keys' longer names
("Clothing store key", eleven cells) in the same ids as the items' do not
fit the bank beside the inventory's; the notes themselves (`Notiz_Bild`)
and the maps (`KarteG`) are drawings. Ways on: other window ids for those
screens (a `@window` that stands in for a picture of another number), or
the description lines rewrapped narrower.

taro, on 2026-11-20, translated, on the build with the options and the
inventory as windows:

> In the menu, Inventory seems to work fine (and I could even use the
> lightbulb), but Keys, Notes and Maps show nothing on screen. They do
> seem to respond to input and play sounds.

> I could play until the first monster shows up, lock it in the room, and
> I _think_ I could go on, but I'm not sure because the Keys menu doesn't
> work, and the door on the left side is locked.
