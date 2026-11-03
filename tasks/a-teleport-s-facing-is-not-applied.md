---
name: "A Teleport's facing is not applied"
description: "RPG Maker 2003's Teleport says which way the hero faces on arrival; the console keeps the facing he had before the jump"
type: bug
status: testing
assignee: taro
agents: [Mulita]
---

Seen by Mulita on 2026-11-02, with the ports at `3e4e95d` and the tools
from the-advocate `23b413cd`, taking the Zounds debug room's Delmar door
(`tasks/zounds-debug-doors-to-delmar-and-itan.md`): its `Teleport` to map
183 asks for facing up, as map 2's does, and Uname lands facing down,
the way she walked into the door.

RPG Maker 2003 added a fourth parameter to `Teleport` (10810): the facing
on arrival, 0 to keep it and 1 to 4 for up, right, down and left
—`Game_Interpreter_Map::CommandTeleport` in easyrpg-player, "RPG2k3
feature"—. The compiler reads the map, x and y and drops the fourth
(`TELEPORT` in `rm2k-snes/events/src/compile.rs`, in the-advocate), and
`op_teleport` has no operand for it, so the converter does not warn.

Zounds has 757 `Teleport`s in its maps and common events, and 104 of
them, in 51 maps and common events, ask for a facing (measured over the
dump, ports `3e4e95d`). The maze door, from 2026-11-02, too: right, onto
113. An RM2k game —ABL— does not have the parameter.

To reproduce: "New Game", the seventh door of the room, "Go": Uname faces
down on Delmar's path.

## The fix (Mulita, 2026-11-03)

taro said "dale" to fixing it. From the-advocate `36dde02d`, the ports
`3e9b2cc` and the book `d432096`.

### What RM2k does, in easyrpg-player

`CommandTeleport` only stores it: `ReserveTeleport(map, x, y,
parameters[3] - 1)`, -1 to keep it. It is applied in
`Game_Player::PerformTeleport`, which `Scene_Map::FinishPendingTeleport`
calls **after the erase** —`StartPendingTeleport` starts the erase and
queues it—: with the screen already black, after `MoveTo`, it does
`SetDirection` and `UpdateFacing`. So the turn does not show on the map
being left, and the new map fades in with him already turned. It applies
on a jump to the same map too, and `UpdateFacing` does nothing over a
locked facing: the direction changes, the drawn facing does not.

### The encoding: a new opcode, `OP_TELEPORT_FACING` (0x56)

`(direction: byte, map: word, x: word, y: word)`, appended at the end of
the declaration; a `Teleport` that keeps the facing is still
`OP_TELEPORT`, byte for byte.

Measured against ABL's `release` at main (`just space`): bank 0 296 B
free, every data bank used. An extra operand on `OP_TELEPORT` would have
cost ABL one byte in every compiled `Teleport`, in banks that are full, and
the handler's bytes in bank 0, for a byte no RM2k game sets. The opcode
costs ABL nothing in its bytecode.

And it is gated, like the sandstorm or the wrapping maps: the converter
asks the cartridge whether some `Teleport` asks for a facing
(`scan::teleports_with_a_facing`, with the compiler's own
`compile::teleport_facing`, so the two cannot disagree), mapdata writes
`TELEPORT_FACING = 1` only then, and the runtime assembles the handler,
`jump_facing` (one BSS byte), the far `teleport_face` and its `jsl` in
`load_requested` only under it. Without it `op_teleport_facing =
page_ends`, and an RM2k cartridge pays only its two bytes in the dispatch
table.

### Who else carries a facing (Zounds' dump, ports `3e9b2cc`)

* `TeleportTargets` (11810): no facing —map, x, y, switch—. The Teleport
  and Escape skills land facing down (`ReserveTeleport(SaveTarget)`), but
  the console compiles neither command. Zounds has one.
* `RecallToLocation` (10830): keeps it, -1. Done: `remembered_place`
  clears `jump_facing` under the gate.
* `SetVehicleLocation`: no facing, and not compiled.
* The database's death teleport (2k3) has `death_teleport_face`, but
  Zounds has `death_teleport` off.
* **`ChangeEventLocation` (10860) has one in 2k3**, its fifth parameter,
  applied only with constant coordinates: 4 in Zounds (maps 13, 99, 144,
  160), and the compiler drops it —its comment says "the game is RM2k"—.
  Not trivial —`OP_PLACE` has no room for it—: a draft,
  `change-event-location-s-facing-is-not-applied`.

### What it costs

`just space`, with the branch's tools: ABL's `abl.sfc` keeps 294 B of
bank 0 (296 at main) and its 80 B of BSS. Its `mapdata.inc` is identical,
and the ROM differs only by the two bytes of the new dispatch entry: every
bank-0 symbol after `opcode_handlers` moves +2 (1,525 of them, measured on
the `.sym`), `EVENT_OPCODE_COUNT` goes 86 to 87, and the bytes that change
in banks 1 and $41 are the references to those. Zounds, which turns the
gate on, pays about 22 B of bank 0 —the table entry, the handler, the
preamble of `op_teleport`, the boot's `stz`, the `jsl`— and one byte of
BSS; the body is in the far bank.

### What ran

* `just crate-test` of bytecode, events, convert, mapdata and cartridge,
  green; clippy on them clean. The events test
  `a_teleport_s_facing_goes_in_its_own_opcode_and_keeping_it_in_the_old_one`,
  red with `teleport_facing` answering `None`.
* The ports' `test_a_door_lands_the_hero_facing_where_its_teleport_asks`
  —Delmar and Itân up, the maze right—: red with main's tools (he faces
  2, down), green with the branch's.
* ABL's `just tests` with `.local-tools` (events convert mapdata
  cartridge): 1639 passed, 2 skipped.
* The ports' whole `just boot`: 7 reds, all Zounds goldens where only the
  hero's sprite turns the way the jump asks —the desert and pickaxe doors
  left, the maze's and the sandstorm's right, Delmar and Itân up, the
  exfont box up (its case's own Teleport asks for it)—. Looked at, side
  by side in `/shared/captures/2026-11-03-teleport-facing/`, and blessed
  in their own commit. `just boot -k zounds` after: 68 passed.
* Only Zounds turns the gate on: no other port's `Teleport` asks for a
  facing (over each dump in the ports).

What no test covers: the turn over a locked facing (`hero_lock`), a jump
with a facing to the same map, a `RecallToLocation` right after a
`Teleport` with a facing in the same frame, and the frame the turn
happens on —the test looks at `hero_dir` once he has control, not at the
black frame—.

### To install when merging

`just install events convert mapdata cartridge`, from `~/the-advocate`:
the bytecode changes, the converter and mapdata write the gate, and
`cartridge` assembles the runtime.
