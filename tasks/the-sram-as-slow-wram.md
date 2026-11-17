---
name: "The SRAM as slow WRAM"
description: "A 256 KB SRAM, and the part the save slots do not use as working memory reached by DMA through $2180 —the map's grid and code stashed across a battle, more room while the screen is black—; first, whether the FX Pak writes its SD card on every change"
type: research
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-11-16, asking whether part of the SRAM could be used as
slow WRAM, "to keep WRAM temporarily when we compress / decompress",
between fade out and in —entering or leaving a battle, changing maps—.
Hornero noted that DMA does reach it (A bus to WRAM through its B-bus port,
`$2180`), and three cautions: the FX Pak saves the SRAM to its SD card when
it changes; the save slots' area must never be touched; emulators save the
whole SRAM in the `.srm`. And then:

> I'd make the SRAM 256 KB, which seems to be a number the FX Pak and
> emulators accept. That can give us a lot of room for optimisations! [...]
> I _think_ the FX Pak's firmware at some point had an update precisely
> for this case (homebrews mainly, and maybe the SA-1?), but either way I'll
> test it, and that will tell us whether it affects gameplay.

Done means: what a 256 KB SRAM takes in ExHiROM (the header byte, where it
maps, what the emulators the suite uses and taro's —snes9x, bsnes, ares,
Mesen, Mednafen— and the FX Pak do with it; sources cited); a small test
ROM for taro to run on the FX Pak that writes a large SRAM region
repeatedly (as a battle would) and shows on screen what it did, so taro can
see whether the FX Pak stalls or writes the SD each time; the DMA path
measured in the harness (bytes per frame, both directions); and a
proposal: what to stash, the layout beside the save slots, what it
saves (load frames, WRAM) — measured, not implemented in the games yet.

## Log

2026-11-16, Aguará. Read from source, in `~/ref` (commits: sd2snes
`cf7e21d` = firmware 1.11.2, snes9x `890b5d44` = the installed libretro
core, bsnes `591b7e1`, bsnes-libretro `a7e88d6`, ares `4cb8d92`, Mesen2
`b9fa69d`, mesen-s `9e4fdeb`, Mednafen 1.32.1):

* **$FFD8 = $08** is 256 KB (1 KB << 8), and it is **the most ExHiROM can
  address**: the SRAM window is `$20-$3F:6000-7FFF` (and `$A0-$BF`), 32
  banks of 8 KB; the FX Pak's FPGA takes `{A20:16, A12:0}` (18 bits) for
  it (`verilog/sd2snes_base/address.v`, mapper `010`). The runtime already
  uses that window bank per slot, `$20-$23`.
* **Caps**: bsnes, ares, Mesen2 and mesen-s cap at 8 (ares wraps 9 to 2
  KB); snes9x at 9, but its libretro core reports at most 128 KB of
  SAVE_RAM to the frontend; Mednafen's `snes_faust` takes up to 9; **its
  default `snes` module masks the byte with 7, so $08 is 1 KB, "no RAM"**
  (`snes/src/cartridge/header.cpp:46`): no saves there at all. The FX Pak
  takes `1024 << n` with no cap.
* **The FX Pak does not write on every change**: it CRCs the SRAM and
  writes the whole `ramsize` to the `.srm`. Without MSU-1 (`snes_main_loop`)
  64 KB every 250 ms, and saves once the CRC has been stable for five full
  passes after a change, or every ~50 passes if it never settles. **With
  MSU-1** (`msu1_loop`, which is ABL's: its builds carry the `.msu`) it
  checks at most once a second, and **synchronously on every data seek**
  (`prepare_data` → `msu_savecheck(1)`), saving at once if changed — but
  only while no MSU audio or data is busy. The "firmware update" is 1.9.0's
  partial-SRAM CRC for **known** SuperFX/SA-1 games, a table keyed by the
  ROM's CRC (no homebrew), and 1.11.1's `autosave` / `msu1_autosave`
  toggles in `config.yml`.

The test ROM, in the ports' `abl/experiments/sram-dma/` (`just sram-dma`,
branch `aguara-sram-dma`): 8 MB ExHiROM like the game, `$FFD8 = $08`; a
round fills 96 KB of WRAM ($7E:8000-$7F:FFFF, which is exactly what a
battle takes from the map), stashes it in banks $24-$2F by DMA through
`$2180`, wipes it, brings it back and checks it; with MSU-1 it times a data
seek right after the stash and another after. Delivered to
`/shared/builds/sram-test/` with a README of what taro should look for.

Measured in the harness (snes9x, bsnes, mesen-s and the audit core, all
four the same within two lines): **256 KB seen in all**, 96 KB in **597-599
lines WRAM to SRAM and 598 SRAM to WRAM** = 8.3 master cycles a byte, **~43
KB a frame** each way; the stash survives a reset; banks $20-$23 untouched.
snes9x's libretro hands its frontend only the first 128 KB (the slots are
in the first 32 KB, so saves are unaffected), mesen-s 256 KB, bsnes saves
it itself. ABL's `release` with `$FFD8` patched to `$08` boots to the same
screens as without in snes9x, bsnes and mesen-s (frames 120, 300, 600): the
byte does not move the header detection, in them or in the FX Pak's
scoring (both header copies lose the same point).
