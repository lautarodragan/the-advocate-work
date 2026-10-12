---
name: "More voices for the sound effects"
description: "With MSU-1 the DSP's eight voices are free for effects; without it, evaluate; and the long-tail effects, trimmed by patch"
type: feature
status: doing
agents: [Mulita]
assignee: Mulita
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

