---
name: "The text's measuring pass stops pages past 256 KB"
description: "compile's first pass gathers the boxes without letter pairs and without a cap, but the compiler still writes each offset in 16 bits: past 256 KB of unpaired text a page stops, and a common event stops the cartridge"
type: bug
status: draft
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
