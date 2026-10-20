---
name: "Terrains do what RM2k does"
description: "A terrain in the database says more than its battle background: damage while walking on it, its encounter rate, a half-hidden character in a bush, which vehicles pass; the console reads only the background and StoreTerrainID"
type: feature
status: todo
---

taro, on 2026-10-20, in their words, translated:

> For the terrain I think we really have nothing. We are going to have
> to implement everything RM offers for events, including "damage".
> Let's make a task for it.

**What the console reads today**: the terrain of each cell, for the
battle's background (`backdrop_terrain`, `rm2k-snes/mapdata/src/scene.rs`)
and for `StoreTerrainID` (`TERRAIN_OUTSIDE`, `TERRAIN_PLANE`,
`block_terrain`, `rm2k-snes/mapdata/src/record.rs`). Nothing else of the
database's terrains.

**What an RM2k terrain says** (liblcf's `Terrain`, to be checked in
easyrpg's `Game_Player`/`Game_Character`/`Game_Map`):

* **damage**: HP lost on each step onto it, with the screen's flash —the
  same moment poison hurts; see
  [`the-partys-conditions`](the-partys-conditions.md)—;
* **encounter rate**: a multiplier of the map's steps to a battle;
* **bush depth**: the lower part of a character drawn half-transparent
  while standing on it;
* **vehicles**: whether the boat, the ship and the airship pass and the
  airship lands;
* the background's own flags and, in RPG Maker 2003 games, the footstep
  sound and the 2003 battle background options.

**Done** is to be written by whoever defines it, one part at a time,
each with what the nine games use. **First step**: which terrains of the
nine games have damage, a rate other than 100, a bush depth or vehicle
flags, and on which maps they are walked on.
