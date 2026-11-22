---
name: "A big DMA from the MSU-1's data port is unverified on the FX Pak"
description: "The battle backdrops already DMA 32 KB from $2001 in one go, and raw maps from the .msu would DMA up to 64 KB: nobody checked that the FX Pak refills its 16 KB buffer from the SD card as fast as a DMA drains it"
type: research
status: draft
author: chaja
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
