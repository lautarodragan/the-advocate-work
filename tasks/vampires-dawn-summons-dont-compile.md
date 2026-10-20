---
name: "Vampires Dawn's summons don't compile"
description: "Parallel common events 1, 2, 5, 6, 8 and 9 (the summons), 30, 48 and 49 stop at ControlVars and branches the compiler leaves out, and 52 is on a switch past 1023"
type: bug
status: todo
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
`vampires-dawn/build/release/converter.log`, and `just culprits`.

**Checked on 2026-10-16 (Mulita)**, at the-advocate 759aa0ba, **reading the compiler, not with `culprits`**: several of the
culprits above compile now —`ControlVars` from an item count
(`557b3ea2`), a random operand in any range (`6d3b12b7`), from any of an
actor's stats (`06710c31`), and switches past 1023, since the switch
table is the game's (`782e1931`)—. Still refused: `ControlVars` from
"other" but gold and the timer (the party size), `ChangeCondition` that
sets a state, and `ChangeParameters`, which the compiler does not know.
So the summons and 30, 48 and 49 most likely still stop, and 52 should
not; a `just culprits` in `vampires-dawn/` says which.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Summoning is one of Vampires Dawn's mechanics and does nothing, so todo.
**Done** is the parallel common events 1, 2, 5, 6, 8, 9, 30, 48, 49 and 52
out of the "do not compile" line of `converter.log`, or each that stays
with its measured culprit written here. First step: `just culprits` in
`vampires-dawn/` with today's tools, since Mulita read that several
culprits compile now; what is left by her reading is `ControlVars` from
"other: party size", `ChangeCondition` that sets a state, and
`ChangeParameters`, each a small piece of the compiler and the runtime.

## Checked (2026-10-20, Chajá)

The first step, done: `rm2k-snes-events culprits --every-map` with the
global tools (installed from the-advocate `8f290c39`) over the
`events-request.json` of Vampires Dawn's `release` built that morning
(ports `68bf55b`), and that build's `converter.log`: "parallel common
events: 23 run, 12 do not compile [1, 2, 5, 6, 8, 9, 10, 11, 18, 30, 48,
49]". **52 runs** —switches past 1023 since `782e1931`—; 10, 11 and 18 are
[`vampires-dawn-transformations-dont-compile`](vampires-dawn-transformations-dont-compile.md).
What each of the others stops at today:

* **1, 2, 5, 6** (the summons): `ControlVars [0, 461, 461, 0, 7, 2]`
  —from "other: party size", which `compile.rs` still refuses: only gold
  and the timer compile— and the branch `[1, 461, 0, 4, 4, 1]` on that
  variable;
* **8, 9**: the same two, and `ControlVars` from an actor's stat
  (`[0, 402|463, …, 5, 11]`) with `ChangeLevel` by those variables;
* **30**: only `ChangeCondition` that sets state 5 on actors 11, 2 and 13
  —setting a state still does not compile—;
* **48, 49**: `ControlVars` random 30–60 into variable 417, and
  `ChangeParameters` by it.

The `ControlVars` from an actor's stat and the random one compile by
themselves since `06710c31` and `6d3b12b7`, so when they are still named
the likely reason is that their variable —402, 417, 461, 463, all past the
256th— has no slot:
[`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md).
Not confirmed one by one. So what is left is that cap, "other: party size",
`ChangeCondition` that sets a state, and `ChangeParameters`.
