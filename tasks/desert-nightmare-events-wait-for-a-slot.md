---
name: "Desert Nightmare: events wait for a slot"
description: "With the towns painted, 7 maps still have more events on screen than the sprite cache has slots —doors, lights and people that change look, and the exit's walking crowd—: the ones drawn last are not drawn until a slot frees"
type: bug
status: draft
assignee: taro
author: cardon
game: desert-nightmare
agents: [Cardón]
links:
  found-in: [still-pieces-painted-into-a-painted-map]
---

Seen by Cardón on 2026-11-19, at the-advocate `cardon-painted-pieces`
(`70c3dd8f`) and the ports `cardon-painted-pieces` (`6cb07f1`), for
[`still-pieces-painted-into-a-painted-map`](still-pieces-painted-into-a-painted-map.md).

**What was seen**: with the still pieces painted into 95 maps,
`events-wait-for-a-slot` in Desert Nightmare's `degradations.json` went
from 34 maps to 7. What is left is not pieces: events whose pages change
their look (doors that open, lights on and off) and people who walk.

    map  name                  on screen / slots
    2    Dusty Creek           19 / 15
    35   Ausgang               27 / 15   the exit's crowd, which walks
    102  a mine                30 / 27   ChipSet map, no panorama
    105  Mine 4                30 / 23   ChipSet map, no panorama
    137  Werkstatt-Keller      15 / 11
    138  Kellergewölbe 1       16 / 15
    172  Alte Minensiedlung    18 / 11

The research
`ports/desert-nightmare/research/2026-11-19-can-the-towns-be-baked.md` in
the book, section 4, says what would take the rest: the posed mechanism
over a painting (a ring cell rewritten when the page changes), which does
not exist, and a patch for map 35's crowd. 33, 71 and 18 are left out of
`painted_events` because painted they would join this list.

**To reproduce**: `just cartridges` in `desert-nightmare/` and
`grep events-wait-for-a-slot build/release/degradations.json`.

## Log

### 2026-11-24, Cardón: a question for taro

**What to decide**: what to do with Desert Nightmare's 7 maps whose events
wait for a sprite slot (doors and lights that change look, people walking,
map 35's crowd): what is lost is seen —late-drawn events— and every way
out costs.

**Options**: (a) the posed mechanism over a painting (a ring cell
rewritten when the page changes), which the book's research
`ports/desert-nightmare/research/2026-11-19-can-the-towns-be-baked.md`
section 4 says does not exist: a runtime feature for every game; (b) a
game patch for map 35's crowd (the game's own choice: fewer walkers); (c)
leave it declared in Desert Nightmare's "Known issues".

**Recommendation**: (b) for map 35 now, the cheapest and the most visible
one, and (a) to `wishlist` until a second game asks for it.
