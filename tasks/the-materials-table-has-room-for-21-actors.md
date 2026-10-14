---
name: "The materials' table has room for 21 actors"
description: "FAR_GROWTH is placed by hand in far RAM with room for 21 experience slots; with every map of ABL 23 actors can join, and the assembler stops"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
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

## Log

**2026-10-14, Tijereta.** the-advocate, branch `tijereta-blockers`, commit
`61c9d5e3`; the-advocate-ports, branch `tijereta-blockers` (from
`d91049e`), commit `0702de0`.

* **`FAR_GROWTH` is a `.res EXP_K * GROWTH_BYTES` in `FARBSS`**, in
  `medicine.s`: it cannot go in `far_ram.s`, which comes before the
  cartridge's `.inc` and so before `EXP_K`. `bank1.s` (`save_table`) and
  `level.s` come before `medicine.s` in `main.s`, so they reach it with
  `.loword` and `f:` (the `FAR_LENGTH +` went: the label carries the
  bank); `medicine_use` runs with the data bank at `$7E` and takes the
  `.loword`. The two asserts against `PANO_ON` are gone: the linker guards
  it now. `$7E7D00`–`$7E7DFF` is free.
* **`FARBSS` did not have room**: 174 bytes left, and `release` asks for
  216, the whole game 276. So the pool took the next stretch, the flash
  palettes' `$7E6900`–`$7E69FF` (`FAR_POOL_SIZE` `$240` → `$340` in
  `banks.rs`), and the palettes went into the segment too, in
  `character_flash.s` —`FLASH_MAX * 32`, half of it—. That is how
  `banks.rs` says the pool grows. `just space`: **86 B of far RAM left in
  `release`, 20 B in the whole game**. If more is needed, `$7E66B0`–`$66BF`
  is free too (the scene's reservation ends at `$66B0`), and after that
  come the map's strips at `$7E6A00`.
* **The test**, in ABL:
  `test_the_materials_table_has_room_for_the_whole_game` in
  `tests/tooling/test_wram_reservations.py`: `FAR_GROWTH` is in `FARBSS`,
  and the pool leaves room for a row per actor that any map of the dump
  adds by its number plus the starting party —23, what the converter's
  `possible_members` gathers—, measured on `release`. Red with the tools at
  `51b4b1b2`, green after. `test_materials.py` reads the table through
  `in_the_wram`, since the label carries the bank now.
* **The whole game**: with Cardón's experiment (see the text task) and no
  assert commented out, the `whole` cartridge assembles with `EXP_K = 23`.
* ABL's suite with these tools: 1304 passed, no golden moved; `just boot`
  9. **What the suite does not cover**: a material used on the actors
  only the whole game carries (29–34); the rows are the same code for any
  slot, and `test_materials.py` covers using one and the save.

To install when merging: `cartridge` (and with it `project`):
`FAR_POOL_SIZE` is compiled into it.
