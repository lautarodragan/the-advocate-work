---
name: "Zounds: the cave under the crack plays the Mountains' song, in the original too"
description: "Past map 59 the cave's maps say \"the parent's\" all the way up to map 33, Mountains, so walking on from the dungeon's PlayBGM brings back 18 - Desert flower; RPG_RT 2003 does the same, so it is the game's data, not the port"
type: bug
status: draft
---

Seen by taro on 2026-10-19 playing the port, and measured by Carpintero the
same day in
[`zounds-desert-flower-plays-in-the-cave`](zounds-desert-flower-plays-in-the-cave.md),
with the zounds clone at `3330c15` (branch `snes-port`).

**What is seen**: the fall into the cave leaves the party on map 59
(Centro (START)), whose autostart page plays `Zounds_Dungeon_01`. Walking
out of 59 to any of its neighbours —60 Derecha to the east, 61 Izquierda
to the west, 77 Cuarto— or further, `18 - Desert flower` starts, and it
plays in the rest of the cave.

**Why**: none of the cave's maps names a song. Map 58 (Caída) and all its
children —68 Planta Baja, 69 Subsuelo, 98, 100, 105 and theirs, among them
59 to 74, 77, 99 to 104— say "the parent's", and so do 52 (Cueva) and 51
(Entrada de la Cueva) above them, up to 33 (Mountains), which names
`18 - Desert flower`. On every map change RPG Maker climbs the tree and
plays the first song it finds, over the one an event started on the map
before. Only 59 and 99 (Caida) play the dungeon's song, with a `PlayBGM`
on their autostart page.

**It is the original's**: with the game's own `RPG_RT.exe` (2003) under
Wine, a copy of the game whose start is map 59 and whose page teleports to
60 after its `PlayBGM`, saved by an autostart page on 60, has
`18 - Desert flower` as its current music (Save01's `current_music`).
EasyRPG's `Game_Map::PlayBgm` does the same. The port matches it, and
`test_the_cave_east_of_the_start_plays_the_mountains_song`, in the ports'
`tests/test_zounds.py`, holds it.

The same goes for 51, 52 and 53 outside the crack: they also climb to 33.

What to do, if anything, is taro's: the data is their game's.
