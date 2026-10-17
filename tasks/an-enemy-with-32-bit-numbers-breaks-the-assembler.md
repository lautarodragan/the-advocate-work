---
name: "An enemy with 32-bit numbers breaks the assembler"
description: "Zounds' debug troop has 99,999 HP and gives 9,999,999 experience: the converter refuses the experience with a message but writes the HP into a .word and ca65 fails with a range error on mapdata.inc"
type: bug
status: todo
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`.

**What happens**: enemy 1 "TESTER" (a debug enemy, in troop 1) has
`max_hp` 99,999, `exp` 9,999,999 and `gold` 999,999. The converter stops
on the experience —`rm2k-snes-mapdata: troop 1 gives 9999999 experience
and the ROM adds it in sixteen bits`— and, with that capped, emits
`enemy_hp: .word 99999, …` and the build dies in the assembler:
`mapdata.inc:287259: Error: Range error (99999 not in [0..65535])`. Gold
was not reached.

**What to decide**: one answer for every 16-bit table the converter emits
from the database —HP, SP, exp, gold, prices, variable constants—: refuse
with the enemy's name, or clamp with a warning. Zounds also has
`ControlVars` with 500,000 and 999,999 (money), which `culprits` already
reports as a culprit of its own.

## Defined

Todo, on 2026-10-16, by Cardón. Zounds builds since its source carries the debug enemy's
numbers within sixteen bits (the ports' `12cd878`), but any other game with
such a number stops in `ca65` with a range error on `mapdata.inc`.

**Done** means no number the converter takes from the database reaches the
assembler out of its width: each 16-bit table —HP, SP, experience, gold,
prices, constants— is either clamped with a loss in `degradations.json`
naming the enemy or item, as a long flash is since `a2141de2`, or refused
with its name, as experience is; the agent picks one answer for all, the
precedent leaning to the clamp. A test with a 99,999-HP enemy. **First
step**: list the tables `emit.rs` writes from the database and which of
them check their width.
