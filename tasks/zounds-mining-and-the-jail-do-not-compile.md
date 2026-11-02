---
name: "Zounds' mining and the jail's guards do not compile"
description: "Loops that only end with a BreakLoop, Control Variables taking a modulo or a quotient by a constant past the word, and the branch on the event started by the action key keep Zounds' mining, smelting and its levels, and the jail's guards, out of the cartridge"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-11-01, in their words, translated, after Hornero listed
what keeps Zounds' pages out:

> Let's go with the Zounds stuff, including the bought / did not buy
> branches for the cafeteria and Unamë's rescue

The cafeteria's shop is
[`a-shops-bought-and-did-not-buy-branches`](a-shops-bought-and-did-not-buy-branches.md),
Carpintero's. This one is the rest, measured by Hornero with
`just culprits` in `zounds/` at the-advocate 0ba09da4:

* **A loop with no wait in its body does not compile** (`loop_waits` in
  `rm2k-snes/events/src/compile.rs`), even when it ends with a
  `BreakLoop` on a condition: map 134 event 46 (the boss's young man who
  pays the mining, Misërenia's north cave), map 57 event 125 (the
  merchant's autostart scene in the mining place), map 133 event 6 (the
  smelting oven), common events 51, 52 and 54 (mining, thief and smithing
  next level's EXP). They count items or variables down and break.
* **`ControlVars` modulo / divide by a constant past 0x7FFF does not
  compile**: common event 26 (mining EXP and level, `mod 100000`), 62 and
  63 (money and coins split in digits, called from map 168). For a 16-bit
  variable a modulo by a constant past the word is the identity and a
  quotient is 0, so it can compile exactly.
* **`ConditionalBranch` type 8, the event started by the action key**:
  the guards' parallel pages on maps 145, 147, 148 and 149 (Unamë's
  rescue, the jail). Without them the guards never catch the player.

**Done**: the three compile with what RPG_RT does (easyrpg's
`CommandConditionalBranch` case 8, `triggered_by_decision_key`), Zounds'
culprits list loses those pages, and a loop that never breaks and never
waits still does not compile. Tests in the events crate, and a ROM test
for what the runtime changes.
