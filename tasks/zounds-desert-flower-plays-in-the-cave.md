---
name: "Zounds: Desert flower plays in the cave and elsewhere"
description: "Inside the crack's cave Zounds_Dungeon_1 starts right, but a screen or two to the right Desert flower plays instead; taro saw the same outside it, always Desert flower"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

**What is seen**: entering the first dungeon (inside the crack) the right
song plays, `Zounds_Dungeon_1`; walking one or two screens to the right,
Desert Rose (`18 - Desert flower`) starts. taro finds no map of the
dungeon that sets it. They think the same happened on other maps outside
the crack, always with that song.

**A lead** (Hornero, read in the dump, not measured): the cave's maps
—58 Caída, 52 Cueva, 51 Entrada de la Cueva and their children, 60, 68,
69, 70, 78…— all say "same as the parent" (`music_type` 0), and going up
the tree the first that names a song is 33 Mountains, `18 - Desert
flower`. Whether RM2k resolves it the same way and the game plays the
dungeon's song with events, and what our runtime does differently, is the
question.

**Also, from the same session**: the `Water` event on map 60 (Derecha
(To-East)) plays `NAU_Splash` in a loop, and the ROM plays a different
sound. Is it one of the sounds left out?

## What was found (Carpintero, 2026-10-19)

Starting from the ports `1182513`, the-advocate `2c350d8f`, the book
`9fa5711`, and the zounds clone at `3330c15`.

**The song is the game's, and RPG Maker 2003 plays it the same.** The
lead holds: map 60 climbs 68 → 58 → 52 → 51 → 33 and only 33, Mountains,
names a song. EasyRPG's `Game_Map::PlayBgm` climbs while a map says "the
parent's" and plays the first song it finds, on every map change, over
whatever an event started; `MapTree::music` in `rm2k/rules/src/tree.rs`
does the same. To know what RPG_RT does and not what EasyRPG says, the
game's own `RPG_RT.exe` ran under Wine (the prefix of
`~/wine/abl/LEEME.txt`, a display of its own) on a copy in
`~/scratch/carpintero/cave-music/wine/`: with `FullPackageFlag=1` in its
`RPG_RT.ini` —without it, "The RPG Maker 2003 Runtime Package is not
present"— and the two RTPs of `~/assets` copied under it with `cp -n`
—without them, "The file vehicle cannot be opened"—. In that copy, the
start is map 59; the HeroStart page, without its messages, plays
`Zounds_Dungeon_01` and teleports to 60 (1, 7); and an autostart page
added on 60 opens the save menu. The save it wrote has
`18 - Desert flower` as `current_music` (chunk `0x4B` of the system, read
with a throwaway parser). The port matches: on 59 `song_current` is
`Zounds_Dungeon_01`, on 60 `18 - Desert flower`. Only 59 and 99 play the
dungeon's song, both with a `PlayBGM` on their autostart page; the rest of
the cave, and 51 to 53 outside, climb to 33 the same way. Draft:
[`zounds-the-cave-plays-the-mountains-song`](zounds-the-cave-plays-the-mountains-song.md).

**The splash is a stand-in.** `Sound/NAU_Splash.wav` is not in the game's
repository; on its `snes-port` branch it is a copy of `Close1`, like the
other 24 `NAU_` sounds (commit `42aa093` there). The ROM plays that file's
row: on map 60 the `PlaySound` starts `NAU_Splash`'s `sound_table` row
(sample 181), and effect place 181 in ARAM holds `NAU_Splash`'s own bytes
—compared in a snes9x savestate against its ROM sample without the
`.msu` and against its `.msu` version with it—, entering 60 directly or
from 59. Draft:
[`zounds-map-60s-water-sounds-like-a-door`](zounds-map-60s-water-sounds-like-a-door.md).

**What changed**: nothing in the tools. A test in the ports,
`test_the_cave_east_of_the_start_plays_the_mountains_song` in
`tests/test_zounds.py`, walks from 59 into 60 and holds both songs: it is
the only one that resolves a chain of "the parent's" through the ROM. It
reads `song_current` and not `Session.song`, which answers None while
`music_off` is set, as it is for both songs here. In the book, the
Zounds page's stand-in line names the splash, and a paragraph says the
cave's song is the original's.

**Branches**: `carpintero-cave-music` in the ports (the test) and in the
book (the Zounds page). Nothing to install when merging: no Rust and no
runtime changed. **What taro can try**: nothing new to play —the song and
the splash are as they were—; the two drafts are questions about the
game's data and its missing sounds.
