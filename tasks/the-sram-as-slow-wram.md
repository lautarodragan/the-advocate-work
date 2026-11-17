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
