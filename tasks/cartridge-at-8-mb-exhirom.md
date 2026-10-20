---
name: "The cartridge at 8 MB, ExHiROM"
description: "First an ExHiROM test ROM for the FX Pak; then move release over, with the goldens unchanged"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-01: `decisions/the-cartridge-goes-to-8-mb.md`. What
changes, according to [`ports/abl/research/2026-10-01-the-whole-game-without-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-the-whole-game-without-msu-1.html)
(Tucu-tucu): `memory.cfg` to 64 KB banks (`banks.rs` is already
parametrised), the header at `$40FFB0`, bank 0's tables seen as
32 KB at `$80`, what crosses banks by hand (`.crossbank`, the samples of
`emit.rs`) because the bank starts at `$0000`, and the SRAM to `$20-$3F:6000`.
WRAM, far RAM and the `.msu` do not change. Unverified: that Mednafen
maps ExHiROM.

## Phase A: the test ROM (Ceibal, 2026-10-01)

`just exhirom` (`rom/experimentos/exhirom/`): an 8 MB file of
pseudorandom bytes with the code twice, which sums stretches across the whole map and
paints nine stripes; the SRAM is written through `$20:6000`, read through
`$A0:6000` and leaves a mark for the next boot. Delivered in
`/shared/experiments/2026-10-01-exhirom/`, with the `LEEME.txt` of what
to look at; **taro still has to test it on the FX Pak**.

What the emulators gave, two boots each:

- **snes9x and bsnes**: everything like the cartridge.
- **mesen-s** —and Mesen2 without "strict board mappings", which is its default
  option, and Mednafen's `snes` module—: they put LoROM's SRAM at
  `$70-$7D:0000-7FFF` also in ExHiROM. **Those 14 low halves, 448 KB,
  cannot be used for data.** The code of both Mesens says so
  (`BaseCartridge.cpp`, "some old romhacks seem to depend on this").
- **Mednafen `snes_faust`**, the one taro plays on: it maps ExHiROM, but reads
  `$80-$BF:8000-FFFF` from the second 4 MB (`cart.cpp` adds 4 MB to every
  bank below `$C0`). The cartridge and the FX Pak (`address.v`:
  `{!A23, A21:0}`) read them from the first. **That is why the game's code
  goes twice**: at `$008000`/`$018000` of the file —what the console sees
  at `$80`/`$81`— and at `$408000`/`$418000` —what Mednafen sees, and where the
  console looks for the vectors, at `$00`—. It costs 64 KB and leaves the `FAST` and
  the runtime's `jsl` as they are.
- FastROM works on all five: the same loop takes 76 lines from `$C0` and
  99 from `$40`. **The second 4 MB are always slow** —MEMSEL only
  speeds up `$80-$FF`—: what the CPU reads byte by byte is better in the
  first.

## Phase B: the game moved over (Ceibal, 2026-10-01)

Commit `ExHiROM: el cartucho pasa a 8 MB`; the why of each part is in
the documentation of `tools/rm2k-snes/cartridge/src/banks.rs` and in the
new section of the README, "El cartucho es ExHiROM, de 8 MB". In short:

- Data in 64 KB banks from `$0000`: first `$C2-$FF` (fast),
  then `$42-$6F` (slow), and the leftover halves for pieces of up to
  32 KB. What crosses by hand only crosses between two consecutive banks.
- Banks 0 and 1 are still linked at `$00:8000`/`$01:8000`, as in
  LoROM, and the build copies them to `$408000`/`$418000`: the runtime did not
  notice the change, except what crosses banks by hand and the `ora #^FAST`
  over data banks, which are gone.
- SRAM at `$20:6000`, 8 KB; header `$35`, `$0D`, `$03`. LoROM saves
  do not load.
- **The goldens did not move**: the suite passes against the ones from before.
- `test_music_ceilings.py[dcbest]` clips **one** sample: I did not run
  `just ceilings`, it is left to be measured when merging.
- `release` fits in the fast banks and leaves free the 46 slow banks
  of 64 KB and 20 halves: `just space`, measured on this commit. No
  data goes to the slow ones yet; when it does, what the CPU reads byte by byte
  —the music stream, the samples, the bytecode— is better kept in
  the fast ones, and the allocation today does not distinguish what each piece is.
- The case `push` grew 32 KB: with 64 KB banks, the text block
  of `test-special` had to go past a bank so that `test_text`
  kept crossing the border.

**For Timbó** (he had already finished, so nothing needed passing on): the emission
did not have to change. Only two comments of `rm2k-snes-mapdata` (`asm.rs`,
`record.rs`) which said that what follows a bank is the WRAM mirror;
the one of `map_table` that is emitted into the `.inc` stayed, because it tells what happened in
LoROM and says so.

### On merging

- Install `cartridge` and `rm2k-snes-audio` (`rm2k-snes-volume-ceilings`
  patches both copies of the code). `mapdata` changed only in comments:
  not needed.
- Measure the ceilings (`dcbest`).
- What is left, and is not part of this task: taro testing on the FX Pak the test
  ROM (`/shared/experiments/2026-10-01-exhirom/`) and then the game;
  and in Mesen2, that the routine names show with the new `.dbg` —the
  code is at `$008000` of the file, which Mesen2 shows at `$80:8000`—.
- Old saves do not load: you have to start over.

# Tested on the SNES

taro, on 2026-10-03, with the FX Pak and the build `2026-10-03-51c48ef-73980930`:
from the beginning until leaving Lashe City, entering both towns and
some of their buildings. In their words, translated:

> Everything seems to keep working perfectly.

It is the first time ExHiROM runs on the console with the game.
