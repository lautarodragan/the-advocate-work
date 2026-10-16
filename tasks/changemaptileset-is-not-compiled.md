---
name: "ChangeMapTileset is not compiled"
description: "A page that changes the map's tileset at run time is left out whole: Frozen World 10 uses on 8 pages (maps 9, 47, 99, 129, 149), Vampires Dawn 10"
type: feature
status: doing
assignee: Mulita
agents: [Calandria, Mulita]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Frozen World leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).

**What is seen** (not played): eight event pages never run, because
`ChangeMapTileset` (11710) has no arm in `compile_command`: map 9 (event 6),
47 (event 2, three commands), 99 (event 2), 129 (events 5 and 7, two pages
each) and 149 (event 6). Which tileset each asks for (8, 11, 13, 14, 25) and
what the player misses was not looked at. The command was already named in
the survey's list of one-at-a-time commands
([Other games: the survey](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-other-games.html)).

**Uses in the eight dumps**: Frozen World 10, Vampires Dawn 10, the others
none.

**taro, 2026-10-16**, playing the delivery of that evening (the ports
`4b2d41e`): on Frozen World's map 9, `Bazaar Stopped`, the characters move
now, but the intro stops running; the hero seems to walk freely on the map,
with no graphic. taro suspected EV0006 dropped for its `ChangeMapTileset`,
and `just culprits release` in `frozen-world/` confirms one map page left
out whole, with `ChangeMapTileset` as its only culprit. The intro blocks
the game. Taken by Mulita: first the command dropped with a warning, so
the page runs; then what doing it for real costs.
