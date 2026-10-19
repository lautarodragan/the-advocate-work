---
name: "Frozen World's map 1: its audio package does not fit in the ARAM"
description: "With map 1 (\"Battle Screen\") brought back into The Frozen World, the build stopped at the audio: its 41 sound effects alone are ~89 KB against ~63 KB of ARAM. The audio stage now relieves a package that does not fit even at the minimum instead of stopping, records what it loses in degradations.json, and map 1 is in"
type: bug
status: done
assignee: taro
agents: [Carpintero, Aguará]
---

Seen by Carpintero on 2026-10-15, on the branches `carpintero-rom-code`
(the-advocate, on top of `huron-tp` and main `978c0d25`; ports, on top of
`huron-tp` and main `08551c6`).

**How to see it**: in `frozen-world/rm2k-snes.toml` of the ports, take
map 1 out of `excluded` and run `just cartridges release` in that
directory. It stops with:

    rm2k-snes-audio: the samples of 1 (30546 of -25987 B) do not fit in the ARAM even at the minimum

**What changed to get here**: until that branch, map 1 stopped first at the
hero's flash (draft `flashing-hero-shares-a-palette-with-an-npc`, which
Hurón's `huron-tp` turned into a warning after a teleport) and then would
have stopped at its code; now its 347,625 bytes of bytecode go to the
cartridge in six blocks of up to a bank (`map-streams-that-dont-fit-in-wram`),
and the next thing it hits is the audio.

**What is known of the cause**, not looked at further: the free space is
negative before any sample, so what the package carries besides the
samples —its songs, which map 1 picks from a chain of `PlayBGM`, one per
battle, read in the data— is already more than the ARAM. Read in the data,
not measured: which songs and how big.

## Measured (Aguará, 2026-10-15, tools 362d3765, ports 0ca371b)

The premise above was off. **No sequence lives in the ARAM**: the per-note
stream stays in the ROM and the 65816 reads it (`irq_music`); what a
package uploads is samples, from `$0400` to the 64 KB minus the IPL's last
64 bytes, with the directory and a silence block in front —`free_for` in
`bank.rs`—. And with MSU-1, the songs that have a track already upload
nothing (`song_per_msu`).

What overflows is map 1's **sound effects**: `measure_job.py` over the
`audio-job.json` the failing build leaves says package `1` carries 6 songs
(BCskyfall, TJO_ST2, tjo_st6, Contributes-BossTheme2, HouseOfTheRisingSun,
JILostSexyWizard), 13 songs that may arrive playing, and **41 distinct sound
effects**; the next package has 12. At the usual 6 kHz and 0.75 s each they
are budgeted at ~89 KB against ~63 KB of ARAM, which is the `-25987 B` of
the message: `free - effect_bytes` before a single music sample. The six
songs' samples at the minimum are the `30546` (now `35577`, with
`huron-tp` merged) of the message.

The precedent is ABL's map 3: 55 KB of effects leave `evilrhys` at 4.5 kHz
with 707 B to spare, and taro chose that by ear (`paid_by_music`). So the
fix must not move a package that fits today.

## Done (Aguará, 2026-10-15)

Branches `aguara-aram` in the-advocate (`f0b15d74`, on `362d3765`), the
ports (`9568637`, on `0ca371b`) and the book; this task here.

**The rule**, in `rm2k-snes/rm2k-snes-audio/src/relief.rs`, and only for a
package that does not fit even with every sample at the minimum —what used
to stop the build; a package that fits is not touched, so ABL's map 3 keeps
evilrhys at 4.5 kHz—:

1. its songs go **separate** (the `apart_themes` mechanism the runtime
   already had: each uploaded when its `PlayBGM` asks, with a pause, the
   others let go): all of them if none plays on entering —a map whose
   songs are all `PlayBGM`s, like map 1—, and from the end of the list
   until the rest fits if the first does (the map's own, the boot's);
2. then the **sound effects at the end of its list are left out** until the
   music of the package, and of each separate song alone, fits at the
   effects' own rate, 6 kHz (`SE_RATE`): the end of the list is also what
   the ROM leaves out when a package does not fit;
3. and a package that cannot fit next to a song that may arrive playing,
   even at the minimum, is not asked to: the ROM uploads what fits and the
   next `PlayBGM` completes it.

Each relief is a loss —`songs-uploaded-on-play`, `sound-effects-left-out`,
`package-waits-for-playbgm`— printed by the stage and put in its
`audio.json` under `losses`; the converter reads them after the stage and
writes `degradations.json` **after the music**, not before, which is what
Hurón could not hook. No runtime change: the ROM's lists carry the result.

**Measured**, tools `f0b15d74`, ports `9568637`:

* The Frozen World, map 1 in: `just cartridges release` builds (8 MB).
  Package 1 keeps 16 of its 41 effects and no song; the six battle themes go
  separate, with 4.7 to 10.4 KB left over next to the 16 effects, their
  samples at 6.3 to 14.5 kHz. Before: `-25987 B` free before any sample.
  The 25 effects left out are in `degradations.json` by name.
  `just boot -k frozen` passes.
* ABL: `release`'s `abl.sfc` and `abl.msu` come out **byte for byte the
  same** as with the tools of `362d3765` (sha256 compared), so no golden
  moves and nothing sounds different: no wavs recorded, there is nothing to
  hear. The converter log differs only in where the `degradations:` line
  is printed. ABL `just tests` with these tools: 1553 passed, 2 skipped,
  4 min (run twice, with each version of the tools).
* the-advocate: `just test` 29 passed; `just rust-test` all green;
  `crate-test rm2k-snes-audio` 84 + 6 + 3 (+ with `SOUNDFONT`) green,
  with four new unit tests of the relief shown red first and one new
  command-line test (the old "does not fit at the minimum" case, which the
  relief now builds; the stop stays for a lone song, tested at 500 B).
* clippy: nothing new on the touched lines.

**What the suite does not cover**: what a fight on map 1 sounds like
—the pause at each battle's `PlayBGM`, which effects are heard, and the
round trips map 1 → map 3 → map 1 every turn with a separate song playing
(the research on the battle system says the game does that; the ROM keeps
the playing song's samples and re-uploads the effects)—. Nobody has fought
in the port yet. The Frozen World page of the book says so in "Known
issues".

**To install when merging**: `just install rm2k-snes-audio convert`.

**Left as a draft**: `overloaded-audio-package-the-floor-is-a-cliff`.

**2026-10-19, taro**: declared done.
