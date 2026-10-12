---
name: "The maps' loose commands"
description: "The small cases that leave pages out: ChangeGold by variable, EraseEvent before a jump, the screen position in ControlVars, the cut in ChangeScreenTransitions, and the ControlVars = 999999 of common event 45"
type: feature
status: doing
agents: [Aguará, Chajá]
assignee: Aguará
---

From Aguará's study, `docs/research/2026-10-05-los-comandos-que-faltan.md`; `rm2k-snes-events culprits` measured it. taro, on 2026-10-05: leave them in todo, without launching yet. None is in release; common event 45, since it doesn't compile, makes 47
calls from Eisen's rooms get skipped.

## Already done

Two of the ones on the list came out on 2026-10-06 with
`four-shortcuts-for-the-other-games` (Chajá), because they paid off in the other
games:

* **The condition on a character's direction**, `OP_IF_FACING`: the 31
  pages of ABL's Eisen simulation, and those of the other games.
* **Moving away from the hero in a route**, command 10, with the random step and facing
  away.

Without them and without the `ControlVars` = 999999 the Eisen simulation still doesn't
work: common event 45 is what's missing.
