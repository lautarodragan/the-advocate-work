---
name: "Variables are capped at 256 slots, and Vampires Dawn names 401"
description: "The RM2k variable's slot is one byte in the bytecode and the converter stops at 256, so a game with more than 256 variables loses every event that names the rest: Vampires Dawn leaves 224 events out for 145 variables without a slot"
type: feature
status: todo
---

Seen by Hurón on 2026-10-15, in the study
[`the-wram-and-sram-map-measured`](the-wram-and-sram-map-measured.md),
with the-advocate `6fa69781` and the ports at `f015801`.

**What happens**: Vampires Dawn's `release` carries 256 variable slots
(`VARIABLES_N` in its `.dbg`), and its `degradations.json` has 224
entries ending in "which has no slot in far RAM", for 145 distinct
variables: each one is an event left out whole because a page's condition
or command names a variable past the 256th. No other of the eight games
gets near the cap; ABL names 176.

**Where the cap is**: in two places that have to move together. The slot
is a byte in the bytecode —`variable_slot` returns a `u8` in
`rm2k-snes/events/src/pages.rs`, and `var_read` in `runtime/variables.s`
masks it with `VAR_SLOT`—, and `FAR_VARIABLES` is a 512-byte region at
`$7E2600` of the hand-written far RAM map, with `FAR_ITEMS` right after
it. The save grows 2 B per variable as well (`save_table`).

**What to decide**: whether the operand becomes a word in every opcode
that carries a variable —`ControlVars`, the conditions, `InputNumber`,
`KeyInputProc`, the picture by variable— and `FAR_VARIABLES` is sized by
`VARIABLES_N` with no cap below RM2k's 5,000; the book's research page
ranks it second and estimates the RAM at 802 B for Vampires Dawn, which
fits once the far RAM map is placed by the linker.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba: far RAM is
no longer a hand-written map. Since `d121156e` `far_variables` is a
`.res VARIABLES_N * 2` in `runtime/far_ram_game.s`, placed by the linker,
so the 512-byte region at `$7E2600` with `FAR_ITEMS` behind it is gone and
RAM is not what caps it. What still does is the byte slot in the bytecode
and the converter's check in `rm2k-snes/mapdata/src/emit.rs`, whose
message still gives the old reason: see
[`the-converter-caps-what-far-ram-no-longer-limits`](the-converter-caps-what-far-ram-no-longer-limits.md).
The same loss was noted earlier, from the converter's log, in
[`variables-past-256`](variables-past-256.md) (2026-10-06); this one is
kept as the one to follow, since it says where the cap is.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
224 of Vampires Dawn's events are left out by it, and it is no longer RAM,
only the byte slot, so todo. **Done** is a game's variables having a slot
up to its own `VARIABLES_N`, Vampires Dawn's `degradations.json` without
any "has no slot in far RAM", the check in `emit.rs` capping at what the
new operand holds with its real reason, and the save carrying them. Two
ways are open and the agent picks and measures, in bytecode and in cycles:
the operand becomes a word in every opcode that carries a variable, or a
slot past 255 goes through a wider form only where it appears, so ABL's
bytecode stays as it is. First step: list every opcode with a variable
operand, from `variable_slot`'s callers in `rm2k-snes-events`. It closes
the second point of
[`the-converter-caps-what-far-ram-no-longer-limits`](the-converter-caps-what-far-ram-no-longer-limits.md).

## Checked (2026-10-20, Chajá)

Still so at the-advocate `8f290c39`: `variable_slot` returns a `u8` in
`rm2k-snes/events/src/pages.rs` and in `compile.rs`, and Vampires Dawn's
`release` built that morning (ports `68bf55b`) still has 224
`degradations.json` entries "which has no slot in far RAM", for 145
variables. Those are only the events left out by a page's **condition**: a
**command** naming such a variable leaves its page out as a culprit of
`rm2k-snes-events culprits`, which `degradations.json` does not list.
Measured that way, the cap is now what keeps out most of the victims'
choice pages
([`vampires-dawn-the-victims-choice-does-not-compile`](vampires-dawn-the-victims-choice-does-not-compile.md):
`ControlVars` on 380, 468, 301, 351) and likely part of the summons
([`vampires-dawn-summons-dont-compile`](vampires-dawn-summons-dont-compile.md):
402, 417, 461, 463). So the Done's test of the degradations alone is not
enough: `just culprits` in `vampires-dawn/` should stop naming
`ControlVars` and branches whose only fault is a variable past the 256th.
