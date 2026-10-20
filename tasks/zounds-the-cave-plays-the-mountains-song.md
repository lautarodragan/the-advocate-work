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

**It is the original's**: measured twice with the game's own `RPG_RT.exe`
(RPG Maker 2003, 1.0.8.0) under Wine. The second time, on 2026-10-20,
walking the game's own way in from its `Save02.lsd` with the three
switches Bandurion's quest sets on (87, 89, 98): 51's stairs, 58's fall,
59, 60, 63. What it looked up, what it sent to the MIDI port and what was
recorded from its audio agree: Desert flower on 51, `ff3boss` from the
fall's `PlayBGM`, Desert flower again on landing on 59 (an event's song
does not survive a "the parent's" map), `Zounds_Dungeon_01` from 59's
page, and Desert flower, from its beginning, on entering 60 and on. The
save it wrote afterwards at 59's save point says `18 - Desert flower`.
The recording is in `/shared/audio/2026-10-20-zounds-cave-music/`.
EasyRPG's `Game_Map::PlayBgm` does the same, the port matches it, and
`test_down_the_crack_the_cave_plays_the_mountains_song`, in the ports'
`tests/test_zounds.py`, walks that same path and holds the sequence.

The same goes for 51, 52 and 53 outside the crack: they also climb to 33.

What to do, if anything, is taro's: the data is their game's.
