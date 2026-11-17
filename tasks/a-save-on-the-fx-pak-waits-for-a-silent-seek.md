---
name: "A save on the FX Pak waits for a silent seek"
description: "With a .msu, the FX Pak writes the .srm to its card only at a data seek or a once-a-second check made with no MSU-1 track playing, or on a reset: a game saved while a track plays and the console turned off before then loses the save"
type: bug
status: draft
---

Seen by Aguará on 2026-11-17, reading the FX Pak's firmware for
[`the-sram-as-slow-wram`](the-sram-as-slow-wram.md) (sd2snes `cf7e21d`,
firmware 1.11.2, `src/msu1.c`), with the-advocate at `269bb12c`. Read, not
seen on the console.

**What was read**: in `msu1_loop`, the loop the FX Pak runs a cartridge
with a `.msu` in —every ABL build—, the SRAM is checksummed and written to
the card only by `msu_savecheck`, which runs at the start of a data seek,
at a track change, or once a second, and only while no MSU-1 track plays
(`is_msu_free_to_save`); and by `save_during_msu_shortreset`, on a reset.
Turning the console off writes nothing. In ABL the once-a-second check
almost never runs either: after a data seek the firmware's data side stays
busy until a read reaches the end of the `.msu`.

So a save made in a place whose song plays from a track is on the card only
after the next silent moment that seeks the `.msu` —a map change with a
new song, a battle— or a reset. Without the `.msu` the firmware polls in
the background and writes within seconds.

**To reproduce**, on the FX Pak with the `.msu`: save in a map whose song
has a track, stay there, turn the console off, turn it on: the slot should
show the save from before. Then the same pressing reset before turning it
off.

**2026-11-17, Hornero, from taro's run of the SRAM test ROM on the FX
Pak** ([`the-sram-as-slow-wram`](the-sram-as-slow-wram.md)): after a power
cycle the ROM found the previous session's round counter (134) on the card
but its stash `LOST` —the 96 KB did not sum to that round's—: the card
held an image of the SRAM taken in the middle of a round, likely by the
periodic check while auto rounds wrote the SRAM. If so, a save slot being
written when such a check fires would reach the card half written. To
look at: whether the runtime's save slots carry a check that refuses a
torn one at load, and how many frames writing a slot takes.
