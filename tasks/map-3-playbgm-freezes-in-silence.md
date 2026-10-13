---
name: "Map 3's PlayBGM freezes in silence"
description: "Without MSU-1, when map 3 appears the game stays frozen and silent for 86 frames uploading TF3_1_awe, and half of it is uploading again what was already there"
type: bug
status: done
assignee: taro
---

Measured on 2026-09-26 while verifying `map-3-may-be-missing-a-sound-effect.md`:
without MSU-1, as soon as map 3 appears (after the fade) the `PlayBGM
TF3_1_awe` freezes **86 frames (1.4 s) with the picture still and in silence**.
TF3 is not in map 3's package and has to be uploaded, but of the 61,614 B that
are uploaded, **25,623 were already in ARAM** (evilrhys and the first 5
sound effects): `compactar` rebuilds everything from scratch when the package was left
incomplete, and rebuilding gains at most one sound effect that is not used until later.
With MSU-1 it does not happen.

The agent's proposals, not implemented, without lowering the quality of anything:
1. **Do not compact when what is wanted would not fit in ARAM anyway**
   (add up the sizes of the marked samples before rebuilding): ~36
   frames fewer, the freeze would go down to ~50, what TF3 alone takes.
2. **Upload TF3 next to escape_newyork without silencing it** (they fit together:
   61,668 of 63,419 B): it would still be frozen but without the silence. It touches
   `tema_asegurar`.

Incidentally: the docstring of `test_the_package_that_did_not_fit_with_another_song_playing_completes`
and the comment of `tema_asegurar` say that the real transition from 2 to 3 happens
"with 2's theme playing"; that is not so (on 2 escape_newyork plays, which
comes from 1). The case `package-incomplete` turns on TF3 by hand and exercises the
same mechanism: fix the prose.

## Taken on 2026-09-30

Decided by Hornero: proposal 1 is done —do not rebuild ARAM when what
is wanted would not fit anyway— and, if the measured time justifies it, proposal 2 —do not
silence the theme that is playing while the new one uploads—. Without lowering the quality of
anything. Incidentally, the prose that gets wrong how one gets from 2 to 3.

## What was done, on 2026-09-30 (Cachirla)

**Proposal 1, done.** `package_load_done` adds up, in `exit_q`, what the
package wants —the theme that is playing, the extra, the package's themes and their
sound effects; not the exit ones, which have no reason to fit— with
`wanted_fits`, and if it does not fit even with ARAM empty it leaves `PKG_COMPACT` at 2
and does not rebuild. Unless what was left out is a theme: there rebuilding does
help, because it puts themes first, and it rebuilds as before.

Measured with the new case `step-to-3` —escape_newyork on 2, `Teleport`
to 3 and `PlayBGM` of TF3_1_awe, like the lift page—, in
hardware frames with the music silent and the picture still:

    before (3d83de68)   86
    with proposal 1     38

And the arrival, under the fade, 53 instead of 55: there it does not rebuild either.
With TF3 playing ten of the package's sound effects remain instead of nine, and
evilrhys, Earth2 and Open1 do not move from where they were.

**Proposal 2, not done.** Uploading TF3 next to escape_newyork without
silencing it is not achieved just by not silencing: on arrival, next to escape
evilrhys and the first five sound effects are already there, and TF3 does not fit with them.
They would have to be released to upload TF3, and then Earth2 and Open1 are lost, which
the map asks for before the `PlayBGM` of evilrhys —the tremor and the door—:
escape (35,793) + TF3 (25,875) + those two (3,780) exceed the sample
ARAM (63,419). Uploading them again with TF3 already playing would be a second
load and a second freeze, with the picture still for longer in
total, in exchange for there being no silence. With 38 frames the numbers do not add up;
if taro hears that the gap is bothersome, that is the way.

**The test:** `test_going_from_2_to_3_does_not_upload_what_was_there_again`,
in `rom/pruebas/rpgmaker/test_musica_paquete.py`. It requires that what was in
ARAM before the `PlayBGM` does not move and that the silence does not exceed
`TOPE_DEL_PASO_AL_3`, one second. With the old runtime it goes red: 26 samples
move. To see where each one is, `places_in_aram`
in the harness.

**The prose**, in its own commit: the docstring of
`test_the_package_that_did_not_fit_with_another_song_playing_completes` and the
comment of `song_ensure`.

**The audio**, to listen to: `/shared/audio/2026-09-30-mapa-3/`, the transition
before and after, with the SPC700 alone.

**What is paid, and was not seen on any map:** without rebuilding, which sound effects
fit in the gaps is decided by the order they were left in, not that of the
list. On 3 more fit than before; in another transition with a package that does not
fit, one from the front of the list that used to fit could be left out,
until the next `PlayBGM`. `just tests` does not look at that outside 3.

**On merging:** nothing needs to be installed. `tools/runtime/` changed, which the
global one builds from the main checkout, and no Rust project.
No golden moved.

**What to play:** without MSU-1, the lift from 2 to 3. Between map 3
appearing and TF3_1_awe playing there is a silent gap with the picture still: it has
to be shorter than before. And on 3, that the tremor and the door sound.
