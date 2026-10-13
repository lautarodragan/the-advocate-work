---
name: "With MSU-1 the theme's samples aren't uploaded"
description: "If there's MSU-1 and the theme has a track, its music samples aren't needed in ARAM: faster loads and more room for the sound effects"
type: feature
status: done
---

With MSU-1, a theme that has a track (`PISTAS_MSU`, 22 themes) plays from the
PCM and the SPC700 doesn't play its music. But the ROM still uploads its samples when
loading the map's or the battle's package: wasted time and ARAM.

Make the package upload (`paquete_cargar_ya`, `tema_asegurar`) skip the
music samples of the themes that are going to play through MSU-1 when the MSU-1
is present (the ROM already detects it: `rom/src/msu1.s`). The sound effects keep
being uploaded always.

What it gains, to be measured:
* **load frames with MSU-1**: step 6 left the battle at 58 frames on
  entering and 63 on leaving, and map 3 at 84; with MSU-1 they should drop a lot;
* **the whole ARAM for the sound effects** while a theme plays through MSU-1.

What has to be taken care of: a theme **without** a track that plays in the same package
(it still needs its samples), the switch from MSU-1 to SPC700 if a track is missing
from the card (the MSU-1 says so with its error bit: does the ROM fall back to the SPC700?,
then the samples have to be there), and that without MSU-1 nothing changes (the
goldens run without MSU-1). The test with `msu=True` in `tests/abl/test_msu.py`
is the place to cover it.

taro's idea, on 2026-09-26: in the worst case, with MSU-1 the music goes through the
track and the sound effects fit whole in ARAM without competing with the music.

## And the other half: quality sound effects from the `.msu`

Done on 2026-09-26, requested by taro: see `quality-sound-effects-with-msu-1.md`.
What follows is how it was laid out. Without MSU-1 nothing was touched: the
cartridge's sound effects are the usual ones, not lighter.

Also from taro, the same day: **the light sound effects in the ROM and the quality
ones in the `.msu`**, with the battle backgrounds' mechanism
(`internals/the-msu-file.md`: the ROM reads the `.msu` through the data port if there's
MSU-1 and the signature matches, and otherwise uses its own).

It fits with the above: with MSU-1 the theme's samples don't take up ARAM, so
there's room for the quality sound effects; without MSU-1, the lighter sound effects
leave room for the music samples, which is exactly today's fight between
map 3's sound effects and the oboe, the flute and the drums. And it shrinks the ROM: the
sound effects are ~211 KB of `muestra`'s ~262.

Careful: this doesn't play the sound effects through the MSU-1's audio (it has a single
audio stream, the music's): it uploads them to ARAM from the data
port and the SPC700 keeps playing them. And without MSU-1 the sound effects would be lighter
than today, which is what taro didn't want to lose: decide it with
recordings of both versions at hand (like the thunder).

## Done, on 2026-09-26: the first half

Only the above —not uploading the theme's samples—; the second section is a
plan B taro hasn't asked for yet, and it wasn't touched.

**How**: `tema_por_msu` (`rom/src/paquete_de_audio.s`) answers whether a theme is going
to play through the MSU-1 —there's MSU-1, the theme has a track in `tema_msu` and that track
never went missing—, and `paquete_cargar_ya` skips those themes in its lists of
themes and of exit themes. **The extra theme doesn't go through there**: if it's requested it's
because it's going to play through the SPC700. Without MSU-1 it always answers no, so
the package is the usual one.

**What had to be taken care of**:

* *A theme without a track in the same package*: it isn't skipped, because the question is
  per theme. In `release` there's no package that mixes themes with and without a
  track (the ones without are from later maps), so the test deletes
  `Gaden`'s track in a copy of the cartridge and looks at map 19, which turns on
  `Gaden` and shares a package with `3D-Galax`.
* *A track missing from the card*: the ROM **does** fall back to the SPC700 —
  `msu_arrancar` looks at bit 3 of `$2000` and the wait caps—, and it already
  did before. Now it also sets the theme's bit in `MSU_FALTA`
  (`$7E7820`, one bit per theme), and `music_start` continues through `tema_asegurar`,
  which sees the samples not uploaded and rebuilds the package with the theme first:
  **that time it freezes for as long as the upload takes** (a whole package load,
  like a `PlayBGM` of a theme the map didn't carry). From then on that theme
  isn't skipped, so it doesn't repeat.
* *Without MSU-1 nothing changes*: the goldens didn't move, and the probe gives the
  same frames as before.

**What was measured**, with step 6's probe (frames of `paquete_cargar_ya`),
`release`, snes9x, with MSU-1, before → after:

| | before | after |
|---|---:|---:|
| map 3 (from 5) | 84 | 56 |
| map 26 | 82 | 21 |
| entering the droid battle | 82 | 20 |
| leaving the battle (to 2) | 82 | 48 |

Without MSU-1, all four the same before and after (84, 82, 82, 82). What's left
with MSU-1 is the sound effects: map 3 carries 20 and map 2, 18.

**Covered by** three new tests in `tests/abl/test_msu.py`, with the
MSU-1 on over a copy of `release`: the first two fail without the
change, and the missing-track one fails if the extra is also skipped and the
missing track isn't recorded.

**Seen in passing, and not fixed**: with MSU-1, the title track **keeps
playing** when the game starts. `music_boot` (`rom/src/musica.s`), when
the map starts silent, sets `music_apagada` and lowers the DSP volume but
doesn't call `msu_parar`, so `Fantasia_Of_The_Wind` keeps going through the track
until the first `PlayBGM`, and the battle records it as the theme to restore.

**For taro**, with MSU-1 (FX Pak or an emulator that has it) and the tracks
alongside: that the music of the maps and the battle sounds as before, that the
sound effects play, and that the loads of map 3, 26 and the battle feel
shorter. And, if he wants to test the fallback: remove a track from the card —
`KSSMKEND`'s is `abl-18.pcm`— and enter 26: the theme has to play through the
SPC700, with a longer freeze that first time.
