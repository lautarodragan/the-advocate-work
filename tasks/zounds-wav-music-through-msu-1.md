---
name: "Zounds: the .wav music through the MSU-1"
description: "Zounds plays three .wav songs —the title, the battle and the victory themes, 242 s— and the converter only knows MIDI; as MSU-1 PCM at 44.1 kHz they weigh 42.8 MB, like ABL's replacement tracks"
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
