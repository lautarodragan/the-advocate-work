---
name: "The music weighs 789 KB"
description: "The stream was raw DSP writes; the per-note format (done) brought it down to 29% without changing a single write, the jumps (done) a further 23.5%, and 3 and 4 remain"
type: refactor
status: done
assignee: taro
---

# For taro

**Idea 2, the jumps, is done** (Tijereta, 2026-10-01): what a theme repeats is
said once. The DSP writes are the same, frame by frame, so **nothing should
sound different**: what needs testing is that the music sounds as before,
especially the long themes —the battle one, `3D-Galax`, `patchb`— and each
one's loop back to the start.

**When merging, install `rm2k-snes-audio`** (`just -f tools/justfile install
rm2k-snes-audio`). `protocol` didn't change —`music.toml` changed, and the
generated output is committed—, and neither did `cartridge`: it reads the
runtime from the checkout.

`test_musica_techos.py` passes without re-measuring: the mix is the same. No
goldens move.

## What ended up (idea 2)

`OP_REPEAT back events`, 4 B: it goes back `back` bytes from its own end,
reads `events` events —1 to 254— and continues after the jump. Single-level:
what it reads can't be another jump, nor `OP_INIT` nor `OP_END`. It writes the
same because the decoder's state —the register cache, each voice's sound—
depends only on the bytes it read, and what the jump reads are the same bytes.

* **The encoder**, `fold` in `stream.rs`: left to right, at each event the
  repetition that saves the most, with a lazy step. **The shortest it accepts
  is 7 B**, not 5, which is the first that saves anything: a short one takes
  away what it covers from what the following ones could read. Over the 103
  themes: with 5, −20%; with 6, −22.9%; with 7, −23.5%; with 8, −23.1%; with
  10, −21.3%. The lazy step adds 0.1%.
* **The 65816**: it counts the events in `music_frame::read`, which they all
  go through —outside a jump, a load and a conditional branch per event—, and
  `ev_repeat` stores the return and subtracts in 24 bits. **4 B of far RAM**,
  `MUS_BACK_TO` and `MUS_LEFT`, in the music's range (`$6C8B`–`$6C8E`). The
  24-bit subtraction works because a stream is only split between banks that
  continue each other (`.crossbank`); in `release` there are 2,814 jumps, in
  seven themes, that go back over the start of a bank.

### How much it dropped

| | Before | After | |
|---|---:|---:|---:|
| `release`, 51 themes | 702,978 B | 526,487 B | −25.1% |
| The whole game, 103 themes | 1,432,782 B | 1,096,211 B | −23.5% |

The whole game is Tucu-tucu's audio job (the union of Lechuza's eleven runs),
compiled with `rm2k-snes-audio compile`: 329 KB less. The study said −26% and
−367 KB, and the difference is the estimator's, not the themes': run over the
same streams it gives −24.8%, but it counts in bytes —a jump that starts or
ends in the middle of an event, which the decoder can't read as an opcode— and
only searches among the last 32 candidates. Restricted to event boundaries it
gives −23.0%, and `fold` gets −23.5%.

### How it was verified

* **Theme by theme, all 103**, with a throwaway script: the baseline's stream,
  decoded by the baseline's `rm2k-snes-audio`, against the new one, decoded by
  the new one following the jumps and also unfolded (`decode --unfold`).
  **All 103 identical**, 1,852,332 writes, each with its frame; each theme's
  sounds, byte for byte identical. The 17 that Tucu-tucu couldn't read from
  the `.inc` are included, because the streams come from the compiler and not
  from the `.inc`.
* **On every build**, the compiler decodes each theme flat and with jumps, and
  both have to give `writes`'s writes; and `fold` refuses if unfolding what it
  returns doesn't give the stream it received.
* **In the ROM**, `test_musica_escrituras.py`:
  * `test_la_rom_vuelve_de_cada_repeticion` plays `wb3shop` (169 jumps) and
    compares what the ROM asks of the DSP against the **unfolded** stream,
    without going through the jump's model. **Seen failing** by breaking the
    ROM twice: going back one byte too many, the music goes silent (the test
    puts it as "`music_frame` no corre en cada cuadro"); reading one event too
    few, it differs on frame 144. The other five in the file also failed both
    times: their themes carry jumps.
  * `test_la_rom_vuelve_atras_por_encima_de_un_banco` searches the cartridge
    for the shortest theme with a jump that crosses the start of a bank and
    compares it the same way. **Seen failing** with `ev_repeat` without the
    borrow to the bank: this one and the `3D-Galax` one fail.
* **Three tests changed how they measure, not what they expect**:
  `test_tema_que_ya_suena`, `test_lugar_recordado` and `test_volumen_y_tempo`
  said "it didn't restart" because the stream pointer didn't go down, and a
  jump takes it down. They now look at `avance_del_stream` (`consola.py`),
  which inside a jump is where it'll go back to. They still see a restart: it
  goes to the start.
* `tests/python.rs`'s fixture changed hash: outside the streams,
  `musicdata.inc` is identical line by line, and each stream, unfolded by a
  separate copy in Python, is byte for byte the earlier one.

### The cycles

`quality-of-the-music.md`'s probe —the scanline on entering and leaving
`music_tick`—, in a throwaway copy, in snes9x, the 50 `release` themes with
music, each one whole from its loop back to the start (385,910 frames). The
IRQ lands on line 112.

| | Before | After |
|---|---:|---:|
| The worst frame (the battle theme's loop back to the start) | 109 lines | 110 |
| The worst in the middle of a theme (without the last 31 frames) | 98 | 99 |
| All music lines | 2,263,834 | 2,309,059 (+2.0%) |

No frame is dropped, but **the worst ends on line 222**, three before vblank.
It was already 221 before this; the quality work had left it at 100 (212).
What raises it is the loop back to the start, not the jumps.

### The space

`just espacio`, before and after:

| | `release` | `test-special` | `test-encounter-every-step` |
|---|---|---|---|
| Data banks | 64 → 62 (2 → 0 in the slow 4 MB) | 15 → 14 | 7 → 7 |
| Gaps | 11,204 → 56,623 B | 19,903 → 2,938 B | 36,527 → 60,739 B |
| Bank 0 free | 1,165 → 1,053 B | 1,183 → 1,071 B | 1,179 → 1,067 B |

`BSS`, `ZEROPAGE` and bank 1, the same. The 112 B of bank 0 are the new code
in `music.s`.

### 3 and 4

* **3, LZSS with a 4 KB window**: not done, as requested. I didn't look for
  RAM beyond the music's range: `$6C8F`–`$6DFF` are free there, some 370 B,
  far from 4 KB.
* **4, not writing the notes that never sound**: measured, and **no longer
  worth it**. Removing the preparation of a note that another overwrites on the
  same frame, the whole game drops 1,592 B flat and 1,188 with jumps: 0.1%.
  The 116,805 B of 2026-09-25 came from the voice allocation of back then;
  today's —the ramp one frame before reusing a voice, from the quality work—
  barely produces them.

# What came before

**Idea 1, the per-note format, has been done since 2026-09-26**: it's step 4
of `quality-of-the-music.md`, which has the format, the bytes, the cycles
and how it was verified. The 32 `release` themes went from 730,695 B to
209,720 counting their tables, and the cartridge from 87% to 74.6%. **2, 3 and
4 remain**, and their numbers below are measured on the prototype's format
—with a pitch dictionary—, not on the one that stayed: before doing any of
them it has to be measured again.

**taro's decision, on 2026-09-25: the new format waits for the music
quality.** Before building a format that represents today's stream, the
feature-level audio changes go first (envelopes, MIDI controllers that are
dropped today, samples): if the format were built first, it would have to be
changed afterwards. Meanwhile, what's below stays as a measurement.


The x-ray in `merge-release-and-test-main.md` puts `tema_stream` at the very
top: 789 KB in the merged cartridge, 21%. This is **why it weighs that and
what could be gained**, measured on 2026-09-25 on `6f1dc4a`, when nothing was
implemented.

Everything measured comes from the `musicdata.inc` files that `just
cartuchos` left built that day: **`test-main`, 31 themes, 768,863 B of
stream**. The merged one is those 31 plus the title's, `Fantasia_Of_The_Wind`
—18,387 B in `release`—, and that's where the 789 KB come from. The scripts
that measured were throwaway, so before implementing it has to be measured
again: the numbers below are from that day.

# What it's made of

**The stream isn't notes: it's raw DSP writes.** It has three opcodes
(`tools/snes/protocol/music.toml`): `OP_DSP registro valor` (3 B), `OP_WAIT
cuadros` (2 B) and `OP_END`. Each note is a voice's whole preparation —left
and right volume, pitch in two bytes, sample, ADSR1, ADSR2— and then a `KON`;
releasing it means turning off ADSR1 and writing GAIN. `pack` skips what
didn't change, and that's all the compression it has.

| What | Bytes | % | Writes per note |
|---|---:|---:|---:|
| Pitch (`PITCH_L` + `PITCH_H`) | 272,061 | 35.4 | 1.00 + 0.85 |
| ADSR1: turning it on at each note and off at each release | 182,532 | 23.7 | 0.62 + 0.62 |
| `KON` and the `KON=0` that lowers it on the next frame | 131,949 | 17.2 | 0.45 + 0.45 |
| Volume (`VOL_L` + `VOL_R`, always equal) | 65,334 | 8.5 | 0.22 + 0.22 |
| Waits | 63,016 | 8.2 | 0.64 |
| Sample (`SRCN`) | 51,909 | 6.8 | 0.35 |
| ADSR2, GAIN, KOF, start, end | 2,062 | 0.3 | — |
| **Total** | **768,863** | | **15.7 B per note** |

49,063 notes that sound, 3,529 seconds of music: 218 B per second.

What there **isn't**, and that the question assumed:

* **Not a byte of control events.** `midi.py` drops the CCs, the pitch bend
  and the aftertouch when reading; the stream has no channel volume, panning
  or bends. The MIDIs do carry them —4,427 CC11, 3,851 CC7, 1,532 CC10 and
  1,058 bends among the 32—: adding them some day **adds** bytes, it doesn't
  remove them. (They were added on 2026-09-26, in step 3 of
  `quality-of-the-music.md`: +2.7% of stream, and the list of what the
  stream carries since then is there.)
* **No unrolled loops.** No MIDI carries CC111, the loop point RM2k honors,
  so the stream is the MIDI once and on finishing it starts over
  (`music_frame`). What there is, is **music that repeats inside the MIDI**
  —bars written twice—, and that's measured below.
* **No duplicated channels.** But there's something similar and worse:
  **116,805 B, 15%, are notes that never sound.** When a channel asks for more
  simultaneous notes than it has voices, `build_events` steals the voice from
  the one that ends first, and if both start on the same frame the second
  overwrites the first one's preparation before the `KON`. They're 12,881
  whole preparations written for nothing.

By theme, the heaviest:

| Theme | Bytes | Notes | Seconds | B/s |
|---|---:|---:|---:|---:|
| `T_VGFighterMAX_Masako` (battle) | 156,520 | 8,467 | 226 | 692 |
| `3D-Galax` | 60,346 | 4,322 | 267 | 226 |
| `cd4` | 50,849 | 3,127 | 149 | 341 |
| `Lunar_Pyramid` | 37,205 | 2,401 | 183 | 203 |
| `bubstix` | 37,137 | 2,631 | 195 | 191 |
| `evilrhys` | 36,461 | 2,385 | 120 | 304 |

The rest go from 35 KB down to under 1 KB. The battle one is a fifth of the
whole stream on its own, and it's the most repetitive of all: see below.

# Why it's like this

No real-time or cycle reason. It's the simplest shape that works, and the size
didn't matter when it was chosen:

* **The PoC** (`cd11930`, 2026-09-01): "the logic in Python and on the console
  an interpreter of a stream". A generic opcode makes the 65816 side be
  reading two bytes and passing them through the ports; anything the DSP can
  do can be asked for without touching the ROM.
* **The register cache** (`d8c0689`): `11h035`'s stream weighed 35 KB, "more
  than the whole ROM", and skipping what doesn't change brought it down to
  19 KB. It's the only compression it got, and its argument for why it's safe
  with the loop is still in `pack`'s docstring.
* **The release via GAIN** (`baf4bbd`) **is on purpose and is quality**: the
  ADSR's release isn't configurable and with `KOF` the note gets cut in 8 ms.
  Releasing by turning off ADSR1's bit and asking GAIN for a decay is what
  makes the piano fade out instead of being cut. It costs 24% of the stream
  —ADSR1 goes back and forth on each note— and **mustn't be touched**: what
  can be touched is how many bytes it costs to ask for it, not the writes.
* **The `KON` is never cached**, also on purpose: it's a trigger and not a
  latch, and it has to be lowered by hand. Another 17%.
* **"The cartridge has room to spare"**: `build_varios`'s docstring says so
  —"un índice no cuesta ARAM: cuesta su stream, que vive en el cartucho, y de
  ése sobra"— and so does `Banco`'s. It was true with three themes. With the
  merged cartridge at 89.6% it no longer is, and
  `el-cartucho-se-queda-en-4-mb.md` says it gets revisited at 85-90%.

What was bought with today's shape and must be kept: `irq_musica` is short, it
needs no RAM of its own beyond the pointer, and the sound effects' shadow
(`dsp_musica`, `SE_SOMBRA`) receives write by write. Everything below keeps
those writes identical.

# What could be gained

Ordered by bytes against risk. The sizes are over `test-main`'s 768,863 B.

## 1. A per-note format, which the 65816 expands into the same writes: done

Done on 2026-09-26: see step 4 of `quality-of-the-music.md`. It isn't
exactly the prototype's: the pitch doesn't go in a separate dictionary but
together with the instrument, in a *sound* per note, because the drums change
instrument on almost every hit; and the volume goes per side, because since
step 3 there's panning. What's below is the earlier study, as it was.

**From 768,863 to 258,639 B (−66%). With a pitch dictionary per theme, to
219,794 (−71%): 549 KB less.** Musical risk: none, **and it's measured**: the
prototype re-encoded the 31 themes of `test-main` and the 22 of `release`,
decoded them, and the sequence of DSP writes came out identical to today's,
frame by frame, in all of them.

What was encoded:

* **A note**: a header byte —voice, "is a note", and three flags: the volume
  changes, the high part of the pitch changes, the instrument changes—, the
  low part of the pitch, and after that only what the header says changed.
  The volume goes once, because left and right are always equal. The
  instrument is an index into a per-theme table of `(SRCN, ADSR1, ADSR2)`
  triples: no theme goes over 18. The decoder keeps the shadow of each voice's
  registers and does the same "skip what didn't change" that `pack` does
  today, so the ADSR1 that the release turns off comes back on its own on the
  next note, without spending a byte.
* **A release**: one byte —voice and "release"—; GAIN only if it changed,
  which is 115 times in the whole cartridge.
* **The `KON` becomes implicit**: the decoder gathers the voices that received
  a note in the frame, writes `KON` when closing it and `KON=0` when opening
  the next. It's exactly today's rule, and it takes away the 17% without
  changing a write.
* **The wait is the frame's close**: one byte, up to 64 frames; two for more.
* The start's writes and the final `KOF` go with a raw escape.

With the pitch dictionary —a per-theme index into the pitches it uses, which
don't go over 103— the stream goes from 15.7 B per note to 4.4, counting
everything. What it ends up made of: note headers 28.6%, pitch indices 28.6%,
frame closes 14.4%, releases 14.1%, instrument 8%, volume 5%.

**What it costs**, estimated and not measured:

* **65816 cycles**: per note, comparing seven registers against the shadow and
  looking at two tables; a few hundred cycles. The writes per frame stay the
  same —median 5, 99% of frames up to 32, the worst 56—, and what dominates
  today is waiting for the SPC700's token on each one, which doesn't change.
  `music-on-the-spc700.md` puts today's cost at up to twenty lines per
  frame; this would add on the order of a few.
* **RAM**: the shadow of the eight voices —64 B— plus current volume, high
  pitch, instrument and GAIN per voice, about 100 B. `BSS` has 108 free and the
  zero page 3, so it goes to `ram_lejana` with long addressing, as
  `SE_SOMBRA` already does.
* **Code**: the decoder replaces `music_frame`; `music_tick` lives in bank 0,
  which has ~1.9 KB left in the merged one.
* **ARAM: nothing.** It's decoded on the 65816 side and the SPC700 driver
  doesn't change. Decoding on the SPC700 would save trips through the ports
  but would grow the driver, and ARAM is the tightest thing audio has.

**What would catch it if it goes wrong**: almost nothing in the suite, and
that's the first thing to solve. There are no audio goldens.
`test_musica_paquete.py` uses `muestras_del_stream`, which would have to be
rewritten for the new format —it would break loudly, which is good—;
`test_tema_del_mapa.py` checks that the pointer advances, and still holds.
`test_msu.py` compares the same ROM with and without a track, so it doesn't
see the format. Two safety nets are needed:

* **in Python, encoding and decoding gives `pack`'s writes**, for all the
  cartridge's themes: it's what the prototype did, and it's cheap;
* **and the 65816 decoder against that**, which no Python test covers. The
  most direct way is to record the audio of the old ROM and the new one with
  the same theme and compare it. The writes are the same on the same frame,
  but the decoder takes a different time inside the IRQ, so a `KON` may land
  one or two DSP samples later: **it has to be measured whether it comes out
  byte for byte identical** before proposing it as a test. If it doesn't, the
  alternative is to read the DSP registers from the core at the end of each
  frame.

## 2. Jumping to what was already played: repeated bars, without RAM

**On format 1 with dictionary: from 216,290 to 121,018 B (−95 KB more).** An
opcode "play N bytes from such a place in the same theme and come back",
single-level: the source has to be bytes that were emitted as is, not another
jump. It costs the decoder a return pointer and a count —5 B of RAM— and no
cycles. Musical risk: none, because what gets expanded are the same bytes.

Why it gains so much: exact repetitions of 64 B or more cover 37% of format 1.
The battle one has one of 2,638 B and 143 in total; `evilrhys`, one of 2,822;
`C3classi`, one of 2,319. On today's format it yields less, because the
register cache makes a bar's second pass not write the same as the first.

## 3. Decompressing with a window in RAM

**On format 1 with dictionary: LZSS with a 4 KB window, 64,948 B; with 32 KB
and matches of up to 258, 60,422.** That is, 704 KB less than today. The bound
—zlib— is 43,414 on format 1 with dictionary, and 71,778 on today's.

It costs a window in far RAM —4 KB to 32 KB—, on the order of forty cycles per
output byte —estimated—, and format 1 spends on average one byte per frame, so
time isn't the problem; the problem is complexity and RAM. Where needs
confirming: `ram_lejana.s` names nothing in bank `$7F`, but that has to be
verified with the whole map and not assumed free. Musical risk: none, same
argument.

**Decompressing the whole theme when it starts**, instead of live, would need
48 KB of RAM for the battle one already in format 1, and a `PlayBGM` happens in
the middle of an event: it would stall the game there, not during a fade. I
don't recommend it.

## 4. Not writing the notes that never sound

**116,805 B of today's format; 32,233 on format 1.** It means changing
`build_events` so the note that loses the voice on the same frame doesn't emit
its preparation. It's the cheapest to do —a few lines in Python, nothing in the
ROM— but **it doesn't leave the writes identical**: it removes the overwritten
preparation, which today changes the voice's pitch and volume during the
microseconds it takes for the next one to arrive. That can't be heard, but
there's no longer an exact comparison that proves it. Best done **after** 1
and in its own commit.

## Summary

| | Bytes | Saving | Risk |
|---|---:|---:|---|
| Today | 768,863 | | |
| 4 alone, on today's format | ~652,000 | −15% | the writes change; can't be heard |
| 1, per-note format | 258,639 | −66% | none, verified |
| 1 with pitch dictionary | 219,794 | −71% | none, verified |
| 1 + 2, single-level jumps | ~124,500 | −84% | none |
| 1 + 3, LZSS with a 4 KB window | ~68,500 | −91% | none; RAM and complexity |

The per-theme tables —instruments and pitches, 3,504 B— are included in the
1 + 2 and 1 + 3 rows. In the merged cartridge, 1 with dictionary is about
565 KB less: from 89.6% to something like 76%.

# `muestra`: 269 KB

**268,794 B, and 79% are sound effects, not music.**

* **Music: 58 samples, 57,285 B.** It's capped by ARAM —the whole bank has to
  fit in the SPC700's 64 KB, `a-single-sample-bank.md`—, so it doesn't
  grow with the themes: what grows is the themes that stay out. **Five groups
  are byte for byte identical**, 6,453 B; I didn't look at which programs or
  hits they come from. That costs ARAM as well as cartridge when two land in
  the same package, and there it does matter: it's resolution that could be
  given back to another sample.
* **Sound effects: 92, 211,509 B.** 50 are at the cap, 2,529 B —0.75 s at 6
  kHz, `SE_MAX_SEGUNDOS` and `SE_TASA`—, and the opening's whole thunder is
  23,760 (`the-thunder-plays-whole-and-pays-for-the-rain.md`). They all go into some
  map's package, so none is dead. `sound-effects-without-cuts.md` wants to
  lift those caps, and that will make it **grow**.
* **Nothing obvious to compress**: BRR is already 9 bytes for every 16
  samples, and zlib over all the samples gives 92%.

# MSU-1, as context

22 themes have a track (`PISTAS_MSU`). With MSU-1 the ROM silences the SPC700
and the stream doesn't run, but **without MSU-1 it's the only thing that
plays**, so it has to be there just the same: the track doesn't save a single
byte of stream. The battle one has a track, and even so it's the one that
dominates everything above.

# In passing, measured and not fixed

* **686 notes are released early** —10,308 frames in total, 329 notes in
  `escape_newyork`—. When a note steals the voice from another that ends
  sooner, the stolen one's release was already scheduled on its final frame
  and it releases the one that stole. I didn't hear it; it's for a separate
  `bug` task, and taro would say whether it's noticeable.
* **A note whose program isn't in the bank takes the voice anyway**:
  `busy[voice]` is set before `build_events`'s `continue`, so the note that
  doesn't sound takes the voice away from the ones that do.
