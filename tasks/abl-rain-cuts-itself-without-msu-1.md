---
name: "ABL's opening rain cuts itself without MSU-1"
description: "Without MSU-1, each new Rain1 on map 1 restarts the voice of the one still playing, and the rain dips almost to silence every four seconds"
type: bug
status: todo
---

Seen by Mulita on 2026-10-11 (`more-voices-for-the-sound-effects.md`),
tools `f29ec27a`, ports branch `mulita-voces`, ABL's `release`.

**What is heard**: on map 1, without MSU-1 —or with MSU-1 while the SPC700
plays music—, the rain fades almost to silence for about half a second
every four seconds, and comes back. With MSU-1 and the theme on its track it
no longer happens.

**What was measured**: a parallel process on map 1 (EV0013) plays `Rain1`
and waits 4.0 s, in a loop; `Rain1` lasts 5.0 s, fades in over its first
second and out over its last. In RM2k the two copies overlap for that
second. In the ROM a new copy with the same sample restarts the voice of
the one playing (`sound_play`, "the one already playing this same sample"),
so the old one loses its last 61 frames and the new one starts from its
quiet beginning: in the core's audio, without MSU-1, the mix drops from
~1,400 to ~110 RMS in a tenth of a second and climbs back over ~0.8 s. Without MSU-1 there are two effect voices,
and giving the rain a second one would take it from the thunder; a third
voice is point 2 of the task.

**How to see it**: case `lightning` of ABL's suite on `release`, without the
`.msu`, and listen from the second rain on —or the wavs in the task—.

## What to try

taro, on 2026-10-11, after hearing the fix with MSU-1 (in
`more-voices-for-the-sound-effects.md`): this goes to todo, with three
angles to compare. The first two reuse what was built for MSU-1; the third
needs no extra voice at all.

1. **More voices for effects**, with the same runtime allocator
   (`se_msu_choose` in `runtime/msu_effects.s`): a third voice, or more,
   taken from the music. It costs the music's polyphony —the voice
   allocation of `rm2k-snes/rm2k-snes-audio/src/voices.rs`—: measure how
   much, and how often the game really has three effects at once.
2. **The allocator over the two voices there are**: today a copy of the
   same sample restarts its own voice so that the rain doesn't take the
   thunder's. With the allocator, the second rain takes the other voice
   and overlaps; the thunder only competes when it sounds, which is not
   all the time, and then it steals —the voice closest to its end—. Measure
   how often the thunder lands on two rains and what is heard then.
3. **Loop points for effects, with the crossfade baked in**: let an
   effect declare a loop —in the project or by patch, as the rest of what
   the converter decides— and bake the overlap of the fade out and the
   fade in as the middle stretch of the sample, so a looping ambience like
   the rain needs a single voice and never cuts itself. That also changes
   how the parallel process that retriggers it is honoured: it has to know
   the effect is already sounding.

Compare them by ear —wavs, as in the MSU-1 fix— and by what each costs,
and say which one, or which combination.

