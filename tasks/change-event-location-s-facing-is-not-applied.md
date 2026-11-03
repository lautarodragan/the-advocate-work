---
name: "ChangeEventLocation's facing is not applied"
description: "RPG Maker 2003's ChangeEventLocation says which way the event faces where it is placed; the console keeps the facing it had"
type: bug
status: draft
agents: [Mulita]
---

Seen by Mulita on 2026-11-03, over Zounds' dump at ports `3e9b2cc` and the
compiler at the-advocate `36dde02d`, while fixing
[`a-teleport-s-facing-is-not-applied`](a-teleport-s-facing-is-not-applied.md).

RPG Maker 2003 added a fifth parameter to `ChangeEventLocation` (10860):
the facing, 0 to keep it and 1 to 4 for up, right, down and left, applied
only when the cell is constant —`Game_Interpreter::
CommandChangeEventLocation` in easyrpg-player, "RPG2k3 feature",
`SetDirection` and `UpdateFacing`—. The compiler places the event with
`OP_PLACE` and drops it: its comment says "only RM2k3 touches the
direction, and the game is RM2k", which was ABL's.

Zounds asks for it four times, all with a constant cell: map 13, event 30,
page 1 places event 20 at (43,40) facing left; map 99, event 2, places
event 1 at (13,0) facing down; map 144, event 15, places 16 at (1,22)
facing right; map 160, event 6, places 7 at (22,19) facing down. Nobody
has looked at what shows on any of them.
