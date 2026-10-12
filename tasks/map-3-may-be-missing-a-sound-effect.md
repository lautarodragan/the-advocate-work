---
name: "Map 3 may be missing a sound effect"
description: "It is missing none: the package arrives incomplete, but what is missing is not asked for until evilrhys's PlayBGM completes it"
type: bug
status: done
---

# What

**It has to be investigated.** It may be that on entering map 3, the Emitter
Room, from 2, its audio package does not fit whole in the ARAM and its last
sound effect gets dropped.

# Where it comes from

From the investigation of `sound-effects-without-cuts.md`, on 2026-09-24.
**It is a calculation, not something measured in the ROM**: a sub-agent added
up the sizes from `abl`'s `musicdata.inc`.

* map 3's package, music plus sound effects, was one of the two heaviest in the
  game;
* during the fade of the 2→3 jump the sample of the theme that had been playing,
  `TF3_1_awe`, stays fixed in the ARAM;
* added up, they went over the space there is for samples by some 2.5 KB.

# What was measured, on 2026-09-26

Against `main` at `b581d4e`, which already brings the whole sound effects
(`4c2fa8e`), the theme that wins and the exit themes. Up to `4939386` nothing
in the audio changed. Without MSU-1 and with MSU-1, in `release`, with a
throwaway script that notes every frame which samples of map 3's package are in
`FAR_ARAM_DE`, which theme is playing, `PAQ_INCOMPLETO`, the sound effects that
start on the two voices (`SE_CUADROS` going back up) and the frames in which
`vueltas` does not advance.

**The path**: the opening played, `viajar(2)`, an `ir_al_mapa` next to the
elevator within the same map 2 —the walkthrough does not know how to play the
rest of the map—, switch 11 and the touch with event 30, which is what the game
does. On 3, walking to the tremor at (47,69), the door at (38,68) and the whole
scene up to the jump to map 4.

**A correction to the premise: 3 is not loaded with `TF3_1_awe` playing.** What
plays throughout map 2 is `escape_newyork`, the theme of the opening on 1: the
game's only `PlayBGM` of `TF3_1_awe` is the one the elevator page does **after**
the `Teleport` to 3. The case `paquete-incompleto` starts `TF3_1_awe` on 2 by
hand, so it exercises the same mechanism with another theme; its test's
docstring and the comment on `tema_asegurar` say that the game's transition
happens "with map 2's theme playing", and it is not so.

## Without MSU-1

Hardware frames from the arrival at 3:

    0     arrives with escape_newyork playing (35,793 B fixed). evilrhys and
          the first five sound effects go in: Earth2, Open1, Switch1, Switch2,
          Key. PAQ_INCOMPLETO at 1; fifteen sound effects missing
    0-55  frozen under the fade (the map load)
    101   the fade ends and the PlayBGM TF3_1_awe runs: it silences the music
          and rebuilds the package with TF3 first
    101-187  frozen, with the picture up and without music: 86 frames
    187   TF3_1_awe plays. Nine sound effects went in (up to Glass); ten are
          missing, from Earth4 to Fog2. PAQ_INCOMPLETO stays at 1: TF3 +
          evilrhys + the 20 sound effects do not fit in the ARAM in any way
    347   Earth2, the tremor: it plays
    479   Open1, the door: it plays
    778   the door's FadeOutBGM
    1044  PlayBGM evilrhys: releases TF3 and completes the package. 34 frames
          frozen, with the music already faded and between two messages
    1078-3362  the scene: the package's 20 sound effects play, every time
          they are asked for
    3496  PlayBGM lufsorr, on the way out: it uploads alone, 12 frames, and
          on to 4

**No sound effect is missing.** While the package is incomplete —from frame 2
to 1044, some 17 seconds— the map asks only for Earth2 and Open1, and both are
there from the arrival because they are the first on the list. Everything that
was missing is used only after evilrhys's `PlayBGM`. It is the design of
`decisions/the-playing-track-wins-and-the-sound-effects-wait.md` working.

## With MSU-1

The three themes go through a track, so none takes up the ARAM: the package
arrives **whole**, `PAQ_INCOMPLETO` never turns on, there is no freeze other
than the fade's and the same sound effects play on the same frames.

# The gap that is heard, without MSU-1

**86 frames, 1.4 seconds, of frozen picture and silence** right after map 3
appears, because of `TF3_1_awe`'s `PlayBGM`. It is not because of the sound
effects: TF3 is not in map 3's package, so it has to be uploaded anyway. What
was uploaded in those frames, comparing `FAR_ARAM_DE` before and after:

* 61,614 B in total, at some 720 B per frame;
* **25,623 B were already in the ARAM** —evilrhys and the five sound effects of
  the arrival— and were uploaded again in another place, because the package
  was left incomplete and `paquete_cargar_ya` rebuilds it all from zero
  (`compactar`);
* that rebuild gains at most one sound effect, Glass, which is not used until
  after evilrhys, which completes the package anyway.

Sizes measured in the cartridge: escape_newyork 35,793 B, TF3_1_awe 25,875,
evilrhys 19,377, the 20 sound effects 43,029, and the sample ARAM is 63,419
(`ARAM_DATOS` to `ARAM_FIN`).

# What would be needed, without lowering the quality of anything (not implemented)

1. **Not compacting when it cannot help.** `compactar` exists for
   fragmentation: a package that fits alone and was left out because of the
   gaps. If what is wanted (`FAR_QUIERE` other than zero) adds up to more than
   the ARAM, rebuilding from zero only reorders, and here it costs ~36 of the
   86 frames. A sum of `muestra_tabla + 3` over the marked ones before
   compacting is enough to know it. The freeze would go down to ~50 frames:
   what TF3 takes. It does not touch anything's rate; the only thing that
   changes is that a couple fewer sound effects may go in until the next
   `PlayBGM`, and on this map none is used in that stretch.
2. **Uploading TF3 without silencing escape_newyork.** escape (35,793) and TF3
   (25,875) fit together (61,668 of 63,419): `tema_asegurar` could release the
   package, upload the new theme next to the one playing and only then switch.
   The game would stay frozen all the same —the upload is not asynchronous— but
   without the silence. It is more work and it touches the same routine as the
   agent of "Two audio bugs in the ROM".
3. What does **not** work: uploading TF3 on arrival, under the fade. Next to
   escape_newyork there are 1,751 B left, and Earth2 and Open1, which the map
   asks for before evilrhys, are 3,780.

# In passing, what does not play on 3 and is not the package's fault

* **The sounds of the routes.** The evilrhys scene asks for a dozen inside
  forced routes —Decision1, Blow1 to Blow6, Shot2 and Switch1— and the
  converter drops them on purpose: see `RUTA_SONIDO` in
  `tools/port/eventos.py`. That is why those names are not even in map 3's
  package. No task has it.
* **Three sound effects on the same frame, with two voices.** On frame 2799 the
  page asks for Explosion4 and Glass together, and animation 79 fires Flame2 on
  the same one: Glass does not get to play. It is the two-voice limit of
  `efectos_de_sonido.s`, not the ARAM.
