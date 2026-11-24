---
name: "The volume ceilings are measured without a ROM"
description: "Each song's volume ceiling is measured today by hand, building a ROM and playing it in a libretro core; with blargg's S-DSP from snes_spc behind a Rust wrapper, fed the writes stream.rs already decodes, the audio stage can compute the table on every conversion, for every game, and the recipe, the stale-table test and the libretro module go"
type: refactor
status: todo
author: taro
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

## Log

### 2026-11-23, Hornero: written

Nothing done yet.
