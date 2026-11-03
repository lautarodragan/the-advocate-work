---
name: "A Teleport's facing is not applied"
description: "RPG Maker 2003's Teleport says which way the hero faces on arrival; the console keeps the facing he had before the jump"
type: bug
status: draft
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
