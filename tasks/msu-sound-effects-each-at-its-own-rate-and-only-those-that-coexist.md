---
name: "The .msu's sound effects, each at its own rate and only those that coexist"
description: "With MSU-1 all the sound effects of a package go at a single rate, the one at which they all fit together in ARAM: one long one drags the others down"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-28, when putting the take-off's `Thunder9` into the battle: with
MSU-1, the battle's quality sound effects went down from 14000 to 12000 Hz, all of them,
because of a single two-second thunder. It is not urgent, because 12000 Hz with MSU-1 still
sounds good. On 2026-09-30 he asked for it to be done.

# Why it happens

`rates_per_package` (`tools/rm2k-snes/rm2k-snes-audio/src/effects.rs`, formerly
`tools/audio/efectos_msu.py`) chose **one rate per package**: the highest of
`RATES` at which **all** the package's sound effects fit, whole, in what
the music leaves free of ARAM. The ROM uploads them all when loading the package
(`se_msu_prepare` and `se_msu_upload`, in `tools/runtime/msu_effects.s`). The
`.msu` has no ceiling: the limit is the 64 KB of ARAM.

# Two ideas, from less to more

1. **One rate per sound effect within the package.** It belongs to the converter; it needs
   checking whether the runtime assumes a common rate anywhere.
2. **That only what can sound together is in ARAM**: uploading a sound effect
   when it is requested, or by groups that come from a static analysis of the
   pages.

# What was measured (2026-09-30, Zorzal, on `f7e53b3a`)

All on `release`. Each package has 62,395 B for sound effects (63,419 of
samples minus the 1 KB margin; with MSU-1 the music of all the packages
has a track and takes up nothing). The scripts, in `<scratchpad>/zorzal/`.

**What "how much it loses" is measured with**: the part of what is heard of each WAV
—its spectrum weighted with the A curve— that lies above what
resampling to that rate lets through (0.9 of half). Without the weighting, the rumble
of a thunder, which carries almost all the energy, says nothing is lost
when the crack goes.

**The runtime does not assume a common rate**: the pitch of each sound comes from
`se_msu_pitch`, which the converter builds per package with the rate of each
sound effect's version. Idea 1 belongs only to the converter.

## Three criteria for idea 1

Over the fourteen packages that do not fit whole at 22050 Hz:

* **single rate** (what there was before);
* **lower the heaviest first**, what this task proposed;
* **lower first the one that loses least of the audible per byte it frees**, and
  at equal loss the heaviest; at the end what is left over goes back to the one that
  recovers most per byte, only if it recovers something.

"The heaviest first" left **the package's worst sound effect worse than the single
rate in five packages**: 1 (`Rain1` 12→33%), 11 (`Glass` 37→79%),
19 (`Glass` 56→84%), 39 (`Sand Storm` 7→48%) and 99 (`misslesnd`
3→48%). The long sound effects are often the high-pitched ones —a glass, a
sandstorm—, and lowering them for being heavy is the opposite of what was
wanted. "The one that loses least" **does not make the worst of any package worse** and
improves the mean in all of them. That one was implemented; the why is in the comment
of `fit`, in `effects.rs`.

## Before and after, per package

Loses: the package's worst sound effect / mean. Bytes: what is uploaded when loading it.

| package | before | after | bytes before → after |
|---|---|---|---|
| battle | 57.5% / 9.1% | 5.4% / 1.0% | 62,010 → 62,280 |
| 2 | 68.9% / 18.3% | 41.6% / 10.0% | 59,121 → 62,316 |
| 3 | 90.4% / 35.4% | 90.4% / 27.8% | 61,992 → 62,370 |
| 7 | 14.5% / 3.2% | 5.8% / 1.6% | 58,563 → 62,037 |
| 11 | 36.7% / 7.7% | 7.0% / 2.1% | 62,235 → 62,370 |
| 19 | 56.0% / 7.6% | 2.8% / 0.7% | 57,312 → 62,316 |
| 26 | 2.2% / 0.4% | 0.2% / 0.0% | 62,190 → 62,361 |
| 32 | 1.2% / 0.7% | 0.1% / 0.0% | 58,572 → 61,542 |
| 39 | 18.4% / 8.9% | 14.5% / 5.7% | 61,479 → 62,208 |
| 99 | 6.1% / 2.0% | 0.7% / 0.3% | 53,901 → 62,028 |
| 261 | 1.2% / 0.3% | 0.0% / 0.0% | 58,806 → 61,902 |
| 9, 20, 49 | 0% | 0% | +45, +2,430, +1,629 |
| 1 | 12.4% / 6.8% | same: `Rain1` and the thunder stay at 16000 | same |

The battle, sound effect by sound effect:

| sound effect | lasts | before | after | loses before → after |
|---|---|---|---|---|
| `Attack2` | 0.70 s | 12000 | 22050 | 57.5% → 5.4% |
| `Escape` | 0.46 s | 12000 | 20000 | 11.6% → 0.0% |
| `Thunder9` | 1.92 s | 12000 | 14000 | 1.8% → 1.6% |
| `Item2` | 1.14 s | 12000 | 14000 | 1.0% → 0.3% |
| `Bite` | 1.00 s | 12000 | 14000 | 0.4% → 0.1% |
| `Damage1` | 0.61 s | 12000 | 12000 | 0.3% |
| `Evasion1` | 0.38 s | 12000 | 11025 | 0.0% |
| `Monster1` | 2.99 s | 12000 | 6000 | 0.0% → 0.5% |

The 5.4% of `Attack2` is what it loses at 22050 Hz too: it is the ceiling.

**What gets worse**: the rule minimises what the package loses in total, so
in the very loaded ones some go down so that others go up a lot. In 2
(18 sound effects) `Explosion3` goes from 6500 to 4000 (5% → 23%) and `Holy3` from 6500 to
16000 (69% → 10%); in 3 (20 sound effects) `Flash3` from 4000 to 3000 (64% →
77%) and `Key` from 6000 to 16000 (47% → 8%). In the rest, what goes down loses
less than one point.

**What it costs**: more bytes to upload in the loads where the single rate
left room unused, at 1.5–1.65 frames per KB (below): 99 some 13
frames more, 19 some 8, 2, 7, 32 and 261 some 5, the battle
less than one. A package that fits whole at 22050 does not change. It is "audio
quality before load time"; if it weighs, `fit` does not upload what recovers nothing, and
what could be touched is not filling to the top the packages that already
ended up fine.

## Idea 2: how much it would gain and how much it would cost

**Uploading a sound effect through the MSU-1 port** costs the same as uploading it from
the ROM —the same command 3 of the driver, three bytes at a time, with the CPU
dedicated— plus three reads of `MSU_DATA` per trio. From the loads table
of `quality-sound-effects-with-msu-1.md` (snes9x, the cartridge's `.msu` against
sound effects from the ROM) and the bytes of each side: **1.64 frames per KB** on 8,
**1.51** on 10 and **1.58** in the battle; from the ROM, 1.45 (`emit.rs`). Plus
one lookup per package, one or two frames in Mednafen. Music playing
changes nothing: with MSU-1 the music belongs to the MSU-1 and does not go through the
port.

So **uploading on request does not work**: `Thunder9` at 22050 is 23.8 KB,
some 38 frames —more than half a second— with the game frozen before it
sounds, and a battle hit has to sound on the frame it lands.
Uploading it in pieces per frame without freezing would delay it even more.
The only thing that would make sense is **groups uploaded at a boundary** —when starting
a scene, when opening the battle—, which is another package load: ~100 frames
per full group.

**How much it would gain**: the ceiling is every sound effect sounding at 22050 Hz, and with
idea 1 it is already less than a point away from that (mean) in all the packages
except four:

| package | at 22050 weighs | idea 1: worst / mean | ceiling: worst / mean |
|---|---|---|---|
| 3 | 291 KB | 90.4% / 27.8% | 2.8% / 0.3% |
| 2 | 201 KB | 41.6% / 10.0% | 1.5% / 0.2% |
| 39 | 90 KB | 14.5% / 5.7% | 5.8% / 0.8% |
| 1 | 86 KB | 12.4% / 6.8% | 1.3% / 0.7% |

1 is hardly fixable with groups: it is two sound effects, `Rain1` (5 s) and
a thunder, the rain and the thunder of the same storm (I did not verify it in
the pages). In
3 the only moment measured with three at once —`Glass`, `Flash3` and `Earth4`
in the `evilrhys` scene, `test_msu_efectos.py`— weighs 77 KB at 22050 Hz:
that group alone no longer fits. Idea 2 would really help on maps 2 and 3
and on no other, and it would cost: a page analysis that says which
`PlaySound` coexist, a table of groups in the ROM, a load of ~100
frames at each group boundary, and the case of the system sound effects.

**The system sound effects**: today the ROM plays none outside the battle
—the menu makes no sound— and the battle's (`BATTLE_AUDIO_SE`) are already in its
package. When the menu plays them, `Cursor1`, `Key`, `Cansel1` and `Fog1` at
22050 are 16.2 KB that have to be **in every package**, with
either idea; with 2, also in every group.

**Idea 2 was not implemented**, as the assignment asked. My reading: it is not
needed except for maps 2 and 3, and there the cost is high.

## The radio's music (Yarará's thing)

This neither unblocks it nor blocks it. With MSU-1 a theme with a track takes no ARAM,
so putting the radio into the battle package does not change the sound effects' rate;
what goes down is the music **without** MSU-1, which is the bank's allocation
and not this. If the radio's theme had no track, it would take room from the
battle's sound effects, and now `Monster1` and the ones that lose least
would go down first instead of all of them together.

# What was done

| commit | what |
|---|---|
| `19272b9d` | `rates_per_package` with one rate per sound effect; `audible.rs`, what each WAV loses at each rate |
| `85631dc0` | the prose of the runtime and of `docs/port/` that said "the package's rate" |

The crate's test against what the Python wrote (`tests/python.rs`)
changed on purpose its hash of the MSU-1 sound effects, with the change written
next to it: only the rates of package 3 of the test game, and the `Rumble` of 1
—a WAV at 11025 Hz— noted at that rate instead of 22050, with the same
bytes.

**It moves the ROM and the `.msu`**: the ROM only through the pitches of `se_msu_pitch`.
It does not move goldens: the suite runs without MSU-1.

# How it was verified

* `NO_CACHE=1 just cartuchos` on the baseline: the assignment's sha256
  (`abl.sfc` `e20182d1…`, `abl.msu` `905decd2…`, `special` `6784ab8f…`,
  `encounter-every-step` `5dc9114c…`).
* After, twice the same: `abl.sfc` `0d43de3c…`, `abl.msu` `e53bc400…`,
  `special` `ea444940…`, `encounter-every-step` `54ef5505…`. The
  `conversor.log` changes only in the lines of the rates and in the size and
  signature of the `.msu`.
* `just pruebas` 893, `just -f tools/justfile test` 46, `cargo test -p
  rm2k-snes-audio` with `SOUNDFONT` green. `test_musica_techos.py` passes.
* **What no test looks at**: that it sounds better. For that, what is below.

# To listen to

`/shared/audio/2026-09-30-efectos-msu/`, with a `LEEME.txt`: the battle's
sound effects that change, before and after, and the ones that change most on other maps,
taken out of the `.msu` and decoded at their rate (without the DSP's interpolation),
with the name and the rate in the file; and the original WAVs of four.

What has to be listened to above all: whether `Monster1` at 6000 Hz is noticeable, and whether
`Attack2` and `Glass` gain what the numbers say.

# On merging

* Install in the global **`rm2k-snes-audio`**: `just -f tools/justfile
  install rm2k-snes-audio`. Without it, the `.msu` comes out with the old single
  rate.
* It adds or renames no Python script.
* It touches a comment of `tools/runtime/msu_effects.s`: the ROM does not change because of
  that.
