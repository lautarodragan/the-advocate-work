---
name: "Quality sound effects with MSU-1"
description: "With MSU-1, the sound effects at whatever rate fits, in full, from the .msu, and the DSP's eight voices when the SPC700 isn't playing music"
type: feature
status: done
assignee: taro
---

# What

taro's request, on 2026-09-26: **when the music goes through MSU-1, the sound
effects have to sound at their maximum quality, with their full length, and
with all the voices possible.** Without MSU-1 nothing changes.

It absorbs point 1 of `more-voices-for-the-sound-effects.md` (with MSU-1, all the
voices for effects) and plan B of
`with-msu-1-the-theme-samples-arent-uploaded.md` ("the quality effects from
the `.msu`").

# The design, with its numbers

Measured on `release` at `b521ffb` and again after merging `d44b906` —the
other agent's full effects—. The numbers below are from that moment: **each
package's rates are printed by the converter** ("efectos de calidad del
paquete N" in `conversor.log`), and they change with each package's themes
and effects.

## What ARAM there is: maximum quality doesn't fit in the big packages

With MSU-1 the samples of the themes with a track aren't uploaded, so for the
effects there's the whole ARAM: 63,419 B of samples, minus the 1 KB margin
the music also leaves. The 92 effects of `release` in full at their WAVs'
rate (22,050 Hz, except `clap` at 11,025) are **1,142,208 B**; the cartridge
carries 420,399. Per package:

| package | effects | full at 22 kHz | fits? |
|---|---:|---:|---|
| 3 | 20 | 291 KB | no, not even close: a fifth fits |
| 2 | 18 | 201 KB | no |
| 19, 11, battle, 1, 32, 261, 26, 9, 7 | 5–11 | 66–90 KB | no, barely |
| 20, 52 | 7, 3 | 65, 46 KB | almost |
| the other seventeen with effects | 1–8 | 6–60 KB | yes |

In other words, "maximum quality and full" fits in half the packages, and in
3 and 2 one has to choose between rate and length. **Length was chosen**,
which is what taro asked for first: all the effects go in full, and the rate
is the highest that fits.

The only thing that would give maximum quality in 3 is uploading each effect
when it's requested, and that can't be done: the SPC700's port uploads some
41 KB per second with the whole CPU dedicated (1.45 frames per KB, measured
in step 6 of the music), so a 17 KB effect would freeze the game a third of a
second each time; and playing it while it uploads —a ring buffer— would eat a
third of the CPU per effect playing. It wasn't attempted.

## How it's allocated: one version per package

Each package has its own version of each effect, at the rate that fits it: a
single one for all its effects —from `TASAS`, in `tools/audio/efectos_msu.py`—,
with a floor per effect: **if the cartridge already carries it in full, it
can't end up worse than without MSU-1**. One the cartridge carries trimmed may
end up at a lower rate than there, but in full.

The alternative was one version per effect, the one that fits its worst
package, which saves the ROM from knowing which version is in ARAM. Measured:
**48 of the 159 (package, effect) pairs lost**, almost all from sharing
effects with map 3, which left at 4.7 kHz effects of 11, 19, 20, 23, 32, 33,
52, 74 and 133 that have room to spare. What the per-package version costs is
that the ROM doesn't store which version ended up in ARAM —there's no RAM:
it's 32 bytes for all of this—, so **with the `.msu` each package's effects
are always uploaded again**, even if they were already there.

What ended up in `release` after merging `d44b906`: at 22,050 Hz packages 8,
10, 12, 13, 14, 16, 17, 18, 21, 23, 28, 30, 33, 74, 133, 255 and 269; at
14–20 kHz 1, 7, 9, 11, 19, 20, 26, 32, 52 and battle; **2 at 6.5 kHz, 3 at
6 and 4 kHz** —the nine the cartridge already carries in full at 6, the
eleven it carries trimmed at 4—, and 261 and 121 low because their themes
have no track and take up the ARAM. When all themes have a track
(`every-theme-has-an-msu-1-track.md`) those two go up on their own.

## Where they come from: the `.msu`

The assignment's two options:

* **(a) in the `.msu`**, uploaded to ARAM through the data port, with the
  signature and the fallback to ROM of the battle backgrounds. It's the one
  chosen.
* **(b) in the ROM.** The versions for all packages are **1.25 MB** —what
  they take in the `.msu`—, and `release` has some 1.7 MB free of its 4
  (measured counting the padding at the end of each bank; the 4 MB are
  LoROM's cap). It would fit, but it would be 1.25 MB of cartridge that's
  useless without MSU-1, and it would leave the ROM half a megabyte from the
  ceiling.

**The upload time per byte is the same in both**: the bottleneck is the
SPC700's port, not where the byte comes from. What the `.msu` adds is the
seeks, and they're done **once per package**: each package has its effects
contiguous in the `.msu`, in SRCN order, which is the order in which
`subir_colocadas` uploads them, so the ROM seeks the first one and reads
straight through (an effect that's in two packages goes twice; the file has
no cap). In Mednafen a seek is one or two frames; in snes9x and bsnes,
nothing; on the FX Pak, reading the card —not measured—.

**If the `.msu` doesn't match** —from another build, empty, or without
MSU-1— the signature isn't there and everything comes from the ROM as always
(`MSU_SE` at 2). It's checked once per power-on, at the first package load.
If a seek doesn't arrive in time, that effect isn't uploaded and doesn't
sound: the ROM can't fall back to its version, which has another pitch. No
emulator here takes that long; no test runs that path.

## How many voices: all eight, when the SPC700 isn't playing music

7 and 6 are still the usual ones, with their state and their shadow. 0 to 5
belong to the effects **while there's MSU-1 and `music_apagada` is set**
—a track is playing, or nothing—. The rule for the new effect, in
`sonido_tocar`:

1. 7 or 6 if they're already playing that same sample (the rain);
2. one of 0 to 5 that's already playing that sample;
3. 7 or 6 if free;
4. one of 0 to 5 that's free;
5. otherwise, the usual between 7 and 6: the one that ends first.

7 and 6 first because they're the ones that survive a theme change.

What had to be taken care of:

* **A theme without a track at the same moment**, or a missing track
  (`MSU_FALTA`): the theme plays through the SPC700, `music_apagada` is at
  zero and 0 to 5 belong to the music. They aren't taken.
* **A theme that moves to the SPC700 in the middle of an effect** on one of
  0 to 5: the effect continues. What the music writes to that voice stays in
  `MUS_SOMBRA` and isn't sent —`dsp_musica`, with a table that gives each
  register's voice bit—, its KON and KOF go out without that bit, and when
  the effect ends it's given back from `MUS_SOMBRA`. It's what already
  happened with 7 and 6, with the music's shadow instead of one of its own.
  **No test runs this**: it would need a theme without a track starting
  while three effects are playing.
* **A theme that moves to MSU-1** in the middle of an effect: `music_start`
  writes KOF at $FF, which cuts all the effects, the ones on 7 and 6
  included. It's from before, and wasn't touched.
* **Battle**: its theme has a track, so with MSU-1 its effects have all eight
  voices and its package its quality version.

## The RAM and bank 0

`$7E78B0-$7E78CF`, the one allotted for this, is used up:
`ram_lejana.s`. The state of 0 to 5 stores the sound's index and not the copy
of the row, and the interrupt reads it when starting it.

The code lives in bank 1 (`rom/src/efectos_con_msu.s`), with `jsl` from the
hooks. **Bank 0: 93 bytes**, measured with `.res` in `release` —from 619
free to 526— and in `test-special` —from 1,317 to 1,224—.

# What it costs

**Longer loads with the `.msu`**, because ARAM fills up with effects and they
are always uploaded. Frames with the loop still, in snes9x, `release` with
MSU-1 and all the tracks, from 5, with an empty `.msu` (the ROM's effects,
which is the before) and with the cartridge's:

| jump | ROM effects | from the `.msu` |
|---|---:|---:|
| to 2 | 73 | 107 |
| to 3 | 71 | 107 |
| to 26 | 80 | 100 |
| to 8 | 47 | 108 |
| to 10 | 21 | 51 |
| entering battle (up to the menu) | 113 | 161 |

What can be adjusted if it weighs: the ceiling of `TASAS` —with a 16 kHz cap
8 would drop to some 80 frames— or going back to the per-effect version.

**Without MSU-1, the audio comes out with the same pairs to the DSP but
shifted some cycles**: the hooks add instructions inside `irq_musica` (an
`lda` and a jump per music write, two `jsl` per frame). Measured against
`main` over 6,000 frames of the title and the opening without MSU-1: the
envelope correlates at 0.99978 and 8 of 6,193 frames differ by more than 5%,
around the change from the title to the game; the individual samples aren't
byte-for-byte equal.

# How it's tested

`pruebas/abl/test_msu_efectos.py`, with MSU-1 and all the tracks on a copy
of `release`, and two new cases:

* `efecto-de-calidad`: `Success2` on map 10. With the cartridge's `.msu` it
  starts with the 22,050 Hz pitch, its envelope follows the WAV's and it ends
  silent —the trimmed one repeats its last stretch until the end—, and with
  the `.msu`'s samples changed and the signature intact it sounds different.
* the same case with a `.msu` from another build (signature recomputed)
  sounds the same as with an empty one, with the `sonido_tabla` row.
* `tres-efectos`: `Glass`, `Flash3` and `Earth4` in the same frame, on 3 with
  `evilrhys` on the track: 7, 6 and one of 0 to 5, three different samples,
  and the same run with 0 to 5 switched off just before sounds different.

**Seen failing**, rebuilding `release` with one piece switched off each
time:

* without voices 0 to 5 or the `.msu`: the quality one fails (`MSU_SE` at 2)
  and so does the three-effects one (no voice among 0 to 5);
* accepting any `.msu` without checking the signature: the other-build one
  fails;
* uploading from the ROM with the ROM's pitch: the quality one fails (pitch
  768 against 2,822);
* uploading from the ROM with the `.msu`'s pitch: the quality one fails (the
  envelope correlates 0.23 with the WAV's).

`test_msu_datos.py` now counts the background entries with `MSU_FONDOS_N`:
the `.msu` carries the effects after them.

Run on the branch with `d44b906` merged: `just cartuchos`, `just pruebas`
green and `test_cores.py` twice; and `release` built with `SIN_CACHE=1`
comes out with the `.sfc` and the `.msu` byte-for-byte identical, because the
quality versions go through the BRR cache.

**What no test runs**: the wait for the seek in the `.msu` and its cut-off
by cap (like the backgrounds'), and a theme moving to the SPC700 with an
effect playing on voices 0 to 5.

# For taro

On the FX Pak, with the tracks and the build's `abl.msu` alongside:

* **the load times**, above all entering 2, 3, 8 and battle: here each one is
  a seek on the card and a full package; if they feel long, the rate ceiling
  is lowered;
* that the effects sound, and in full: the thunder and the rain of the
  opening, `Sword3` on 26, the battle ones, the ones on 3;
* the `evilrhys` scene on map 3, which can now play three effects at once.

And listen to `/shared/audio/2026-09-26-efectos-con-msu/`, with its `LEEME.txt`.
