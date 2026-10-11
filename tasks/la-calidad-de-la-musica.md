---
name: "The quality of the music"
description: "Why escape_newyork sounds bad through the SPC700, eleven versions recorded to compare, and in what order to fix it"
type: feature
status: done
---

**What taro chose by listening, on 2026-09-25**: what matters most to him, and
by a lot, is **the voice allocation** (variant 09 "is very acceptable"); then
**the envelopes**; then **the drums**; and **the samples at 22 kHz** make a
noticeable difference but matter less. He wants **all of them together**,
knowing that even so the difference with the reference will be noticeable
(that is what the MSU-1 is for).

The order of implementation is not that of his priorities, because of space:
the allocation adds +74% of stream in today's format (~436 KB, the whole
margin of the merged cartridge). So: drums → notes released early → envelopes
→ velocity and CC → **the per-note format, designed for everything above and
for the allocation** → allocation and ramp → samples per map. **0, 1 and 2
done**, on 2026-09-25, **and 3, 4 and 5** on 2026-09-26: see each one below.
After 5, the same day: **5b**, the battle phrase the allocation cut, and **the
air per theme** (option B, at the end of 5). **And 6**, the same day:
measured, prototyped, decided by taro (option A) and implemented entirely, with
the startup lowered to 40 frames. With that all the steps of the plan are
there: what is left are details, in "What is left of the quality of the
music", at the end of 6.


taro, on 2026-09-25: *"`escape_newyork` sounds particularly bad, and maybe
including the envelopes improves it a lot. And there are notes that cut off
very abruptly."* This is the investigation: **the diagnosis, eleven versions of
the theme recorded coming out of the ROM, and the plan**. Nothing is merged.

* The recordings and what changed in each one:
  `/shared/audio/2026-09-25-escape-newyork/` and its `LEEME.txt`.
* The prototypes: local branch `proto-calidad-musica` (commit `0067f7c`), **not
  to be merged**. `tools/audio/proto_musica.py` builds each variant according
  to `PROTO_MUSICA`; `tools/audio/proto/` has how each one was built, recorded
  and measured.

The numbers below are from 2026-09-25, on `9602035`, with the 22 themes of
`release`: the scripts that measured them are on that branch, and before
implementing they have to be run again.

# The diagnosis

## The drums do not play, in any theme: it is a bug

`dsp_musica` (`rom/src/efectos_de_sonido.s`) receives the value in B, and the
`rep #$20` / `and #$000F` with which it builds the shadow's index sets it to
zero: **every write of the music to voices 6 and 7 reaches the DSP as zero**.
Those two are the percussion ones (`DRUM_VOICES`, and also the sound effects').
Recording the ROM with a drums-only stream gives silence from start to finish;
with the fix, it plays.

`git blame`: voice 7 since `854dba96` (2026-09-11, the music in the IRQ), 6
since `8c9c182e` (2026-09-24, the second sound effects voice). That is, since
yesterday no drum voice plays, and before that half did not play. Nothing
caught it because no test looks at the music's audio.

The fix, three lines per voice, is in the prototype: saving the value on the
stack before the `rep` (`xba` / `pha` / `xba`) and taking it out with `pla`
instead of the `xba` that follows the `sep`.

## Half of what the MIDI plays is lost

`escape_newyork`: 195 s, 2,660 notes, nine channels, 80 quarter notes per
minute. The polyphony it asks for goes from 8 to 12 almost all the time, with
peaks of 20, against 8 voices. Today's allocation (`assign`) gives **one fixed
voice to each melodic channel** and two to the drums:

| Channel | Program | Asks for at once | Has |
|---|---|---:|---:|
| 2 | strings (48), 3-note chords of 12 s, velocity 29 | 3 | 1 |
| 4 | polysynth (90), chords | up to 6 | 1 |
| 0 | piano (0) | 2 | 1 |
| 3 | synth bass (38), 6-frame notes in octaves | 2 | 1 |
| 6 | polysynth (90) | 2 | 1 |
| 1 | saw (81), the bass line | 1 | 1 |
| 5 | clavinet (7) | 2 | **0** |
| 7 | square wave (80) | 1–3 | **0** |
| 9 | drums | 3 | 2 |

**55% of the note-time** is lost: 6% from channels without a voice and 50% from
notes that lose their voice. With 8 voices the floor is 23% —what goes over 8
at once—. When a chord starts on a single frame on one voice, the three setups
overwrite each other and the last one plays: 864 notes.

## The hard cuts

Every steal of a voice that is playing is a `KON`, which sets the envelope to
zero at once: a click. Today there are **204 notes cut while playing**,
**~1,100 release tails cut** on reusing the voice, and the **329 notes released
early** of `notas-que-se-sueltan-antes-de-tiempo.md`. It is what best explains
"notes that cut off very abruptly".

## The samples, at 4-8 kHz

The bank is shared by the 22 themes and the melodic part has 40 KB: the piano
ends up at 6 kHz, the strings at 5.5, the saw at 6.1, the polysynth at 8.4,
against the SoundFont's 22 kHz. And each program carries **a single sample,
the one of the middle C zone**: the bass line with saw (notes 24 to 40) plays
`SAW0_60` two octaves down, with less than 1 kHz of bandwidth, when the SF2
brings `SAW0_48` for that zone. It is what dulls the sound the most: see the
measurement below.

## What the MIDI does not have

No pitch bend, no panning, no expression, no reverb or chorus: only CC7 in the
last 20 s, for the final fade. The fluidsynth reference comes out dry, same as
the ROM, so the DSP's echo is not what is missing here.

## Envelopes and volume

The families of `sdsp.py` are not that far from the SF2. What differs most:
the synth bass and the saw are released in 25–30 ms in the SF2 and in the ROM
drag tails of 2.4 s (GAIN 14); the piano drops to 50% in 110 ms instead of
dying out in some six seconds.

The velocity is converted linearly, and fluidsynth attenuates 40·log10(127/v)
dB —squared—. The strings at velocity 29 end up 26 dB down in the reference and
13 dB in the ROM: the mix comes out shifted towards the pads.

**The SF2's attenuator and the samples' peak change nothing here**: measured,
the theme's seven programs and drum hits are normalised from the factory and
their initial attenuation is ~0.

# The recorded variants

Eleven, in `/shared/audio/2026-09-25-escape-newyork/`. From 02 to 08 each one
adds a change over the previous one, in the order they would be done; 09 and
10 isolate the two that weigh the most. How they were recorded —the title
screen playing the theme, snes9x, without MSU-1, with nothing else on top, the
whole theme— is in the `LEEME.txt`.

| # | What it adds | Theme's stream | The 22 themes |
|---|---|---:|---:|
| 00 | reference: fluidsynth + the SF2 | | |
| 01 | today's ROM | 34,329 | 626,319 |
| 02 | the drums (the `dsp_musica` fix) | +0 | +0 |
| 03 | not releasing the one that stole; without a sample it takes no voice | −1,760 | −71,072 |
| 04 | the SF2's envelopes, and air in the mix | +624 | +10,011 |
| 05 | fluidsynth's velocity curve, CC7/10/11 | +48 | +22,086 |
| 06 | allocation of the 8 voices in a single group | +16,391 | +436,356 |
| 07 | 12 ms ramp before reusing a voice that is playing | +4,814 | +124,146 |
| 08 | bank with only this theme, at 22 kHz | −93 | (does not apply) |
| 09 | only the allocation, on top of 03 | +15,837 over 02 | +371,719 |
| 10 | only the bank at 22 kHz, on top of 02 | −1,131 | (does not apply) |

"Air" is lowering each voice's ceiling by 20% and raising `MASTER` from `$60`
to `$78`: with the drums playing and the SF2's sustains, the sum of the voices
saturated the DSP, which clips before the master volume —1,000 clipped samples
in 04 without this; with this, fewer than 100 in all of them—.

The mean spectral difference against the reference (24 bands, 0.25 s windows),
which guides and does not replace the ear: 7.8 dB today's ROM, 7.2 with
envelopes and volume, 6.3 with the allocation, **4.2 with everything and the
samples at 22 kHz**; the rate alone lowers the highs from 9 dB to 5, and the
allocation alone, the lows and mids.

# What I would do, in what order, and how much it costs

## 0. The `dsp_musica` fix: done

Done on 2026-09-25, in `1d8a2ba`. It is not the prototype's: the shadow's index
is built with X in eight bits (`sep #$10` / `tax` / `rep #$10`) and A is not
widened, so B is not touched; it comes out three bytes shorter per voice and
overwrites the high part of Y, which `music_frame` does not use.
`pruebas/rpgmaker/test_bateria_suena.py` enforces it: it plays the title's
theme and requires the shadow of voices 6 and 7 to have what the stream writes
to them, with volume and pitch other than zero. Without the fix it goes red.

In passing: **the shadow is not initialised**, so before the music's first
write it has whatever WRAM had ($55 in snes9x). If a sound effect ends before
the music has written to its voice, that garbage is given back to the DSP.
Pending, small.

**The saturation, with only the fix** (without touching the mix). How it was
measured: the `release` of `1d8a2ba` with the `lda #TEMA_TITULO` of `titulo.s`
patched in the ROM to each theme —that way each one plays alone, with its
samples uploaded by `tema_asegurar`; it was checked that none is missing—,
snes9x, without MSU-1, the whole stream once, counting the samples of the
core's audio (L+R) at the ceiling. **The ceiling is not 32767 but 24575**: the
DSP clips the sum of the voices to 16 bits and only then multiplies by
`MASTER` (`$60`), so audio that reaches ±24575 is clipped. The script is
throwaway; measure again before fixing the air.

| Theme | Without the fix | With the fix |
|---|---:|---:|
| T_VGFighterMAX_Masako (battle) | 168,213 | 309,040 |
| hzbreach | 70,186 | 146,578 |
| TF3_1_awe | 60,996 | 110,894 |
| hzstream | 6,370 | 57,672 |
| rshinld | 2,876 | 10,344 |
| evilrhys | 148 | 6,920 |
| Lunar_Pyramid | 0 | 4,574 |
| 3D-Galax | 0 | 3,404 |
| lufsorr | 268 | 2,336 |
| cd4 | 102 | 1,036 |
| cd2 | 0 | 894 |
| Astpgmarch | 24 | 858 |
| Fantasia_Of_The_Wind (title) | 2 | 542 |
| wb3shop | 0 | 382 |
| escape_newyork | 0 | 140 |
| C3classi | 0 | 112 |
| wb3mlair, Gaden, KSSMKEND, vswar, dcbest, golden_axe-turtlevillage2 | 0 | 0 |

That is: **16 of the 22 themes clip with the drums back**, and three already
clipped heavily without them —the battle one the most—, so the air of step 2 is
not only because of the drums. `golden_axe-turtlevillage2` is all percussion:
without the fix its peak was 0, complete silence. `dcbest` has no drums and is
the same in both.

## 1. The notes released early: done

Done on 2026-09-25 (commit "Música: una nota robada no suelta a la que le robó
la voz"). The release is scheduled at the end of `build_events`, only for the
notes that reach their end still owning the voice, and it does not go when the
voice is reused on the same frame the note ends; and a note without a sample no
longer takes a voice.

**What stopped happening**, counted with the old logic on the same inputs:
**564 notes and 14,486 frames** were released before their end in the 22
themes —341 of `escape_newyork` (the prototype counted 329 stolen notes; here
the ones that were released are counted), 168 of `cd4`, 31 of
`Fantasia_Of_The_Wind`, 19 of `3D-Galax` and 5 among `hzstream`, `TF3_1_awe`
and `hzbreach`—, and **11,024 notes without a sample** took a voice in the nine
themes that do not contribute to the bank. **The stream of the 22 went down
from 626,319 to 555,247 B (−11.3%)**, same as in the prototype. The saturation
barely changed. `pruebas/herramientas/test_musica_stream.py` enforces it.

## 2. Envelopes from the SoundFont, with air: done, with more air than planned

Done on 2026-09-25 (commit "Música: las envolventes salen del SoundFont, y la
mezcla tiene aire"):

* **`gunter sf2 --extract --json` returns the zone's envelope**, generators 33
  to 40, already resolved —the instrument's plus the preset's, with the
  specification's defaults and caps— and in the SF2's units. **`just
  herramientas` has to be run**: the converter refuses, with that message,
  with an earlier `gunter`.
* `sdsp.envelope` translates it to ADSR1, ADSR2 and the release GAIN, with the
  two things the recording showed —linear release below 100 ms, and the
  exponential drop to zero where the SF2 is around -40 dB—. It gives exactly
  the same as the prototype in 3,456 combinations of program and key —the
  programs the SF2 has, one key out of every three between 20 and 98—. The
  eight families of `sdsp.py` are gone.
* **The air**: with 0.8 and MASTER at `$78`, what the prototype proposed, the
  16 themes kept clipping —hzbreach 107,218 samples, the battle 59,982—: the
  prototype had measured it on `escape_newyork`, which is one of those that
  clip the least. It ended up at **0.5**: a ceiling of 48 per voice and 42 for
  the percussion, MASTER at `$7F`, which is the register's cap. The sound
  effects lower their ceiling by the same amount MASTER went up and sound the
  same as before.

**How it was measured** —the same method as in point 0—: the `release` with
the `lda #TEMA_TITULO` of `titulo.s` patched to each theme, snes9x without
MSU-1, the whole stream once, counting the samples of the core's audio (L+R) at
the ceiling, which is `32767·MASTER/128` —24,575 with `$60`, 30,719 with
`$78`, 32,511 with `$7F`—. Integrated LUFS with ffmpeg's `ebur128` on the same
recording. The scripts, throwaway, in the session's scratchpad
(`audio-pasos-1-2/sat.py`).

| Theme | Stream today | Step 1 | Step 2 | Clips today | Step 1 | Air 0.8 | Step 2 (0.5) | Peak today → step 2 | LUFS today → step 2 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| hzstream | 13,042 | 11,990 | 11,999 | 57,672 | 58,114 | 34,718 | 36 | -2.5 → -0.1 | -7.6 → -9.6 |
| escape_newyork | 34,329 | 32,569 | 33,193 | 140 | 108 | 190 | 0 | -2.5 → -2.6 | -15.6 → -17.3 |
| TF3_1_awe | 23,444 | 21,546 | 21,546 | 110,894 | 113,112 | 78,030 | 468 | -2.5 → -0.1 | -7.1 → -9.0 |
| T_VGFighterMAX_Masako | 156,304 | 147,088 | 148,312 | 309,040 | 311,370 | 59,982 | 70 | -2.5 → -0.1 | -6.6 → -10.7 |
| evilrhys | 36,338 | 35,126 | 35,876 | 6,920 | 6,864 | 4,314 | 0 | -2.5 → -0.5 | -11.0 → -13.6 |
| lufsorr | 16,161 | 10,533 | 11,529 | 2,336 | 2,346 | 2,202 | 0 | -2.5 → -0.4 | -11.2 → -12.6 |
| cd4 | 50,885 | 43,087 | 45,886 | 1,036 | 914 | 208 | 0 | -2.5 → -3.4 | -14.4 → -17.4 |
| C3classi | 33,498 | 26,532 | 27,537 | 112 | 100 | 38 | 0 | -2.5 → -3.7 | -14.8 → -15.9 |
| rshinld | 12,272 | 7,274 | 7,406 | 10,344 | 10,566 | 9,372 | 4 | -2.5 → -0.1 | -10.6 → -12.1 |
| cd2 | 30,461 | 29,225 | 29,261 | 894 | 892 | 348 | 0 | -2.5 → -2.7 | -12.5 → -15.0 |
| hzbreach | 30,758 | 29,620 | 29,626 | 146,578 | 148,166 | 107,218 | 858 | -2.5 → -0.1 | -6.8 → -8.6 |
| wb3mlair | 9,117 | 7,335 | 7,497 | 0 | 0 | 0 | 0 | -4.8 → -6.2 | -22.2 → -22.2 |
| Astpgmarch | 6,521 | 6,350 | 6,527 | 858 | 834 | 850 | 0 | -2.5 → -1.9 | -10.7 → -14.0 |
| Gaden | 7,271 | 5,357 | 5,639 | 0 | 0 | 0 | 0 | -7.5 → -12.7 | -19.0 → -23.0 |
| 3D-Galax | 60,346 | 49,146 | 49,080 | 3,404 | 3,490 | 1,022 | 0 | -2.5 → -2.3 | -14.7 → -16.9 |
| wb3shop | 9,916 | 9,046 | 9,046 | 382 | 368 | 422 | 0 | -2.5 → -3.0 | -16.9 → -19.2 |
| KSSMKEND | 12,942 | 10,980 | 10,980 | 0 | 0 | 0 | 0 | -6.1 → -9.0 | -22.2 → -23.7 |
| vswar | 21,289 | 20,536 | 20,536 | 0 | 0 | 0 | 0 | -3.7 → -5.3 | -15.1 → -16.9 |
| Lunar_Pyramid | 37,190 | 32,792 | 32,792 | 4,574 | 4,304 | 498 | 0 | -2.5 → -3.0 | -13.4 → -15.5 |
| dcbest | 5,017 | 5,017 | 5,017 | 0 | 0 | 0 | 0 | -7.7 → -10.5 | -20.8 → -21.1 |
| golden_axe-turtlevillage2 | 831 | 831 | 831 | 0 | 0 | 0 | 0 | -7.4 → -11.1 | -17.0 → -20.7 |
| Fantasia_Of_The_Wind | 18,387 | 13,267 | 14,902 | 542 | 592 | 2,018 | 0 | -2.5 → -0.6 | -12.1 → -13.1 |
| **The 22** | 626,319 | 555,247 | 565,018 | 655,726 | 662,140 | 301,430 | 1,436 | | |


**What the air costs**: where it did not clip before, the level goes down
20·log10(0.5·127/96) = −3.6 dB —`escape_newyork` from -15.6 to -17.3 LUFS, with
the new envelopes in between—. The ones that clipped go down more, but what
they lost was distortion: the battle, from -6.6 to -10.7 LUFS. Five clip, at
most 858 samples out of 6.3 million (hzbreach).

**What could not be done with a global number**: zero clips in all of them
without lowering the level. Measuring the true peak of each theme with the
ceiling at a quarter —24 and 21, without clips in any— and scaling, for none
to clip the global ceiling has to be 1.56 times that quarter (hzbreach),
against today's 2: another −2.2 dB for everyone. A ceiling per theme would
leave the calm ones where they are, but the peak cannot be estimated from the
stream: against the sum of the voices' volumes, the ratio varies from 85 to 135
among the dense themes, so the rule needs a margin that eats what it gains.
What would work is a measured table of ceilings, which would have to be
measured again with each change of the mix —the velocity curve of 3, the
allocation of 5—. It was not done: it is a decision for after 5.

**Stream**: +9,771 B over step 1 (+1.8%), as expected: the piano changes ADSR2
per key. `test_musica_stream.py` enforces it, with the real SF2: the synth
bass's release and the piano's decay per key.

**To listen**: `/shared/audio/2026-09-25-pasos-1-y-2/`, with its `LEEME.txt`.

## 3. Velocity curve and controllers: done

Done on 2026-09-26 (commit "Música: la velocidad al cuadrado, y los
controladores del MIDI"). Measured on `55098bd`, with today's `release`, which
has **32 themes** and not the 22 of the tables above: the ten new ones go at
the end of the table.

**The curve**, measured with fluidsynth and the SF2 —a single note, RMS,
against velocity 127—: the velocity drops exactly 40·log10(127/v) dB (64 gives
-11.9; 29, -25.7). CC7 and CC11 the same, each one —CC7 measured against 100,
its GM value, so a channel at 127 sounds **+4 dB**—; the panning is sine and
cosine with the centre at -3 dB from a full pan (0 gives +3.0 dB and silence;
32, +2.3 and -5.3). That is how `sdsp.volume` ended up; the floor went down
from 4 to 2.

**What went in** —`midi.py` no longer drops them; see its header—:

* **CC7, CC11 and CC10**, to the note that starts and to the one already
  playing (also in its tail). There are 3,851 CC7 in 25 themes, 1,532 CC10 in
  21, 4,427 CC11 in three (`vswar`, `3D-Galax`, `Fire_Mustang`).
* **The pitch bend**, with the range of RPN 0 (CC101 and CC100 at zero, and
  CC6/CC38). Three themes really use it: `3D-Galax` (194, the melody's saw,
  116 with the note playing), `dcbest` (396 in the bass, almost all **between**
  notes: they detune the next one, up to 1.2 semitones) and `vswar` (445 on
  channel 13, which has no voice: it does not play). It went in because it
  costs **2,270 B** in the 32 themes and the pitch at the note's start is free.
  `3D-Galax` asks for a range of **95 semitones**; fluidsynth respects it
  (measured: the drop reaches -20.6 semitones) and a GS synthesiser caps it at
  24. fluidsynth was followed, as it is the reference and where the MSU-1 track
  comes from: if it sounds odd, it is the first thing to look at. A CC101
  without its CC100 does not select the RPN —measured; it is `dcbest`'s case,
  which stays at 2—.
* **The pedal (CC64)**, which is not a stream event: it lengthens the notes
  released with the pedal down. The title (`Fantasia_Of_The_Wind`, 38, the
  piano) and `pn28year` (606) use it. It **lowers** the stream by 5,481 B,
  because a note sustained until another steals it no longer writes its
  release.

**What did not go in**, and who uses it:

* **Modulation (CC1)**: only `Tnt07` for real (392); `vswar` and `11h035` send
  it at 0. It is the SF2's vibrato, that is, a pitch write per frame while it
  plays, or an LFO in the driver. Noted for the format.
* **Reverb and chorus (CC91, CC93)**: in 13 themes, almost always a fixed value
  at the start. The reference comes out dry (`-R 0 -C 0`) and the DSP's echo is
  off: it goes with the echo, if it is ever turned on.
* **The AWE32 NRPNs** of `TF3_1_awe` (4,134, MSB 127): the filter's cutoff and
  resonance, which the DSP does not have.
* **Aftertouch**: no theme uses it.
* **The SF2's per-key panning** —the hi-hat to one side, the kick in the
  centre—: `gunter` does not return generator 17. The drums play in the centre
  except for their channel's CC10.
* **Program changes in the middle of the theme**, which were already ignored
  (the first one of each channel counts): `hzbreach`, `Astpgmarch` and
  `bubstix`.

**Stream bytes**, before → after, and **saturation** —samples at the ceiling,
L+R, with step 2's method and **the same air**: 0.5 and MASTER `$7F`—, with
peak (dBFS) and integrated LUFS:

| Theme | Stream before | Step 3 | Clips before | Step 3 | Peak | LUFS |
|---|---:|---:|---:|---:|---:|---:|
| hzstream | 11,999 | 11,999 | 36 | 36 | -0.1 → -0.1 | -9.6 → -9.6 |
| escape_newyork | 33,193 | 33,235 | 0 | 0 | -2.6 → -5.4 | -17.3 → -20.7 |
| TF3_1_awe | 21,546 | 30,054 | 460 | 0 | -0.1 → -1.8 | -9.0 → -13.4 |
| T_VGFighterMAX_Masako | 148,312 | 148,312 | 70 | 290 | -0.1 → -0.1 | -10.7 → -10.3 |
| evilrhys | 35,876 | 35,882 | 0 | 232 | -0.5 → -0.1 | -13.6 → -11.1 |
| lufsorr | 11,529 | 12,231 | 0 | 0 | -0.4 → -2.4 | -12.6 → -15.0 |
| cd4 | 45,886 | 45,799 | 0 | 0 | -3.4 → -3.7 | -17.4 → -17.9 |
| C3classi | 27,537 | 27,537 | 0 | 0 | -3.7 → -3.6 | -15.9 → -16.6 |
| rshinld | 7,406 | 8,906 | 0 | **4,552** | -0.1 → -0.1 | -12.1 → -8.7 |
| cd2 | 29,261 | 29,255 | 0 | 0 | -2.7 → -4.1 | -15.0 → -16.7 |
| hzbreach | 29,626 | 29,626 | 816 | 834 | -0.1 → -0.1 | -8.6 → -8.6 |
| wb3mlair | 7,497 | 7,497 | 0 | 0 | -6.2 → -9.3 | -22.2 → -24.7 |
| Astpgmarch | 6,527 | 6,527 | 0 | 0 | -1.9 → -1.7 | -14.0 → -14.0 |
| Gaden | 5,639 | 5,639 | 0 | 0 | -12.7 → -17.9 | -23.0 → -31.3 |
| 3D-Galax | 49,080 | 52,615 | 0 | 166 | -2.3 → -0.1 | -16.9 → -13.9 |
| wb3shop | 9,046 | 9,046 | 0 | 0 | -3.0 → -5.1 | -19.2 → -21.3 |
| KSSMKEND | 10,980 | 10,980 | 0 | 0 | -9.0 → -10.9 | -23.7 → -24.7 |
| vswar | 20,536 | 26,345 | 0 | 0 | -5.3 → -6.8 | -16.9 → -20.3 |
| Lunar_Pyramid | 32,792 | 32,792 | 0 | 0 | -3.0 → -0.3 | -15.5 → -14.1 |
| dcbest | 5,017 | 6,594 | 0 | 0 | -10.5 → -6.3 | -21.1 → -17.0 |
| golden_axe-turtlevillage2 | 831 | 831 | 0 | 0 | -11.2 → -8.2 | -20.7 → -17.7 |
| Fantasia_Of_The_Wind | 14,902 | 14,545 | 0 | 0 | -0.6 → -4.9 | -13.1 → -16.3 |
| Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco | 15,030 | 15,030 | 0 | 0 | -4.2 → -3.9 | -16.2 → -15.8 |
| bubstix | 29,988 | 29,988 | 0 | 0 | -2.3 → -3.4 | -15.8 → -17.1 |
| wb3town | 6,002 | 6,002 | 0 | 0 | -5.7 → -7.7 | -18.2 → -20.2 |
| 11h035 | 17,342 | 17,234 | 0 | 0 | -4.9 → -7.8 | -18.0 → -21.2 |
| prepara | 630 | 630 | 0 | 0 | -9.3 → -13.8 | -20.5 → -26.3 |
| T_ProjectJustice_DiscLoad | 15,819 | 15,819 | 0 | 0 | -6.5 → -7.9 | -22.9 → -24.3 |
| pn28year | 19,767 | 17,781 | 4 | 0 | -0.1 → -4.8 | -13.0 → -19.2 |
| Tnt07 | 8,299 | 8,299 | 0 | 0 | -7.5 → -9.6 | -21.8 → -23.8 |
| Deflector1 | 31,025 | 31,025 | 0 | 178 | -1.6 → -0.1 | -16.6 → -14.2 |
| MML2_MotherZone | 2,640 | 2,640 | 0 | 0 | -10.7 → -9.2 | -21.2 → -19.7 |
| **The 32** | 711,560 | 730,695 | 1,386 | 6,288 | | |
| **The 22 of the tables above** | 565,018 | 586,247 | 1,382 | 6,110 | | |

* **Stream: +19,135 B (+2.7%)** in the 32. Broken down: the curve alone −12
  B, CC7/10/11 +22,328, the bend +2,270, the pedal −5,481. The ones that change
  are those that really use CCs: `TF3_1_awe` +39% (two square waves with a CC7
  gate, 34 → 0 → 34 every ~10 frames, and panning everywhere), `dcbest` +31%
  (the bend), `vswar` +28%, `rshinld` +20%. Keeping the tails updated —the
  voices whose note was already released— costs 1,195 B of that: it is not
  worth a separate case.
* **Saturation: from 1,386 to 6,288 samples**, 4.5 times more, and almost all
  in **`rshinld` (4,552, out of 3.1 million)**: CC7 at 127 on almost all its
  channels, +4 dB over the ceiling the air assumed. The others that start to
  clip do so a little (the battle 290, `evilrhys` 232, `Deflector1` 178,
  `3D-Galax` 166), and `TF3_1_awe` stops clipping. **The air was not
  touched**, as taro asked: step 2's table of ceilings per theme had to be
  measured again after this step and 5.
* **The level** goes down in the ones with soft pads (`escape_newyork` -3.4
  LUFS, `Gaden` -8.3, `pn28year` -6.2) and goes up in the ones that ask for a
  high CC7 (`rshinld` +3.4, `dcbest` +4.1). Against the reference —fluidsynth
  with the SF2, integrated LUFS—, in the 13 themes that contribute to the bank,
  and that is why they play whole, the ROM − reference distance ends up **more
  even between themes: its deviation goes down from 2.7 dB to 1.5**. Counting
  the 22 with the mutilated ones it does not change (4.1), because there what
  does not play dominates.
* **There is stereo**: `TF3_1_awe` goes from mono to side/centre -8.8 dB.
* **The fade at the end of `escape_newyork` exists**: it goes down some 25 dB
  in the last 12 s, where before it stayed at the same level until the cut.

**It is enforced by** `pruebas/herramientas/test_musica_stream.py`: the curve,
CC7 in the middle of a note, CC7 times CC11, the panning, the bend before and
during, that a controller does not touch another channel nor the drums' pitch,
and in the reader RPN 0 and the pedal. The eight go red with the `tools/` of
`55098bd`.

**To listen**: `/shared/audio/2026-09-26-paso-3/`, with its `LEEME.txt`:
`escape_newyork`, the battle, the title (the pedal), `3D-Galax` (CC11 and the
bend), `vswar` (CC11), `rshinld` (the one that clips the most) and `TF3_1_awe`
(the stereo and the gate), before and after.

### What the stream carries after step 3: the list for the format

Everything counts per DSP voice; the amounts are from the 32 themes of
`release`, 3,741 s of music, with today's allocation.

**Per note** (50,565 notes that start):

* pitch: 14 bits, `sdsp.pitch_for(tecla + bend del canal, raíz, tasa)` —with
  the bend it is any pitch, not a key—; the drums are not transposed or
  doubled;
* sample (SRCN), ADSR1 and ADSR2: together they are "the instrument", and ADSR2
  changes per key within a program (the piano);
* left and right volume: **different in 12,056 notes (24%)**, many because of
  a pan of 60 to 63, almost in the centre. They come from five things
  —velocity, the channel's CC7, CC11 and CC10, and the melodic or drum
  ceiling—, so a format that stores the velocity per note and the channel's
  state separately rebuilds them; storing L and R already computed is what is
  done today;
* KON.

**Per release** (15,450): ADSR1 at 0 and the release GAIN, which is **per
instrument and key** —it comes from the same envelope as ADSR1 and ADSR2—, so
it can live in the instrument's table and the event be "release the voice".

**Per controller, to a voice that is already playing** —in 3,976 frames, 1.06
per second of music on average but very concentrated: `vswar` 9.3 frames per
second, `pn28year` 8.5, `TF3_1_awe` 7.6; 24 of the 32 have none—:

* **L and R volume of a voice**: 4,301. The whole pair goes: a CC changes the
  volume or the pan, and both sides are recomputed. A channel CC7 writes **all
  the voices of that channel at once**, so the worst frame is 8 voices × 2
  registers = 16 writes (`rshinld`, which has few frames with controllers —36—
  but each one touches all eight). A "channel volume" event that the driver
  applied to its voices would shrink it, but the driver would have to know
  which voice belongs to which channel, and with step 5's allocation that
  changes note by note;
* **pitch of a voice**: 563, the bends with the note playing (`dcbest` 395,
  `3D-Galax` 168). The two bytes of PITCH;
* nothing else: the expression and the volume merge into L and R, and the
  pedal comes already applied to the notes' ends.

**What it does not carry and the format might want later**: the modulation
(CC1, `Tnt07`: vibrato, that is, pitch per frame or a driver LFO), the drums'
per-key panning and the ramp of 5.

## 4. The per-note format: done

Done on 2026-09-26 (commits "Música: el stream es por nota, y el 65816 lo
expande a las mismas escrituras" and "Música: la ROM anota lo que le pide al
DSP, y una prueba lo compara cuadro a cuadro"). It is idea 1 of
`la-musica-pesa-789-kb.md`. The reason for each decision is where it lives:
"the per-note format" in `tools/audio/snes_music.py`, the header of
`tools/protocol/music.toml` and `music_frame` in `rom/src/musica.s`.

**The property that holds it up: the sequence of writes to the DSP, frame by
frame, is the one from before.** `escrituras` is what `pack` was —the
specification—, and the converter stops if a theme, decoded, does not give it.
The SPC700 did not change.

### The format

A theme is its stream and its table of **sounds**: six bytes —PITCH_L,
PITCH_H, SRCN, ADSR1, ADSR2 and the release GAIN— for each combination the
theme plays. The voice goes in the opcode's three low bits.

| Opcodes | Name | Arguments | What it writes |
|---|---|---|---|
| `$00`-`$07` | `OP_NOTE_V0`-`V7` | sound | PITCH, SRCN, ADSR1, ADSR2; KON on closing the frame |
| `$08`-`$0F` | `OP_NOTE_VOL_Vv` | volume, sound | VOL_L = VOL_R, and what `OP_NOTE` writes |
| `$10`-`$17` | `OP_NOTE_PAN_Vv` | left, right, sound | VOL_L, VOL_R, and what `OP_NOTE` writes |
| `$18`-`$1F` | `OP_RELEASE_Vv` | — | ADSR1 at 0 and the GAIN of the voice's sound |
| `$20`-`$27` | `OP_RELEASE_GAIN_Vv` | GAIN | ADSR1 at 0 and that GAIN |
| `$28`-`$2F` | `OP_SET_VOL_Vv` | volume | VOL_L = VOL_R, to a voice that is playing |
| `$30`-`$37` | `OP_SET_PAN_Vv` | left, right | VOL_L and VOL_R, to a voice that is playing |
| `$38`-`$3F` | `OP_SET_PITCH_Vv` | pitch (word) | PITCH_L and PITCH_H, to a voice that is playing |
| `$40`-`$5F` | `OP_WAIT_1`-`32` | — | closes the frame —fires the KON— and waits |
| `$60` | `OP_WAIT` | frames (word) | the same, longer; 0 fires without waiting |
| `$61` | `OP_DSP` | register, value | a raw write, not a voice one: the final KOF |
| `$62` | `OP_INIT` | — | the DSP's startup, the `dsp_init_*` table, and KON and KOF at 0 |
| `$63` | `OP_END` | — | starts over |

All voice writes go through the 65816's cache —`MUS_SOMBRA`, eight registers
per voice—, so the stream never says what does not change: a note on the same
voice and with the same volume as the previous one is **two bytes**, the family
with the voice and the sound, and it writes only what the cache does not have
—in the typical case the pitch and the ADSR1 the release had turned off—.
Before it was three bytes per write: a note like that was 9 plus its share of
the KON.

**What it is made of**, in the 32 themes of `release`: notes without volume
50%, waits 16.5%, notes with volume 11.7%, releases 7.4%, notes with pan 5.9%,
the sounds table 4.5%, volume and pitch changes to a voice that is playing 4%.
`OP_RELEASE_GAIN` is not used by any theme yet: it is there for the ramp of 5.

### Bytes

From each cartridge's `conversor.log`, which prints them per theme. Before: the
`release` of `fb12bbb`.

| Theme | Before | Stream | Sounds | After | % |
|---|---:|---:|---:|---:|---:|
| T_VGFighterMAX_Masako | 148,312 | 40,796 | 540 | 41,336 | 28% |
| 3D-Galax | 52,615 | 14,548 | 276 | 14,824 | 28% |
| cd4 | 45,799 | 12,395 | 276 | 12,671 | 28% |
| evilrhys | 35,882 | 9,648 | 624 | 10,272 | 29% |
| escape_newyork | 33,235 | 8,539 | 426 | 8,965 | 27% |
| Lunar_Pyramid | 32,792 | 7,820 | 252 | 8,072 | 25% |
| Deflector1 | 31,025 | 8,455 | 528 | 8,983 | 29% |
| TF3_1_awe | 30,054 | 9,538 | 426 | 9,964 | 33% |
| bubstix | 29,988 | 7,793 | 540 | 8,333 | 28% |
| hzbreach | 29,626 | 8,645 | 630 | 9,275 | 31% |
| cd2 | 29,255 | 6,696 | 246 | 6,942 | 24% |
| C3classi | 27,537 | 7,262 | 438 | 7,700 | 28% |
| vswar | 26,345 | 8,992 | 192 | 9,184 | 35% |
| pn28year | 17,781 | 5,364 | 264 | 5,628 | 32% |
| 11h035 | 17,234 | 4,433 | 360 | 4,793 | 28% |
| T_ProjectJustice_DiscLoad | 15,819 | 4,230 | 78 | 4,308 | 27% |
| Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco | 15,030 | 3,870 | 114 | 3,984 | 27% |
| Fantasia_Of_The_Wind | 14,545 | 3,672 | 528 | 4,200 | 29% |
| lufsorr | 12,231 | 3,002 | 330 | 3,332 | 27% |
| hzstream | 11,999 | 3,434 | 594 | 4,028 | 34% |
| KSSMKEND | 10,980 | 2,885 | 114 | 2,999 | 27% |
| wb3shop | 9,046 | 2,469 | 132 | 2,601 | 29% |
| rshinld | 8,906 | 3,040 | 402 | 3,442 | 39% |
| Tnt07 | 8,299 | 2,511 | 102 | 2,613 | 31% |
| wb3mlair | 7,497 | 2,073 | 216 | 2,289 | 31% |
| dcbest | 6,594 | 2,696 | 30 | 2,726 | 41% |
| Astpgmarch | 6,527 | 1,835 | 330 | 2,165 | 33% |
| wb3town | 6,002 | 1,481 | 156 | 1,637 | 27% |
| Gaden | 5,639 | 1,203 | 114 | 1,317 | 23% |
| MML2_MotherZone | 2,640 | 509 | 24 | 533 | 20% |
| golden_axe-turtlevillage2 | 831 | 255 | 12 | 267 | 32% |
| prepara | 630 | 205 | 132 | 337 | 53% |
| **The 32** | 730,695 | 200,294 | 9,426 | 209,720 | 28.7% |

`test-special`, with its 5 themes: from 221,558 to 61,910 (27.9%).

**The `release` cartridge**, adding up the `.dbg`'s segments: from 3,649,137 B
used to 3,128,883 (87.0% to 74.6%), **520 KB more free**. Bank 0 pays for the
decoder: from 1,825 B free to 1,168 —581 from the decoder and 76 from the
log—. If needed, the decoder can move to bank 1 with a bridge for
`dsp_musica`, like the battle.

### Cycles

Measured with a probe in a throwaway copy of both trees —`fb12bbb` and this
one—: the scanline on entering and leaving `music_tick`, on every frame of the
32 whole themes, in snes9x. The IRQ falls on line 112.

* **The worst frame of all goes down from 94 lines to 89.** It is the battle
  one's return to the start, with the startup and the eight voices written
  whole; what dominates there is the SPC700's wait for each write.
* What goes up is the frame with many notes and few writes: the
  `escape_newyork` one with 16 notes and 43 writes goes from 65 lines to 78.
* By regression over the 224,436 frames: before, 1.05 + 1.59 lines per write;
  now, 1.02 + 1.34 per write + 1.27 per voice event. In total the music takes
  7.8% more lines. A note whose sound was already whole in the cache costs on
  the order of a line and a quarter.

What is left to gain, if 5 asks for it: in `nota_sonido`, copying the sound and
comparing inline, without a `jsr` per register —on the order of 75 cycles per
note, estimated—.

### RAM

Nothing in `BSS`, and the zero page **gains** the byte of `wait_frames`. The
decoder's goes to far RAM, **`$6C00` to `$6FFF`**, which nobody used
(`ram_lejana.s` has the map): `MUS_SOMBRA` 128 B —72 used, eight registers and
the sound's GAIN per voice—, 11 B of state —the sixteen-bit wait, the gathered
KON, the one that has to be lowered, where the theme's sounds start, which
voices already had a note and GAIN—, and the test's log, 4 B and a 512 ring.

### How it was verified

* **In Python, on each build**: `build_varios` decodes each theme's stream
  with `decodificar` —the model of `music_frame`, which also imitates that the
  65816's cache cannot say "I don't know"— and stops if it does not give
  `escrituras`. It passes on the 32 themes of `release` and the 5 of
  `test-special`. Before changing the format, `escrituras` was compared against
  the old streams of both cartridges: the same writes on the same frames.
* **In the ROM**: `dsp_musica` notes what it receives in `MUS_BITACORA` if the
  test turns it on, and `test_musica_escrituras.py` plays whole themes and
  compares it frame by frame against the model running on the cartridge's
  bytes: the title's, started by the main code on power-up; `escape_newyork`,
  the battle one, 3D-Galax and TF3_1_awe, started by the IRQ on returning to
  the start. And the second pass of each one.
* **How it was seen failing**, breaking the decoder and building each time:
  without the `iny` between the two sides of `OP_NOTE_PAN`, the title and
  TF3_1_awe red on frame 0; without writing blindly the first note of each
  voice, three of five red on the return to the start; with the initial wait
  loaded with a dirty B, the title red on frame 0.
* **That last one was the only real error**: `music_start_ya` set the wait to
  zero with an eight-bit `lda #0` and a sixteen-bit `sta`.
  `test_bateria_suena` found it, because the title's drums did not arrive: the
  theme waited thousands of frames. The IRQ path does not see it —B arrives at
  zero—, and that is why the test starts the title through the other one.

### How 5 fits

* **The allocation by priority does not touch the format.** The format knows
  nothing of channels: each event says the voice, and the converter chooses
  it. A voice going from one channel to another is one more note with its
  sound, and changing instrument costs the same as not changing it —the sound
  goes in each note—. What in the old format added +74% of stream here is, at
  most, one more volume byte per note when the voice comes from another
  channel. Not measured.
* **The ramp is an `OP_RELEASE_GAIN`** with the ramp's GAIN, on the frame
  before the note: it is what the prototype did (`frames[at].release` with
  `RAMPA`), and it already fits as is in `Frame.release`, as (voice, GAIN). It
  stays on the 65816's side, without latency or a timer in the driver: the
  doubt below about doing it in the SPC700 is answered by it not being needed.
* **The cycles**: the prototype's worst frame went from 56 to 80 writes. With
  1.34 lines per write and 1.27 per event, that is on the order of 30 more
  lines in the worst frame, which today is 89. If it does not fit, the
  `nota_sonido` thing above.
* **What the format does not have and 5 does not need**: the modulation (CC1)
  and the drums' per-key panning. If they go in, a pitch per frame is an
  `OP_SET_PITCH`, and the panning is the volume of each hit's sound.

## 5. The allocation of the eight voices, and the ramp: done

Done on 2026-09-26, in two commits that can be listened to and measured
separately: "Música: las ocho voces para todos los canales, repartidas nota a
nota" and "Música: una voz que suena se baja en 12 ms antes de dársela a otra
nota"; and a third that corrects how a hit's note-time is counted ("Música: el
tiempo-nota de un golpe se cuenta hasta que suelta la voz"), which does not
change the ROM. Measured on `92754ab`, with the 32-theme `release`. The reason
for each rule is where it lives: `assign`, `_libre`, `_victima` and `RAMPA` in
`tools/audio/snes_music.py`.

**To listen**: `/shared/audio/2026-09-26-paso-5/`, with its `LEEME.txt`:
`escape_newyork`, the battle, the title, `cd4`, `Lunar_Pyramid` and
`T_ProjectJustice_DiscLoad`, before, with the allocation, and with the
allocation and the ramp, all at the same loudness.

### The allocation

* **The eight voices belong to all the channels** (`assign`). A note takes a
  free voice —the one nobody holds—, first a silent one and otherwise the one
  that ends its tail first; the hits prefer voices 6 and 7 —the sound effects'
  ones, as when the drums had them fixed— and the melodic part the others; and
  if equal, the one that had a note from the same channel, which comes out
  cheaper.
* **If all eight are held, the prototype's rule** (`_victima`): the same key of
  the same channel steals from itself; never from a note that started on that
  frame nor from the last voice of another channel; among the rest, from the
  weakest —the volume it started with— and when tied from the oldest; and the
  new note yields if its channel is already playing and the victim is the last
  of another, or is louder than it and its channel has no more voices. On each
  frame the loudest notes choose first.
* **A hit holds its voice until the end of the note in the MIDI** or that of
  its sample, whichever comes first; what is left of the sample is like a
  tail. Holding it until the end of the sample made the melodic part lose 8.3%
  of the note-time instead of 7.9% (Lunar_Pyramid 33% instead of 23%).

**The rules that were tried**, on the 32 themes, with a throwaway script
(`audio-paso-5/evaluar.py`) that builds everything with each rule. "Weighted" is
the lost note-time weighted by the velocity squared, which is how the volume
goes down; "steals" are the notes cut while they were playing:

| Rule | Lost | Weighted | Steals | Stream |
|---|---:|---:|---:|---:|
| the prototype's (the one that stayed) | 7.4% | 6.74% | 2,883 | 322,752 |
| steal from the oldest, never yielding | 7.4% | 6.85% | 7,121 | 336,426 |
| steal from the weakest, never yielding | 7.6% | 6.91% | 3,597 | 326,689 |
| the prototype's, protecting the lowest and the highest | 7.4% | 6.73% | 2,636 | 321,687 |
| the prototype's, stealing first within one's own channel | 7.4% | 6.75% | 2,905 | 322,761 |

(With the ramp in place, hence the stream.) Protecting the extremes gains in
`escape_newyork`, `TF3_1_awe` and the battle what it loses in `11h035` and
`evilrhys`: it did not go in. What was not tried and could gain something:
estimating the victim's current level with its envelope —the sustained piano
decays— instead of the volume it started with, and letting a long note that
did not get a voice start late (`escape_newyork`'s square wave loses 99%: its
nine notes fall on frames with nine notes or more, and they are among the
softest).

**The format did not change** nor the driver: each event already said its
voice. The converter prints per theme how much note-time is lost against the
eight-voice floor (`tiempo_perdido`), which replaces `coverage`;
`share_voices` and `coverage` are gone from `musica.py`.

**They are enforced** by three new tests in `test_musica_stream.py` —the chord
with more channels than voices, that no note goes without a voice while there
is a free one, whom it steals from— and `pruebas/rpgmaker/test_musica_reparto.py`,
on the real `escape_newyork`: the strings' first chord fires three voices, and
the clavinet and the square wave are in the bank and play. The five go red with
the allocation from before, reproduced in the script.

### The ramp

On the frame before the note that takes a voice that is still playing —held or
in its tail—, ADSR1 at zero and GAIN `RAMPA`: linear, 64 steps of 6 samples,
12 ms. It is one more `OP_RELEASE_GAIN`. It does not go to a note that started
on that same frame, nor to a silent voice. **There are 28,714 ramps against
64,274 notes**: 20,331 on melodic tails —14,298 on ones that had fewer than 15
frames left—, 5,138 on hits, 2,815 on held notes. A ramp only where the tail
would still be heard would shrink the cost, but it asks for estimating its
level; it was not done.

**They are enforced** by two tests in `test_musica_stream.py`: the steal of a
held note and that of a tail. A rough measurement of clicks on the recordings
—1 ms windows where the second difference jumps 8 times over its
surroundings, which also counts the drum hits— gives, with allocation → with
ramp: the title 116 → 8, the battle 642 → 424, `escape_newyork` 3,497 → 3,407
(almost all drums), `cd4` 519 → 522.

### Bytes, loss and cycles

Bytes: stream plus sounds, from `conversor.log`. Loss: `tiempo_perdido`, and
the one from before with the old allocation reproduced in the script. Cycles:
the probe of step 4 —the scanline on entering and leaving `music_tick`—, each
whole theme from its return to the start, in snes9x; the IRQ falls on line
112.

| Theme | Stream before | Allocation | Ramp | Note-time lost before → after | Floor | Worst frame (lines) before → allocation → ramp |
|---|---:|---:|---:|---:|---:|---:|
| hzstream | 4,028 | 4,268 | 4,452 | 0.0% → 0.0% | 0.0% | 32 → 38 → 37 |
| escape_newyork | 8,965 | 10,458 | 12,329 | 57.6% → 40.8% | 19.9% | 78 → 76 → 78 |
| TF3_1_awe | 9,964 | 12,378 | 16,786 | 23.1% → 11.5% | 4.1% | 54 → 73 → 73 |
| T_VGFighterMAX_Masako | 41,336 | 50,212 | 72,203 | 53.2% → 48.9% | 35.4% | 89 → 100 → 100 |
| evilrhys | 10,272 | 11,556 | 16,436 | 44.7% → 33.6% | 14.5% | 81 → 98 → 98 |
| lufsorr | 3,332 | 4,319 | 6,168 | 0.0% → 0.0% | 0.0% | 36 → 47 → 48 |
| cd4 | 12,671 | 15,119 | 16,910 | 27.2% → 0.1% | 0.1% | 62 → 65 → 66 |
| C3classi | 7,700 | 10,369 | 14,883 | 17.8% → 0.0% | 0.0% | 58 → 64 → 65 |
| rshinld | 3,442 | 4,558 | 7,089 | 28.0% → 11.3% | 4.9% | 63 → 73 → 75 |
| cd2 | 6,942 | 7,168 | 8,083 | 4.8% → 0.0% | 0.0% | 50 → 61 → 61 |
| hzbreach | 9,275 | 10,019 | 14,047 | 0.0% → 0.0% | 0.0% | 40 → 49 → 48 |
| wb3mlair | 2,289 | 2,600 | 2,720 | 0.0% → 0.0% | 0.0% | 45 → 45 → 45 |
| Astpgmarch | 2,165 | 2,275 | 2,381 | 0.0% → 0.0% | 0.0% | 40 → 40 → 40 |
| Gaden | 1,317 | 2,010 | 2,189 | 69.4% → 0.0% | 0.0% | 23 → 29 → 29 |
| 3D-Galax | 14,824 | 17,869 | 17,914 | 0.4% → 0.0% | 0.0% | 34 → 38 → 38 |
| wb3shop | 2,601 | 2,874 | 3,252 | 5.4% → 0.0% | 0.0% | 74 → 81 → 81 |
| KSSMKEND | 2,999 | 3,328 | 3,454 | 1.0% → 0.0% | 0.0% | 44 → 43 → 43 |
| vswar | 9,184 | 14,179 | 15,007 | 54.7% → 0.0% | 0.0% | 33 → 48 → 49 |
| Lunar_Pyramid | 8,072 | 9,376 | 12,536 | 57.9% → 18.9% | 3.1% | 79 → 94 → 94 |
| dcbest | 2,726 | 3,979 | 3,979 | 0.0% → 0.0% | 0.0% | 25 → 27 → 27 |
| golden_axe-turtlevillage2 | 267 | 267 | 321 | 0.0% → 0.0% | 0.0% | 30 → 30 → 30 |
| Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco | 3,984 | 7,024 | 7,720 | 0.0% → 0.0% | 0.0% | 42 → 52 → 52 |
| bubstix | 8,333 | 11,295 | 13,064 | 0.0% → 0.0% | 0.0% | 30 → 55 → 55 |
| wb3town | 1,637 | 1,913 | 2,002 | 0.3% → 0.0% | 0.0% | 38 → 52 → 52 |
| Fantasia_Of_The_Wind | 4,200 | 5,337 | 7,879 | 18.9% → 11.5% | 8.9% | 61 → 79 → 78 |
| 11h035 | 4,793 | 5,362 | 6,875 | 13.4% → 8.9% | 1.4% | 70 → 76 → 77 |
| prepara | 337 | 668 | 778 | 15.5% → 0.0% | 0.0% | 38 → 48 → 48 |
| T_ProjectJustice_DiscLoad | 4,308 | 4,826 | 5,190 | 21.3% → 0.0% | 0.0% | 72 → 85 → 85 |
| pn28year | 5,628 | 6,349 | 9,224 | 60.9% → 50.6% | 49.9% | 46 → 47 → 55 |
| Tnt07 | 2,613 | 2,835 | 2,835 | 0.0% → 0.0% | 0.0% | 44 → 43 → 43 |
| Deflector1 | 8,983 | 11,184 | 11,844 | 31.0% → 0.0% | 0.0% | 37 → 52 → 51 |
| MML2_MotherZone | 533 | 1,629 | 2,202 | 28.4% → 0.0% | 0.0% | 29 → 42 → 42 |
| **The 32** | 209,720 | 257,603 | 322,752 | | | |

* **Stream: from 209,720 to 257,603 B with the allocation (+23%) and to
  322,752 with the ramp (+25% more)**. The prototype's +74% was in the old
  format; in the per-note one, a voice changing channel costs a volume byte.
  The battle is the one that pays the most for the ramp (50,212 → 72,203): it
  is the densest.
* **The `release` cartridge, from 74.6% to 75.7% with the allocation and to
  77.3% with the ramp** (3,128,883 → 3,176,812 → 3,241,961 B used, adding up
  the `.dbg`'s segments). Bank 0 does not change: 1,168 B free.
* **Cycles: the worst frame of all, from 89 lines to 100** with the
  allocation, and the ramp does not move it. It is the battle one's return to
  the start —the startup and the eight voices written whole—, which ends on
  line 212, 13 before the vblank. The worst in the middle of a theme **goes
  down** from 82 to 79 with the allocation (the chords no longer overwrite
  each other on one voice) and stays at 78 with the ramp. In total the music
  takes 24% more lines with the allocation and 37% with the ramp. The
  `nota_sonido` thing of step 4 was not needed.
* **Note-time loss: on average from 19.8% to 7.4%**, with a floor of 4.4%.
  `escape_newyork` from 58% to 41% (floor 20%; the prototype counted 55% → 39%
  and a floor of 23% measuring the hits by their length in the MIDI); twelve
  themes that lost something go to losing nothing.
* **The bank**: the channels that had no voice add seven programs —the
  celesta, the steel guitar, the timpani, the shakuhachi, the fantasia, the
  space voice and the koto—, 67 samples instead of 60 in the same 57 KB, and
  the others go down in rate: the piano from 6.1 to 4.5 kHz, the strings from
  5.5 to 4.1, the saw from 6.1 to 4.6, the brass from 10.8 to 5.4. The same 19
  themes still do not contribute. 6 compensates for it.

### The saturation, and the two options for the air

With the method of the previous steps —each theme on the title, snes9x without
MSU-1, the whole theme, L+R samples at the ceiling, which with MASTER `$7F` is
32,511— and **without touching the air** (0.5, MASTER `$7F`), as taro asked:

| Theme | Clips before | Allocation | Ramp | Peak before → ramp (dBFS) | LUFS before → allocation → ramp |
|---|---:|---:|---:|---:|---:|
| hzstream | 36 | 84 | 88 | -0.1 → -0.1 | -9.6 → -9.5 → -9.5 |
| escape_newyork | 0 | 0 | 0 | -5.1 → -4.2 | -20.7 → -18.5 → -18.5 |
| TF3_1_awe | 0 | 6 | 7 | -1.8 → -0.1 | -13.4 → -11.3 → -11.4 |
| T_VGFighterMAX_Masako | 298 | 2,400 | 2,528 | -0.1 → -0.1 | -10.4 → -10.9 → -11.2 |
| evilrhys | 240 | 1,458 | 1,468 | -0.1 → -0.1 | -11.1 → -10.6 → -10.7 |
| lufsorr | 0 | 0 | 0 | -2.4 → -3.0 | -15.0 → -14.9 → -15.0 |
| cd4 | 0 | 0 | 0 | -3.7 → -1.4 | -17.9 → -16.1 → -16.1 |
| C3classi | 0 | 0 | 0 | -3.6 → -3.1 | -16.6 → -15.7 → -15.8 |
| rshinld | 4,724 | 7,888 | 7,786 | -0.1 → -0.1 | -8.7 → -8.1 → -8.2 |
| cd2 | 0 | 0 | 0 | -4.1 → -3.3 | -16.7 → -16.5 → -16.5 |
| hzbreach | 846 | 514 | 536 | -0.1 → -0.1 | -8.6 → -8.9 → -8.9 |
| wb3mlair | 0 | 0 | 0 | -9.6 → -9.5 | -24.7 → -24.9 → -24.9 |
| Astpgmarch | 0 | 0 | 0 | -1.7 → -1.2 | -14.0 → -14.2 → -14.2 |
| Gaden | 0 | 0 | 0 | -17.9 → -8.3 | -31.3 → -11.0 → -11.3 |
| 3D-Galax | 186 | 1,410 | 1,406 | -0.1 → -0.1 | -13.9 → -13.7 → -13.7 |
| wb3shop | 0 | 0 | 0 | -5.1 → -3.8 | -21.3 → -20.3 → -20.3 |
| KSSMKEND | 0 | 0 | 0 | -10.9 → -7.9 | -24.7 → -24.4 → -24.4 |
| vswar | 0 | 0 | 0 | -6.7 → -3.6 | -20.3 → -18.4 → -18.4 |
| Lunar_Pyramid | 28 | 5,723 | 5,852 | -0.1 → -0.1 | -14.1 → -11.6 → -11.6 |
| dcbest | 0 | 0 | 0 | -6.3 → -3.9 | -17.0 → -15.8 → -15.8 |
| golden_axe-turtlevillage2 | 0 | 0 | 0 | -8.1 → -8.1 | -17.7 → -17.7 → -17.7 |
| Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco | 0 | 8 | 11 | -4.1 → -0.1 | -15.8 → -13.5 → -13.5 |
| bubstix | 0 | 0 | 0 | -3.3 → -3.4 | -17.1 → -17.3 → -17.3 |
| wb3town | 0 | 0 | 0 | -8.0 → -6.2 | -20.2 → -20.1 → -20.1 |
| Fantasia_Of_The_Wind | 0 | 0 | 0 | -5.0 → -4.3 | -16.3 → -16.2 → -16.3 |
| 11h035 | 0 | 0 | 0 | -8.0 → -6.8 | -21.2 → -21.1 → -21.2 |
| prepara | 0 | 0 | 0 | -14.4 → -13.8 | -26.3 → -25.2 → -25.2 |
| T_ProjectJustice_DiscLoad | 0 | 0 | 0 | -7.9 → -4.9 | -24.3 → -20.9 → -20.9 |
| pn28year | 0 | 0 | 0 | -4.6 → -5.2 | -19.2 → -19.4 → -19.4 |
| Tnt07 | 0 | 0 | 0 | -9.6 → -8.6 | -23.8 → -23.7 → -23.7 |
| Deflector1 | 178 | 806 | 806 | -0.1 → -0.1 | -14.2 → -13.0 → -13.0 |
| MML2_MotherZone | 0 | 0 | 0 | -9.2 → -3.5 | -19.7 → -17.9 → -17.9 |
| **The 32** | 6,536 | 20,297 | 20,488 | | |


**The clips triple**, from 6,536 to 20,488 samples, almost all in five themes:
`rshinld` (7,786, the one that already clipped the most, because of CC7 at
127), `Lunar_Pyramid` (28 → 5,852), the battle (298 → 2,528), `evilrhys` (240
→ 1,468) and `3D-Galax` (186 → 1,406). The ramp barely changes anything. The
level goes up where the allocation gave channels back: `escape_newyork` +2.2
LUFS, `cd4` +1.8, `Gaden` +20 (it had almost everything that plays without a
voice).

**The two options**, for taro to choose. Both come from each theme's true
peak: the same commit was built with the air at 0.25 —each voice's ceiling at
a quarter of the original, 24 and 21—, which does not clip in any, the peak was
measured and multiplied by 2 (the volume is linear; the register's rounding at
0.25 makes it approximate). The options' LUFS is that of that recording plus
the gain; today's, the measured one.

* **A, a global air**: 0.318 instead of 0.5, **−3.9 dB for everyone**.
  `rshinld` sets it, whose true peak goes 3.9 dB over the ceiling. None clips,
  and the 22 themes that do not clip today go down 3.9 dB needlessly
  (`escape_newyork` to -22.7 LUFS).
* **B, a ceiling per theme**: each one with the highest air that does not clip,
  capped at today's 0.5. **22 themes stay as they are**; the 10 that go over
  the ceiling go down, from −0.5 dB (`TF3_1_awe`) to −3.9 (`rshinld`), the
  battle −2.9. It costs a table —one volume per theme that `build_events`
  applies in `lados`— and **measuring it again with each change of the mix**:
  step 6 changes the samples and with them the peaks. Measuring it is this same
  script with the air at 0.25, 30 s of snes9x per theme in parallel.

| Theme | True peak with 0.5 (dB over the ceiling) | B: theme's air | B: dB | LUFS today | A: LUFS | B: LUFS |
|---|---:|---:|---:|---:|---:|---:|
| hzstream | +1.1 | 0.438 | -1.1 | -9.5 | -13.4 | -10.6 |
| escape_newyork | -4.2 | 0.500 | +0.0 | -18.5 | -22.7 | -18.8 |
| TF3_1_awe | +0.5 | 0.470 | -0.5 | -11.4 | -15.3 | -11.9 |
| T_VGFighterMAX_Masako | +2.9 | 0.358 | -2.9 | -11.2 | -15.0 | -14.0 |
| evilrhys | +2.3 | 0.382 | -2.3 | -10.7 | -14.6 | -13.0 |
| lufsorr | -2.9 | 0.500 | +0.0 | -15.0 | -18.8 | -14.9 |
| cd4 | -1.3 | 0.500 | +0.0 | -16.1 | -20.0 | -16.1 |
| C3classi | -3.0 | 0.500 | +0.0 | -15.8 | -19.8 | -15.9 |
| rshinld | +3.9 | 0.318 | -3.9 | -8.2 | -12.0 | -12.0 |
| cd2 | -3.3 | 0.500 | +0.0 | -16.5 | -20.3 | -16.4 |
| hzbreach | +2.2 | 0.390 | -2.2 | -8.9 | -12.8 | -11.0 |
| wb3mlair | -9.3 | 0.500 | +0.0 | -24.9 | -28.8 | -24.9 |
| Astpgmarch | -1.3 | 0.500 | +0.0 | -14.2 | -18.1 | -14.2 |
| Gaden | -8.0 | 0.500 | +0.0 | -11.3 | -15.1 | -11.2 |
| 3D-Galax | +2.2 | 0.388 | -2.2 | -13.7 | -17.5 | -15.8 |
| wb3shop | -3.7 | 0.500 | +0.0 | -20.3 | -24.3 | -20.4 |
| KSSMKEND | -7.8 | 0.500 | +0.0 | -24.4 | -28.5 | -24.6 |
| vswar | -3.5 | 0.500 | +0.0 | -18.4 | -22.3 | -18.4 |
| Lunar_Pyramid | +2.5 | 0.377 | -2.5 | -11.6 | -15.6 | -14.1 |
| dcbest | -3.8 | 0.500 | +0.0 | -15.8 | -19.7 | -15.8 |
| golden_axe-turtlevillage2 | -8.2 | 0.500 | +0.0 | -17.7 | -21.8 | -17.9 |
| Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco | +0.6 | 0.467 | -0.6 | -13.5 | -17.5 | -14.2 |
| bubstix | -3.4 | 0.500 | +0.0 | -17.3 | -21.2 | -17.3 |
| wb3town | -6.1 | 0.500 | +0.0 | -20.1 | -24.0 | -20.1 |
| Fantasia_Of_The_Wind | -4.3 | 0.500 | +0.0 | -16.3 | -20.2 | -16.3 |
| 11h035 | -6.6 | 0.500 | +0.0 | -21.2 | -25.1 | -21.2 |
| prepara | -13.5 | 0.500 | +0.0 | -25.2 | -28.9 | -25.0 |
| T_ProjectJustice_DiscLoad | -5.0 | 0.500 | +0.0 | -20.9 | -24.9 | -21.0 |
| pn28year | -4.9 | 0.500 | +0.0 | -19.4 | -23.3 | -19.4 |
| Tnt07 | -8.6 | 0.500 | +0.0 | -23.7 | -27.6 | -23.7 |
| Deflector1 | +2.4 | 0.379 | -2.4 | -13.0 | -16.9 | -15.4 |
| MML2_MotherZone | -3.3 | 0.500 | +0.0 | -17.9 | -21.7 | -17.8 |

### The air: a ceiling per theme (option B): done

taro chose B. Done on 2026-09-26, after 5b —which changes the battle's mix—,
in the commit "Música: un techo de volumen por tema, medido". The reason lives
in `leer_techos` (tools/audio/snes_music.py) and how it is measured in
tools/audio/techos.py.

* **The table**: `parches/auto/musica/techos.toml`, versioned like the
  decisions in `parches/auto/`: each theme's air —the 32, the ones that do not
  clip with 0.5—, the peak and the LUFS with it, up to which frame it has to be
  played to go through its peak and the fingerprint of its mix.
  `build_varios` reads it and `build_events` multiplies each voice's ceiling by
  air/0.5.
* **It is not written by hand: `just techos`**, some four minutes. It builds a
  copy of `release` in `rom/build/techos/` with all the themes at 0.25 (the
  converter's `--aire-de-medida`), plays each one whole in snes9x without MSU-1
  —the title screen patched to the theme, like the scripts of the previous
  steps, eight at a time—, gives it the highest air that leaves its peak 0.5 dB
  below the ceiling (capped at 0.5), writes the table, rebuilds `release` and
  measures it again; if any still clipped, it lowers it and repeats. The first
  time all of them fit in one pass. `just techos --medir` only measures the
  built `release`.
* **The cartridges' stamp looks at the table's airs**
  (`cartuchos.huella`): changing one rebuilds, and rewriting the peaks or the
  fingerprints does not.
* **The test**, `pruebas/rpgmaker/test_musica_techos.py`:
  `test_la_tabla_de_techos_es_la_de_esta_mezcla` builds the 32 themes in
  memory (3 s) and compares each one's fingerprint —what it writes to the DSP
  and the samples it plays— with the table's: any change of the mix (step 6)
  turns it red saying which theme and that `just techos` has to be run. And
  `test_el_tema_no_recorta_en_su_pico`, one per theme among those left at less
  than 1.5 dB from the ceiling —12—, plays the theme in the ROM up to its
  `hasta` and asks for zero samples at the ceiling: 42,555 frames in total,
  **some 21 s of CPU, 5 s with the eight processes**; the longest, 3D-Galax,
  3.5 s. Playing the 32 whole would be some 2 minutes of CPU.
* **Why only the close ones**: with the mix the same (the fingerprint), the
  only thing that moves the peak is at what moment of the frame each write
  falls, which changes with any change of the ROM. Measured: `11h035`, `cd4`
  and `vswar` have the same stream before and after this change, and their
  peak moved 0.2 dB. The ones more than 1.5 dB away do not reach the ceiling
  because of that.
* **How it was seen failing**: with the battle's air changed by hand to 0.45
  in the table, both red: the battle's fingerprint, and 224 samples at the
  ceiling in its first 8,700 frames.

Before: the `release` with 5b and the air at 0.5 for everyone, measured with
`just techos --medir`. After: the table. "dB" is how much each theme goes down.

| Theme | Air | dB | Clips before → after | Peak before → after (dB) | LUFS before → after |
|---|---:|---:|---:|---:|---:|
| rshinld | 0.298 | -4.5 | 7790 → 0 | 0.0 → -0.7 | -8.2 → -12.7 |
| T_VGFighterMAX_Masako | 0.350 | -3.1 | 2384 → 0 | 0.0 → -0.5 | -10.1 → -13.1 |
| Lunar_Pyramid | 0.356 | -3.0 | 5436 → 0 | 0.0 → -0.5 | -11.5 → -14.5 |
| Deflector1 | 0.363 | -2.8 | 792 → 0 | 0.0 → -0.6 | -13.1 → -15.9 |
| 3D-Galax | 0.366 | -2.7 | 1380 → 0 | 0.0 → -0.5 | -13.7 → -16.4 |
| evilrhys | 0.380 | -2.4 | 538 → 0 | 0.0 → -0.5 | -10.5 → -12.9 |
| hzbreach | 0.381 | -2.4 | 556 → 0 | 0.0 → -0.4 | -8.9 → -11.2 |
| hzstream | 0.389 | -2.2 | 130 → 0 | 0.0 → -0.5 | -9.5 → -11.8 |
| Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco | 0.438 | -1.1 | 7 → 0 | 0.0 → -0.5 | -13.5 → -14.7 |
| TF3_1_awe | 0.440 | -1.1 | 14 → 0 | 0.0 → -0.5 | -11.4 → -12.5 |
| 11h035 | 0.500 | 0.0 | 0 → 0 | -6.6 → -6.4 | -21.2 → -21.2 |
| Astpgmarch | 0.500 | 0.0 | 0 → 0 | -1.2 → -1.2 | -14.2 → -14.2 |
| C3classi | 0.500 | 0.0 | 0 → 0 | -3.1 → -3.1 | -15.8 → -15.8 |
| Fantasia_Of_The_Wind | 0.500 | 0.0 | 0 → 0 | -4.4 → -4.4 | -16.3 → -16.3 |
| Gaden | 0.500 | 0.0 | 0 → 0 | -8.2 → -8.2 | -11.0 → -11.1 |
| KSSMKEND | 0.500 | 0.0 | 0 → 0 | -7.9 → -7.9 | -24.4 → -24.4 |
| MML2_MotherZone | 0.500 | 0.0 | 0 → 0 | -3.5 → -3.5 | -17.9 → -17.9 |
| T_ProjectJustice_DiscLoad | 0.500 | 0.0 | 0 → 0 | -5.0 → -5.0 | -20.9 → -20.9 |
| Tnt07 | 0.500 | 0.0 | 0 → 0 | -8.6 → -8.6 | -23.6 → -23.6 |
| bubstix | 0.500 | 0.0 | 0 → 0 | -3.1 → -3.1 | -17.2 → -17.2 |
| cd2 | 0.500 | 0.0 | 0 → 0 | -3.2 → -3.2 | -16.5 → -16.5 |
| cd4 | 0.500 | 0.0 | 0 → 0 | -1.3 → -1.1 | -16.2 → -16.2 |
| dcbest | 0.500 | 0.0 | 0 → 0 | -3.8 → -3.8 | -15.9 → -15.9 |
| escape_newyork | 0.500 | 0.0 | 0 → 0 | -5.1 → -5.1 | -18.5 → -18.5 |
| golden_axe-turtlevillage2 | 0.500 | 0.0 | 0 → 0 | -8.0 → -8.0 | -17.7 → -17.7 |
| lufsorr | 0.500 | 0.0 | 0 → 0 | -3.1 → -3.1 | -15.0 → -15.0 |
| pn28year | 0.500 | 0.0 | 0 → 0 | -5.1 → -5.1 | -19.5 → -19.5 |
| prepara | 0.500 | 0.0 | 0 → 0 | -13.7 → -13.7 | -25.3 → -25.3 |
| vswar | 0.500 | 0.0 | 0 → 0 | -3.6 → -3.8 | -18.4 → -18.4 |
| wb3mlair | 0.500 | 0.0 | 0 → 0 | -9.4 → -9.4 | -24.9 → -24.9 |
| wb3shop | 0.500 | 0.0 | 0 → 0 | -4.0 → -4.0 | -20.3 → -20.3 |
| wb3town | 0.500 | 0.0 | 0 → 0 | -6.1 → -6.1 | -20.2 → -20.2 |

**The clips, from 19,027 samples to zero.** The 22 that did not clip stay the
same (the peak of three moved 0.2 dB because of the above). The ten that
clipped go down between 1.1 dB (`TF3_1_awe`, `Fire_Mustang`) and 4.5 dB
(`rshinld`), a little more than option B estimated because of the 0.5 dB
margin; the battle, 3.1 dB, to -13.1 LUFS.

## 5b. The battle phrase, which the allocation cut: done

taro, on 2026-09-26, listening to the recordings of 5: *"some improve a lot,
but one gets worse: the battle theme. [...] the main phrase (which starts at
second 15 and ends at second 22, approx, and then repeats) is constantly
interrupted, which makes it unlistenable."*
Done the same day, in the commit "Música: la melodía de la batalla no llega
última a su cuadro". The reason lives in `_orden_del_cuadro` of
`tools/audio/snes_music.py`.

**To listen**: `/shared/audio/2026-09-26-batalla/`, with its `LEEME.txt`: the
battle (47 s: the reference, before the allocation, step 5 and the two
variants that fix it), and `escape_newyork` and the title whole with step 5 and
the two variants.

### The diagnosis

* **The phrase is the top voice of the organ's chords**, channel 0 (program
  20): three-note chords —the top one with velocity 127, the other two with
  100—, which start at 15.43 s with a 1.7 s chord and go down 72, 71, 69,
  67... until 22.2 s, and start again. It is the loudest channel of the mix:
  its CC7 leaves it at a level of 124 against 114 for the bass and 82 for the
  drums. In the MSU-1 track, the spectrum's peak between 300 and 1200 Hz
  follows exactly that line (an octave up, the organ's second harmonic).
  Channel 1 is an echo: the same notes 9 frames later, at a third of the
  level. Channels 2 and 3 play the bass **identically note for note**, with two
  programs.
* **Neither the steal nor the ramp cut it: the note did not get a voice.** Of
  its 536 notes in the whole theme, 290 played whole, 32 were stolen halfway
  and **214 did not play**; in the phrase, 5 of 21 without a voice and 1
  stolen, every other note (17.57 s, 18.43 s, 21.00 s, 21.65 s, 21.97 s...).
  The organ was silent 48% of the time the MIDI makes it play (52% in the
  phrase).
* **The 214 are the same case**: the eight voices had already started on that
  same frame, and a note of the frame is not stolen from. Who had them, summed
  over the 214 frames: the drums 946 voices of 1,712 —4.4 per frame—, the two
  basses 214 each, the brass 238, the guitar 100. On each beat the theme hits
  five or six drums together —35 and 36, two kicks; 38 and 40, two snares; the
  hi-hat— and everything goes with velocity 127, so the frame's order —by
  velocity and, when tied, the lowest first— left the melody, the highest, for
  last.
* **With the fixed allocation from before it did not happen**: the organ had
  its fixed voice and the drums two, so the organ was never silent (0%), even
  though the chord's bottom note played and not the top one (the top one was
  "lost" 94%, but another one of the same chord, with the same rhythm, played
  on its voice). What is heard as "is interrupted" is the rhythm: the channel
  going silent.
* **Neither a voice cap for the drums nor protecting the just-started notes
  change anything**: the melody was not lost because of steals between frames
  but because of the order within one. The recordings confirm it: in the
  windows of notes 71 and 67 of the phrase, the melody's energy is 24% and 10%
  of the total between 300 and 1200 Hz in step 5, against 80% and 60% with the
  fix and 51% and 48% in the reference.

### The variants

With a throwaway script (`audio-batalla/variantes.py` in the scratchpad),
which builds the 32 themes of `release` with each rule. As in 5: "lost" is the
average note-time lost per theme; "weighted", weighted by the level each note
starts with (with the controllers; that of 5 weighted by velocity alone);
"top" and "bottom", in what fraction of the frames the highest (lowest) note
of the melodic part the MIDI has playing does not play; "hits", what fraction
of the hits does not play, counting only once those of a family on the same
frame —two kicks together are one hit—; "stream", stream plus sounds of the
32. The battle's melody is the top voice of channel 0 throughout the theme, and
in parentheses in the phrase.

| Rule | Lost | Weighted | Steals | Top | Bottom | Hits | Stream | Battle: melody lost (15-22 s) | Organ silent |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| the fixed allocation per channel, from before step 5 | 19.84% | 19.99% | 13,968 | 11.2% | 10.8% | 2.49% | 283,360 | 94% (91%) | 0% |
| step 5: by velocity, and when tied the lowest first | 7.38% | 6.06% | 2,883 | 10.7% | 3.3% | 0.39% | 322,752 | 48% (52%) | 48% |
| step 5, and a note with fewer than 4 frames is not stolen | 7.39% | 6.06% | 2,124 | 10.6% | 3.4% | 0.44% | 319,527 | 56% (57%) | 56% |
| same, 8 frames | 7.42% | 6.10% | 1,760 | 10.7% | 3.3% | 0.52% | 317,748 | 73% (63%) | 73% |
| step 5, and the drums hold at most 2 voices | 7.31% | 6.00% | 2,811 | 10.7% | 3.3% | 0.64% | 322,764 | 48% (52%) | 48% |
| same, 3 voices | 7.33% | 6.02% | 2,851 | 10.7% | 3.3% | 0.52% | 322,833 | 48% (52%) | 48% |
| step 5, and a note of fewer than 8 frames does not steal | 6.94% | 5.76% | 1,559 | 9.8% | 3.1% | 2.58% | 308,736 | 25% (20%) | 25% |
| step 5, and a hit does not steal from the melodic part | 7.08% | 5.77% | 2,728 | 10.4% | 3.2% | 2.29% | 322,102 | 48% (52%) | 48% |
| step 5, and a family's repeated hit at the end of the frame | 7.09% | 5.79% | 2,815 | 9.4% | 3.1% | 0.35% | 323,081 | 31% (23%) | 31% |
| by level (with CC7) instead of velocity | 7.06% | 5.60% | 3,051 | 8.3% | 3.3% | 2.52% | 326,081 | 22% (29%) | 22% |
| by level, and the repeated hit at the end | 6.90% | 5.48% | 3,064 | 7.4% | 3.3% | 2.14% | 326,174 | 22% (29%) | 22% |
| round: the first of each channel before the second of any | 6.92% | 5.97% | 1,998 | 4.4% | 3.7% | 2.54% | 315,482 | 0% (0%) | 0% |
| hits first, the melodic part by level / place in its channel | 7.39% | 6.12% | 2,761 | 7.5% | 3.9% | 0.15% | 320,540 | 25% (34%) | 25% |
| **round** by level, each family of hits a channel, hits first when tied, repeated ones at the end | 6.94% | 5.91% | 2,511 | 5.6% | 3.7% | 0.18% | 318,665 | 0% (0%) | 0% |
| **level and place** (the one that stayed): hits first one per family, the melodic part by level / place, repeated ones at the end | 7.05% | 5.82% | 2,528 | 6.9% | 3.7% | 0.12% | 319,160 | 0% (0%) | 0% |
| level and place, and the repeated hit does not steal | 6.91% | 5.73% | 2,446 | 6.7% | 3.6% | 0.12% | 318,586 | 0% (0%) | 0% |

* **What decides is the frame's order, not whom one steals from.** Everything
  done in `_victima` —not stealing what just started, a cap for the drums,
  hits not stealing, short notes not stealing— leaves the melody the same or
  worse. The idea of detecting the melody's channel (the register, the volume,
  the one that plays alone the most) was not needed: sorting by the real level
  already puts it first, because it is the loudest.
* **The strict round** saves the melody, but costs the drums (hits 2.54%; the
  battle's loses 44% of its hits) if the drums are one more channel; with each
  family as a channel, 0.18%. And in `escape_newyork` it gives a voice to the
  velocity-29 strings —level 6, almost inaudible— at the expense of the
  polysynth (level 36): that theme's weighted goes up from 24.7% to 28.1%.
* **Level and place** —the chosen one— is the round without that defect: a
  channel's second note is worth half its level, so it goes before the first
  of a channel that plays at less than half. Against step 5: lost 7.38% →
  7.05%, steals 2,883 → 2,528, top 10.7% → 6.9%, hits 0.39% → 0.12%; what gets
  worse is the bottom, 3.3% → 3.7%. Per theme, what changes: the battle 48.9%
  → 47.0% (its drums lose 30% of the hit time, almost all the second kick and
  the second snare: per family, 0.1%); `evilrhys` 33.6% → 29.4%;
  `Lunar_Pyramid` 18.9% → 14.0%; `escape_newyork` 40.8% → 39.7% and its hits
  6.9% → 3.3%; `11h035` 8.9% → 10.3% and `pn28year` loses more of the bass
  (bottom 55.9% → 64.5%, with a floor of 50%). `cd4`, `vswar` and `Gaden` stay
  at 0%.
* **The repeated hit not stealing** gains a little more (6.91%, 2,446 steals)
  but it is one more rule in `_victima`: it did not go in. The two left even,
  to choose by listening, are level and place (implemented) and the round (in
  the recordings, `-3-ronda`; it is changing the key of
  `_orden_del_cuadro`).

### Bytes, cycles and the test

* **Stream: from 322,752 to 319,160 B** in the 32 themes (the battle 72,203 →
  69,613): fewer steals, fewer ramps. The `release` uses 3.6 KB less; bank 0
  does not change (1,168 B free).
* **Cycles**, with the probe of step 4 in snes9x, each whole theme from its
  return to the start: **the worst frame stays at 100 lines** —the battle's
  return to the start—, the worst in the middle of a theme (without the last
  31 frames) goes down from 91 to 90, and the music takes 1.2% fewer lines in
  total. What goes up the most is `cd2` (61 → 68) and `3D-Galax` (38 → 44),
  which lose nothing but allocate the voices in another order.
* **The test**: `test_la_melodia_de_la_batalla_no_pierde_notas`
  (`pruebas/rpgmaker/test_musica_reparto.py`) builds the theme and asks that
  each note of channel 0's top voice play whole, throughout the theme; with
  step 5's rule it goes red with 214 + 32. And
  `test_la_voz_de_arriba_del_acorde_no_llega_ultima_a_su_cuadro`
  (`pruebas/herramientas/test_musica_stream.py`), the case built by hand:
  eleven notes on a frame, five hits from three families, and left out are the
  second kick, the second snare and the chord's bottom note; with step 5's rule
  the one left out is the whole chord.

## 6. The samples: budget per package and zones

It is what changes the sound the most (10 alone already gets closer than 07)
and the most expensive: it is `presupuesto-de-muestras-por-paquete.md`, and
behind it `una-muestra-por-instrumento.md`. taro listened to variant 08/10 and
said it makes "a noticeable difference", and approved starting.

### Done, on 2026-09-26

taro chose option A (*"1.3 s is a very low cost to pay for what we get in
return"*) and lowering the startup to less than a second. Implemented in four
commits plus the prose one, on `d5caa40`:

1. **The budget per package** (A): `repartir` and `Banco` in
   `tools/audio/snes_music.py`, the packages built in the converter before the
   bank, the inheritance with `temas_heredados` (the teleports of the compiled
   pages, which `Temas.destino` now notes). Gone are the trimming of
   contributors, `--banco-entero`, `build_bank`, `build_drum_bank` and the hits'
   brightness. **And a change in the ROM that was not in the plan**: with each
   package filling the ARAM, the samples the new package shares with the
   previous one stayed where they were and the gaps left out samples of
   packages that fit on their own —with the music silenced, in five of thirteen
   jumps between the fullest maps, and on returning from a battle—.
   `paquete_cargar_ya` now decides first where each one goes, without
   uploading, and if something does not fit it arranges everything from zero
   (except the theme that is playing) before uploading.
   `test_cada_paquete_entra_entero_aunque_la_aram_quede_partida` enforces it.
2. **The most used zone**: `zonas_mas_usadas`, one per program.
3. **The low-pass** before lowering the rate (`resample` in
   `tools/audio/snes_samples.py`): a sinc with a Blackman window, circular in
   the loop. `gunter` did not change.
4. **The startup**: `BOOT_CUADROS` from 112 to 40, with the count in the
   converter (`cuadros_del_arranque`), which stops if the starting map's
   package does not fit.

**The numbers**, measured on `release` before (`d5caa40`) and after:

* **Rates**: the median of the 67 programs goes from **11.1 to 21.4 kHz**
  (before only 39 were in the bank), and that of the 49 hits from **7 to
  14.4** (before 28). All the themes have all their notes, except seven hits
  of `Astpgmarch`, `vswar` and `bubstix` on keys the SoundFont's GS kit does not
  have (10, 13, 22, 23, 88, 124, 125): they do not play in the reference
  either. The whole list, with which package limits each sample, is printed by
  the converter in `rom/build/release/conversor.log`.
* **The ones that ended up worse than before**, all because of map 3 (43 KB of
  sound effects): the oboe (21.9 → 6.8 kHz), the flute (21.8 → 8.8), the slap,
  the harp, strings 48 (4.1 → 10.4: better than before, but the lowest of
  `escape_newyork`), and the kick, the snare and the hi-hat (≈19 → 10.3, in all
  the themes). With the most used zone, some zones are longer and
  `escape_newyork`'s polysynth ended up at 12.6 kHz (16.9 with only step 1)
  and its bass at 14.6 (20.8).
* **Upload, measured in the ROM** with the prototype's probe (frames of
  `paquete_cargar_ya`, from 4 and with whatever comes playing):

  | | before | after |
  |---|---:|---:|
  | map 1 | 40 | 52 |
  | map 2 | 58 | 71 |
  | map 3 | 58 | 84 |
  | map 9 | 32 | 59 |
  | map 19 | 32 | 58 |
  | map 26 | 23 | 83 |
  | entering the battle | 36 | 58 |
  | leaving the battle (to 2) | 58 | 63 |
  | the startup package | 10 | 21 |
  | the title's theme | 6 | 12 |

  The work of `release`'s startup ends on frame 30 (before 20): with
  `BOOT_CUADROS` at 40, **the game starts 72 frames earlier, 1.2 s**.
* **Clips**: zero, with the ceilings measured again on each commit that
  changed the mix (`just techos`; `test_musica_techos.py` enforces it).
* **Cartridge** (sum of `ld65`'s segments): from 3,238,073 to 3,510,754 B.
  **Bank 0** in `release`: from 1,144 to 1,015 B free (the rearranging of
  `paquete_cargar_ya`); in `test-special`, 1,713.
* **The low-pass**, against an ideal FFT resampling on the 62 samples that go
  down from their rate: 5.5 dB more signal-to-error ratio at the median, and in
  the cymbals, the hi-hat, the tambourine and the cabasa from -9..-3 dB (the
  aliasing louder than the signal) to +7..+17. Against the MSU-1 track, with
  the "highs difference" from above, it is not seen (±0.1 dB): the aliasing
  weighs little in the whole theme's average spectrum.

Against the MSU-1 track (highs, in dB, the count of the recordings above):
`escape_newyork` 10.4 → 7.6, the battle 3.5 → 3.1, the title 5.3 → 1.3,
`3D-Galax` 11.8 → 4.1, `Gaden` 7.4 → 1.8.

**To listen**: `/shared/audio/2026-09-26-paso-6-final/`, with its `LEEME.txt`:
the four themes from before and `Gaden` —one of the 19 that did not
contribute: two channels out of seven played—, from the final ROM without
MSU-1, at the same loudness.

**What `just pruebas` does not cover**: that with the inherited theme playing
the package's themes fit with the ARAM fragmented in the game's jumps. A
separate script looked at it with fourteen jumps of the inheritance (no theme
was missing anything; six were missing sound effects, which the `PlayBGM`
completes); the converter only checks that the sum fits.

### Without map 3's ceiling, on 2026-09-26

taro, about the ones that ended up worse: *"I don't find it acceptable that
instruments lose quality because of a single map, but I don't want to lose
quality in the sound effects either."* So the sound effects were not touched
—their 92 samples and the 120 rows of `sonido_tabla` come out byte for byte
identical, with the SRCN shifted; a script compared it against the
`musicdata.inc` of `d7056b6`— and it was attacked from two sides, in the commit
"Audio: copias de una muestra para el paquete que la limita, y los temas de
salida aparte".

**What really plays on map 3.** A single page (event 5, page 2) starts
`evilrhys`, plays the whole sequence of sound effects, fades the theme, and
only after "Core...?" starts `lufsorr` and jumps to map 4. That is, both themes
of the package play on 3, but **never with the sound effects at the same time
as `lufsorr`**: the oboe and the flute are only `lufsorr`'s, and the limited
drums are `evilrhys`'s, which does play with the sequence. `lufsorr` is heard
on 3 for an instant; its audience is 4 and the maps after it.

**1. Exit themes** (`Temas.de_salida` in `tools/port/eventos.py`): a `PlayBGM`
followed by a `Teleport` to another map, without sound effects, another theme
or branches in between, does not have to fit with the map's sound effects. It
goes in a third list of the package; it is uploaded on entering **if there is
room**, and otherwise its `PlayBGM` uploads it on its own, releasing the rest
and leaving the package noted as incomplete (`extra_de_salida` in
`rom/src/paquete_de_audio.s`). The converter finds five: `lufsorr` on 3,
`hzstream` on 4 —which took with it the inheritances `4+Astpgmarch` and
company, which limited half
the cartridge—, `hzbreach` on 14, `wb3mlair` on 16 and `vswar` on 26.

**2. Copies** (`snes_music.copias`): a key limited by a group where not all the
themes that use it are becomes another sample for the ones inside; the ones
outside stop paying for it. The worst first, until the directory is full: there
are 47 copies and the directory ends up at 255 entries, the SRCN's cap. The
whole option B —the condition for all the samples— would ask for some 370.

**Numbers**, `release` before (`d7056b6`) and after, kHz, outside map 3 (the
table per theme is printed by the converter: one line per copy, with the themes
that use it):

| | before step 6 | before | after |
|---|---:|---:|---:|
| oboe (`lufsorr`, `prepara`) | 21.9 | 6.8 | 20.4 (its native rate) |
| oboe (`Astpgmarch`) | 21.9 | 6.8 | 13.6 |
| flute (`lufsorr`) | 21.8 | 8.8 | 21.9 |
| kick `KICK264` | 19.4 | 10.2 | 16.2 |
| kick `SOLKK60A`, snares | 4.7-8.1 | 10.3 | 16.0 (13.9 in `Astpgmarch`) |
| hi-hat | 14.9 | 10.3 | 16.0 |
| `escape_newyork`'s polysynth | 8.4 | 12.6 | 21.1 |
| strings 48 (`escape_newyork`, battle) | 4.1 | 10.4 | 16.4 |

On map 3, `evilrhys` goes up from 10.3 to 12.5 on all its drums (`lufsorr`
leaves it room). The median of the 338 (theme, sample) pairs goes from 14.5 to
16.2 kHz and none is left below 12 any more (before 113).

**What was not reached**: the `KICK264` kick stays at 16.2 against the 19.4 of
before step 6 —map 9 with `rshinld` playing limits it, and the directory filled
up before reaching that copy—, and `Astpgmarch`'s oboe at 13.6, which its own
map 18 with `hzstream` playing limits.

**What is paid**:

* **86 pairs go down**, almost all from ~22 to 16-20 kHz (the battle's crash
  and a tom 21.7 → 16.0, `rshinld`'s koto 27.7 → 13.9): what is freed from map
  3 competes in the other packages, and the split gives everything the same
  fraction. It is the drums at 16 against cymbals at 22 from before.
* **Cartridge**, sum of `ld65`'s segments: from 2,986,461 to 3,089,032 B
  (71.2% → 73.6%). **Bank 0** in `release`: from 1,027 to 902 B free.
* **Frames**, computed at 1.4 per KB (what was measured in step 6), not
  measured: starting `lufsorr` on 3 freezes some 13 frames (9 KB), after
  "Core...?" and before the jump. `vswar` on 26, if it does not fit next to its
  package, up to some 70 (51 KB) on touching the event. 4, 14 and 16 have room:
  their exit theme is uploaded on entering, as before. Map 3's load is the same
  (the package is still full).

**What `just pruebas` does not cover**: the game's jumps with the exit theme
playing on the destination map; what is covered is the ROM's path on map 3
(`test_el_tema_de_salida_sube_solo`, case `tema-de-salida`).

**To listen**: `/shared/audio/2026-09-26-sin-el-techo-del-mapa-3/`, with its
`LEEME.txt`: `lufsorr`, the battle, `escape_newyork`, `Astpgmarch` and
`evilrhys`, before and after, without MSU-1, at the same loudness.

**Discarded**:

* **That 3's sound effects not all be there at once**: the sequence plays them
  in a row, under the same theme; uploading one at the moment is freezing the
  cutscene.
* **Deduplicating sound effects**: the thunder of 1 (whole, 22 kHz) and that of
  3 (6 kHz, trimmed) are different samples; there are no two identical ones.
* **Deduplicating identical music samples**: at the native rate there are only
  four repeated keys (piano 1 and 2, strings 48 and 49, the three choirs), and
  the hits that come out identical are so only at certain rates. They are four
  directory entries: left for later.
* **Giving the sound effects their own place in the directory**: it would free
  some 70 entries —no package has more than 20 sound effects— and it would be
  enough for the kick, but the ROM's lists are one byte and `FAR_ARAM_DE` and
  `FAR_QUIERE` would go past their place in far RAM: it is redoing
  `paquete_de_audio.s`. It is the next thing if more is needed.

### What is left of the quality of the music

With 6 done, **all the steps of the plan are there**: the drums, the notes that
were released early, the envelopes, the velocity and the controllers, the
per-note format, the allocation and the ramp, the air per theme and the
samples. What is left are details, in the order I would do them:

1. **Covering it**: the battle's fade
   (`el-fundido-al-entrar-y-salir-de-la-pelea.md`), which is the only thing of
   step 6 that is seen often.
2. ~~**Map 3's sound effects**~~: done without touching them, in "Without map
   3's ceiling". If more is needed —the kick at the 19 from before—, giving the
   sound effects their own place in the directory so that more copies fit.
3. **Listening to it against the reference** in the themes that were never
   recorded: the 19 that did not contribute play whole for the first time, and
   it is where there may be surprises —a program in a register the most used
   zone does not cover, a hit the kit does not have—.
4. **A second zone only where it can be heard**, if taro misses it in some
   bass.
5. **The polyphony**: `escape_newyork` loses 40% of the note-time for lack of
   voices (floor 20%) and the battle 47% (floor 35%). It is about eight voices
   and not about the samples; what could be done is look at what is lost, not
   gain it.
6. **The SPC700's upload loop** (storing with `mov !abs+y`, acknowledging
   before the last store): between 10 and 20% fewer frames in each package,
   estimated. Only if the fade does not manage to cover it.
### What was measured before implementing it

**Status, 2026-09-26, before the decision**: measured, prototyped and recorded;
the plan is below and it has decisions for taro. **Done and ready to merge only
step 1** —the package that did not fit is completed on the next `PlayBGM`—,
which fixes something that happens today in the game and that the rest needs.
Measured on `03c21fb`, with the 32-theme `release`.

* **To listen**: `/shared/audio/2026-09-26-paso-6/`, with its `LEEME.txt`:
  `escape_newyork`, the battle, the title and `3D-Galax` (one of the 19 that do
  not contribute today) in five versions —today, per package, per package with
  the most used zone, with two zones, and the ceiling at 22 kHz—, at the same
  loudness.
* **The prototypes**: local branch `proto-paso-6` (commit `06a40ef`), **not to
  be merged**: a timing probe in `paquete_cargar_ya` and a `Banco` that builds
  each sample with the budget from a JSON (`PROTO_PASO6`).
* **The scripts**, throwaway, in the session's scratchpad (`audio-paso-6/`):
  `volcar.py` takes out of the converter what `emit` receives —packages,
  themes, samples—, `reparto.py` does the split, `herencia.py` the graph of
  which theme may come in playing, `medir_subida.py` and `herencia_rom.py`
  measure in the ROM, `grabar.py` and `distancia.py` record and compare against
  the MSU-1 track.

### What was not as thought: the upload no longer goes through the IPL

* **The IPL only uploads the driver and the directory** —less than 1 KB, less
  than a frame—. The samples are uploaded by `paquete_cargar_ya` through the
  driver's command 3: **triplets through ports 0, 1 and 2, with the token on
  3**. That is, the "four-port loader" of
  `decisiones/el-arranque-esta-dimensionado-para-el-techo-de-aram.md` **already
  exists** since the per-map packages.
* **Measured in the ROM**, with the probe —frame and line on entering and
  leaving `paquete_cargar_ya`—, in eighteen packages: **1.33 to 1.42 frames per
  KB**, some 45 KB/s. It is almost the same as what the comment of
  `BOOT_CUADROS` measured for the IPL byte by byte (1.4): the triplet did not
  gain what it promised.
* **The ceiling is the SPC700**: its triplet loop is 56 cycles at 1.024 MHz,
  55 KB/s. What is missing up to there is the latency of the acknowledgement,
  the music's IRQ —which keeps playing during the upload— and the rebuilding of
  the pointer every 255 B. A tighter loop (storing with `mov !abs+y` instead of
  `[dp]+y`, acknowledging before the last store) reaches some 48 cycles:
  **between 10 and 20% faster, estimated**. It was not prototyped: it does not
  pay for a new driver command.
* **The startup**: it finishes its work on frame 20 —map 4's package, 7.4 KB,
  is 10 frames— and waits until 112. With the ARAM full through command 3 it
  would be 62 KB × 1.36 + 9 = 94 frames, so `BOOT_CUADROS` still covers the
  ceiling, but **what would buy it back is no longer a loader**: it is sizing
  it for the startup package and not for the ceiling. It is a decision (see
  below).

### The budget per package, measured

**How**: `release`'s converter was run intercepting `emit` —each map's
packages and the battle's, the themes, the sound effects' samples— plus the
title's package (the title's theme with map 4's package, which is what
`tema_asegurar` builds). For each package, what is free is the ARAM minus the
directory, minus its sound effects, minus 1 KB of margin; and each sample —one
per program and one per hit, across the whole cartridge, as today— has to fit
in **all** the packages where it is. The split is a progressive filling over
the fraction of its size at the SF2's rate: all are raised together until a
package fills up, those stay fixed, and it continues with the rest. The voices
come out of `build_voice` and `build_drum` with that budget, that is, they are
the ones the converter would build.

**Which themes can play on each map**: those of the package —its own and the
ones a `PlayBGM` of its pages starts—, and **the one that comes playing from
the previous map**, because almost no map of the game brings its own theme: a
page starts it, and until then the one from before continues. Following the
`Teleport`s without looking at conditions gives that any theme can reach any
map (4 is the router); with the rule "a map with a `PlayBGM` leaves with one of
its own" the column below remains. No common event has a `PlayBGM`.

The variants: **A**, one sample per program limited by its worst package, and
the themes that come playing weigh only as themes (their samples plus the
package's have to fit, without the sound effects: see "The inheritance"); **B**,
one copy per theme, limited only by that theme's packages. "Upload" is the
music plus the package's sound effects at 1.36 frames per KB.

| Package | Themes | May come playing | Sound effects | Music today | Music A | Music B | Free A | Upload today → A (frames) |
|---|---|---|---:|---:|---:|---:|---:|---:|
| 4 | hzstream | Astpgmarch, Fantasia Of Th, dcbest, evilrhys, lufsorr | 0 | 7452 | 14490 | 13041 | 48093 | 10 → 19 |
| 1 | escape newyork | hzstream | 26289 | 9387 | 23472 | 35568 | 12822 | 47 → 66 |
| 2 | TF3 1 awe | escape newyork | 36765 | 10935 | 25731 | 24660 | 87 | 63 → 83 |
| 3 | evilrhys, lufsorr | TF3 1 awe, hzstream | 43029 | 14598 | 19404 | 18909 | 150 | 77 → 83 |
| 7 | hzstream | — | 12375 | 7452 | 14490 | 13041 | 35718 | 26 → 36 |
| 8 | cd4 | C3classi, cd2, hzstream | 15228 | 5706 | 12645 | 11763 | 34710 | 28 → 37 |
| 9 | hzstream, cd4, C3classi | rshinld | 10413 | 18837 | 42957 | 40752 | 9213 | 39 → 71 |
| 11 | rshinld | C3classi, cd4, hzstream | 16182 | 9342 | 22455 | 20952 | 23946 | 34 → 51 |
| 12 | cd2, hzstream | cd4 | 2529 | 14805 | 29385 | 38079 | 30669 | 23 → 42 |
| 14 | hzbreach | cd2, hzstream | 1728 | 9063 | 19062 | 23994 | 41793 | 14 → 28 |
| 16 | hzbreach, wb3mlair | — | 2529 | 14454 | 31023 | 39789 | 29031 | 23 → 45 |
| 17 | hzstream | hzbreach | 8046 | 7452 | 14490 | 13041 | 40047 | 21 → 30 |
| 18 | Astpgmarch | hzstream | 6543 | 10962 | 52281 | 48789 | 3759 | 23 → 78 |
| 19 | Gaden, 3D-Galax | hzstream | 18234 | 9522 | 44163 | 43497 | 186 | 37 → 83 |
| 20 | wb3shop | 3D-Galax, Gaden, KSSMKEND | 13518 | 7353 | 22734 | 24984 | 26331 | 28 → 48 |
| 21 | KSSMKEND | — | 4797 | 2124 | 8082 | 7803 | 49704 | 9 → 17 |
| 26 | KSSMKEND, vswar | — | 15777 | 11709 | 46728 | 46260 | 78 | 37 → 83 |
| 28 | Lunar Pyramid | KSSMKEND, wb3shop | 7146 | 9531 | 30546 | 36684 | 24891 | 22 → 50 |
| 32 | dcbest | Lunar Pyramid | 12384 | 1809 | 13086 | 14481 | 37113 | 19 → 34 |
| 33 | dcbest | — | 5058 | 1809 | 13086 | 14481 | 44439 | 9 → 24 |
| 36 | golden axe-turtlev | hzstream | 0 | 1161 | 14319 | 15129 | 48264 | 2 → 19 |
| 52 | Fire Mustang Intro | — | 7587 | 4149 | 13752 | 15480 | 41244 | 16 → 28 |
| 70 | 11h035 | — | 0 | 6003 | 13581 | 22986 | 49002 | 8 → 18 |
| 73 | 11h035 | — | 0 | 6003 | 13581 | 22986 | 49002 | 8 → 18 |
| 74 | prepara | — | 7326 | 4896 | 20178 | 24984 | 35079 | 16 → 37 |
| 121 | T ProjectJustice D, bubstix, wb3town | — | 2529 | 15327 | 54873 | 58977 | 5181 | 24 → 76 |
| 133 | pn28year | — | 5922 | 1629 | 5886 | 7866 | 50775 | 10 → 16 |
| 255 | Tnt07 | — | 4797 | 1620 | 9891 | 11916 | 47895 | 9 → 20 |
| 261 | Deflector1 | — | 15840 | 7695 | 25119 | 31815 | 21624 | 31 → 54 |
| 269 | MML2 MotherZone | — | 4797 | 1485 | 12672 | 15039 | 45114 | 8 → 23 |
| 348 | T ProjectJustice D | — | 0 | 7614 | 26784 | 23571 | 35799 | 10 → 36 |
| battle | T VGFighterMAX Mas | — | 14832 | 15642 | 42327 | 46557 | 5424 | 40 → 76 |
| title | Fantasia Of The Wi, hzstream | — | 0 | 11520 | 23400 | 27225 | 39183 | 15 → 31 |

(Maps 5, 6, 10, 13, 23, 29, 30 and 34 have no themes in the package and limit
nobody; the ones in the second half of the table are the test ones.)

And what each melodic program gets. "Limited by" is the package that fixed it
in A ("4+Astpgmar" is 4 with `Astpgmarch` playing); "A+inheritance" is A with
the inherited theme **and the sound effects** in the budget; B gives the range
among the copies of the themes that use it. kHz:

| Program | Sample | Themes | Today | A | Limited by | A+inheritance | B |
|---|---|---:|---:|---:|---|---:|---:|
| 0 | PIANO64 | 6 | 4.5 | 14.7 | 4+Astpgmar | 17.4 | 13.2–22.1 |
| 1 | PIANO56 | 1 | 4.7 | 22.1 | — | 22.1 | 22.1–22.1 |
| 2 | PIANO56 | 3 | 4.7 | 22.1 | — | 22.1 | 14.9–22.1 |
| 7 | CLAVI60 | 3 | 21.1 | 21.1 | — | 21.1 | 21.1–21.1 |
| 8 | CELST77 | 2 | 22.5 | 18.2 | 3 | 18.2 | 18.2–22.5 |
| 10 | M_BOX82 | 2 | not there | 19.9 | 26 | 21.5 | 14.9–21.5 |
| 11 | VIBE_64A | 3 | 7.9 | 22.3 | — | 22.3 | 15.8–18.4 |
| 13 | XYLO_72 | 1 | 22.8 | 22.8 | — | 22.8 | 14.3–14.3 |
| 15 | SANTR74 | 1 | 22.5 | 22.5 | — | 22.5 | 22.5–22.5 |
| 16 | EORG173 | 1 | not there | 18.0 | 26 | 22.5 | 18.0–18.0 |
| 17 | EORG253 | 2 | 11.1 | 22.3 | — | 22.3 | 15.3–22.3 |
| 18 | EORG379 | 3 | not there | 19.5 | 19 | 20.9 | 14.9–16.6 |
| 20 | R_ORG53 | 1 | 22.1 | 22.1 | — | 22.1 | 22.1–22.1 |
| 24 | NYLON57A | 2 | 11.1 | 22.2 | — | 22.2 | 15.2–18.1 |
| 25 | STLGT57B | 1 | 9.4 | 22.2 | — | 22.2 | 17.6–17.6 |
| 26 | JAZGT59A | 1 | not there | 19.6 | 26 | 22.0 | 15.8–15.8 |
| 27 | CLNGT60 | 1 | not there | 22.0 | — | 22.0 | 14.7–14.7 |
| 30 | DSTGT64 | 3 | 21.3 | 21.3 | — | 21.3 | 16.0–21.3 |
| 32 | ACOBS60A | 2 | not there | 20.6 | — | 20.6 | 20.6–20.6 |
| 33 | MMBAS62 | 12 | 21.0 | 18.4 | 19 | 21.0 | 13.1–21.0 |
| 34 | PCKBS50A | 2 | 12.9 | 15.2 | 4+Astpgmar | 5.8 | 12.9–15.2 |
| 35 | FRTLS48A | 3 | 8.3 | 10.4 | 3 | 6.2 | 10.4–22.9 |
| 36 | SLPBS43 | 2 | not there | 22.1 | — | 22.1 | 22.1–22.1 |
| 37 | SLPMT52A | 2 | 22.3 | 11.1 | 3 | 5.9 | 9.8–15.7 |
| 38 | SYBS148A | 6 | 10.3 | 20.6 | 26 | 22.6 | 14.4–22.6 |
| 39 | SYBS248A | 2 | not there | 19.5 | 26 | 21.6 | 15.4–17.5 |
| 40 | VIOLN68 | 1 | not there | 23.3 | — | 23.3 | 16.7–16.7 |
| 42 | CELLH64 | 2 | 21.0 | 21.0 | — | 21.0 | 21.0–21.0 |
| 44 | STRNG71B | 2 | not there | 22.1 | — | 22.1 | 15.0–22.1 |
| 45 | PIZZ_71 | 3 | 19.7 | 22.4 | — | 22.4 | 17.9–22.4 |
| 46 | HARP_57A | 7 | 12.0 | 10.6 | 3 | 5.6 | 9.9–21.8 |
| 47 | TMPNI47 | 2 | 7.2 | 11.0 | 3 | 6.0 | 9.9–15.3 |
| 48 | STRNG71B | 10 | 4.1 | 10.8 | 3 | 5.9 | 9.6–22.1 |
| 49 | STRNG71B | 3 | not there | 19.5 | 19 | 20.9 | 15.8–22.1 |
| 50 | SSTR162A | 2 | not there | 22.0 | — | 22.0 | 14.9–22.0 |
| 52 | CHOIR65A | 4 | not there | 19.7 | 19 | 21.1 | 15.9–22.3 |
| 53 | POPVX64A | 1 | not there | 21.4 | — | 21.4 | 21.4–21.4 |
| 56 | TRMPT65 | 2 | not there | 19.3 | 26 | 22.1 | 16.6–19.3 |
| 58 | TRMBN62A | 2 | not there | 13.8 | 4+Astpgmar | 18.3 | 13.8–18.3 |
| 61 | BRASS64 | 1 | 5.4 | 21.7 | — | 21.7 | 16.3–16.3 |
| 63 | SBRS255 | 1 | not there | 21.9 | — | 21.9 | 21.9–21.9 |
| 68 | OBOE_61A | 3 | 21.9 | 8.8 | 3 | 4.4 | 8.8–21.9 |
| 69 | EHORN61A | 1 | not there | 17.5 | 19 | 21.9 | 17.5–17.5 |
| 71 | SYNCL64 | 1 | not there | 20.4 | 19 | 20.4 | 20.4–20.4 |
| 73 | FLUTE65A | 1 | 21.8 | 10.9 | 3 | 5.4 | 10.9–10.9 |
| 75 | PNFLT72 | 2 | 11.9 | 18.9 | 19 | 20.3 | 16.0–21.4 |
| 77 | SHAKU63 | 1 | 8.0 | 22.1 | — | 22.1 | 15.0–15.0 |
| 79 | OCARI72A | 2 | 16.1 | 16.1 | 4+Astpgmar | 16.1 | 16.1–24.1 |
| 80 | SQUAR60 | 6 | 6.2 | 14.7 | 4+Astpgmar | 5.8 | 13.1–22.0 |
| 81 | SAW0_60 | 4 | 4.6 | 14.7 | 4+Astpgmar | 11.7 | 13.1–22.0 |
| 82 | CALLI72 | 2 | 8.3 | 22.0 | — | 22.0 | 14.9–22.0 |
| 83 | CHFFR72A | 1 | not there | 25.3 | — | 25.3 | 25.3–25.3 |
| 87 | BS_LD48 | 3 | 14.6 | 20.8 | 2 | 6.2 | 16.7–22.9 |
| 88 | FANTA53 | 3 | 8.6 | 22.0 | — | 22.0 | 17.8–22.0 |
| 89 | WRMPD72A | 1 | not there | 22.0 | — | 22.0 | 22.0–22.0 |
| 90 | POLY_60A | 3 | 8.4 | 16.9 | 2 | 4.2 | 12.6–21.1 |
| 91 | SPACE79 | 3 | 7.2 | 19.1 | 2 | 5.9 | 15.0–22.1 |
| 92 | ELP1_56 | 1 | not there | 19.6 | 19 | 22.9 | 16.4–16.4 |
| 94 | CHOIR65A | 1 | not there | 19.7 | 19 | 21.1 | 16.7–16.7 |
| 96 | ICE__60A | 1 | not there | 22.1 | — | 22.1 | 18.1–18.1 |
| 99 | ATMOS60A | 3 | not there | 21.1 | — | 21.1 | 21.1–21.1 |
| 102 | CHOIR65A | 1 | not there | 22.3 | — | 22.3 | 18.2–18.2 |
| 107 | KOTO_57 | 1 | 24.4 | 24.4 | — | 24.4 | 16.3–16.3 |
| 112 | TNKBLA5 | 1 | not there | 22.4 | — | 22.4 | 22.4–22.4 |
| 116 | SURDO60 | 1 | 9.6 | 10.7 | 3 | 5.9 | 9.6–9.6 |
| 118 | SYNDR56 | 1 | not there | 20.8 | — | 20.8 | 20.8–20.8 |
| 127 | PISTL60 | 2 | 11.4 | 22.1 | — | 22.1 | 15.0–22.1 |

What it says:

* **The 19 themes that do not contribute today all start contributing**: in A
  all the programs and all the hits of the cartridge are there (116 samples
  against 67). `3D-Galax`, for example, gets back the organ, the electric piano
  and the choir, which do not play today.
* **The programs' median goes from 11.1 to 20.8 kHz**, and that of the hits
  from 7 to 14.7 (today only 28 of the 49 hits are in the bank). The piano goes
  from 4.5 to 14.7, the strings from 4.1 to 10.8, the saw from 4.6 to 14.7, the
  brass from 5.4 to 21.7.
* **What dominates is the sound effects of maps 2 and 3**: 36.8 and 43 KB of
  their 64. Everything `evilrhys` and `lufsorr` play on 3 ends up close to
  10 kHz, and since the sample is one per program, it stays that way in all the
  themes: the harp, strings 48, the common drum hits. **Six programs end up
  worse than today**, because today they were short and the bank gave them the
  SF2's rate —the oboe (21.9 → 8.8), the flute (21.8 → 10.9), the slap (22.3 →
  11.1), the celesta, the harp and synth bass 33—, and the battle's kick and
  hi-hat go down from 19.4 and 14.9 to some 10.7.
* **B** —one copy per theme— removes that ceiling: each theme is limited only by
  its own packages (`escape_newyork` all at some 21.5 kHz, the battle at
  16–22). But it is **430 samples** and the SRCN is a byte: today the 92 sound
  effects take their place in the same directory, so the music is left with
  163. See the order of implementation.

### The inheritance: the theme that comes playing, and the sound effects

`paquete_cargar_ya` does not move the samples of the theme that is playing
—the music keeps going during the fade—, and arranges the new package around
it, in order: its themes and then its sound effects. What does not fit is not
uploaded. Measured in the ROM (`herencia_rom.py`: the jump with the origin
map's theme marked as the one playing, which is the only thing
`paquete_cargar_ya` looks at):

* **It already happens today, in the game**: from 2 to 3 the elevator page
  jumps with 2's theme playing —only afterwards does it ask for it again— and
  3 was missing sound effects, which did not come back during the whole scene
  even though 3's page started `evilrhys` right away. It is what step 1 fixes.
* **With A, and nothing else**, many more are missing, because each package
  already fills the ARAM on its own: from 1 to 2 with `escape_newyork` playing
  6 sound effects of 2 are missing, from 2 to 3 10 are missing, from 4 to 19 6
  are missing, and from 4 to 1 with `hzstream` playing **the whole thunder** is
  missing (23.8 KB). And with the jumps that are not the game's —the harness
  jumps from anywhere— a couple of the themes' samples are missing too,
  because the still samples leave the ARAM fragmented into gaps.

The two ways of paying for it:

1. **Budgeting the whole inheritance** —each package has to fit with any of the
   themes that may come playing, sound effects included— is the
   "A+inheritance" column: `escape_newyork`'s polysynth at 4.2 kHz, the strings
   and the square wave at 5.8. Worse than today in the themes that matter.
2. **That the playing theme has priority and the sound effects wait**: the
   package is built the same, what does not fit is noted, and the first
   `PlayBGM` —which starts the theme from zero and silences the old one—
   uploads what was missing. It is step 1, and it costs a freeze the size of
   what was missing in that `PlayBGM`: with A, on the order of 10 to 25 KB in
   those jumps, that is, **15 to 35 frames**. The map's sound effects do not
   play between the arrival and that `PlayBGM`; on the game's 2 and 3, the page
   starts its theme before using them. A is this: the inherited themes count in
   the budget only as themes.

Option 2 is the one that makes A worth it; option 1 is not.

### The sound effects

They are the last thing of each package and go at 6 kHz, trimmed to 0.75 s
(map 1's thunder whole, at 22 kHz). In the budget per package they are a fixed
cost subtracted before splitting: that is why maps 2 and 3 are the ones that
limit. With step 1 they survive the inheritance; they already survived the
package change, because they belong to the package. If more room is ever
needed, 3's are the place to look for it: there are twenty, almost all from the
sequence at the end of the map, and the thunder at 6 kHz is there twice (on 3
and whole on 1).

### One sample per zone

Today each program carries the sample of the middle C zone. **34% of the
melodic note-time of the 32 themes plays 12 semitones or more from that
sample's root, on keys for which the SF2 has another.** And it is very
concentrated: 32 (theme, program) pairs play more than a quarter of their notes
in another zone, and many **all** of them —synth bass 33 in twelve themes plays
`MMBAS40` and not the 62 one; the saw of `escape_newyork` and of `hzstream`,
`SAW0_48`—.

* **The most used zone** (variant 3): each program carries the sample of the
  zone that adds up the most note-time in the cartridge, instead of the middle
  C one. **It costs no ARAM** —it is still one per program— and it is what left
  `3D-Galax` closest to the reference (highs: 11.8 dB of difference today, 7.3
  per package, 3.4 with the most used zone, 3.8 the ceiling). What it loses: a
  program that two themes play in different registers ends up right for only
  one.
* **Two zones** (variant 4, the ones with at least 15% of the program): **149
  samples instead of 116**, each one at a lower rate (median from 14.7 to 12.6
  kHz in the recorded themes). In the spectrum count it comes out worse than a
  single one, because the count measures highs and not timbre; it is for
  listening to in the lows.
* **Three zones** would be 151: almost nobody uses a third with more than 15%.

### How much it costs in frames, and where it is paid

The table above has each package's upload. Where it falls:

* **The map change**: in the fade, which is not seen. The worst goes from 77 to
  83 frames (1.4 s); maps 2, 3, 19 and 26 all end up there.
* **The battle**: today it freezes some 40 frames on entering and as many on
  leaving; with A, some 76 (1.3 s) each time. It is the only thing that would
  be seen often.
* **The title**: 15 → 31 frames, on appearing.
* **A `PlayBGM` in the middle of a scene**: none changes package —the themes
  each page starts are already in its map's package, and the common events have
  no `PlayBGM`—, except step 1's completion, which is what was missing and
  nothing more.
* **The startup**: 10 → 19 frames of work, inside the 112 it already waits.

### Cartridge, bank 0 and the suite

* **The `release` goes from 3,246,058 to 3,518,487 B used** with A (77.4% to
  83.9% of the 4 MB): 166 KB more of samples —each program at what its worst
  package gives, 116 samples— and 106 KB of stream, which is what the 19 themes
  that did not contribute had without a sample.
* **Bank 0 does not move with A**: it is all the converter's. With step 1 it
  went from 1,168 to 1,144 B free in `release`.
* **What breaks** on implementing A:
  `test_un_tema_pierde_sus_muestras_pero_nunca_su_numero` and
  `test_un_tema_que_no_aporta_pierde_notas_y_la_ROM_lo_dice` test the trimming
  of contributors, which goes away; the fingerprint of the 32 themes in
  `techos.toml`, which has to be measured again with `just techos`.

### Decisions that would have to be taken or rewritten

* **`decisiones/un-solo-banco-de-muestras.md` is not reverted with A: its
  reason is rewritten.** There is still one bank, one sample per program,
  uploaded in packages per map. What goes away is `build_varios`'s rule that
  the **whole** bank has to fit in the ARAM, and with it the trimming of
  contributors and `--banco-entero`. With B it is reverted: each theme has its
  copies.
* **A new one: when the theme that comes playing and the package do not fit
  together, the theme wins and the sound effects wait for the next
  `PlayBGM`.** It is step 1's, and the one that makes A possible.
* **`decisiones/el-arranque-esta-dimensionado-para-el-techo-de-aram.md`**: its
  "what would buy it" became stale —the multi-port loader already exists—.
  What is left to decide is whether `BOOT_CUADROS` is shrunk to the startup
  package (with A, 19 frames of work plus 9 of map: it could go down to some 48
  with margin and gain a second on power-up) with an assertion in the converter
  that the starting map's package fits in that time.
* **The battle at 1.3 s of freeze at each end**, instead of 0.7: taro's memory
  says that audio quality is worth a few frames of loading; this is half a
  second more, in each battle.
* **`wishlist/velocidad-presupuesto-percusion.md` goes away with A**: the loop
  that lowers the percussion 10% at a time is `Banco`'s, which A replaces.
* **`musica-del-lado-del-spc700.md`**: if the sequencer ever goes to the SPC700,
  it needs a buffer in the ARAM, and with A each package fills it. It would
  have to be reserved in the budget (it is changing the margin).

### The order of implementation, in verifiable commits

1. **Done: the package that did not fit is completed on the next `PlayBGM`**
   (commit "Audio: el paquete que no entró con otro tema sonando se completa en
   el próximo PlayBGM"). `PAQ_INCOMPLETO` and the rebuild in `tema_asegurar`.
   It already fixes the transition from 2 to 3. It is enforced by
   `test_el_paquete_que_no_entro_con_otro_tema_sonando_se_completa` with the
   case `paquete-incompleto`, which requires the package to have been left
   incomplete on arrival —otherwise it tests nothing— and goes red without the
   fix.
2. **The budget per package (A), in the converter.** The packages' lists are
   built before `build_varios` —the themes and the sound effects' names are
   already known; the sound effects' sizes come from `build_efectos`, which is
   deterministic— and are passed to it; `Banco` replaces the 40 KB and the
   percussion loop with the progressive filling; the trimming of contributors
   goes away. The converter also computes the realistic inheritance (the
   `Teleport`s and the `PlayBGM`s of each map, what `herencia.py` does) and
   **stops** if a package does not fit on its own, or if with an inherited theme
   the themes do not fit. It prints each sample's rate and which package
   limited it. Verification: the whole ROM with `SIN_CACHE=1` identical to the
   one with cache, `just techos`, `just pruebas` with the two trimming tests
   replaced by one that asks that each package fit and that all the themes have
   all their samples, and `test_cores.py` twice. To listen: variant 2.
3. **The most used zone** (variant 3), if taro prefers it by listening: the key
   with which each program's sample is requested goes from 60 to the root of
   its most used zone, and each note's pitch comes from that root. It does not
   change the ARAM. `just techos`.
4. **The resampling with a filter**, separately: `snes_samples.resample`
   interpolates linearly without filtering, and at 10 kHz from 22 that aliases.
   It only changes sample bytes; it is measured with the spectrum count and
   listened to. `just techos`.
5. **If more is needed**, in this order: lowering `BOOT_CUADROS` (decision
   above); giving the sound effects their own place in the directory —some
   twenty per package instead of the cartridge's 92— so that **B** fits for the
   programs that another theme's package limits (the oboe, the flute, strings
   48, the drums); and a second zone only where it can be heard.

# What to measure in the other themes

With the scripts of `tools/audio/proto/` on the prototype's branch:

* **The drums that come back**: measured in 0, with the table; measure it again
  with the envelopes in place before fixing the air.
* **Polyphony against 8 voices and lost note-time**: measured in 5, and the
  converter prints it per theme. The worst is `pn28year` (51%, with a floor of
  50%), then the battle (49%, floor 35%).
* **Which themes use CC7, CC10, CC11 and pitch bend**, and how much stream they
  would add.
* **Hits trimmed without a fade**: `_build_drum` cuts at 0.5 s without a fade,
  and the SF2's cymbal, ride and open hi-hat last longer and even bring a loop;
  that is a hard cut on every cymbal. In `escape_newyork` it does not happen
  —its four hits last less than 0.2 s—.
* **Notes far from middle C**, which play with the wrong zone.
* The battle one, `T_VGFighterMAX_Masako`, which is the heaviest and the one
  heard the most.

**The pitch bend range of 3D-Galax (95 semitones)**: taro decided to leave it as the MIDI asks, which is how fluidsynth plays it and how the Amiga version sounds (the last note of the phrase drops several octaves). On Windows with a GS synthesiser it would have been capped at 24. Respecting it costs nothing: the bend is already written the same way, only the pitch value changes. 2026-09-26.
