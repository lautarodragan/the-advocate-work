---
name: "The text's measuring pass stops pages past 256 KB"
description: "compile's first pass gathers the boxes without letter pairs and without a cap, but the compiler still writes each offset in 16 bits: past 256 KB of unpaired text a page stops, and a common event stops the cartridge"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: `rm2k-snes-events compile` stops with "common event 12
compiled on its own and not with the cartridge's registries". Common event
12 is a two-line box. With a print in `body_of` (`commons.rs`): it stops at
its `ShowMessage`, with the text block at 262,207 bytes.

`compile` runs twice: the first pass gathers the boxes with
`Messages::measuring` —one byte per letter, "without the cap of the
operand"— and the second compiles with the pair table. But the
`SHOW_MESSAGE` arm of `compile.rs` still writes the box's offset with
`usize_word`, which refuses a value past 16 bits: past 256 KB of unpaired
text, every box makes its page "not compile" in the first pass. A map page
takes its texts back silently; a common event the plan said compiles stops
the cartridge. The block that goes into the ROM, with pairs, is far from
the cap: 218,410 bytes counting by eight (`MESSAGES_STEP`), against the
262,144 the operand reaches counting by four.

**How to see it**: the request the converter sends to `compile` for a
cartridge with every map of ABL, and `rm2k-snes-events compile` on it.

## Log

**2026-10-14, Tijereta.** Fixed in `rm2k-snes/events`, the-advocate,
branch `tijereta-blockers` (from `51b4b1b2`), commit `44177d88`.

The blame of `Messages::measuring`: it was made uncapped on purpose, so
that the unpaired block can pass 256 KB; what was left out is that every
caller still writes the returned offset with `usize_word`. The measuring
pass's bytecode is thrown away —`compile` keeps only `gathered`, and
`commons.rs`'s plan and the scan's pictures only whether the page
compiles—, so `Messages::store` now hands out the offset wrapped to 16
bits when it is not capped (`operand`, with the why). The capped one —the
second pass and every other— still stops past the operand. One place for
every box: `ShowMessage`, choices, inns, numbers and troops all go through
`store`.

* **The test**: `a_box_past_the_operand_still_compiles_while_measuring`,
  in `compile.rs`: a measuring block filled past 64 KB counting by one, and
  a `ShowMessage` page after it compiles. Red before the fix
  (`code.is_some()`), green after; `just crate-test events` all green.
* **The whole game**: with Cardón's experiment —108's fork out,
  `timer_never_runs_in = [66, 108]`, the slot screen's names let through,
  `--msu-everything`, the 307 maps— but **without** his `MESSAGES_STEP = 8`
  nor his far RAM asserts commented out, the `whole` cartridge builds:
  `just space` says the texts are 208,574 B of 262,144 counting by four.
  The experiment is not committed; it lived in two throwaway worktrees.
* ABL's suite with these tools: 1304 passed (1303 + the materials' new
  test); `just boot` 9; the-advocate `just test` 27.

To install when merging: `events`.
