---
name: "Zounds: the .wav music through the MSU-1"
description: "Zounds plays five .wav songs —the title, battle and victory themes and two the map tree sets—; their MSU-1 tracks are built, and without MSU-1 they are silent"
type: feature
status: done
assignee: taro
agents: [Aguará]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**Measured**: `Music/` has 34 MIDIs and 19 `.wav` (22,050 Hz, stereo,
16-bit, 210.7 MB, 39.8 minutes). Only three `.wav` are referenced, and by
the System: `23 - Town of a wind and ruins` (title, 153.1 s), `08. Mugen,
Activate` (battle, 64.5 s) and `2-03 Victory!` (battle end, 24.8 s). The
other 16 and four MIDIs are never played. No map sets music from the
tree; 29 of the 47 `PlayBGM` songs are MIDIs in the game, 18 are missing
from the repo.

**What it would take**: the MSU-1 track path ABL already has —the
replacements in `msu_replacements`, the `.msu` and the tracks next to the
ROM—, pointed at the game's own `.wav` instead of a replacement: the
converter would have to take a `.wav` as a song (upsampled to 44.1 kHz,
176,400 B/s: 42.8 MB for the three) and emit the MSU-1 play for it where
it emits the MIDI's. Without MSU-1 the three slots fall silent, or get a
MIDI chosen for them as a knob. The title and the battle theme are the
first and most heard music of the game.

**Corrected on 2026-10-16 (Hornero)**: five `.wav` are played, not three.
The map tree sets its own music (`music_type` 2) on map 33, Mountains,
`18 - Desert flower`, and on maps 89, 91, 92 and 177, the small caves,
`04 - Cavern`; the study read the tree as setting none. The fourteen
nothing plays were removed from taro's repository that day (taro's call),
so `Music/` holds only these five `.wav`.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: the tracks are already built. `rm2k-snes-audio` takes a song that is
a `.wav` in the game as an MSU-1 track, decoded with ffmpeg
(`TRACK_EXTENSIONS` in `src/game.rs`, since 2026-09-29), and Zounds'
`release` delivered that day carries the five: its `music.json` gives
them tracks 1 to 5, and `zounds-5.pcm`, the title theme, is 27.0 MB,
153 s at 176,400 B/s. Whether the ROM plays them through the MSU-1 was
not heard. What stands is the other half: without MSU-1 those slots are
silent.

**taro, 2026-10-16**: look for MIDIs of the five songs, for when there is no MSU-1. Some never existed as MIDI —the opening is Tales of Symphonia's, not synthesised—, but MIDIs exist of songs that were not synthesised either (rock, classical, pop). Private use only, like the Final Fantasy ones: the zounds repository stays private. Taken by Aguará.

**Done by Aguará on 2026-10-16**, as far as MIDIs exist. **A song can be
a `.wav` and a `.mid` under the same name**: the SPC700 plays the MIDI and
the MSU-1 track comes from the `.wav` (the-advocate, `rm2k-snes-audio`:
`song_path` asks MIDI-first, the new `track_source` WAV-first, and
`find_resource` takes the earliest extension asked instead of whatever
the directory lists first —which was arbitrary with both—; the test
`a_song_with_a_midi_and_a_wav_uses_each_where_it_plays`, red before the
fix). No other game had such a pair (the eight `.zip`, `rtp.zip`, `rtpe`).
EasyRPG takes the `.wav` first, so the game plays the same there.

Per song:

* `23 - Town of a wind and ruins` (title): Tales of Symphonia, disc 1,
  track 23, Asgard. **Found**: The Midi Shrine,
  http://www.midishrine.com/midipp/ngc/Tales_of_Symphonia/town_of_a_wind_and_ruins.mid
  (one pass, ~68 s). In the clone, `ff8cf97`.
* `18 - Desert flower` (map 33): Tales of Symphonia, disc 1, track 18,
  Triet. **Not found** (VGMusic, The Midi Shrine, BitMidi).
* `04 - Cavern`, `08. Mugen, Activate`, `2-03 Victory!`: **not
  identified**, so not found.

The four left: draft
[`zounds-four-wav-songs-without-a-midi`](zounds-four-wav-songs-without-a-midi.md).

**Measured** in Zounds' `release` built with TRACKS=1 and the branch's
tools: `music.json` gives the title a stream (length 3856, fingerprint
`901f0acce8d87a77`, before: 0) and keeps it track 5; the five tracks are
still 1 to 5 and the log says each came from its `.wav`. **Not heard**:
neither the MIDI on the SPC700 nor the tracks through the MSU-1.

**Branches** (Aguará, 2026-10-16): the-advocate `aguara-zounds-assets`
(`fcc68c0e`, main merged in `a02041ef`), the ports `aguara-zounds-assets`
(Zounds' README), the book `aguara-zounds-assets` (the Zounds page and
`internals/audio.md`); the clone `~/juegos/zounds` `master`/`snes-port`
at `ff8cf97`, not pushed. **To install when merging**: `rm2k-snes-audio`.

**Verified**, with the branch's tools (`rm2k-snes-audio` plus the crates
main had changed) and main merged: `just rust-test` and `just test` green;
`SOUNDFONT=…/FluidR3_GM.sf2 just test-game` 36 passed, 1 skipped; ABL's
`just tests` 1563 passed, 2 skipped, no golden moved; `just boot` 49 of
50, and the one red, Sunset found stale right after building, is the
draft `arrancan-sunset-stale-right-after-built`: `just boot -k sunset`
right after, 2 passed. No suite plays a song that is both a `.wav` and a
`.mid`: the new path is covered only by the crate's unit test and by the
Zounds build measured above.

**2026-10-19, taro**: declared done.
