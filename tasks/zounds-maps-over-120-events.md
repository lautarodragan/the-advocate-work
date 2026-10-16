---
name: "Zounds: four maps have more events than the console's 120"
description: "Maps 47 (284 events), 51 (214), 57 (131) and 178 (327) lose 155, 88, 8 and 206 pages that run; they are grids of identical info/coin/rock events the twin folding does not catch because each carries its own commands"
type: bug
status: wishlist
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`; from the converter's log.

**What happens**: the console's RAM holds 120 events per map. Three maps
are saved by the twin folding (14: 212 twins of 233; 50: 276 of 282;
112: 222 of 254; 113: 125 of 143) and four are not: 47 "Oeste de la
Grieta" (245 events "Info- Plantas", each a message with a face and its
own switch), 51 "Entrada de la Cueva" (194 "Info- Plantas"), 57 "Mining
Place" (119 "Roca 2": `ControlVars` + `CallEvent`), 178 "Kuak-Man" (314
"Coin" events: `PlaySound`, `ControlVars`, `EraseEvent`, collision
trigger, all with the same charset, a mini-game).

**Why the folding does not catch them**: a twin is "the same pages as an
earlier one, nothing drawn, still"; these differ by the switch or
variable they set, or draw a sprite (the coins). The Kuak-Man map is a
whole mini-game and loses 206 of its coins. What RM2k could do with a
single event and `ControlVars` by position these maps do with one event
per cell.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Side content —the info signs, a mine, the Kuak-Man mini-game—, and Zounds
is far from playable for other reasons, so wishlist. **Done** is those four
maps keeping every page that runs, or the measured limit written here. Two
ways are open and the agent picks and measures: twins that differ only in
the switch or variable they set or in their sprite, folded with a
per-instance operand; or more events per map, which the runtime's byte
index (`action_key.s`: "EV_MAX is 128") and every table sized by `EV_MAX`
make the more expensive one.
