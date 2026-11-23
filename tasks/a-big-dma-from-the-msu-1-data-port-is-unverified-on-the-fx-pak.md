---
name: "A big DMA from the MSU-1's data port is unverified on the FX Pak"
description: "The battle backdrops already DMA 32 KB from $2001 in one go, and raw maps from the .msu would DMA up to 64 KB: nobody checked that the FX Pak refills its 16 KB buffer from the SD card as fast as a DMA drains it"
type: research
status: testing
author: chaja
assignee: taro
agents: [Chajá, Hornero, Aguará, Hurón]
---

Found by Chajá on 2026-11-22, in
[`maps-uncompressed-in-the-msu`](maps-uncompressed-in-the-msu.md), with
the-advocate `ec672f4c`. Read, not run: there is no FX Pak here.

**What is in doubt**: the FX Pak's FPGA serves the data port from a
16 KB buffer in two 8 KB halves, and the MCU refills the half the read
left behind from the SD card (`msu1_loop` and `prepare_data` in
sd2snes's `src/msu1.c`, `cf7e21d`). A DMA from `$2001` reads a byte
every 8 master cycles, so it drains 8 KB in about 3 ms. If the card does
not refill a half in that time, the DMA reads stale bytes. It would show
as broken tiles, not as lag, and **no emulator models it**: they all read
the file directly.

**Who does it today**: `scn_dma_msu` in `runtime/battle_scene.s`, the
battle backdrop's 32 KB into each WRAM buffer, in one DMA. Its task,
[`msu-1-the-backgrounds-through-the-data-port`](msu-1-the-backgrounds-through-the-data-port.md),
left "the risk of the 32 KB read in a single DMA" untested on 2026-09-26.
The battle shows the `.msu`'s backdrop only with the MSU-1, so on the FX
Pak a battle in Sector 27 or 30 would show it.

**Why it matters now**: loading a map's background and grid raw from the
`.msu` saves 5 to 25 frames a load (measured in the task above), with
DMAs of up to 64 KB from the port. That should not be built before this
is known.

**How to answer it**: a test ROM like the SRAM one in
[`the-sram-as-slow-wram`](the-sram-as-slow-wram.md), for taro to run on
the FX Pak: seek far-apart places of a `.msu` of known bytes, DMA 8, 32
and 64 KB from each in one go, and show each block's checksum against the
expected one, with and without an MSU-1 track playing, plus how long each
seek waited. If big blocks come out wrong, the DMAs go in pieces with a
wait between them, and the same test finds the largest piece that holds.

taro, 2026-11-22, asked whether to start with the FX Pak test ROM:

> Go ahead

## Log

### 2026-11-22, Hornero: taken for Aguará, the test ROM

### 2026-11-22, Aguará: the test ROM, run in six emulators and delivered

From the-advocate `1b8825d8` and the ports `544f9bc` (branch
`aguara-msu-dma`, with main `74152d7` merged). Nothing of the-advocate
changed: the ROM is its own, in the ports' `abl/experiments/msu-dma/`
(`build.py`, `dma.s`, `measure.py`), and `just msu-dma` in `abl/` builds it
and runs it in the emulators. What it does is in the header of `dma.s`.

#### The ROM

A 512 KB HiROM **with no SRAM**, so that the FX Pak's save check before a
silent seek (`msu_savecheck`) has nothing to checksum and the seeks are the
card's alone; an 8 MB `.msu` whose every 32-bit word is a hash of its
offset; a `-1.pcm`, a soft hum. At power on, and again with START, two
passes —no track, then the track playing on repeat— of forty blocks: at four
places megabytes apart (`$0A1235`, `$2C0000`, `$5A01FF`, `$7D7FFE`: an odd
byte, an 8 KB boundary, a sector's last byte, near the end), taken in turn
so that every seek jumps,

* one DMA of 8, 32 and 64 KB from `$2001`, fixed source, into WRAM through
  `$2180`;
* the same into VRAM through `$2118`, read back by DMA from `$2139` to be
  checked, with the screen off;
* 64 KB into WRAM in pieces of 16, 8, 4 and 2 KB, 64 lines (~4 ms) apart:
  if the big ones fail, the largest piece that holds.

Each block is compared word for word against the ROM's copy of the place
(banks `$C1-$C4`): the word sum got and expected, OK or BAD, the offset of
the first byte that differs; and the seek's wait (bit 7 of `$2000`) and the
DMA's lines. A 64 KB DMA lasts a frame and a half, so the single DMAs start
at line 0 and the V-IRQ flag (`$4211`, set at line 200 with the IRQ masked)
says whether they went into the next frame; `RDNMI` would not, it clears
itself at the end of the vblank. Seven pages: a summary (bad blocks per
group and pass, seeks min/mean/max in ms, DMA lines for 8/32/64 KB, the
largest DMA that came right, whether the track played) and the forty blocks
of each pass in three.

The garbage background of the SRAM test ROM: this one sets every PPU
register and clears VRAM, CGRAM and OAM by DMA before drawing. Not seen on
the console yet; my guess is that the old one's garbage came from a register
left as the console powered on (colour math, a subscreen), since it did
upload its whole tilemap.

Two things the emulators caught on the way: reading VRAM back by DMA gives
word 0 twice unless a read is thrown away first (`$213A` reloads the latch
from the address before incrementing it, fullsnes "2139h"); and the pieces'
count started one short.

#### Measured in the emulators

`just msu-dma` (exit 0): snes9x, bsnes, mesen-s, bsnes's accurate PPU (the
audit core), Mesen2 and Mednafen's `snes_faust` —this one unthrottled, read
from the save state it writes on exit—. In all six, the 80 blocks right and
the track played throughout; DMAs of 8, 32 and 64 KB in 49-50, 198 and 396
lines (8 master cycles a byte plus the refresh: 8192 x 8 / 1324 = 49.5);
the pieces 396-416 lines in all, a line of rounding each. Seeks: at once in
the libretro cores; 30.8-33.3 ms in Mednafen, its fixed model. snes9x also
runs it again with START: the same, run 2. A run is 1,568 frames, ~26 s on
the console before the FX Pak's seeks.

The check checks: a copy of the `.msu` with one byte changed at B + `$3001`
and C + `$4000` given the 8 KB from 16 KB earlier —a stale half—, in
snes9x: BAD on exactly the 32 blocks that read them (the 8 KB ones do not
reach), first bytes `3001` and `4000`, LARGEST OK `NONE`.

No test in ABL's suite: its folders are about the game (`tooling/` runs no
ROM), and the other hardware experiments (`exhirom`, `msu-port`,
`sram-dma`) have their recipe only. `measure.py` exits 1 on any wrong
block, wrong DMA timing or a seek at the cap, so `just msu-dma` is the
check; it takes about a minute.

`msu-port` (2026-10) asked part of this —32 KB DMAs from a 1 MB `.msu`— and
was never run on the console; the recipe's comment says this one goes
further. It was left as it is.

#### Delivered

`/shared/builds/msu-dma-test/`: `msu-dma-test.sfc` (sha1 `a5908a44…`), its
`.msu` (`b65a71ab…`) and `-1.pcm` (`902d3dd7…`), `emulator-summary.png`
and a `README.txt` with the commits, what to look at and what to send.
Built from the ports' `512ef02`.

**What taro has to do**: run it on the FX Pak and send a photo of page 1,
and of every page with a red row; START two or three times, and whether the
hum played and stuttered. The answer decides whether a map's background can
be read raw from the `.msu` in one DMA of up to 64 KB, or in pieces of the
largest size that held; and whether the battle backdrop's 32 KB DMA is safe.

**What has to be installed when merging**: nothing. Not run: ABL's suite
(nothing it builds changed), the console.

### 2026-11-22, Hurón: what to look at

![Page 1 in snes9x: OK in every row of both columns, DMA lines 50/198/396, LARGEST OK 64K in both, the music PLAYED, "ALL 80 BLOCKS CAME RIGHT."](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/emulator-summary.png)

Aguará's `emulator-summary.png`, from `/shared/builds/msu-dma-test/`, at
2x: what page 1 looks like when big DMAs from the data port hold. On the
FX Pak, compare row by row. The seek times will differ and that is not a
failure: snes9x seeks at once (0.0), the card takes milliseconds, and how
many is part of the answer. What does decide it is any red "n BAD", a
LARGEST OK below 64K, DMA lines other than 49-50/198/396, or a last line
in red. The `README.txt` next to the ROM explains every row.

**How to test it**: copy the three `msu-dma-test` files (`.sfc`, `.msu`,
`-1.pcm`) to the card together and run it. It runs on its own for about
half a minute (the screen goes black for a few seconds while it reads
into VRAM) and then shows page 1. Photograph page 1 and every page with a
red row; press START two or three times for more runs, and note whether
the hum played and whether it stuttered.

### 2026-11-22, Hornero: run 1 on the FX Pak, all right

taro ran `/shared/builds/msu-dma-test/` on the SNES with the FX Pak:

> no row not ok. now running more tests with START...

![Run 1, page 1, on the console](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-1-page-1.jpg)

What page 1 says, against the emulators:

| | no music | music on |
|---|---|---|
| into WRAM, into VRAM, 64 KB in pieces | OK | OK |
| seek, ms, min / mean / max | 2.0 / 2.0 / 2.3 | 2.0 / 2.0 / 2.4 |
| DMA lines, 8 / 32 / 64 KB | 50 / 198 / 396 | 50 / 198 / 396 |
| largest piece OK | 64 KB | 64 KB |

All 80 blocks right, and the track played. The DMA takes the same lines as
in every emulator: the FX Pak keeps up with a DMA from `$2001` of up to
64 KB in one go, with and without a track playing. The seeks take some
2 ms both ways —this ROM has no SRAM, so the ~48 ms silent seeks of
`a-save-on-the-fx-pak-waits-for-a-silent-seek` do not happen here—.
taro is repeating it with START.

### 2026-11-22, Hornero: run 2 on the FX Pak, 40 blocks wrong the same way

taro pressed START for a second run:

> damn 😭

![Run 2, page 1](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-1.jpg)
![Run 2, page 2: no music, into WRAM](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-2.jpg)
![Run 2, page 3: no music, into VRAM](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-3.jpg)
![Run 2, page 4: no music, 64 KB in pieces](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-4.jpg)
![Run 2, page 5: music on, into WRAM](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-5.jpg)
![Run 2, page 6: music on, into VRAM](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-6.jpg)
![Run 2, page 7: music on, 64 KB in pieces](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-2-page-7.jpg)

What the pages say:

* **The same blocks fail, at the same byte, on all six pages**: 32 KB
  at B, first bad `2B17`; 64 KB at A `8E93`, at B `2B17`, at C `946F`;
  and every piece size, 16 down to 2 KB, of A, B and C, with the same
  first bad bytes. With and without music, into WRAM and into VRAM, in one
  DMA and in pieces 4 ms apart. 8 KB blocks, 32 KB at A, C and D, and
  everything at D are right.
* So the wrong bytes are at fixed places of the file —A + `8E93`,
  B + `2B17`, C + `946F`, all odd—, not where a DMA outran the card:
  pieces with 4 ms between them fail at the same byte.
* **GOT equals WANT on every bad row**: the word sum of what arrived is
  the right one, though a word differs (`verify` in `dma.s`). The wrong
  bytes add up to the right ones: the right data in another order, by the
  look of it, more than garbage.
* Run 1, the same places, was all right. Nothing changed between the two
  but that the places had been read before.
* Seeks, ~2 ms as in run 1; DMA lines, the same.

### 2026-11-22, Hornero: run 3, one more place, and a suspicion about the reference

taro, a third run with START:

> second manual run. every page has errors.

![Run 3, page 1](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-1.jpg)
![Run 3, page 2](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-2.jpg)
![Run 3, page 3](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-3.jpg)
![Run 3, page 4](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-4.jpg)
![Run 3, page 5](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-5.jpg)
![Run 3, page 6](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-6.jpg)
![Run 3, page 7](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-run-3-page-7.jpg)

Every place bad in run 2 is bad again at the same byte, and one more
joins them, D + `3F5A` —so 32 and 64 KB at D and every piece of D—: 56
blocks. GOT still equals WANT on every bad row.

Bad places that stay bad and add up run after run, the same on every page
and mode, with the sum of what arrived right: that reads more like the
ROM's **reference copy** being written over —on the FX Pak the ROM is in
its SDRAM and may take writes no emulator lets through— than like the
MSU-1 serving wrong bytes. Aguará checks that first.

### 2026-11-22, Hornero: after a reset, green again; the FX Pak's settings

taro:

> I tried a reset (without powering off and on) and it was all green.
> Then, a manual run: 56 red blocks. Every page with bad rows.

A reset does not reload the ROM into the FX Pak's PSRAM, so a byte written
over there would have stayed bad: what breaks is state a reset clears and
a first run leaves behind —the console's, the test's, or the FX Pak's
FPGA or MCU—, or a read that goes wrong under it. Firmware **1.11.0**; in-game
hook off, cheats off, auto region patch on, reset patch for clock phase
on, SuperCIC off; CPU/PPU1/PPU2 2/1/2, 60 Hz.

![System information](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-settings-1.jpg)
![Chip options](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-settings-2.jpg)
![In-game settings](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-settings-3.jpg)
![SGB settings](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-settings-4.jpg)
![SuperCIC settings](images/a-big-dma-from-the-msu-1-data-port-is-unverified-on-the-fx-pak/fx-pak-settings-5.jpg)

### 2026-11-22, Aguará: the firmware read, and a ROM that tells the copy from the data

#### The firmware: `msu1.c` does not predict these places

Read in sd2snes `cf7e21d` (`src/VERSION` 1.11.2; taro's FX Pak runs
1.11.0, not diffed). `prepare_data` reloads the whole 16 KB buffer from
the sector holding the offset whenever the offset is in neither 8 KB half;
it takes the "within the buffer" shortcut only when it is. In this test
every seek jumps megabytes, so **every seek is a miss** and reloads from a
sector-aligned offset; `msu1_loop` then refills the half the read left,
from the file pointer, which stays in step as long as each toggle of the
read MSB is seen once. Nothing in that path depends on whether a place was
read before, and a stale half or a misplaced sector would change hundreds
of bytes —the low byte matching 1 time in 256— and the sum of what arrived.
What was seen is one byte per place, always the high byte of its word for
A, B, C, with GOT = WANT. So the firmware's buffer does not explain it.

What does: **the sum is of what arrived** (`verify` adds BUFFER), and WANT
is `build.py`'s, from the `.msu`. A byte wrong in what arrived would change
GOT; a byte wrong in the ROM's copy, which `verify` compares against
(`cmp [ref],y`), would not. So the data was most likely right, and either
the copy changed or reading it went wrong. The 65816 cannot write the copy:
in `verilog/sd2snes_base/address.v` a SNES write reaches PSRAM only through
the save RAM (off: no SRAM, mask 0) or the patch regions, which land at the
raw address, $C0xxxx and up, not the ROM image at $01xxxx-$04xxxx. dma.s has
no long or indirect store, and its only B-to-A DMA goes to bank $7F.

The four places in the ROM: $C1:8E93, $C2:2B17, $C3:946F, $C4:3F5A (PSRAM
$018E93, $022B17, $03946F, $043F5A), one in each place's 64 KB and nothing
common in the low 16 bits; D's offset is even, so there it is the low byte.

What the FX Pak writes or contends with in PSRAM while a game runs, for the
next step: the context shadow (`ctx.v`) copies every SNES write to WRAM
(also through `$2180`), VRAM, CGRAM, OAM and the registers into
$F5xxxx-$F9xxxx, and those writes take the PSRAM bus ahead of the SNES's
address (`main.v`, the ROM address mux) —`verify` writes WRAM on every
word—; the MCU's SD DMA into PSRAM (target 0); USB. Which of these is
switched on with savestates off is not settled by reading.

#### The ROM

Branch `aguara-msu-dma-2` of the ports, `a8df535`, `1264ead`, `597d674`.
A run's first 80 blocks are unchanged. New:

* for every bad block a verdict (`judge`): compared again with a loop that
  writes nothing, and each differing word against the true bytes, which the
  ROM computes from `build.py`'s formula: **OK, BAD** (what arrived is not
  the truth), **REF** (it is; the copy is not) or **RD** (the second look
  matched); on pages 2-7 and counted on page 1;
* the copy checked against sums of the truth (`chunk_sums`, 256 bytes
  each, written by `build.py`) at power on, at a run's start, between its
  passes, after them, after the rereads, and continuously while the pages
  are shown (a whole check every ~2 s); each changed byte logged with its
  old and true value, the run, the phase and the second; every page's top
  line turns red with the count when one is found (page 9);
* page 8: the first bad block of each place up close —12 bytes got, copy
  and truth, the three counts, the copy's word read again at once 16-bit
  twice and 8-bit—;
* after the two passes, each place read again: then, at once, after an 8
  KB read elsewhere (page 10);
* a clock: the SPC700, idle otherwise, counts hundredths of a second in
  its ports, loaded through its boot ROM, so time is kept through DMAs and
  with NMI off. Page 1: when the run started, how long it took, how long
  the pages were shown before it; page 11, every run;
* Y held at power on or reset: NMI is never enabled, the pages poll.

`just msu-dma` builds and checks it, and now also builds one with a byte
of the copy flipped (`build.py --rot 0:8E93`) that `measure.py --rot`
checks.

#### Measured in the emulators

Under `nice -n 19`, between 22:33:26 and 22:44:16 (22:33:26-22:33:36,
22:36:14-22:36:17, 22:36:58-22:38:22, 22:39:08-22:39:10,
22:39:16-22:40:40, 22:42:18-22:42:32, 22:42:40-22:44:16), one emulator at a
time.

* `just msu-dma`, exit 0: snes9x, bsnes, mesen-s, bsnes-accurate, Mesen2,
  Mednafen `snes_faust`, and snes9x with Y held; snes9x and Y-held snes9x
  again with START. Every block OK, the copy unchanged, the rereads OK.
* The `--rot` build in snes9x: the byte found at power on (BOOT, 0.2 s,
  $23 for $63), the 12 blocks that read it and A's three rereads REF,
  none BAD; page 8 shows GOT = TRUE, REF red at the byte.
* By hand, a `.msu` with a byte changed at B + `3001`: those blocks BAD,
  the copy unchanged.
* Not reachable in any emulator: RD, the FX Pak's PSRAM and its MSU-1
  buffer.

#### Delivered

`/shared/builds/msu-dma-test/`: `msu-dma-test.sfc` sha1 `f4e0a142…` (the
`.msu` and `-1.pcm` unchanged), `emulator-summary.png`,
`example-planted-copy-error.png` and the `README.txt`: two sessions, a
normal one and one with Y held at power on, START until it goes wrong and
once more, photos of all eleven pages, and of page 9 whenever the top line
turns red while idle.

**What to install when merging**: nothing; no tool of the-advocate changed.

### 2026-11-22, Aguará: a second ROM that logs to SRAM

taro: the tests may write the SRAM freely, and will send the `.srm`
afterwards —simpler and more reliable than photos—; photos still, to
cross-check. The no-SRAM ROM stays exactly as it is (`f4e0a142…`, rebuilt
byte for byte from the ports' main `4aa4d58`); a second variant declares
SRAM and logs everything there. Branch `aguara-msu-dma-3` of the ports,
from main `4aa4d58`.

#### The ROM

Ports `56e3a4a`. `build.py --sram` builds `msu-dma-test-sram.sfc` from
the same `dma.s`: every hook is inside `.ifdef SRAM_KB`, the log itself in
`sram_log.s`, so without the flag the ROM is still `f4e0a142…` (checked
after every change). What it adds:

* **32 KB of SRAM** (`$FFD6 = $02`, `$FFD8 = $05`), the size the games
  declare, so a silent seek pays what it pays in them: by the rule taro's
  console gave on 2026-11-17, ~48 ms of checksum before each seek made
  with no track playing, ~130 ms when the SRAM changed. That is the
  comparison: the FX Pak's save check and the CPU's writes into the PSRAM
  the ROM lives in are both new here.
* **A ring of records** from offset `$20`: sync `A5 5A`, type, 16-bit
  length, 32-bit number, payload, 16-bit checksum; two copies of a header
  (next offset, next number, boots) written A then B after every record;
  a record never split by the ring's end. Records: BOOT (build id, flags
  —Y/no NMI, PAL, warm reset vs power on, MSU-1, `--rot`, wiped, fresh—,
  boots, SRAM KB, lines, time), RUN (start, idle before, idle sweeps,
  seeks per place), PASS (×3 per run: no music, music on, rereads; start
  and end, MSU-1 status, and per block verdict, bad, first byte, seek and
  DMA lines, start), DIFF (per bad block: the counts, the copy's word
  reread, 16 bytes got / copy / truth around the first bad byte, and up to
  8 differing words), COPY (per changed byte of the copy: time, run,
  phase, place, offset, truth, found, read again as a byte, a word and
  after ~4 ms, the chunk's old and new sum), HEAL (a chunk back to the
  truth), END. Copy events capped at 64 between two runs' starts, the rest
  counted. A whole block does not fit (8 KB at the least, 32 KB of SRAM).
* **Written to the WRAM first** and copied to the SRAM after the boot's
  check, at a run's start, between passes, before the rereads, at the end,
  and while the pages are shown: inside a pass the SRAM does not change,
  so its seeks pay the checksum alone.
* SELECT at power on or reset empties the log. Page 1's last two lines:
  boots and the last record's number, and "RESET, THEN SEND THE .SRM".

`parse_srm.py` looks for records at every byte, keeps the ones whose
checksum holds, orders them by number, says the gaps and the broken ones,
and computes the truth again from `build.py`'s formula; `--json` too.

#### Measured in the emulators

Under `nice -n 19`, the load at 4-18 with Chajá's and others' suites:
23:10:08-23:10:12, 23:12:07-23:13:31, 23:13:52-23:14:00, 23:14:15-23:14:21,
23:14:45-23:14:46, 23:15:05-23:18:15, 23:18:21-23:20:25, 23:23:07-23:23:17,
23:23:49-23:27:31.

`just msu-dma`, exit 0 (23:23:49-23:27:31): the first two ROMs as before,
and `measure.py --sram`: in snes9x, mesen-s, Mesen2 and Mednafen's own
save file, every PASS entry equal to the WRAM's results, every run
whole, no gaps; bsnes and the audit core do not expose their SRAM. snes9x:
START and reset —the second boot logged as warm—, Y held (the flag on the
first boot only), and the `.srm` with a byte damaged, cut and without its
header: the rest read, the damaged one said. The `--rot` build: the byte
logged at BOOT, every block that read it a DIFF with verdict REF and got =
truth ≠ copy at `8E93`, and —with the sums the ROM last saw changed in its
WRAM, since no emulator changes its ROM— the same byte logged again IDLE,
and a HEAL for a chunk with none. An 8 KB `--rot` build went round its ring
after 4 runs: records 18-82 read, 1-17 said missing, the newest run whole.
By hand: SELECT at reset wiped it (flags warm, wiped, fresh; numbers from
1, nothing left past the new records).

Once, at load ~12, Mednafen left no save state in its 20 s: `measure.py`
now gives it a second try of 60 s when the run did not end.

#### Where the `.srm` goes, and when (read, sd2snes `cf7e21d`)

Not next to the ROM: `save_srm` writes `/sd2snes/saves/<rom name>.srm`,
and an `.srm` next to a ROM is moved there when it loads. With a `.msu`,
written only at a silent data seek, at a track start (once a second at
most), at a short reset (`save_during_msu_shortreset`) and at a reset to
the menu (`prepare_reset`); never at power off. taro confirmed the short
reset with ABL on 2026-11-17; the menu path is read, not tried. So the
README asks to go back to the menu before turning off, and to copy the
`.srm` off the card after each session: the 32 KB ring holds about four
runs full of bad blocks.

#### Delivered

`/shared/builds/msu-dma-test/`, next to the second delivery's files,
which did not change: `msu-dma-test-sram.sfc` sha1
`98da8606bc73095c65c4e339e694df67a02114b9`, its `.msu` and `-1.pcm` (the
same bytes under its name), `emulator-summary-sram.png`, two example
`.srm` from snes9x with their `parse_srm.py` reports (a normal one with
START and reset; the planted copy error), and the `README.txt`: what each
ROM is for, the order (sessions 1-2 the old ROM, 3-4 the SRAM one, normal
and with Y), what looks different and is expected (silent seeks ~50 ms),
where the `.srm` is and how to get it written.

**What taro has to do**: sessions 3 and 4 of the README, and send the
`.srm` copies with a photo of page 1 of each run.

**What to install when merging**: nothing; no tool of the-advocate
changed. Not run: ABL's suite (nothing it builds changed), the console.

### 2026-11-23, Hornero: read live over USB, and the error gone on both consoles

With the FX Pak's USB in the container (see "Where this runs" in
`AGENTS.md`), Hornero read the ROM's copy in its PSRAM with usb2snes GETs
—the client, checked against sd2snes v1.11.0's `src/usbinterface.c`, in
`~/scratch/hornero/fxpak/fxpak.py`— at the four places, A+8E93, B+2B17,
C+946F and D+3F5A, 16 bytes around each:

* The second ROM, freshly loaded and after several START runs, all green:
  the four places identical to the delivered `.sfc`. No COPY CHANGED.
* The first ROM, rebuilt from the ports' `512ef02` —sha1 `a5908a44…`, the
  one that failed—, uploaded to `/advocate/msu-dma-v1/` with PUT (~380
  KB/s, read back with the same hashes) and booted with BOOT: clean after
  the automatic run, and then green for five or six START runs; green too
  with the USB cable unplugged.
* taro then noticed the failing sessions had been on the **Super Famicom**
  in the living room, and these on the SNES (CPU/PPU1/PPU2 2/1/2). Back
  on the Super Famicom, many runs: all green as well.

taro:

> I give up. Many runs, all green on the Super Famicom too 😭

What changed between the failing sessions and these: the FX Pak was
powered off with the cable out —a full reset of its MCU; with the cable
in it stays half powered—, savestates are off, and time went by. The
likeliest reading is that the FX Pak was left in a bad state that
session and a full power-off cleared it; it is not proven. Every received
block summed right in every run, so **the big DMA from `$2001` holds on
the FX Pak**: what failed was the comparison against the ROM's copy. If it
comes back, the second ROM's verdicts and a live read over USB tell which
side it is.
