---
name: "The materials' table has room for 21 actors"
description: "FAR_GROWTH is placed by hand in far RAM with room for 21 experience slots; with every map of ABL 23 actors can join, and the assembler stops"
type: bug
status: draft
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: the assembler stops at the two asserts that guard
`FAR_GROWTH` —"what the materials added reaches the panorama's state", in
`runtime/far_ram.s`, and "the growth tables go into the panorama's state",
in `runtime/pano.s`—. `FAR_GROWTH` is at `$7D00` by hand, with twelve bytes
per experience slot up to `PANO_ON`: 21 slots, as its comment says. With
the whole game `EXP_K` is 23 (18 in `release`): Drago (29), Royal Dalia
(30), the Advocate (31), Kersh (32) and "ABL 2.0 Save" (34) join.

**How to see it**: `EXP_K` in the cartridge's `mapdata.inc`, and the
assembler's output.
