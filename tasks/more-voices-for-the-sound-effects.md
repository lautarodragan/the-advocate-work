---
name: "More voices for the sound effects"
description: "With MSU-1 the DSP's eight voices are free for effects; without it, evaluate; and the long-tail effects, trimmed by patch"
type: feature
status: done
agents: [Mulita]
assignee: taro
---

Request from taro on 2026-09-26, for after today's suite (not now).
Today the effects have two voices (6 and 7). While verifying map 3 a
moment in `evilrhys`'s scene was seen with three effects at once: one doesn't
sound.

1. **With MSU-1, all voices for effects.** Done on 2026-09-26, in
   `quality-sound-effects-with-msu-1.md`: while the SPC700 doesn't play music, the
   effects also have voices 0 to 5. What remains here is without MSU-1.
2. **Without MSU-1, evaluate it**: a third voice is taken from the music, and the
   voice allocation (`quality-of-the-music.md`, step 5) loses polyphony.
   Measure how many times it happens in the game that three effects sound at once and
   how much it costs the music.
3. **Three effects at once is rare**: if the cases are due to an effect with
   a long tail (fade out), the simplest thing is to **edit that effect** —
   trim its tail— with the patch system that already exists
   (`parches/manual/`, see `parches/README.md`), instead of adding voices.

## taro, on 2026-10-11

The rain of ABL's opening sounds ugly because of its tail: it seems to be
retriggered while the previous one is still sounding, and the new one
cuts the old. In RM2k sounds never cut each other: playing a 3 s sound
three times, 1 s apart, has three moments of the same sound playing at
once for about a second. That is the behaviour to reach, as far as the
voices allow.


## With MSU-1: copies overlap (Mulita, 2026-10-11)

taro narrowed it the same day, through Hornero: only the MSU-1 case, and
the path without MSU-1 has to stay exactly as it was.

**The hypothesis held**, measured on ABL's `release` (tools `01388b04`,
ports `f632ca8`). On map 1 a parallel process (EV0013) plays `Rain1` and
waits 4.0 s, in a loop, with the thunder in one of the turns. `Rain1`
lasts 5.0 s (300 frames in `sound_table`) and is made to overlap: it fades
in over its first second and out over its last. `sound_play` gave a new
sound with the same sample to the voice already playing it —on purpose,
so the rain did not take the thunder's voice when there were only two—,
and with MSU-1 `se_extra_same` did the same on voices 0 to 5. So each
turn restarted voice 7 with **61 frames of the old rain still to play**,
and the new one started from its quiet beginning: in the core's audio the
rain drops from ~900 to ~80 RMS in a tenth of a second and takes ~0.8 s to
come back, at 9.2, 13.2 and 17.2 s of the recording. That is the ugly
tail. Without MSU-1 it is the same code path, and the same dip (~1,400 to
~110 with the music).

**What was done**: `se_msu_choose`, in `runtime/msu_effects.s`. While
voices 0 to 5 belong to the effects (MSU-1 and `music_off`), every
`PlaySound` takes a free voice of the eight —7, 6, then 0 to 5—, the same
sample included, and only when all eight are busy it steals the one with
the fewest frames left (a pending one counts as whole). Nothing is baked by
the converter. Without MSU-1, or with the SPC700 playing music, it returns
C at 0 and `sound_play` does what it always did. `se_extra_same` and
`se_extra_free` are gone: they only acted in that same condition, which now
never reaches them. The DSP's ENDX was not used: the driver only writes to
the DSP, and the frames come from the WAV's length, so a whole effect
frees its voice when it ends.

`msu-sound-effects-each-at-its-own-rate-and-only-those-that-coexist.md`
does not get in the way: its idea 2 (only what coexists in ARAM) was not
implemented, so nothing assumes which effects sound together; the rates
are per package and the allocator does not look at them.

**How it was checked**:

* new test in ABL, `test_con_msu_la_lluvia_que_vuelve_no_corta_la_anterior`
  in `pruebas/abl/test_msu_efectos.py`: red before ("in tick 551 the rain
  started again on voice 7, which still had 61 frames of the previous
  one"), green after (the new one on voice 6, both sounding).
* **without MSU-1, unchanged**: 25 s of map 1 (case `relampago`) recorded
  from the core with the ROM before and after: the audio is byte for byte
  equal. And the whole suite, which runs without MSU-1.

**The recordings**: `~/scratch/mulita/audio/2026-10-11-lluvia/`, with a
`LEEME.txt`; for taro, the `despues-con-msu.wav` against `antes-con-msu.wav`.

## What remains

Without MSU-1, in its own task: `abl-rain-cuts-itself-without-msu-1.md`,
in todo, with the three angles taro proposed on 2026-10-11. taro heard the
wavs with MSU-1 the same day and declared it fixed: done.

## On merging

* the-advocate `mulita-voces`: the runtime only, no Rust. **Nothing to
  reinstall**: the global tools assemble the runtime of `~/the-advocate`,
  so the merge there is enough for the next `just cartuchos`.
* the-advocate-ports `mulita-voces`: the test and the suite's README.
* the-advocate-docs `mulita-voces`: internals/audio.md and the known issue.
