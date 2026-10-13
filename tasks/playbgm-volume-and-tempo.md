---
name: "PlayBGM's volume and tempo"
description: "The ROM ignores the volume and tempo a PlayBGM asks for: 69 of the game's 168 ask for another volume and 13 another tempo"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-30, as the next task after
`theme-that-is-already-playing-does-not-start-over.md` (Yacaré), which left it measured: of
the game's 168 `PlayBGM`s, 69 ask for a volume other than the default
and 13 another tempo, and the ROM uses neither. Also, in
RM2k, a `PlayBGM` of the theme already playing with another volume or tempo adjusts them
without restarting (`Game_System::BgmPlay`), and Yacaré already left that ready.

## What RM2k does

Read in easyrpg (`src/game_system.cpp`, `src/audio_decoder_midi.cpp`,
`src/audio_decoder_base.cpp`). It couldn't be confirmed with RPG_RT under Wine:
there MIDI doesn't play —Yacaré already saw that—, and what it says about a WAV (that the
tempo also changes the pitch) isn't what happens with a MIDI, which is every
theme in this game.

- **`BgmPlay`** clamps the volume to 0–100, the tempo to 10–400 (the editor gives
  50–150) and the balance to 0–100. With the same name and no fade
  in between it only adjusts the three that changed, without restarting.
- **A MIDI's volume** is each channel's CC7 times `volume/100`
  (`AudioDecoderMidi::SetVolume`), linear **in the CC7**. The ROM's stream
  already squared the CC7 —`volume` in `rm2k-snes-audio/src/sdsp.rs`, like
  fluidsynth—, so in amplitude it's `(v/100)²`: 80 is 0.64, 50 is a
  quarter, 40 is 0.16. (For what isn't MIDI easyrpg uses another curve, DirectSound's:
  a 35 dB range, `AdjustVolume`.)
- **A MIDI's tempo** speeds up the sequencer's clock (`mtime +=
  delta * pitch / 100`): faster, **the same pitch**. With a WAV it
  resamples, and there the pitch does change.
- **A MIDI's balance** shifts each channel's pan by `(b − 50) × 2`; without
  MIDI messages, it lowers the opposite side 6 dB every 10 (`ApplyLogVolume`).

## What the game asks for

In `release`'s maps there are 62 `PlayBGM`s: 12 with another volume —80 is
the most common: `TF3_1_awe` in map 2, `evilrhys` in 3,
`dcbest`, `tsmedit`, `bubstix`, `jackalstg2`— and only one with another tempo,
`Kfmus5` at 110 (map 37, on entering 41). 93 has the case of "the
same theme with another volume": its autorun asks for `jackalstg2` at 50 and,
midway through the scene, at 80. The night forest ones (`nightbg` at 40 and tempo
80, maps 218–222, and at 50/50 in 108) aren't in the cartridge.

**Nobody uses the balance**: the only `PlayBGM` with a balance other than
50 is an `(OFF)` in map 128.

## What was done

- **The bytecode**: `OP_BGM` carries, besides the theme, the gain of each side
  in 128ths and the tempo step in 256ths (`events.toml`). The calculations
  are in a single place, the event compiler's `bgm_level`, with the above
  in its comment: volume squared, balance with the 6 dB curve
  (the cheap approximation: the stream already baked in each voice's pan), tempo
  clamped to 50–150.
- **The level** is those four bytes, in far RAM: the requested one
  (`BGM_ASK`), the playing one (`BGM_NOW`), the one from before the battle and the
  `MemorizeBGM` one. `music_play` applies the request with `bgm_level_set`
  (`bgm_level.s`, outside bank 0): with the same theme it only changes the level,
  and with another it starts it at that level. `music_start` —the title, the loaded
  game, a map's own theme— starts it as written.
- **Without MSU-1, the volume** scales the `VOL_L`/`VOL_R` of each music
  voice with the PPU's multiplier, same as the fade and on top of it
  (`song_gain_scale`). The sound effects aren't touched. If the theme continues
  with another volume, `GAIN_DIRTY` asks `irq_music` to rewrite all
  the voices on the next frame.
- **Without MSU-1, the tempo**: `music_tempo` adds the step into an accumulator and
  runs one music frame per whole unit. At 100 it's exactly what it was
  before; at 150, two frames every two; the pitch doesn't change.
- **With MSU-1, the volume** is the track's: `MSU_VOLUME_MAX` times the
  loudest side (`MSU_BASE`), used by `msu_start`, the fade and the `PlayBGM`
  that lowers the continuing theme. **The tempo is ignored with MSU-1**: a PCM track
  doesn't change speed without changing pitch. The expensive option, one track
  per tempo, would today be a single one —`Kfmus5` at 110, whose track, 100, weighs
  25.8 MB—: some 23 MB more for a theme that goes 10% faster. 
  `decisions/first-the-whole-game-then-the-quality.md` applies. There's no
  balance in the MSU-1 either: it takes the loudest side.
- **The battle** saves the map's level and restores it on returning; its theme and the
  victory one go as written (the LDB says 100, 100 and 50). And
  `MemorizeBGM` remembers the level with the theme, like RM2k.

## The tests

Seen red before the fix, with the new bytecode and the `op_bgm` that
only skipped the four bytes:

- `rpgmaker/test_volume_and_tempo.py`, with three new cases
  (`song-a-volume-50`, `song-a-tempo-150`, `song-that-low`):
  - at volume 50, each `VOL` that reaches `dsp_music` is a quarter of what
    the stream wrote. Red: "el registro $00 quedó en 33 y el stream le
    escribió 33: tenía que quedar en 8";
  - at tempo 150, in 120 video frames 180 music frames run. Red: "corrieron
    120";
  - the same theme at 100 and then at 50 doesn't restart and the voices go down without
    waiting for their next note. Red: "el registro $00 quedó en 45 … tenía que
    quedar en 11".
- `abl/test_msu.py::test_with_msu_the_volume_of_a_song_that_goes_on_lowers_the_track`:
  with the tracks, `song-that-low` against `song-requested-two-times`, the same
  audio after the second `PlayBGM`; the amplitude has to end up at a
  quarter. Red: "dejó la pista a 1.00".
- `cargo test -p rm2k-snes-events`: `a_play_bgms_level_in_the_consoles_units`.
  **Two hashes in `tests/python.json` change** —`scan.maps` and
  `compile.maps`—, on purpose: measured with both compilers over the
  small game, the only thing that changes is the four new bytes after each
  `OP_BGM` (128, 128, 0, 1: all its `PlayBGM`s go as written) and
  the jump destinations that come after, shifted by 4.

`test_music_ceilings.py` passed: with everything at 100 the mix is the same, and a
`PlayBGM` can only lower it.

## What's left

- **A map's own theme and the title's don't use their level.** The map
  tree carries volume for some maps' music (`worlds5` at 70,
  `MML2_MotherZone` at 80, `Turrican_1_-_Loader` at 50…, in 18 maps), and the
  LDB says the title's goes at 90 and **at tempo 130**. Both go through
  `music_start`, which plays them as written. The title's, moreover,
  is how `test_music_writes.py` and the ceiling measurement play the
  themes: applying its level changes those two.
- A map whose theme is the one already playing doesn't change its level (RM2k does:
  `Game_Map::PlayBgm` goes through `BgmPlay` with the map's volume).
- **The level doesn't travel in the saved game**: on loading, the theme plays
  as written. Adding it changes the SRAM format.
- With MSU-1, the sound effects that use voices 0 to 5 restore on finishing the
  stream's volume without the gain (`se_extras_before`, which didn't apply
  the fade either). With MSU-1 every theme has a track and the SPC700 doesn't play
  music, so it shouldn't be heard.
- `ChangeSystemBGM` is still not done, from before.

## To listen

`/shared/audio/2026-09-30-volumen-y-tempo/`, with its `LEEME.txt`: map 93
(`jackalstg2` at 50 and then at 80, without restarting) and entering 41 from
37 (`Kfmus5` at tempo 110), before and after, with MSU-1 and without. Measured
over the recordings: 93 ends up at a quarter and at 0.64 of what it was, and
with MSU-1 `Kfmus5` comes out the same as before, on purpose.

## On merging

- **Install `events` in the global** (`just -f tools/justfile install
  events`): the compiler emits the new `OP_BGM`, and with the old one the
  interpreter would read four extra bytes. `cartridge` isn't needed: only
  `tools/runtime/` changed, which the global reads from the main checkout.
- `bgm_level.s` is a new file in `tools/runtime/`, included in
  `main.s` after `remembered_place_and_song.s`.
- Far RAM: $25C6 to $25DF.
- There are no new or moved goldens, and `test_music_ceilings.py` passed.
- With `main` merged (`4a94948c`): `NO_CACHE=1 just cartridges` identical byte
  for byte to the cached one, `just tests` 919 green, `just -f
  tools/justfile test` 46, `cargo test -p rm2k-snes-events` green.
  `just space` in `release`: bank 0 from 581 to 364 B, bank 1 from 4,544 to
  4,233 B, data banks 120 of 124 as before.

## What to listen for while playing

`TF3_1_awe` in map 2 and `evilrhys` in 3 ask for 80: a bit quieter than before. In
the agency (map 93) the theme starts quiet and goes up when the guard warns about the
missile. And without MSU-1, the `Kfmus5` of 41 a bit faster.
