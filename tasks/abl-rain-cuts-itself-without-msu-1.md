---
name: "ABL's opening rain cuts itself without MSU-1"
description: "Without MSU-1, each new Rain1 on map 1 restarts the voice of the one still playing, and the rain dips almost to silence every four seconds"
type: bug
status: draft
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

**How to see it**: case `relampago` of ABL's suite on `release`, without the
`.msu`, and listen from the second rain on —or the wavs in the task—.
