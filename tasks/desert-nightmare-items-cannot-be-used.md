---
name: "Desert Nightmare: items cannot be used"
description: "Common event 20, which uses an item where the hero stands, and 14, the map screen, do not compile: both read the hero's map id with ControlVars, which the ROM does not do. The light bulb never goes into the warehouse's lamp"
type: bug
status: doing
assignee: Chajá
game: desert-nightmare
agents: [Hurón, Chajá]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**: `just culprits` in `desert-nightmare/` says 28 of 30
common events compile; the two out are **20, "Sache benutzen"** (use a
thing: by the hero's map, cell and the item chosen, it sets the switch the
target's page waits for) and **14, "Menü 5 aktiv"** (the maps screen).
Both stop at `ControlVars` with operand 6, field 0 —an event's map id—
for the hero, `[0, 19, 19, 0, 6, 10001, 0]`; `degradations.json` has the
call of common 8 to 20 as `call-skipped`.

Played: the light bulb taken on map 23, the hero at the lamp on map 26
(11, 7) facing it, B, A on Inventory, A on the bulb: switch 6 (the
inventory) goes on and 242 —"the lamp now works"— never does. Every
puzzle of the game goes through 20.

The compiler leaves field 0 out on purpose (`VAR_CHARACTER`'s comment in
`compile.rs` of the event compiler): in RPG_RT it gives 0 for an event,
and A Blurred Line never asks; for the hero it is the map the party is on.

**To reproduce**: the stages `bulb` and `use_bulb` of
`~/scratch/huron/dn/stages.py`; captures in
`/shared/captures/2026-11-19-desert-nightmare/menu.png`.

## Taken (2026-11-20)

By Chajá, from Hurón's ranking in `desert-nightmare-what-it-takes-to-be-playable`. taro: "dale!".
