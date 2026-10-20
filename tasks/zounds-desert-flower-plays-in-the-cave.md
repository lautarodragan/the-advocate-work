---
name: "Zounds: Desert flower plays in the cave and elsewhere"
description: "Inside the crack's cave Zounds_Dungeon_1 starts right, but a screen or two to the right Desert flower plays instead; taro saw the same outside it, always Desert flower"
type: bug
status: testing
assignee: taro
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

## Measured again (Carpintero, 2026-10-20)

taro doubted the first measurement: the save's `current_music` is not
what is heard, and the path (start moved to 59, a teleport to 60) was not
the game's. Measured again:

* **The setup**: a private copy of the Wine prefix and of the game
  (`3330c15`, `FullPackageFlag=1`, both RTPs under it), its own Xvfb, and a
  private pulseaudio with a null sink that `parec` records. The game's
  `RPG_RT.exe` sends its MIDI with `midiOutShortMsg`, and this container has
  no ALSA sequencer, so Wine's MIDI goes nowhere: a native `midimap.dll`
  written for this (a MIDI driver that logs every message with its tick)
  stands in for Wine's, so what RPG_RT plays is a log of notes. The WAV
  songs —`18 - Desert flower` is a `.wav`, not a MIDI— go to pulse and
  are recorded. Which song RPG_RT looks up at each change is in Wine's
  file trace (`FindFirstFileExW` of `Music\…`).
* **The path**: the game's own `Save02.lsd` (map 94, in the desert west of
  the crack), walked with xdotool through 55, 87, 41, 87, 55, 54 and 47 to
  51, the cave's entrance. The stairs (51, event 57) let the party down
  only with switch 98, set by Bandurion (24, event 2, page 5) after the
  plant notes (variable 30 ≥ 8 sets 89). So `Save04.lsd` is `Save02` with
  87, 89 and 98 on, the switches the game has set by then, and nothing else
  changed; from there the party walks in like the game does: 51's stairs,
  58's fall, 59, 60.

**What RPG_RT did** on that path, from three sources that agree —the songs
it looked up (Wine's file trace), the MIDI it sent (the logging driver;
its first 40 note-ons on 59 are those of `Zounds_Dungeon_01.mid`) and the
WAV it played (the recording; Desert flower matches the song file with a
normalized correlation of 0.99 on 51 and on 60, 0.2 against the song
reversed)—:

1. on 51, `18 - Desert flower`, which 51 inherits from 33;
2. on 58, the fall's `PlayBGM` plays `ff3boss` and teleports to 59;
3. **landing on 59, Desert flower again**, over the song the fall's event
   had started, until 59's autostart page fades it out;
4. 59's page plays `Zounds_Dungeon_01`;
5. **entering 60, Desert flower from its beginning**; the MIDI stops (all
   notes off) at the same instant, and nothing else is sent to the port on
   60, 63 or 78 but the controller resets of each map change.

The save RPG_RT wrote afterwards at 59's save point (after 60, 63, 78 and
back) says `18 - Desert flower`. The recording, 110 s from 51 to 60 with
the MIDI rendered back in at its own times, is in
`/shared/audio/2026-10-20-zounds-cave-music/`.

**taro's hypothesis does not hold in RPG_RT 2003 (1.0.8.0)**: a song an
event started does not survive entering a map that says "the parent's";
it happened twice on this path (steps 3 and 5). What the editor offers
for a map's BGM is liblcf's `MapInfo::MusicType`: 0 "the parent's", 1
"the event's" (leave what is playing) and 2 a song; the cave's maps are 0,
not 1. EasyRPG's `Game_Map::PlayBgm` does the same: it climbs while the
type is 0, leaves the music alone on 1, plays on 2. So there is no rule
missing, neither in the runtime nor in `MapTree::music`.

**What changed**: the ports' test, renamed
`test_down_the_crack_the_cave_plays_the_mountains_song`, no longer jumps
to 59: it puts the party on 51 above the stairs with 87, 89 and 98 on,
walks down the stairs and the fall, out of 59 to 60 and across 60 to 63,
and holds the whole sequence of songs —Mountains', `ff3boss`, Mountains',
the dungeon's, Mountains'—, which the ROM plays exactly as RPG_RT. In the
book, the Zounds page's paragraph says it was measured on the game's way
down. The draft
[`zounds-the-cave-plays-the-mountains-song`](zounds-the-cave-plays-the-mountains-song.md)
has the new measurement.

**How it was measured, to do it again**: everything is in
`~/scratch/carpintero/cave-music-2/`: `drv/mididump.c` (the MIDI driver,
built with `i686-w64-mingw32-gcc -shared -Wl,--kill-at -lwinmm` and put
as `midimap.dll` in the copy of the prefix, with
`WINEDLLOVERRIDES=midimap=n`), `start.sh` (Xvfb and pulse), `run.sh`
(RPG_RT, with `parec` and the file trace), `drive.py` (walks to a tile in
closed loop: captures, finds the camera by matching the map's
`rm2k-render`, plans with RM2k's passability), `lsdset.py` (switches on
in a save), `match.py` and `notes.py` (what the recording and the MIDI log
are). None of it is a recipe: it answered one question.

**Verified**: `just boot` in the ports with the global tools: 70 passed and
23 Book of Three ones red because its cartridge did not build in that run
(the tools changed under it; `just cartridges` alone built it next), and
those 33 passed again on their own. No ROM changed, so ABL's suite was not
run.

**Branches**: `carpintero-cave-music-2` in the ports (the test) and in the
book (the Zounds page). Nothing to install: no Rust and no runtime
changed. **What taro can try**: listen to the recording; in the port
nothing changes.
