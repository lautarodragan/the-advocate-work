---
name: "Expansion chips: SA-1 and S-DD1"
description: "Whether it is worth moving the cartridge to SA-1 or S-DD1: support, what each one gives measured, what it costs, and when"
type: refactor
status: wishlist
---

# What

taro asked on 2026-09-26 whether it is worth using an **expansion chip** of those
used by official games and supported by the FX Pak Pro, limited to two: the
**SA-1** (a second 65816 at 10.74 MHz, Super Mario RPG, Kirby Super Star) and the
**S-DD1** (a hardware decompressor, Star Ocean and Street Fighter Alpha 2).

This is the investigation, not the implementation: not a single line of the ROM changed.
What follows comes from the emulators' code and the FX Pak's firmware
—cloned in `/extras/ref/`—, from fullsnes, and from measurements made with the harness
on `8527f44`. How each thing is reproduced is at the end.

# Status

Investigated on 2026-09-26. **The recommendation is not to migrate to either now**, and
to keep the S-DD1 as the prepared answer for when the cartridge reaches the
threshold in `decisiones/el-cartucho-se-queda-en-4-mb.md`. The SA-1 is to be looked
at again only when the car race is tackled, and only if optimising the
interpreter wasn't enough first. The why is in "The recommendation".

# Support

| | SA-1 | S-DD1 | MSU-1 together with the chip |
| --- | --- | --- | --- |
| **FX Pak Pro** | Yes, since firmware **v1.9.0** (RedGuy). Up to 8 MB | Yes, since **v1.10.0** (magno) | **Yes for both.** The SA-1 core compiles the MSU-1 only on the Mk3, which is the Pro: on an sd2snes Mk2 there is no MSU-1 with SA-1 |
| **Mednafen**, `snes` module (the one it uses by default, a fork of bsnes v0.059) | Yes | Yes | **No**: that module has no MSU-1, same as today |
| **Mednafen**, `snes_faust` module (experimental, requested with `-force_module snes_faust`) | Yes | Yes | **Yes**. Its documentation says "timing is approximate" |
| **snes9x** (the suite's core) | Yes | Yes, by HLE: it decompresses the whole transfer when the DMA starts | Yes |
| **bsnes** (the one in `test_cores.py`) | Yes | Yes | Yes |
| **mesen-s** (libretro) and **Mesen2** | Yes | Yes | Yes |
| **ares** | Yes | Yes | Yes |

What each row says, with where it is written:

* **FX Pak.** `sd2snes`'s `CHANGELOG` (cloned at `cf7e21d`, which is v1.11.2):
  "v1.9.0 — add SA-1 support by RedGuy", "v1.10.0 — add S-DD1 support by
  magno". The detection is `src/smc.c:232-257`: `map & 0xEF` —that is, the
  FastROM bit doesn't matter— at `$23` with type `$32/$34/$35/$36` is SA-1, at `$22` with
  `$43/$45` is S-DD1. Both FPGA cores carry their `msu.v`
  (`verilog/sd2snes_sa1/` and `verilog/sd2snes_sdd1/`), and the address decoder
  of both enables the MSU-1 at `$2000-$2007` the same as the
  base core (`address.v:116` and `:105`). The difference is that `sd2snes_sa1/msu.v`
  wraps everything in `` `ifdef MK3 ``. The SA-1 mapper keeps three bits per
  1 MB block (`sd2snes_sa1/address.v:73`): 8 MB. Save states do **not**
  work with chip games (note in v1.11.0).
* **Mednafen.** `Documentation/snes.html` and `snes_faust.html` from the tarball of
  1.32.1, which is the installed one. The `snes` module detects the SA-1 and the S-DD1 in
  `src/snes/src/cartridge/header.cpp:151` and `:160`, and carries nothing of MSU-1.
  `snes_faust` lists "CX4, DSP-1, DSP-2, MSU1, S-DD1, SA1, Super FX"
  (`src/snes_faust/cart.cpp:352-354` detects, `msu1.cpp:430` maps the MSU-1
  separately from the chip). **In passing**: `docs/snes/emulators.md` says Mednafen doesn't
  have MSU-1, and it is true only of the default module. With
  `mednafen -force_module snes_faust abl.sfc` the MSU-1 should play today;
  I didn't try it.
* **snes9x.** `memmap.cpp:2172-2225`: the key is `(tipo << 8) | mapeo`, and the
  SA-1 is **only `0x3423` or `0x3523`**, that is, exactly mapping `$23`. With `$33` —the
  same with the FastROM bit— it doesn't recognise it. The S-DD1 is `0x4332` or `0x4532`.
  The MSU-1 goes through `ppu.cpp:241` and `:989`, which don't look at the chip. The S-DD1 is
  HLE: `dma.cpp:131-155` decompresses everything when the DMA starts, only if the channel
  is in fixed address mode, and clears `$4801` entirely instead of channel by
  channel like bsnes.
* **bsnes.** `heuristics/super-famicom.cpp:255-293`: mapping `$22/$32` is S-DD1,
  `$23/$33` is SA-1, and the high nibble of the type confirms it. The boards are
  `SA1-RAM` and `SDD1-RAM` from `boards.bml`. The MSU-1 is loaded if
  `msu1/data.rom` exists, without looking at the board (`sfc/cartridge/load.cpp:72`).
* **Mesen2** (`Core/SNES/BaseCartridge.cpp:274-275`, by the high nibble of the type)
  and **mesen-s** (`Core/Sa1.cpp`, `Core/Sdd1.cpp`): the MSU-1 is set up by
  `SnesConsole.cpp:127` separately. **ares**: `mia/medium/super-famicom.cpp:556-600`
  is the same heuristic as bsnes, and the MSU-1 goes separately
  (`ares/sfc/cartridge/load.cpp:54`).

So **the header would have to say `$23` and `$35` for the SA-1** —SA-1,
RAM and battery; `$23` because snes9x accepts nothing else— and **`$32` and `$45` for the
S-DD1**. None of the emulators that matter is an obstacle, and neither is Mednafen:
it stays as it is today, without MSU-1, which is the path the ROM already supports.

# What each one would give

## More than 4 MB

The 4 MB decision says that going past that is ExHiROM. Both chips have their
own mapper, and neither asks for ExHiROM:

* **SA-1**: up to **8 MB**, in 1 MB blocks (`$2220-$2223`, fullsnes "SNES
  Cart SA-1 Memory Control"). **Four are visible at once**: with 4 MB nothing has to be
  switched, and from 4 to 8 you have to choose which block goes in each window.
* **S-DD1**: 1 MB blocks in four windows `$C0-$FF` (`$4804-$4807`). Star
  Ocean uses 6 MB; bsnes accepts 4 bits per register, and the FX Pak since v1.11.1
  detects S-DD1 of more than 48 Mbit ("fixes the PT-BR translation of Star
  Ocean"). The LoROM window `$00-$3F:8000` sees **only the first 2 MB**
  (`sfc/coprocessor/sdd1/sdd1.cpp`, `mcuRead`).

But with S-DD1 the 4 MB question changes shape, because **it compresses**: what
is measured below says that the graphics that travel by DMA end up at less than a
third. The whole game was estimated at ~7 MB uncompressed, and the bulk is
graphics.

## Compression: the S-DD1

**The format.** It isn't an LZ: it is a **context-adaptive binary
coder**, bit by bit, with runs coded in Golomb and eight run
"buckets" according to the estimated probability (fullsnes, "SNES Cart S-DD1
Decompression Algorithm"; the original description is by Andreas Naive). What
makes it good for this console is that **it understands planar tiles**: it has
2, 4 and 8 bitplane modes, and the context of each bit is the history of its
own plane, including the row above. It also has an "8 bits" mode for
data that isn't tiles.

**There is a compressor, and now there is one of our own.** Andreas Naive published a compressor
in C++ on the superfamicom.org wiki (`CompressionExample.7z`, page "S-DD1"),
with no explicit licence. To measure without depending on that I wrote one from
fullsnes's pseudocode: `/extras/scratch/chips/sdd1.py`, about 150 lines.
**It is verified by a decoder that isn't mine**: each compressed block is
decompressed with snes9x's —`sdd1.c`, compiled separately— and comes out byte for byte
the same. What is **not** verified is against the real chip; the FX Pak
isn't either: it is a VHDL reimplementation of the same algorithm.

**The ratio, measured on 2026-09-26** on the blocks of `release` at `8527f44`,
choosing per block the best of the four context configurations. zlib
-9 serves as a reference, as a ceiling for what software gives —a decompressor in
65816 stays well below zlib—:

    class          bpp  unit            raw        S-DD1            zlib -9
    map_tiles       8   the map       458.9 KB   252.7 KB (55%)   223.9 KB (49%)
    sprite_poses    4   the pose, 512 366.0 KB   108.1 KB (30%)   135.0 KB (37%)
    sprite_tiles    4   the block     287.8 KB    61.3 KB (21%)    53.2 KB (18%)
    anim_batalla    4   the block     548.0 KB    17.5 KB ( 3%)    21.6 KB ( 4%)
    battler         4   the block      74.8 KB    34.2 KB (46%)    32.9 KB (44%)
    fondo           8   the backdrop   48.0 KB    27.6 KB (58%)    31.1 KB (65%)
    titulo_tiles    8   the image      31.0 KB    13.3 KB (43%)    13.7 KB (44%)
    above_tiles     4   the map        19.3 KB    10.6 KB (55%)    11.3 KB (59%)
    map_celdas      8b  the map       278.2 KB    38.4 KB (14%)    22.9 KB ( 8%)
    map_bloques     8b  the map        51.8 KB    23.4 KB (45%)    20.2 KB (39%)
    evcodigo        8b  the map        39.1 KB    29.7 KB (76%)    16.1 KB (41%)
    mensajes        8b  the block      64.8 KB    55.7 KB (86%)    26.0 KB (40%)
    total                            2267.7 KB   672.6 KB (30%)   608.1 KB (27%)

Three readings:

* **In tiles it beats or ties zlib**, and in the poses, which is what matters
  most, it clearly beats it: 30% against 37%. In what isn't tiles —bytecode,
  text— it loses badly: its 8-bit mode doesn't see byte repetitions, only
  bit statistics.
* **`anim_batalla` is 97.8% zeros** —measured: 931 distinct tiles out of 17,536—.
  Those 530 KB are recovered by any RLE or software deduplication and aren't
  an argument for the chip. I pass it on to whoever investigates software
  compression. Without it, the graphics that travel by DMA go down from 1286 KB to 507 KB
  with the S-DD1.
* **What only the chip gives is decompressing without CPU**: the S-DD1 delivers one byte
  per DMA cycle, so a compressed pose is uploaded in vblank in the same
  time as a raw one and without a single extra instruction. In software, the
  on-the-fly poses —which are uploaded by DMA in vblank, like FF5— would cost
  CPU in the worst place.

**The restrictions**, all in the emulators' code:

* **Only by DMA.** Reading the compressed data with the CPU returns the
  compressed bytes. The DMA has to come from `$C0-$FF`, with the channel enabled in
  `$4800` and `$4801`, and **with a fixed source address** —bit 3 of `DMAP`,
  the same trick the MSU-1 data port already uses—: bsnes compares each
  read against the address the DMA started with (`sdd1.cpp`, `mcuRead`), and
  snes9x only decompresses with `AAddressFixed`.
* **A DMA is a stream**, starting from zero, of up to 64 KB. There is no random
  access inside: **the map's grid, which is walked with a pointer while
  walking, can't stay compressed in the ROM**. It could be decompressed to
  WRAM when loading the map —the DMA reaches `$2180`— and bank `$7F` is free,
  but that is another decision.
* **The destination can be anything on bus B**: VRAM, CGRAM, or WRAM through
  `$2180`.
* **The memory map changes**, and not a little: the LoROM window sees only the
  first 2 MB, so everything that today lives in banks `$40-$7D` —the upper 2 MB—
  moves to `$C0-$FF`, in 64 KB banks. SRAM stays where it is,
  at `$70` (bsnes's `SDD1-RAM` board, Mesen2's `Sdd1.cpp:25`, snes9x maps
  `$70-$7F`), and **FastROM is kept**: `$32` is the fast mapping both
  games use, and `$80-$BF` is still the mirror of `$00-$3F`.

## CPU: the SA-1

A 65816 at 10.74 MHz with 2 KB of I-RAM, the cartridge's BW-RAM —which is the SRAM,
with battery—, cross interrupts, multiplication and division, bitmap to
planar conversion by DMA and variable-length bit reading (fullsnes, "SNES
Cart SA-1"). **It doesn't see the console's WRAM, nor the PPU, nor the APU, nor the main
CPU's DMAs.**

What it really yields is in bsnes's `sfc/coprocessor/sa1/memory.cpp`:

    the SA-1 reads...       cycles   that is       if the main CPU is
                                                   on the same memory
    ROM                        1     10.74 MHz     2 cycles: 5.37 MHz
    I-RAM                      1     10.74 MHz     3 cycles
    BW-RAM                     2      5.37 MHz     4 cycles

The main CPU, against that, reads ROM at 3.58 MHz with FastROM and WRAM at
2.68. **The trap is the right-hand column**: our whole code runs
from ROM, so while the main CPU works, each ROM read by the
SA-1 costs double. An interpreter that reads bytecode from ROM and state from
BW-RAM yields between **1.5 and 3 times** today's, not four, and the good end
requires the main CPU to wait with `wai` or from WRAM.

**And FastROM with SA-1 isn't clear.** fullsnes: "The SNES CPU can access
memory at 2.68MHz rate (or 3.5MHz, but that mode may not be used in combination
with the SA-1)". bsnes and snes9x respect `MEMSEL` anyway, and Mesen2 even models
FastROM against the SA-1's conflicts (`Sa1Cpu.cpp:141`), so **no
emulator would catch it**. The FX Pak isn't the real chip but an FPGA, so
what it does there doesn't prove what a real SA-1 would do either, but it is what matters
for taro. Losing FastROM means losing what `RAPIDO` gained on 2026-09-11 —the
opening lost one frame in three without it— in everything that stays on the
main CPU.

# Where the frame goes today

## The method

The ROM has no profiler, so I built **a probed copy**:
`/extras/scratch/chips/instrumentar.py` copies `rom/src/` to a separate directory,
puts after each `jsr` of the main loop a `jsl` to a probe that reads the
vertical counter's line (`$2137`/`$213D`) and accumulates at `$7F:F000` how many
lines passed since the previous probe, and does the same around
`music_tick` in `irq_musica`. It builds against the `.inc` files in `rom/build/release`, without
touching the tree. `medir.py` runs scenes and, on each pass of the loop, splits its
lines by routine.

**Each probe costs one line** —measured: two probes in a row give 1.0 between
them—, and in a normal pass about 27 run. That is, the probed passes
are **~27 lines inflated**, and what they say about "lost frames" is
pessimistic. That's why each scene was also run on the real ROM
(`REAL=1`), counting passes against frames. A pass has 262 lines.

## The stones minigame (map 11)

    scene                                   real ROM                 probed
    walking at (19,46), no stones           599 passes / 600         598 / 600
    stones mode, still                       60 / 60                  60 / 60
    stones mode, throwing two stones        139 / 140                138 / 140
    stones mode, walking                    240 / 240                239 / 240

In the emulator, **today the minigame hardly loses frames**: one every 140 to 600.
What the probe does say is that **the margin is thin and where the cost is**:

    stones mode, still — 191 lines per pass (~164 without the probes)
       parallel (eventos_de_mapa)     123   47% of the 262
       build_oam                       28
       flush_video                      6
       the rest, one or two each      ~34   (almost all of it, the probe itself)

The passes that overrun are those that add to the parallel ones a hero step
(`move_hero` 14, `stream_map` 30) or a page refresh (21). **What eats
is the interpreter of the parallel ones**: the map has **13 parallel pages
without a wait** —the six `Light*`, the idol, three guards, the PC, `EV0017` and the
145-command `LightFloor`—, and each one runs entirely every frame. They come to
about 9 lines per page.

I didn't reproduce heavy lag. If taro sees it while playing, it is most likely
one of those peaks added to something these scenes don't touch —a guard
walking, a message—, and with 60 lines of margin little is needed. **It is CPU**, and
it is exactly what the SA-1 speeds up.

## The terrace (map 32)

`EV0005`'s cutscene has no `TintScreen`: **the "tints" are
flashes**, seven `FlashSprite` —Kersh blue, Arden light blue, the hero red— and
three `FlashScreen`. Played up to the battle with A every 20 frames, **the real
ROM loses 9 isolated frames in ~2100**. The heavy passes, probed:

    121 passes of more than 224 lines, 260 on average; the worst, 289 (~262 without
    the probes):
       destello_tick     103   FlashScreen: redoes the whole palette
       flashes_tick       94   FlashSprite: redoes the event's palette
       build_oam          32
       flush_video        11
       parallel           11

**Almost 200 of the 262 lines go into redoing palettes** when a
`FlashScreen` and a `FlashSprite` coincide. It is pure CPU: multiplications and
divisions per colour, same as the tint (see `tabla_canal` in
`rom/src/tinte.s`, which already had to drop ninety-six `jsr` to fit).
Uploading the palette to CGRAM in vblank is 512 bytes: it isn't that.

## The race (maps 49-54)

It isn't in any ROM, so **it isn't measured**. What can be counted is
the work (`/extras/scratch/chips/carrera.py`): maps 49, 52 and 54 have
**41 parallel pages each** —`RaceController2` and forty events of ~17
commands that read coordinates, compare and change the sprite—, against the 13 of
map 11. At map 11's 9 lines per page, that's **~370 lines: it doesn't fit in
a frame** with the interpreter as it is today. It is an order-of-magnitude
estimate: map 11's pages aren't the same as these.

# taro's ideas, one by one

**The stones minigame.** The cost is the interpreter of the parallel ones
(~123 lines). On the SA-1 those pages would run 1.5 to 3 times faster, that
is, the margin would go from ~60 to ~110-140 lines. But today it hardly loses
frames in the emulator, so the SA-1 would fix a problem that in
software is fixed more cheaply: see "Without a chip".

**The terrace.** It is the SA-1's best candidate by shape —redoing a palette is
a pure function: in go the palette and the flash, out comes the palette—, and the SA-1 would
do it in its I-RAM while the main CPU carries on; the main CPU's DMA
reads I-RAM and BW-RAM, which are on bus A. But it is also the
easiest case without a chip: a flash's palette can be computed once per
strength step, or spread across frames, or not redo what didn't change.

**The car race.** It is the only case where the SA-1 could be the difference
between 60 and 30 fps, because ~370 lines of parallel ones don't fit even with an
interpreter twice as fast on the main CPU. With the SA-1, at 1.5-3 times,
they come to 120-250. **Before deciding it has to be measured**: put 52 in a test
cartridge and run the probe.

**Move the parallel events to the SA-1.** It is the general one, and that's why it is the version
that counts: it knows nothing about ABL. What it requires:

* **everything the bytecode touches has to live in BW-RAM or I-RAM**: the
  variables (today at `$7E:2600`, through the `WMADD` window), the switches, the
  event table with their positions, the state of each parallel one
  (`FAR_PAR_ESTADO`), the randomness, the inventory. They are all the users of
  `WMDATA` —about 190 in 17 files— and those of the BSS the interpreter looks at;
* **what the bytecode does with the hardware can't be done by the SA-1**:
  `PlayBGM`, `PlaySound`, a message that uploads glyphs, a teleport that
  reloads VRAM, a tint that uploads palettes. Those opcodes become requests
  in a queue the main CPU serves;
* **the order of `Game_Map::Update` can't be broken**: the parallel ones go
  before the hero and the goldens are pixel exact. That is, the main CPU
  **waits** for the SA-1 to finish, and what is gained is the segment's speed,
  not parallelism. The only thing that can overlap is what doesn't look at
  the events' state.

**Have the main CPU process the transitions and the SA-1 do the checks.**
On map 11 "the checks" —where the stone is, whether I stepped on a light— **are
RM2k pages**: the `Light*` and the `LightFloor`. Having the SA-1 do them without
ABL code is exactly the previous idea. Any finer version —the
SA-1 compares positions and the main CPU decides— needs to know which page
is "a check", and that means recognising the minigame from the inside, which is what
`el-mapa-11-se-rediseno.md` already discarded with path 4.

# Designs

**A. The event interpreter on the SA-1, the main CPU with video and
audio.** It is the previous idea taken to the whole interpreter: `eventos_de_mapa`,
`eventos_tick` and the routes. It wins in the three measured cases and in the race.
It requires moving the events' state to BW-RAM and the request queue. The
big problem is synchronisation: each opcode that touches hardware is a round
trip, and a message or a battle are many.

**B. The whole game on the SA-1, the main CPU as an I/O servant.** It is how
Super Mario RPG and Kirby are made: the whole loop runs on the SA-1, and the main
CPU only does the vblank DMA from shadows in BW-RAM, reads the
controller and plays the music from its IRQ. It wins everything, `build_oam` and `stream_map`
included, and there is no synchronisation within the frame. In its favour, the
SA-1 sees I-RAM at `$0000-$07FF`, so the direct page and the stack stay
where they are. But the BSS —7680 bytes, full— doesn't fit in the 2 KB of I-RAM and
goes to BW-RAM at 5.37 MHz, and **the BW-RAM is the battery-backed SRAM**: working
in it changes its CRC every frame, and the FX Pak writes the SRAM to the card
when it sees it change (`msu_savecheck` in `src/msu1.c:73`, in the MSU-1's pauses). It is the
biggest refactor of the three.

**C. Specific jobs.** Everything stays on the main CPU and the SA-1 receives
pure functions: the palette of a tint or a flash, a software
decompression at 10 MHz. It is the most incremental and the cheapest, but **it doesn't touch the
interpreter**, which is what eats on map 11 and in the race.

# What migrating would cost

## Step zero: change the mapping without using the chip

It is the incremental path, and it is the same for both: the ROM starts declaring the
chip, is rearranged, and **doesn't use it**. It is verified by the goldens —the ROM has to
draw exactly the same— and `test_cores.py`.

What it touches:

* **`tools/ensamblado/bancos.py`**, `ld65`'s `.cfg`. Today they are 126 LoROM areas
  of 32 KB in `$00-$7D` and two reserved. With S-DD1, the upper 2 MB go to
  `$C0-$FF` in 64 KB banks; with SA-1, either to `$80-$BF` (its MMC's default
  mapping puts MB 2 and 3 there, in LoROM) or to `$C0-$DF`. The two reserved
  for `$7E-$7F` are no longer needed.
* **`RAPIDO`**, in three places. With S-DD1 nothing changes. With SA-1 it depends on
  FastROM: if it is valid, the MMC is programmed so that `$80-$BF` mirrors
  `$00-$3F` (`$2222 = $80`, `$2223 = $81`) and the high MBs go to `$C0-$DF`; if it isn't
  valid, the code stays at `$00` and the mirror goes away.
* **The header** (`rom/src/cabecera.s`): two bytes, and the checksum stays in the
  same place.
* **The SRAM**: with S-DD1 it stays at `$70`. With SA-1 it moves to `$40` and writing
  has to be enabled for the main CPU (`$2226`), which starts protected.
  `SRAM_BANCO` is in `partida.s`, `ranuras.s` and `nivel.s`.
* **The harness**: `en_la_rom` in `pruebas/arnes/consola.py` is the LoROM formula and
  it is used by the tests that read tables from the ROM. And the converter has two
  written LoROM assumptions (`snes_convert.py:2977` and `:3634`) and a grid
  pointer that crosses banks by adding one: a block can't straddle
  the 2 MB.
* **`just entregar`** and the `.sym` don't change: they are built by the same `ld65`.
* **The MSU-1** doesn't either: `$2000-$2007` doesn't clash with either of the two
  (the SA-1's `$2200-$23FF`, the S-DD1's `$4800-$4807`).

On the order of **100 to 200 lines**, almost all in Python.

## What comes after

* **S-DD1, the compressed poses.** The converter compresses —the compressor in
  `/extras/scratch/chips/sdd1.py` goes into the disk cache, because in Python it takes
  minutes—, and the poses' DMA switches to fixed-source mode from `$C0-$FF`.
  Small: the format touches the ROM only in how the DMA is set up. Then, the
  tiles of maps and backgrounds on load.
* **SA-1, design A or B.** Weeks. Moving the state, the SA-1's boot
  (it starts at reset and has to be given its vector), the mailbox and the request queue.

## What the tests would catch and what they wouldn't

**They catch**: any data misread by the new mapping —the goldens, in
pixels—; uninitialised memory —`test_cores.py`, which with SA-1 would also
have to look at the BW-RAM—; the saved game —`test_guardar.py` and the slot ones,
through the SRAM that snes9x exposes—; an extra frame —`cuadros_perdidos` and
`test_el_hq_de_los_lazer_teeth_entra_en_el_cuadro`—.

**Nothing catches**, and it has to be taken to the FX Pak:

* **FastROM with SA-1**: the emulators let it work;
* **the MSU-1 together with the chip** on the FX Pak, and the data port by DMA there;
* **the SRAM on the FX Pak**: where the S-DD1 core maps it —v1.11.1 mentions
  a "mixed mapper SRAM layout"— and how the SA-1 one writes the BW-RAM;
* **the SA-1's timing**: snes9x approximates it and bsnes doesn't, so on a map that
  just fits `test_cores.py` could start going red because of a lost frame in
  one and not in the other;
* **Mednafen**, which no test runs.

# The recommendation

**Don't migrate now.** Neither of the two fixes anything that doesn't have a
cheaper fix today:

* map 11 hardly loses frames, and what eats is the interpreter;
* the terrace is palettes that can be computed fewer times;
* the cartridge hasn't reached the threshold the 4 MB decision set itself to be
  revisited (`radio.py` from the compression study, over the `.dbg`, gives ~77% on
  2026-09-26).

**The S-DD1 is the answer for space**, and it is worth having it ready for
when the cartridge reaches 85-90%. Against software compression it wins
where software can't: it decompresses **without CPU**, in the same DMA, so it also serves
for the poses that are uploaded every frame. It leaves all graphics at
less than a third, keeps FastROM and the SRAM at `$70`, and it is run by the FX
Pak with MSU-1, the harness's four emulators and Mednafen without MSU-1. Against:
two games used it, the compressor is ours, and the ROM gets tied to a chip that
no ordinary cartridge has.

**The SA-1 is the answer for the race**, if needed. Before that, two things in
this order: measure the race in a test cartridge, and optimise the
interpreter, which is general and works on any console. If with that the
race's parallel ones still don't fit in the frame, design A is the
way. You can't have both: they are different boards.

## Without a chip

* **The interpreter of the parallel ones**, which is what eats the most on map 11 and in
  the race. The general approach: fuse in the compiler the RM2k patterns that
  repeat in each page —read an event's X into a variable and compare it—,
  and read variables with `lda f:$7E2600, x` instead of the `WMADD` window
  (three writes and two reads per variable). The comment in
  `ram_lejana.s` says that memory "can't be indexed"; with
  long addressing it can. It has to be checked with `git blame` why the
  window was chosen before touching it. How much it would gain isn't measured.
* **The flashes' palettes**: compute each strength step's palette
  only once, spread the work across frames, or not redo what didn't
  change. The hardware's colour addition doesn't help: it gives `c + f·s` and not RM2k's
  blend.
* **Software compression**, which another agent is investigating: for
  `anim_batalla` an RLE is enough, and for maps it is decompressed on load,
  which is when there is time to spare. What it can't do well is the poses.
* **ExHiROM**, which the FX Pak supports (`smc.c:259`, `mapper_id = 2`), is still
  worth what the decision says: it changes how each address is computed, same
  as step zero of either chip, and gives neither compression nor CPU.

# How it is reproduced

The scripts stayed in `/extras/scratch/chips/`, and they all carry the
worktree's root written inside (`WT`): it has to be changed before running them, and
`release` has to be built first.

* `instrumentar.py` builds the probed ROM in its own directory;
* `medir.py <escena>` runs `mapa11_caminar`, `mapa11_piedras`, `terraza` or
  `terraza_real`, probed or with `REAL=1` on the real ROM;
* `sdd1.py` is the compressor and decompressor, with its round-trip test;
  `armar_s9x.py` sets up snes9x's decoder to compile it with
  `gcc -O2 -o s9x_sdd1 s9x_sdd1.c`, and `ratio.py` gives the table above
  (`ratio.log` is the run);
* `paralelos.py` and `carrera.py` count a map's parallel pages.

The clones: `/extras/ref/sd2snes` (the FX Pak's firmware), `/extras/ref/ares`,
`/extras/ref/mednafen-src` (the 1.32.1 tarball) and `/extras/ref/fullsnes`.
bsnes, snes9x, mesen-s and Mesen2 were already there; the snes9x in `/extras/ref` is the
same commit as the installed core.
