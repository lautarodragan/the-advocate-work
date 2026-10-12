---
name: "Vampires Dawn's summons don't compile"
description: "Parallel common events 1, 2, 5, 6, 8 and 9 (the summons), 30, 48 and 49 stop at ControlVars and branches the compiler leaves out, and 52 is on a switch past 1023"
type: bug
status: draft
---

Seen by Aguará on 2026-10-12, with the-advocate `6ed7c4a0` and the ports
`0e1d9ba` (`parallel-common-events-dont-run.md`), in Vampires Dawn.

**What is seen**: summoning a skeleton, a skeleton mage, a demon or a
golem does nothing: their parallel common events —1, 2, 5, 6, 8 and 9— do
not compile, nor do 30 (`Lebensstatus`), 48 (`Geschick`) and 49
(`Staerke`).

**Where they stop**, by `rm2k-snes-events culprits`:

* the summons: `ControlVars` from "other: party size" (operand 7, 2) and
  from an item count (operand 4), a branch on a variable against 4 with
  "less than" (`[1, 461, 0, 4, 4, 1]`), and 8 and 9 also `ChangeLevel` by
  a variable;
* 30: `ControlVars` from an actor's parameter and `ChangeCondition`;
* 48 and 49: `ChangeParameters` by a variable, and a random
  `ControlVars`;
* and 52, `Diebestour`, is on switch 1621, past the 1024 the ROM's bitmap
  holds: no page can turn it on, so it is left out whole.

**How to see it**: the line "parallel common events" of
`vampires-dawn/build/release/conversor.log`, and `just culpables`.
