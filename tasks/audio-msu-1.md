---
name: "Music via MSU-1"
description: "The CD tracks that replace the synthesized music"
type: feature
status: done
---

### The MSU-1

The synthesized music sounds ugly, and the cause is measured: the demo's eight
themes share 53 KB of ARAM, so each instrument is a short, trimmed
sample. The **MSU-1** is the way out: it isn't hardware of the
console but an extension supported by the FX Pak Pro and the emulators, with the
music in PCM files next to the ROM. The theme comes from a 44.1
kHz stereo file instead of the SPC700's eight voices.

It's used by **the 21 themes that play until leaving Lashe City**, plus the
title's: `PISTAS_MSU` in `snes_music.py` says which have a track and with what
number, and the converter emits `tema_msu`, one byte per theme —`$FF` for the one that
has none—. The whole game's are 43, ninety-one minutes, 923 MB of PCM;
they go in the day there is a ROM that plays them. Carrying all of them matters
because a theme without a track plays through the SPC700, and there it can lose from 28% to 88%
of its notes: see "Several themes in the cartridge". **The numbers 1 to 8 never
move**: they are the ones already on the card, and renumbering them would force
renaming files.

Two of the themes **belong to no map** and so they escape any
sweep of `PlayBGM`: they come from the LDB. `title_music` is the title
screen's and `battle_music` the one for **all** battles —`T_VGFighterMAX_Masako`—.

They cost 10.6 MB per minute, that is about **423 MB per cartridge** for the 21. And
there's no shortcut through the loop: of the 21 the only one that repeats exactly at the half is
`C3classi`, measured note by note over the two halves of the MIDI, and it's 8.6 MB
of 423.

How it works, on the ROM side:

* **The signature is checked once, at reset** (`msu_detectar`): "S-MSU1" at
  `$2002..$2007`. If it's not there —that is, whenever there's no MSU-1— `MSU_HAY` stays
  at zero and **nothing else of the system turns on**: the music keeps coming from the
  SPC700 as before all this. That is the property that matters, because the
  ROM has to work the same on a console without a prepared card.
* **`PlayBGM` tries the track first** (`msu_arrancar`): it waits for the
  MSU-1 to be free, writes the number, waits for it to finish loading it, and if
  the MSU-1 says the track isn't on the card it returns without doing anything and
  the SPC700 plays. With a track, instead, the SPC700 **goes silent**:
  `music_apagada` and a `KOF` of the eight voices. Sound effects stay on the
  SPC700, so the ARAM is left free for them.
* **The wait on `AUDIO_BUSY` is a path no emulator executes**, and
  it's worth knowing before touching it. bsnes never sets `io.audioBusy` —it starts
  false in `power()` and is not written anywhere:
  `bsnes/sfc/coprocessor/msu1/msu1.cpp`—, so in the whole suite and in all
  the state tests the loop exits on the first iteration. On the FX Pak the
  track comes from the SD card and opening it takes real time. In the same
  file is the reason for waiting **before** writing and not only after:
  `case 0x2007: if(io.audioBusy) break;`, that is, with `AUDIO_BUSY` set the
  hardware **ignores** writes to the audio registers, and a `PlayBGM`
  that arrives while the previous track is still opening is lost entirely. With a
  title screen that happens: two tracks are requested 1.8 s apart.
  The wait's ceiling is `$FFFF` iterations, about three tenths of a second, and
  falling short costs not a frame but the whole theme.
* **`FadeOutBGM` lowers the MSU-1's volume**, not the DSP's: the fade
  level already goes from 255 to 0, which is exactly the scale of `$2006`, and on reaching
  zero the track is cut. The DSP's volume isn't touched **because it's the one
  the sound effects hear**: lowering it in the fade left them mute until
  the next `PlayBGM`, which is the only one that restores it. And the command has
  to be allowed to start with `music_apagada` set, which with a track is 1: without
  that a `FadeOutBGM` did nothing and the track went on forever.
* **The DSP has to be set up anyway**, even if the music doesn't use it. The
  start of the stream did it —taking it out of the mute the SPC700 starts with, the
  master volume, and where the sample directory is— and with a track the
  stream never runs. Without that the sound effects fire against a
  mute DSP, and the symptom is music via MSU-1 and **no effects**.
  The prologue comes from `dsp_init_reg`/`dsp_init_val`, which the converter emits from
  `init_writes`, that is, from the same list the stream already wrote; copying it
  by hand into the 65816 would be two sides that can be wrong in the same way. KON and KOF
  are left out: with a track, KOF is left at `$FF` so the music's voices don't
  sound, and `se_despues` clears it by itself when starting an effect.

* **The track doesn't play at full level, and that's not caution: it's arithmetic.** The MSU-1
  is **added** to the SPC700's output instead of being mixed with it, so a
  music that reaches the ceiling leaves no room for a sound effect. With the
  volume at `$FF`, in the opening, 42 samples reached the top —all 42 in
  frames with an effect playing— while the same run through the SPC700 doesn't
  clip once; and the music via track peaked at 28933 against 23867, that is
  1.21 times louder, which is the same thing heard the other way round: "the effects sound
  much quieter". `MSU_VOLUMEN_MAX` is `$D8` —that 0.85— and with it the clipping
  goes to zero and the music sits at 24508, next to the SPC700's 23867. It goes
  in the register and not in the tracks: normalizing them lower would mean redoing all
  the cartridge's PCMs, and would lose the level reference between one theme and another.
  The fade scales against that ceiling and not against 255, or its first frame
  **would raise** the music before lowering it.

And on the cartridge side, `tools/audio/msu.py` (recipe `msu`): it renders the MIDI
with fluidsynth and **with the same soundfont the game sounded with on the PC**
—the one `snes_samples.py` already uses to extract the samples—, so the
arrangement doesn't change: what changes is that it doesn't have to be reduced to eight voices. The track is "MSU1", the
loop point in samples, and the raw audio.

And running the recipe again redoes nothing: a track doesn't depend on the
cartridge but on the MIDI, the soundfont, fluidsynth and how it's normalized, and
all of that is in the key. What's stored in `rom/build/cache/msu/` is the
sha256 of the `.pcm`, not the `.pcm`, because the file is already written next to
the ROM.

One more thing on the cartridge side: **the track is normalized to 0.97 of the
scale**. fluidsynth is run low, at 0.6, because at 1.0 the themes with many
voices saturate, and without normalizing afterwards the track comes out at a quarter of the volume of
the SPC700's music —peak 4632 against 17012— and changing from one theme to another gives
a jump.

How it's verified, because the suite doesn't listen: first the protocol alone, with
a separate minimal ROM that requests the track and leaves the registers in RAM —the
signature, the status before and after, and how many iterations it took to load—. And then
the real ROM, running 1800 frames with the libretro core and recording
the output:

* **the level**: peaks from 17096 to 20118 in the 300-frame windows, against
  the 17012 of the SPC700's music;
* **that that track plays and nothing else**: the energy envelope of the recorded
  audio against that of the rendered WAV gives a correlation of **0.927 with zero
  lag**;
* **the fade**: patching in the `FadeOutBGM` request, the track is cut at
  84 frames and the peak drops 19059 → 3464 → 0.

**And the sound effects have to be isolated, because the music covers them.**
The way that works is the same ROM with the two volume bytes of each row of
`sonido_tabla` set to zero, and comparing the two outputs sample by sample:
what differs **is** the effects. That's how it was proven that the DSP prologue is what
makes them sound with a track: with the prologue in place 714382 samples of
1027098 differ from frame 212 on, and with a `$FF` in the first byte of `dsp_init_reg`
—which disables it— **zero** differ.

And the whole suite stays green **without** the MSU-1 files, which is the
path any test here takes.

## Pending

What's missing: the loop point. The MSU-1 goes back to the start of the file, so
a theme with an introduction repeats it on every loop; today they loop whole. And the
themes the demos don't play.

## Compatibility

The MSU-1 is emulated correctly in:
- FxPak, on real SNES
- snes9x
- Mesen

And not in:
- Mednafen
