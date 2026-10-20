---
name: "Zounds: map 60's water sounds like a door, because NAU_Splash is a stand-in"
description: "The Water event on map 60 plays NAU_Splash, which the repository never had; on the snes-port branch it is a copy of Close1, like the other NAU_ sounds"
type: bug
status: testing
assignee: taro
agents: [Chajá]
---

Seen by taro on 2026-10-19 playing the port, and measured by Carpintero the
same day in
[`zounds-desert-flower-plays-in-the-cave`](zounds-desert-flower-plays-in-the-cave.md),
with the zounds clone at `3330c15` (branch `snes-port`) and the-advocate at
`2c350d8f`.

**What is seen**: on map 60 (Derecha (To-East)), in the cave under the
crack, the parallel `Water` event plays `NAU_Splash` twice and Kazar says
he heard water; the console plays a door closing instead of a splash.

**Why**: `Sound/NAU_Splash.wav` is one of the sounds the repository never
had, and on the port's branch it is a copy of `Close1`
(commit `42aa093` there, "A stand-in for each of the 197 assets the
repository lacks"): all 25 `NAU_` sounds are that same file. The ROM plays
what it was given: on map 60, entering it directly or from 59, with and
without the `.msu`, effect place 181 holds `NAU_Splash`'s own bytes —its
ROM sample, or its `.msu` version— and the `PlaySound` starts that row.

See
[`zounds-the-repository-lacks-197-assets`](zounds-the-repository-lacks-197-assets.md).

## taro's decision (2026-10-20)

Look for `NAU_Splash` on the internet by its name; if it is not found, any
similar sound we have. Hornero searched on 2026-10-20 and found nothing by
that name. Don Miguel's RTP has `Water1`–`Water6`, but its files carry no
free license, and this repository replaced its RTP stand-ins with
EasyRPG's CC BY ones for that reason (`7a5ecc6`); a freely licensed splash
—for instance OpenGameArt's CC0 "6 short water splashes", by ezwa— fits
that rule.

## Done (Chajá, 2026-10-20)

**What the event does**: map 60's `Water` (event 9) is parallel. Page 1
(no condition) waits 7.5 s, plays `NAU_Splash` at volume 70, waits 12 s,
plays it again, and Kazar says "Estoy seguro de que oí agua..." and turns
on switch 97. Page 2 (switch 97) loops forever: with variable 8 at 27, a
pair 6 s apart at 90 if variable 7 is 31 and at 80 if not; otherwise at 70,
7.5 and 12 s apart. Map 71's `Water` loops the same at
100. Always tempo 100, balance 50. So a single, short splash, played now
and then, faint: something heard in the dark.

**The candidates**, measured since nobody here can listen (length,
envelope in 10 ms steps, energy per band):

* ezwa's "6 short water splashes" (OpenGameArt, CC0): its `info.txt` says
  they are cut from a syringe emptied into water. All six are a hiss with
  its centroid at 7.6 to 9.7 kHz: a 22050 Hz file keeps half of it, and
  the console's 6000 Hz sample almost none. Left out.
* rubberduck's "40 CC0 water / splash / slime SFX" (OpenGameArt, CC0,
  2018), 15 splashes: most are the same hiss (01, 06, 07, 08, 13, 15:
  over half their energy above 4 kHz), 09 and 10 are short plops, 04 a
  plunge with 73% of its energy between 60 and 200 Hz, 05 and 11 nine
  to twelve bursts in a row. **`splash_02`**: 0.72 s —the stand-in was
  0.75—, one attack at 30 ms and half a second of tail, its energy spread
  from 200 Hz to 8 kHz (39% under 2 kHz), so it survives both rates.
  Chosen.

Don Miguel's RTP `Water1`–`Water6` were not looked at: no free license.
The game has a water sound of its own, `Zounds_Water` (2017, the
fishing common event's cast), 1.15 s; not taken, since this is what
taro's decision asked for, but it is there if taro prefers the game's
own.

**The file**: mixed to mono, raised 6.9 dB through a limiter at -1
dBFS, resampled with soxr to 22050 Hz 16-bit mono PCM (113 of the 139
sounds in `Sound/` are that format). Normalized to its peak alone it
was 10 dB quieter than the stand-in over its loudest 300 ms; the
limiter brings it 4.3 dB up and takes up to 5.5 dB off the attacks,
about 35 ms of them. Not played in RPG_RT.

**`NAU_Water2`** stays a stand-in: it is the sound of the battle
animation "Dispel (!)", a spell, not a splash, and nothing in either
pack is that.

**In the cartridge** (Zounds' `release` built with `GAME_DIR` at the
game's branch; nothing committed in the ports changes, `data/` is the
same since only a `.wav` changed): `audio.json` gives `NAU_Splash` 2421
bytes of BRR at 6000 Hz in the ROM —the stand-in was 2529, like every
`NAU_` copy of `Close1`— and its `.msu` version, 8901 bytes at 22050
Hz, sits in `zounds.msu` and decodes to the new WAV (normalized
correlation 0.83; 0.02 against the old one).

**Heard on map 60**: the ROM, from the debug map jumped to 60 (1, 11)
with switch 97 off, 45 s in snes9x, A tapped every 32 ticks, with and
without the `.msu`, built from the game's branch and from master; and a
third build with `NAU_Splash` as silence, whose take subtracted from the
others leaves the sound alone as the ROM plays it (two takes of the same
build came out byte for byte equal; without the `.msu` what is left
besides the sound is about 20 dB below it, with the `.msu` the takes
drift apart more, so only the SPC700 ones are subtracted). The splash
falls at 7.5 s and 19.5 s (page 1), then at 29.0 s and 41.0 s (page 2),
as the event says; over its loudest quarter second it is about 7 dB
quieter than the door was. In `/shared/audio/2026-10-20-zounds-splash/`,
with the source file and a README. The throwaway scripts are in
`~/scratch/chaja/splash/scripts/`.

**Verified**: `GAMES=<the game branch's parent> just boot -k zounds` in
the ports, 29 passed (the `release` with the new sound). Not played in
RPG_RT. No test covers which sample a sound effect plays: the check is
`audio.json`, the `.msu` and the recordings above.

**Commits**: the game's `chaja-splash`, `75dc0e6` on master `dfcbce0`
(not pushed: the game's repository is taro's); the book's `chaja-splash`.
The ports have no change: `data/` and everything committed are the same,
and the cartridge takes the sound from `GAME_DIR`. Nothing to install.

**What taro can try**: listen to `map60-after-*.wav` against
`map60-before-*.wav`, and `map60-splash-alone-spc700.wav`; if it is too
faint or too dull at 6000 Hz, the level is the gain of
`~/scratch/chaja/splash/scripts/convert.sh`, and `Zounds_Water` is the
alternative.
