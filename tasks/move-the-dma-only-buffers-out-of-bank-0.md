---
name: "Move the DMA-only buffers out of bank 0's BSS"
description: "oam, oam_high, cgram_shadow and text_buf —3,024 B— are built in bank 0 and leave it by DMA, which reads any bank; the BSS has 97 B left in every game, and EV_MAX cannot grow by more than 13 events"
type: feature
status: draft
---

Suggested by Hurón on 2026-10-15, in the study
[`the-wram-and-sram-map-measured`](the-wram-and-sram-map-measured.md),
with the-advocate `6fa69781` and the ports at `f015801`.

**What was measured**: `just space` prints 97 B of `BSS` left in every
game's cartridge; the `BSS` does not depend on the game, only on the
runtime's caps (`EV_MAX` 120, `NPC_MAX` 104…). Its largest labels, from
the `.dbg`: `text_buf` 1,968 B, `npc_buf` 1,664, `oam` 512 + `oam_high`
32, `cgram_shadow` 512, `pal_buf` 512, `ev_pos_buf` 480, `route_ev` 384,
the four strips 384, `pick_by_ev` 240. Of those, `oam`, `oam_high`,
`cgram_shadow` and `text_buf` leave bank 0 only by DMA, and are written
with indexed absolute addressing in 11, 1, 4 and 8 places (`grep` over
the runtime). `pal_buf` has to stay: the battle scene borrows a page of
it as direct page. `npc_buf` is walked 118 times in the per-object loop
of `build_oam` and is better where it is. One more event in `EV_MAX`
costs 7 B of `BSS` and 9 of far RAM.

**What it costs**: each `sta oam, x` becomes `sta f:oam, x`, one byte of
ROM and one cycle; the DMAs already carry a bank byte. The failure mode
is a DMA whose `A1B` stays at zero: the screen shows it at once, and
`test_cores.py` and the goldens see it.

**What to decide**: which of the four go, where in far RAM —into
`FARBSS`, which needs the far RAM map placed by the linker first (its
own draft), or into a stretch of the hand-written map—, and whether
`text_buf`'s compositor, which writes it per letter row, pays the cycle.
