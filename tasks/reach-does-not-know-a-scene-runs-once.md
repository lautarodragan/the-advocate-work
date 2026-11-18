---
name: "reach does not know a scene runs once"
description: "An autostart scene that turns on the switch of the page above it runs once, from where the hero first arrives; reach takes it as starting wherever a recall can put him, and on ABL's Hover-Tram that keeps four seated people out of the background"
type: feature
status: draft
game: abl
---

Seen by Cardón on 2026-11-18, in
[`abl-the-hover-tram-s-crowd-is-cut`](abl-the-hover-tram-s-crowd-is-cut.md),
with the-advocate at `55268148` (branch `cardon-hover-tram`).

**What happens**: map 13's `EV0028`, page 1, autostart, asks for nothing;
page 2 asks for switch 69, which page 1 turns on before it teleports the
hero away. So page 1 runs once in the whole game, from where the hero
arrives the first time —(2,7), from map 9—. `rm2k_rules::reach` starts it
where the hero can arrive on the map (`Run::on_arrival`), and on ABL that
is any open cell: its recalls of a computed place (`CE42`, `CE44`: the
hero's cell, five rows up) can put him on any cell one can step on, of
any map (`any_open`). Started on any aisle cell, the scene can seat him on
any seat from x=8 on, or beside one: `Leave1`, `EV0004`, `EV0007` and
`EV0026` stay objects for it.

**How to see it**: the converter's log of ABL's `release`, map 13: "17
event(s) stay objects, someone can stand behind what it draws past its
cell: 3, 4, 7, …". With the request's `reach.any_open` set to false by
hand, `wally map` takes all seven seated still people.
