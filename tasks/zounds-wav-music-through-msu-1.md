---
name: "Zounds: the .wav music through the MSU-1"
description: "Zounds plays five .wav songs —the title, battle and victory themes and two the map tree sets—; their MSU-1 tracks are built, and without MSU-1 they are silent"
type: feature
status: draft
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
