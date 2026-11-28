---
name: "The volume ceilings are measured at the title song's level"
description: "volume-ceilings plays each song on the title screen, and since 2026-10-19 the title plays at the database's title_music level (ABL: volume 90, tempo 130), so the table is measured about 1.9 dB quieter than the song as written: at volume 100, 43 of ABL's 102 songs clip with today's table"
type: bug
game: abl
status: done
author: mulita
links:
  found-in: [the-volume-ceilings-are-measured-without-a-rom]
---

**What was seen**: `rm2k-snes-audio volume-ceilings` measures each song
by patching the title screen's `lda #SONG_TITLE` and playing it there
(`play` and `with_song_on_title` in
`rm2k-snes/rm2k-snes-audio/src/ceilings.rs` in the-advocate). Since
96044e1b (2026-10-19, "Songs start at their level"), the title starts its
song through `bgm_level_title` (`runtime/bgm_level.s`), at the level of
the database's `title_music`: in ABL `SONG_TITLE_GAINS = $6868` and
`SONG_TITLE_STEP = $014D`, volume 90 and tempo 130. So every song is
measured at a gain of 104/128 and 1.3 times faster, while
`ceilings::cap()` assumes the song as written.

Measured on ABL's `release`, the-advocate `bf18d71e`, ports `60f1d0f`
(abl.sfc sha256 `3bf35fd7…`), with today's
`patches/auto/music/ceilings.toml`:

* At the title's level, every song peaks where the table says it does
  (within 0.05 dB): the table is not stale.
* With the title's two immediates patched to `$8080` and `$0100`, volume
  100 and tempo 100, **43 of the 102 songs clip** (from 1 sample to 1164
  —`hzstream` 168, `Drahkken_Neo_Remix` 1109, `dd2shad2` 1164—), and 45
  go past the 0.5 dB margin.
* At half the headroom, the song as written is 1.89 dB louder than at the
  title's level, on average over the 102.

Whether ABL ever plays one of those songs above volume 90 was not
checked: it clips only where a `PlayBGM`, a map or the battle asks for
more than the title does. Nothing was heard on the console.

**How to reproduce it**: the scripts in the log of
[`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)
(2026-11-27, Mulita), left in `~/scratch/mulita/ceilings/scripts/`:
`whole.py` copies a built ROM with the immediates patched, and
`rom_peaks.py` plays every song of it through `volume-ceilings --play`.
By hand: in `abl.sfc`, the bytes `A9 68 68 8F` followed three bytes
later by `A9 4D 01` (once, at file offset `$12436` in that build) become
`A9 80 80 …  A9 00 01`.

## Log

### 2026-11-27, Mulita: found while measuring the model

Found during step 1 of
[`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md):
the model and the ROM differed by a steady 2 dB from the first sample,
and the cause was the ROM's title level, not the model. Step 2 of that task removes this
measurement path. Until it lands, the table stays measured this way.

### 2026-11-27, Hornero: stays a draft, for step 2

Step 2 of [`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)
measures each song as written and removes this path, so it fixes this
as a side effect; it waits on taro's answers there. If step 2 is not
taken, this is fixed alone: measuring on the title with its level
patched to 100/100, as Mulita's `whole.py` does.

### 2026-11-28, Mulita: fixed by step 2, closed

Step 2 of [`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)
(the-advocate, branch `mulita-ceilings`) measures each song's ceiling
while it compiles, from the writes of the song as written, so the
title's level no longer comes into it; the ROM path, the table and its
test went. Checked the way this draft found it: ABL's `release` of the
branch with its title patched to volume 100 and tempo 100 (`whole.py`),
every song played whole through the old `volume-ceilings --play`.
Before, 43 of the 102 clip; after, **none**, and the loudest, `juries`,
peaks at -0.05 dB. `hzstream`, `Drahkken_Neo_Remix` and `dd2shad2` went
from 168, 1109 and 1164 samples at the cap to none. Nothing was heard
on the console.
