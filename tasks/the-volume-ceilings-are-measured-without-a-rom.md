---
name: "The volume ceilings are measured without a ROM"
description: "Each song's volume ceiling is measured today by hand, building a ROM and playing it in a libretro core; with blargg's S-DSP from snes_spc behind a Rust wrapper, fed the writes stream.rs already decodes, the audio stage can compute the table on every conversion, for every game, and the recipe, the stale-table test and the libretro module go"
type: refactor
game: advocate
status: doing
assignee: mulita
agents: [mulita]
author: taro
links:
  relates: [one-advocate-command, tests-without-the-stages-subcommands]
  blocked-by: [cartridges-runs-itself-to-assemble]
  found: [the-volume-ceilings-are-measured-at-the-title-songs-level]
---

**Why**: `rm2k-snes-audio volume-ceilings`
(`rm2k-snes/rm2k-snes-audio/src/commands/volume_ceilings.rs` in
the-advocate) builds a copy of `release` at half headroom through
`rm2k-snes-cartridges`, plays each song in the snes9x libretro core, writes
`patches/auto/music/ceilings.toml` and rebuilds and measures again, up to
four rounds. It is manual —ABL's `just ceilings`, some four minutes and a
commit of its own— and ABL's `tests/rpgmaker/test_music_ceilings.py` turns
red whenever the mix changes, which is every week or two: 2026-10-16,
10-19, 11-16 and 11-23. The other eight games have no table at all.

But a song's sound is already, in full, a list of S-DSP register writes
frame by frame —the SPC700 driver only forwards them, see
`runtime/spc700.s`—, and `stream.rs` already decodes a packed stream back
into them (`decode`). What is missing is the S-DSP. game-music-emu, which
plays `.spc` files, does not fit as it is: our SPC700 plays nothing on its
own. But what it uses inside, blargg's `snes_spc`, carries the DSP as a
piece of its own, `SPC_DSP`: ARAM in, register writes, run N clocks,
samples out.

> A Rust wrapper that calls the C functions seems fine to me.

> [deleting the Python about this] Go ahead! And I would remove any Python
> related to this. I prefer to deduplicate.

(taro, 2026-11-23)

**What is asked**:

1. **The experiment first**, in scratch and without touching the
   toolchain: `SPC_DSP` built, the 32 songs of ABL's `release` fed from
   `decode`, and their peaks against today's table. The measured limit is
   what counts: how far the model is from the ROM, song by song. Today's
   test says when each write falls within the frame moves a peak about
   0.2 dB with any change of the ROM, and the table's margin is 0.5 dB.
   Shown to taro before going on.
2. **Then the change**: `SPC_DSP` behind a small Rust wrapper —the `cc`
   crate, inside the workspace—, and the audio stage computes each song's
   ceiling while converting, for every game. The table stops being a
   versioned file in `patches/auto/` measured by hand.
3. **What goes**, being duplicate once the table cannot go stale: the
   `volume-ceilings` subcommand, ABL's `ceilings` recipe,
   `test_music_ceilings.py`, `retro.rs` and the ROM-building path in
   `ceilings.rs`. Whatever names them —docs, the book, `release.yml`'s
   comment on why the Linux builds are glibc and not musl, which was the
   libretro core's `dlopen`— follows.

**What is lost, and taro hears it before deciding**: the only check of a
song's peak against the real ROM —the songs that ended less than 1.5 dB
from the cap, played in the core until their peak—. What the model does
not see is the timing of the writes inside the frame; the experiment
measures how much that weighs. The per-song LUFS the table keeps today is
measured with `ffmpeg`: it stays only if something reads it.

**What has to be decided before it lands**:

* **The licence**: `snes_spc` is LGPL 2.1, and the release binaries link
  statically; the-advocate has no LICENSE file.
* **The audit**, like `cc65`'s and SuperFamiconv's in AGENTS.md: where the
  sources come from, what was read, what was not. The first C++ in the
  workspace.

It goes after
[`cartridges-runs-itself-to-assemble`](cartridges-runs-itself-to-assemble.md).

## Comments

### 2026-11-27, Mulita: a question for taro

Three things to decide before step 2.

**1. The model: how it takes the peak.**

* **A. One run, writes at the start of the frame, margin 0.5 dB.** The
  simplest and about one CPU-minute per game. 13 of ABL's 102 songs would
  go up to 0.9 dB past the margin in the ROM.
* **B. The loudest of six write timings, margin 0.5 dB.** No song goes
  past the margin in the ROM (the worst is 0.36 dB). Songs come out 0.42
  dB quieter on average than a ROM measurement makes them. It costs about
  6.6 CPU-minutes per game, cached per mix.
* **C. One run with the margin widened to about 1.9 dB.** As simple as A
  and as safe as B, but every song that reaches its ceiling loses about
  1.4 dB.
* **D. Neither: keep the ROM measurement** and fix its level (the draft),
  so that no C++ and no LGPL code enters the workspace.

I recommend **B**. It is the only one that keeps every song inside today's
margin and still loses less loudness than C. Its CPU is spent once per mix,
and the cache keeps it after that.

**2. The licence.** `snes_spc` is LGPL 2.1 or later (the notice at the
top of each file, and `license.txt`), and the release binaries link
statically. This is my reading, not a lawyer's:

* **A. Vendor the six files in a crate of the workspace, and comply.**
  Their notices stay, the LGPL's text goes with the release binaries
  together with a notice that they contain snes_spc, and its source is
  in the repo. Static linking is allowed if the user can relink against
  a modified library, and with the whole of the-advocate public and
  buildable, they can. The gap is that **the-advocate has no LICENSE**,
  and §6 of the LGPL asks that the terms of the work that uses the
  library allow modifying it for one's own use and reverse engineering
  it. That takes a LICENSE, which taro would choose, or at least a
  sentence granting that.
* **B. Port ares's S-DSP to Rust** (`ares/sfc/dsp/`, ISC, about 940
  lines of C++ tied to ares's framework). No LGPL and no C++ in the
  workspace, but it is a port to write, and it has to be shown equal to
  SPC_DSP's output; this experiment's harness can show that. Where ares's
  DSP came from was not checked: it does not mention blargg.
* **C. Load it dynamically**: it goes against the static release
  binaries, so I do not recommend it.

Rewriting SPC_DSP in Rust does not get out of the LGPL: a translation is
a derived work.

I recommend **A**, with taro choosing a LICENSE for the-advocate, which the
repo lacks anyway since it went public. B if taro would rather have no
LGPL and no C++ at all.

**3. The audit**, in the shape of `cc65`'s and SuperFamiconv's in
AGENTS.md.

*What was checked*:

* The six files carry the snes_spc 0.9.0 header and the LGPL 2.1 notice
  (Copyright 2007 Shay Green).
* `SPC_DSP.cpp` differs from the copy in bsnes (`~/ref/bsnes`) only in
  bsnes's own known changes: the power-on table zeroed, cubic
  interpolation, a second echo pointer. That is what an untouched 0.9.0
  would show. Against Mesen-S it differs in 107 lines, and snes9x's copy
  is reworked.
* The files include only `assert`, `limits`, `stdint`/`inttypes`,
  `string`, `stddef`, `stdlib` and `new`. Their only `asm` is
  PowerPC-only, behind a guard. They have no file, network, process or
  environment calls.
* The compiled library leaves undefined only `malloc`, `free`, `memset`
  and `__stack_chk_fail`.
* The build is the `cc` crate compiling two files. Nothing is downloaded
  besides the clone and the crates (`cc`, `flate2` and `serde_json`, all
  already in the workspace).

*What was not checked*:

* The sources come from a third party's mirror, not from blargg. The
  original zip could not be found, so there is no hash to compare
  against.
* The mirror is not signed, and its first commit is that third party's
  import.
* Nobody read the DSP's algorithm line by line. It was only searched for
  what it calls.
* The build ran as root.

The defence that does not depend on the audit is this same comparison:
the model's output against the ROM's, sample for sample, until the first
write that lands at a different moment inside its frame.

Waiting for taro before step 2.

### 2026-11-28, taro: a comment

> Let’s do B. I _think_ there’s some clipping going on at some point in the game, so best to be safe.

### 2026-11-28, Hornero: B; the licence still open

Question 1 is B: the loudest of six write timings, 0.5 dB margin.

The clipping taro thinks they hear is likely real and measured:
[`the-volume-ceilings-are-measured-at-the-title-songs-level`](the-volume-ceilings-are-measured-at-the-title-songs-level.md)
—today's table is measured at the title's volume 90 and tempo 130, so
43 of ABL's 102 songs clip when played at 100—. Step 2 fixes it, as
every song gets measured as written.

Step 2 still waits on question 2, the licence: (A) vendor snes_spc's six
LGPL files and comply, which needs a LICENSE for the-advocate that taro
picks; (B) port ares's ISC S-DSP to Rust and show it equal; (C) load it
dynamically, not recommended. And on question 3, the audit as written
above being enough: the sources come from a third party's unsigned
mirror, because blargg's original zip is gone.

### 2026-11-28, taro: a comment

> Ah I forgot about the license! I like GPLv3. It should be compatible with the licenses of the dependencies, right?
>
> Any reason not to go with GPLv3?

### 2026-11-28, Hornero: GPLv3 fits everything

Yes. Checked against the workspace's whole dependency tree
(`cargo metadata --locked`, 63 third-party crates): all of them are
MIT, Apache-2.0, BSD, ISC, Zlib, 0BSD or Unlicense —or a choice among
them—, and every one of those can go into a GPLv3 work (Apache-2.0
can into v3, not into v2). `snes_spc` is LGPL 2.1 *or later*, and the
LGPL lets its code be used under the GPL, so vendoring it into a GPLv3
the-advocate is fine, and its §6 question goes away.

What the licence does not touch: `ca65`/`ld65` (zlib) are run, not
linked; the test game's pictures keep their CC0 and CC BY 4.0, as
`test-game/AUTHORS.md` says; and the libretro cores are loaded only by
`volume-ceilings`, which step 2 removes.

One choice left, and the last before step 2: **GPL-3.0-or-later**
—the usual, and what lets a future GPL version apply— or
**GPL-3.0-only**. Recommended: or-later. And question 3, whether the
audit as written is enough.

### 2026-11-28, taro: a comment

> or-later is fine, and so is the audit.

### 2026-11-28, Hornero: all decided; step 2 to Mulita

All three decided: (1) B, the loudest of six write timings with the
0.5 dB margin; (2) A, snes_spc's files vendored, with the-advocate
licensed **GPL-3.0-or-later**; (3) the audit as written. Back to Mulita
for steps 2 and 3.

## Log

### 2026-11-23, Hornero: written

Nothing done yet.

### 2026-11-27, Hornero: taken, to Mulita

> And let's also move on with the snes-audio one (I had forgotten it!),
> in parallel or in sequence, as possible.

(taro, 2026-11-27) Its blocker is in `testing`: `rm2k-snes-cartridges`
is gone, and `volume-ceilings` builds through `advocate`'s libraries now.
Step 1 first, the experiment, shown to taro with the licence and audit
questions before step 2.

### 2026-11-27, Mulita: step 1, blargg's S-DSP against the ROM

Measured on ABL's `release` built from the-advocate `bf18d71e` and the
ports `60f1d0f` (`abl.sfc` sha256 `3bf35fd7…`, the same bytes as the
ports checkout's `build/release`), with
`patches/auto/music/ceilings.toml` as it stands, which matches that
build: every song's headroom and fingerprint. Nothing in the toolchain
was touched. The experiment is in `~/scratch/mulita/ceilings/`: `model/`
is the S-DSP behind a C shim and a Rust binary built with the `cc`
crate, `romplay/` plays one song of a ROM through `ceilings::play` and
writes it as a WAV, and `scripts/` has the rest. Two things in this task
are out of date: the table has **102 songs**, not 32, and the timing of
the writes moves a peak by much more than 0.2 dB (see below).

#### What was built and how it is fed

* **The sources**: [yupferris/snes_spc](https://github.com/yupferris/snes_spc),
  cloned to `~/ref/snes_spc`, at its **first commit, `8f0ea63`**
  (2013-11-12, "started repo for safety before I start tearing this shit
  apart"). That commit is snes_spc 0.9.0 with a Visual Studio demo added
  beside it, and the commits after it rewrite the library. Six files are
  used, 1,817 lines: `SPC_DSP.cpp`, `SPC_DSP.h` and the four
  `blargg_*.h`. blargg's own site, slack.net, does not answer, and the
  Wayback Machine has only 404s for `snes_spc-0.9.0.zip` since 2021. So
  the files could not be checked against the original zip.
* **The ARAM**: the directory and the silence from the ROM's
  `spc_samples`, and each sample the song writes to an SRCN from its
  `sample_table` row (pointer, length and loop), placed one after the
  other from `ARAM_DATA`. Where a sample sits does not change what it
  sounds like. All 102 songs fit; none drops a sample.
* **The writes**: `music-writes/<i>.json.gz` from the build, which is
  `decode(unfold(stream))`, and which `song_writes` checks against the
  compiler's own writes. Each frame's writes land all at once at the start
  of the frame, at 1,024,000 / 60.0988 DSP clocks per frame. Then
  `length + 60` frames are played, as `volume-ceilings` plays them.
* **Against what**: the same ROM, played through `volume-ceilings --play`.
  It has to be played **at the song's own level**, which is the next
  point.

#### Today's table is measured at the title's level

The model and the ROM came out a steady 2 dB apart from the very first
sample. The cause was the ROM, not the model. Since `96044e1b`
(2026-10-19), the title starts its song at the level of `title_music`,
which in ABL is volume 90 and tempo 130 (`SONG_TITLE_GAINS = $6868`,
`SONG_TITLE_STEP = $014D`). `volume-ceilings` plays every song on the
title screen, so every song is measured 1.89 dB quieter than written, on
average, and 1.3 times faster. With today's table and the song as
written, **43 of the 102 clip in the ROM**. It is a draft of its own:
[`the-volume-ceilings-are-measured-at-the-title-songs-level`](the-volume-ceilings-are-measured-at-the-title-songs-level.md).
For this comparison, the ROM was patched to play the title song at
volume 100 and tempo 100 (`whole.py`).

With that patch, the model and the ROM are **equal sample for sample**
until the first write that lands at a different moment inside its frame.
In `hzstream` that is 8 frames in, the second KON: the ROM sends a
frame's writes one after another, so a KON after 30 setup writes reaches
the DSP later than a KON alone. Giving each write a cost of 75 DSP
clocks in the model, and 17,038.6 clocks per frame, makes `hzstream`
equal to frame 16. Past that point, matching the ROM exactly would mean
emulating the 65816.

#### Results, song by song

All at half the headroom, 0.25 (the copy `volume-ceilings` builds, made
with `advocate build release --into … -- --measure-headroom 0.25`).
Nothing clips at 0.25, so the peak is the real one. Each peak is in dB
against the cap, as written. **ROM**: `volume-ceilings --play`.
**model**: one run, writes at the start of the frame. **max of 6**: the
model's loudest of six runs, each write costing 0, 25, 50, 75, 100 and
125 DSP clocks. **off** is the model minus the ROM. **fits**: the model
is not more than 0.5 dB below the ROM, so a ceiling taken from the model
would keep the ROM under the cap within the table's margin. **s** is the
seconds the single run took, on one thread, with other agents' suites
running.

| # | song | ROM | model | off | fits | max of 6 | off | fits | s |
|--:|---|--:|--:|--:|:-:|--:|--:|:-:|--:|
| 0 | `hzstream` | -3.94 | -4.12 | -0.19 | yes | -4.12 | -0.19 | yes | 0.25 |
| 1 | `escape_newyork` | -11.19 | -10.44 | +0.75 | yes | -10.41 | +0.78 | yes | 0.83 |
| 2 | `TF3_1_awe` | -3.92 | -3.20 | +0.72 | yes | -3.20 | +0.72 | yes | 0.36 |
| 3 | `T_VGFighterMAX_Masako` | -2.65 | -2.76 | -0.10 | yes | -2.09 | +0.56 | yes | 0.98 |
| 4 | `KW-robot` | -4.97 | -6.28 | -1.31 | **no** | -5.07 | -0.10 | yes | 0.25 |
| 5 | `evilrhys` | -3.59 | -3.84 | -0.24 | yes | -2.85 | +0.74 | yes | 0.45 |
| 6 | `lufsorr` | -9.31 | -9.55 | -0.24 | yes | -8.86 | +0.45 | yes | 0.77 |
| 7 | `cd4` | -6.50 | -6.65 | -0.15 | yes | -6.60 | -0.10 | yes | 0.67 |
| 8 | `C3classi` | -8.96 | -8.76 | +0.20 | yes | -8.35 | +0.60 | yes | 0.47 |
| 9 | `rshinld` | -1.34 | -1.56 | -0.22 | yes | -0.41 | +0.93 | yes | 0.20 |
| 10 | `cd2` | -9.46 | -8.16 | +1.30 | yes | -8.16 | +1.30 | yes | 0.47 |
| 11 | `hzbreach` | -4.89 | -4.37 | +0.52 | yes | -4.16 | +0.73 | yes | 0.39 |
| 12 | `wb3mlair` | -14.59 | -14.36 | +0.23 | yes | -14.36 | +0.23 | yes | 0.30 |
| 13 | `Astpgmarch` | -6.78 | -6.66 | +0.12 | yes | -6.63 | +0.15 | yes | 0.18 |
| 14 | `Gaden` | -7.41 | -7.23 | +0.18 | yes | -7.23 | +0.18 | yes | 0.72 |
| 15 | `3D-Galax` | -3.41 | -3.38 | +0.03 | yes | -3.30 | +0.11 | yes | 1.28 |
| 16 | `wb3shop` | -8.63 | -8.22 | +0.41 | yes | -8.18 | +0.45 | yes | 0.20 |
| 17 | `KSSMKEND` | -12.42 | -12.67 | -0.25 | yes | -12.55 | -0.13 | yes | 0.52 |
| 18 | `vswar` | -5.80 | -5.63 | +0.18 | yes | -5.16 | +0.64 | yes | 0.69 |
| 19 | `Lunar_Pyramid` | -1.94 | -1.74 | +0.20 | yes | -1.58 | +0.36 | yes | 0.81 |
| 20 | `dcbest` | -3.71 | -3.30 | +0.41 | yes | -3.16 | +0.55 | yes | 0.37 |
| 21 | `golden_axe-turtlevillage2` | -6.99 | -5.86 | +1.13 | yes | -5.33 | +1.66 | yes | 0.25 |
| 22 | `Kfmus5` | -13.55 | -13.36 | +0.19 | yes | -13.36 | +0.19 | yes | 0.70 |
| 23 | `tsmedit` | -11.93 | -11.61 | +0.32 | yes | -11.52 | +0.41 | yes | 1.84 |
| 24 | `Fire_Mustang_Intro_And_Level_2_By_Luiz_Vasco` | -4.35 | -4.89 | -0.55 | **no** | -4.01 | +0.34 | yes | 0.48 |
| 25 | `fm2bar_gs` | -11.30 | -12.18 | -0.88 | **no** | -10.91 | +0.39 | yes | 0.40 |
| 26 | `hydr` | -9.97 | -9.82 | +0.15 | yes | -9.82 | +0.15 | yes | 0.84 |
| 27 | `prepara` | -17.25 | -17.21 | +0.04 | yes | -16.92 | +0.33 | yes | 0.18 |
| 28 | `iknow` | -9.06 | -9.09 | -0.02 | yes | -8.84 | +0.23 | yes | 0.54 |
| 29 | `jackalstg2` | -1.28 | -1.24 | +0.04 | yes | -1.19 | +0.09 | yes | 0.83 |
| 30 | `susan` | -8.75 | -8.86 | -0.11 | yes | -8.86 | -0.11 | yes | 1.40 |
| 31 | `lf-st5` | -3.45 | -2.49 | +0.96 | yes | -2.27 | +1.18 | yes | 0.34 |
| 33 | `wb3town` | -7.97 | -8.62 | -0.65 | **no** | -7.67 | +0.30 | yes | 0.20 |
| 34 | `Drahkken_Neo_Remix` | -4.64 | -3.86 | +0.77 | yes | -3.86 | +0.77 | yes | 0.95 |
| 35 | `sladies` | -10.67 | -10.66 | +0.01 | yes | -10.65 | +0.02 | yes | 1.13 |
| 36 | `dfrelax` | -21.00 | -21.24 | -0.24 | yes | -20.23 | +0.76 | yes | 0.57 |
| 37 | `TF4edit` | -2.81 | -2.19 | +0.62 | yes | -2.19 | +0.62 | yes | 0.16 |
| 38 | `Farewell2` | -9.53 | -8.95 | +0.58 | yes | -8.95 | +0.58 | yes | 0.43 |
| 39 | `Knights` | -7.57 | -7.09 | +0.48 | yes | -6.76 | +0.81 | yes | 0.24 |
| 40 | `bubstix` | -7.30 | -7.60 | -0.30 | yes | -7.18 | +0.11 | yes | 0.94 |
| 41 | `Black-Dove_2_CH` | -8.89 | -9.54 | -0.65 | **no** | -8.71 | +0.18 | yes | 1.23 |
| 42 | `elemental_end` | -2.05 | -1.53 | +0.52 | yes | -1.49 | +0.56 | yes | 1.16 |
| 43 | `lodging` | -6.39 | -6.57 | -0.19 | yes | -5.80 | +0.59 | yes | 0.58 |
| 44 | `Pretty_Good_Year_2_JW` | -10.65 | -10.91 | -0.26 | yes | -9.88 | +0.77 | yes | 1.03 |
| 46 | `WW2_Water` | -14.02 | -14.55 | -0.53 | **no** | -14.39 | -0.36 | yes | 0.54 |
| 47 | `toprepare` | -7.56 | -7.84 | -0.28 | yes | -7.62 | -0.06 | yes | 0.60 |
| 48 | `TeramisSong2` | -5.27 | -5.44 | -0.18 | yes | -5.44 | -0.18 | yes | 0.85 |
| 49 | `eileen` | -3.19 | -3.44 | -0.24 | yes | -2.63 | +0.57 | yes | 0.96 |
| 50 | `Bells_for_Her_2_CA` | -5.22 | -5.22 | +0.00 | yes | -5.15 | +0.07 | yes | 1.43 |
| 51 | `cruel` | -7.02 | -7.30 | -0.27 | yes | -6.21 | +0.82 | yes | 0.86 |
| 52 | `pn28year` | -8.76 | -8.72 | +0.04 | yes | -8.65 | +0.11 | yes | 0.43 |
| 53 | `illusion` | -7.52 | -7.15 | +0.37 | yes | -6.95 | +0.57 | yes | 0.62 |
| 54 | `Wolfchild` | -4.17 | -4.22 | -0.05 | yes | -3.48 | +0.69 | yes | 0.82 |
| 55 | `dgate008` | -3.82 | -3.36 | +0.45 | yes | -1.89 | +1.93 | yes | 0.50 |
| 56 | `human4` | -3.26 | -2.17 | +1.09 | yes | -2.17 | +1.09 | yes | 0.87 |
| 58 | `MystTheme` | -11.06 | -11.64 | -0.58 | **no** | -10.95 | +0.11 | yes | 0.13 |
| 59 | `Deathmod` | -11.14 | -9.89 | +1.25 | yes | -9.66 | +1.48 | yes | 0.07 |
| 60 | `Zanac_12` | -8.91 | -8.30 | +0.61 | yes | -8.30 | +0.61 | yes | 0.23 |
| 61 | `aolulumod` | -8.87 | -8.79 | +0.08 | yes | -8.66 | +0.21 | yes | 0.59 |
| 62 | `viperedit` | -8.68 | -8.45 | +0.23 | yes | -8.45 | +0.23 | yes | 0.33 |
| 63 | `brcklayr` | -8.80 | -8.80 | +0.00 | yes | -7.83 | +0.97 | yes | 0.58 |
| 64 | `quiksil3mod` | -1.45 | -1.40 | +0.05 | yes | -0.71 | +0.74 | yes | 0.49 |
| 65 | `1_-_The_Story_of_a_Lost_Love` | -10.52 | -10.35 | +0.17 | yes | -10.33 | +0.19 | yes | 0.53 |
| 66 | `u6menu-arrangement` | -5.26 | -4.38 | +0.88 | yes | -4.38 | +0.88 | yes | 0.44 |
| 67 | `Jambala_Title` | -1.67 | -1.92 | -0.25 | yes | -1.26 | +0.41 | yes | 1.40 |
| 68 | `Quick_&_Silva_-_Level_1` | -2.89 | -2.94 | -0.05 | yes | -2.82 | +0.07 | yes | 0.84 |
| 69 | `elf2` | -8.94 | -8.28 | +0.66 | yes | -7.25 | +1.69 | yes | 0.90 |
| 71 | `DeflectorModded1` | -3.25 | -3.32 | -0.06 | yes | -2.87 | +0.38 | yes | 0.76 |
| 72 | `ValiusBatt` | -7.79 | -8.57 | -0.77 | **no** | -7.56 | +0.23 | yes | 0.86 |
| 73 | `Winter_8_CA` | -5.49 | -5.82 | -0.32 | yes | -5.20 | +0.29 | yes | 1.61 |
| 74 | `DC4chase` | -4.02 | -4.00 | +0.02 | yes | -4.00 | +0.02 | yes | 0.62 |
| 75 | `Hawkeye_-_Title` | -1.01 | -1.42 | -0.41 | yes | -1.16 | -0.15 | yes | 1.87 |
| 77 | `md-scene6` | -5.28 | -5.18 | +0.10 | yes | -4.96 | +0.33 | yes | 0.52 |
| 78 | `T_AVGFighter_KyaraSelect` | -6.59 | -6.59 | +0.00 | yes | -6.59 | +0.00 | yes | 0.54 |
| 79 | `dd2shad2` | -2.65 | -3.16 | -0.52 | **no** | -2.71 | -0.07 | yes | 0.84 |
| 80 | `patchb` | -13.00 | -13.01 | -0.01 | yes | -13.00 | +0.00 | yes | 0.83 |
| 81 | `Ryan_Bury_-_Eternal_Champions_Theme_-_Club_Mix` | -4.28 | -4.25 | +0.02 | yes | -4.05 | +0.23 | yes | 0.60 |
| 82 | `Fantasia_Of_The_Wind` | -9.51 | -9.29 | +0.22 | yes | -9.29 | +0.22 | yes | 0.93 |
| 83 | `GameOver3` | -8.51 | -8.52 | -0.01 | yes | -8.50 | +0.01 | yes | 0.26 |
| 84 | `T_ProjectJustice_DiscLoad` | -7.64 | -7.95 | -0.31 | yes | -7.57 | +0.07 | yes | 0.30 |
| 85 | `11h035` | -10.29 | -10.66 | -0.37 | yes | -10.18 | +0.11 | yes | 0.49 |
| 86 | `arc1_v2` | -7.11 | -8.51 | -1.40 | **no** | -6.81 | +0.30 | yes | 0.38 |
| 87 | `bmlv2-sbl` | -6.37 | -6.83 | -0.46 | yes | -5.65 | +0.72 | yes | 0.67 |
| 88 | `juries` | -4.99 | -5.31 | -0.32 | yes | -5.31 | -0.32 | yes | 0.51 |
| 89 | `GLlevel4` | -15.54 | -15.54 | +0.00 | yes | -15.54 | +0.00 | yes | 0.38 |
| 90 | `piperdun` | -8.07 | -8.73 | -0.66 | **no** | -8.34 | -0.27 | yes | 0.33 |
| 91 | `mboy` | -8.89 | -8.56 | +0.33 | yes | -8.42 | +0.47 | yes | 0.52 |
| 92 | `worlds5` | -6.49 | -6.59 | -0.10 | yes | -5.29 | +1.21 | yes | 0.51 |
| 93 | `Parallax-Loader` | -3.16 | -3.70 | -0.54 | **no** | -3.14 | +0.02 | yes | 1.62 |
| 94 | `Turrican_1_-_Loader` | -2.30 | -2.42 | -0.12 | yes | -2.20 | +0.11 | yes | 0.75 |
| 95 | `Sand_Ocean_-_Remix_V2` | -4.22 | -3.90 | +0.32 | yes | -3.90 | +0.32 | yes | 0.87 |
| 96 | `MML2_MotherZone` | -6.33 | -6.65 | -0.32 | yes | -4.77 | +1.56 | yes | 0.29 |
| 97 | `Laconia_-_Where_Land_Ends` | -1.83 | -1.82 | +0.01 | yes | -1.82 | +0.01 | yes | 0.52 |
| 98 | `Turrican2_bath` | -7.05 | -6.81 | +0.24 | yes | -6.73 | +0.32 | yes | 0.78 |
| 99 | `ec2vents` | -8.04 | -8.41 | -0.37 | yes | -8.00 | +0.04 | yes | 0.35 |
| 100 | `Tnt07` | -10.56 | -9.50 | +1.06 | yes | -9.50 | +1.06 | yes | 0.42 |
| 101 | `Story Music` | -6.90 | -6.87 | +0.04 | yes | -6.87 | +0.04 | yes | 1.23 |
| 102 | `Deflector1` | -3.26 | -3.32 | -0.06 | yes | -2.89 | +0.37 | yes | 0.85 |
| 103 | `u7indoors` | -3.16 | -2.92 | +0.24 | yes | -2.92 | +0.24 | yes | 0.18 |
| 104 | `StatsScreen` | -6.24 | -6.83 | -0.59 | **no** | -6.35 | -0.12 | yes | 0.53 |
| 105 | `light2` | -11.29 | -10.73 | +0.55 | yes | -10.46 | +0.82 | yes | 0.09 |
| 106 | `TRoboW1` | -8.53 | -7.42 | +1.11 | yes | -7.40 | +1.13 | yes | 0.64 |

* **One run**: the model is between 1.40 dB below and 1.30 dB above the
  ROM, with a mean of +0.04 dB and a mean distance of 0.37 dB. 71 songs
  are within ±0.5 dB, and 38 within ±0.2 dB. **13 do not fit**: a
  ceiling from the model would leave them up to 0.9 dB past the margin
  in the ROM.
* **Max of 6 timings**: the ROM is at most 0.36 dB above the model, so
  **every song fits**. The cost is that the model is 0.42 dB above the
  ROM on average (up to 1.93 dB), so songs come out that much quieter
  than a ROM measurement would make them. Three timings (0, 50 and 100
  clocks) leave one song outside the margin, by 0.66 dB. Eighteen
  timings (six costs times three offsets inside the frame) do not do
  better than six: at most 0.36 dB.
* **How much the timing alone moves a peak**: across the 18 timings,
  each song's peak varies by 0.67 dB (median) and up to 2.85 dB
  (`arc1_v2`: from 11,987 to 15,251, while the ROM gives 14,341). This is
  the same effect the task puts at about 0.2 dB, and it is several times
  that. **It applies to the ROM as much as to the model**: snes9x's
  timing is not the console's, so the peak the ROM measures is also only
  one sample of that range.
* **The clocks per frame do not matter**: 17,038.6 against 17,066.7 (60
  Hz exactly) moves the peaks less than the timing does.

#### Time, and what could stop it

* **The model**: 66 s on one thread for all 102 songs, which are 14,259
  s of music, about 216 times real time. That is 0.65 s per song on
  average and 1.87 s for the longest, `Black-Dove_2_CH` (4.6 minutes).
  With four threads it takes 16 s. Six timings cost six times as much:
  about 6.6 CPU-minutes per game, or one minute across eight threads.
  The stage cache would keep it per mix.
* **The ROM, for comparison**: one pass over the 102 songs takes 76 to
  101 s with four processes. `just ceilings` builds twice and measures up
  to four rounds, about four minutes.
* **The echo buffer** does not come into it: the stream writes `FLG =
  $20` (echo writes off), `EON = 0` and `EVOL = 0`, so whatever the DSP
  reads from `ESA` is multiplied by zero. A game that turned the echo on
  would need the echo region modelled in the ARAM.
* **Three traps in the C++, which the wrapper will have to guard**:
  1. `SPC_DSP::run(0)` does not return. It `require`s at least one
     clock, and with zero it counts down through four billion clocks.
  2. The class declares its own `operator new` (`BLARGG_DISABLE_NOTHROW`),
     so `new (std::nothrow) SPC_DSP` does not compile. A plain `new`
     returns NULL on failure.
  3. `reset()` loads the power-on register values, KON among them.
     Frame 0's writes have to land before any clock runs. In the ROM
     they were written at boot.
* **What was not modelled**: the sound effects, which take voices 6 and
  7 in the game. The ROM measurement does not play them either.
* **The binary links no C++ runtime**: the static library needs only
  `malloc`, `free`, `memset` and `__stack_chk_fail`, and `ldd` shows only
  libc and libgcc_s. `cc` 1.12.0 is already in the workspace's
  `Cargo.lock`.

#### What is lost, measured

* **The only check of a peak against the real ROM.** With one run, the
  model is wrong by up to ±1.4 dB, and 13 of 102 songs would end up as
  much as 0.9 dB past the margin. With six timings, none would, and the
  price is 0.42 dB of loudness on average. That ROM check was itself
  snes9x, whose timing the same measurement shows to be worth up to 2.85
  dB on some songs.
* **The per-song LUFS**: nothing reads it. It is written into the table,
  and only the table's report prints it. The model's samples could go to
  `ffmpeg` the same way if it were wanted.
* **The wrong level the table is measured at today** goes with it. That
  is a gain, not a loss: the model plays the song as written.

What taro can listen to is in `/shared/audio/2026-11-27-volume-ceilings/`,
with a `README.txt`. It has `hzstream` at the title's level, as the table
measures it today; the same song as written, from the ROM and from the
model, both of which clip; and `arc1_v2`, the song where the model and
the ROM disagree most, from each of them.
