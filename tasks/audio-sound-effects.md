---
name: "Sound effects"
description: "PlaySound plays, with its samples in the map's package"
type: feature
status: done
---

### Sound effects

`PlaySound` plays. It compiles to `OP_SOUND` with the index of the
effect in `sonido_tabla`, which carries, per effect, the sample, the pitch, the
volume of each side and how many frames it lasts: RM2k's tempo stretches the pitch
and the duration, and the panning lowers the opposite side.

Three decisions, all three because of the ARAM:

* **They go per map**: see "Each map's audio package", below. Until
  then they made do with what the music left free, and of the 38 the
  demo asks for, 5 fit.
* **At 6 kHz and at most three quarters of a second** —it was one until the package,
  which has to upload them during the fade of each jump—. A longer one repeats its
  last 0.4 s until it lasts what it lasts in RM2k: the rain in the opening is
  five seconds of noise and that way it is heard whole.
* **The effect steals voice 7 from the music**, which is percussion. The ROM
  keeps a shadow of the registers of that voice that the music writes
  (`dsp_musica`), and when the effect ends it gives it back as it was; while it plays,
  the music doesn't touch it.

The suite doesn't measure audio: it compares images, and `OP_SOUND` doesn't cost a tick. What
was run was a recording of `abl`'s opening with the libretro core, against the
same ROM with the effects' volume at zero: the shots fall on frames 191, 433 and 576, and in the
gap between the end of the third and the next (frames 890 to 920) the two
outputs are identical sample by sample. That is, the music comes back whole.
Whether they sound good is for taro's ear to say.

`play_sound_effect` in move routes is still accepted without being performed.
