---
name: "Zounds: the cave under the crack plays the Mountains' song, in the original too"
description: "Past map 59 the cave's maps say \"the parent's\" all the way up to map 33, Mountains, so walking on from the dungeon's PlayBGM brings back 18 - Desert flower; RPG_RT 2003 does the same, so it is the game's data, not the port"
type: bug
status: testing
assignee: taro
agents: [Calandria]
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

## taro's decision (2026-10-20)

> Dale, usemos la canción del calabozo en los mapas del calabozo en
> Zounds.

The dungeon's maps play `Zounds_Dungeon_01`, changed in the
game's own data, in `~/juegos/zounds` —taro's repo, retouched with their
approval like the cave's doorways—.

## What was done (Calandria, 2026-10-20)

Starting from the game's `master` `e82e5b8`, the ports `68bf55b` and the
book `8c5c4c0`; the tools are the global ones, untouched.

**Which maps are the dungeon.** Under 58 (Caída) the tree has five
children: four folders with no events of their own —68 Planta Baja, 69
Subsuelo, 98 2 Piso, 100 3° Piso— that hold every map of the dungeon
(59–67, 70–74, 77–80, 84–86, 96, 97, 99, 101–104; all ChipSet 46
"Dungeon 3" but 102, "I-Dungeon", in the middle of it), and 105 Salida.
Not everything under them is the dungeon:

* **105 (Salida)** is the way out, outdoors (ChipSet 100, "Desert Outer
  Towers"): 73 fades the music out and teleports there, and its "Iniciar"
  event takes the party to 47 and plays `Zounds_Desierto_01`. Left as it
  was: it is not under the four folders.
* **81 ("4", under 78 Arriba)** is outdoors too, ChipSet 100: 79's events
  10 and 13 fade out, teleport there and play `Zounds_Desierto_01`.
* **189 ("5", under 78)** is a small cave between 81 and 44, which is "2"
  under 93 Cave, under 34 Main: the other cave, not this dungeon.

**How.** `music_type` 2 with `Zounds_Dungeon_01` on 68, 69, 98 and 100
—fade 0, volume 100, tempo 100, balance 50, liblcf's defaults and the same
as 59's and 99's `PlayBGM`—, so 4 nodes cover the dungeon. 81 and 189 got
`music_type` 2 with `18 - Desert flower`, the song they inherited until
now, so outside the dungeon nothing changes (from 81, "the event's" would
have carried the dungeon's song into the other cave through 189). Not on
58: its fall plays `ff3boss` after landing there, and on 58 Desert flower
goes on as before.

**59 says "the event's"** (`music_type` 1). With 59 inheriting the song
from 68, landing from the fall would start the dungeon's song only for
59's autostart page to fade it out two seconds later, in silence through
the scene, and play it again; with "the event's" `ff3boss` goes on into
59 until that `FadeOutBGM`, which is what it was there for. Every other
way into 59 and into its room 77 —60, 61, 77, 86— is a dungeon map, so
what is playing there is already the dungeon's song. **59's and 99's
`PlayBGM` stay**: both come after a `FadeOutBGM`, and without them the
scenes would end in silence.

Written with `ditto read`/`write` (the round trip of `RPG_RT.lmt` alone
is byte for byte equal); only `RPG_RT.lmt` changes, seven nodes. Commit
`02aa303` on branch `calandria-dungeon-song` of the game, over `master`
`e82e5b8`.

**In RPG_RT** (1.0.8.0 under Wine, Carpintero's setup copied to
`~/scratch/calandria/dungeon-song/wine/` with the new `RPG_RT.lmt`): from
`Save04.lsd` (Save02 with 87, 89 and 98), the game's way —94, 55, 87, 41,
87, 55, 54, 47, 51, two battles on the way—, down 51's stairs, 58's
fall, 59 and its scene, 60, back to 59, 60 again and across to 63. The
songs it looked up (Wine's file trace): Desert flower on 51 and again on
58, `ff3boss` from the fall, **no song on landing on 59**,
`Zounds_Dungeon_01` from 59's page, and **nothing more** on 60, 59, 60
and 63. The MIDI it sent (the logging driver): `ff3boss`'s notes go on
from the landing until the switch to the dungeon's song, and from there
the notes go on across 60, 59, 60 and 63 with no controller reset. One
slip: the logging `midimap.dll` writes to Carpintero's folder by an
absolute path, so this run's log overwrote the stray `midi.log` there
(their copies, `t1`–`t3.midi.log`, are untouched); it is now
`t1.midi.log` in mine. Not recorded nor checked by ear; no save written.

**Ports** (branch `calandria-dungeon-song`, `d21150d`): `just dump` with
`GAME_DIR` on the game's worktree changes only those seven nodes of
`zounds/data/maps.json`. The cave test, red with the new dump (the ROM
played Desert flower, `ff3boss`, `Zounds_Dungeon_01`), is now
`test_down_the_crack_the_cave_plays_the_dungeons_song` and holds that
sequence, and also that on the first frame on 59 the song asked for is
still `ff3boss`: turning 59 back to "the parent's" in the dump makes that
check red, so it tells the two designs apart. `just boot -k zounds`: 29
passed.

**Book** (branch `calandria-dungeon-song`, `92dde52`): the section "The
cave plays the Mountains' song, as in RPG Maker" goes, and the fix is a
bullet of "What is fixed in the game itself". There was no "Known issues"
line about it.

**When merging**: nothing to install. The game's branch has to be merged
into `master` and pushed in `~/juegos/zounds`, or the next `just dump`
undoes the ports' `data/`.

**What is not covered**: the rest of the dungeon (69, 98, 100 and their
maps, 99's fall, 81 and 189 from both sides, 105) was not walked, neither
in RPG_RT nor on the console; it is the tree. Neither the editor nor
EasyRPG opened the new tree.
