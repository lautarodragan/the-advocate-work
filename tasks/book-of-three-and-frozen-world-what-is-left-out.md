---
name: "Book of Three and Frozen World: what is left out, and why"
description: "Both already carry every map; their culprits report still leaves pages and common events out. Which, by which variant of each command, and what fixing each would take"
type: research
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-10-14: "can you do the same for Book of Three and The Frozen
World?" —the same as for ABL: what is left out and what the compiler
ignores silently—.

Measured by Hornero on the-advocate `14e200fc`, ports `f775b66`: both
`release`s already carry every map (Frozen World excludes 1 and 2, each
with its reason in its `rm2k-snes.toml`). `just culprits`:

* **Book of Three**: maps 1273 of 1282 pages; commons 20 of 25 (left out
  9, 13; parallel 18, 21 do not compile); troops 497 of 746 (95 with a
  trigger the ROM cannot look at). Culprits: ControlVars, ShowChoice,
  ConditionalBranch in commons; ChangeItems, MoveEvent, ControlVars in
  maps; ControlVars, ChangeItems, ShowBattleAnimationB, ChangeMonsterHP in
  troops.
* **Frozen World**: maps 3823 of 3891 (1 stops at the page as a whole);
  commons 89 of 100 (left out 15, 31); troops 0 of 80 (all with a trigger
  the ROM cannot look at). Culprits: ShowMessage (494 culprits in maps,
  668 in commons), ConditionalBranch, ChangeMapTileset, ShowChoice,
  ChangeActorFace, InputNumber, ControlVars.

The silent holes of the compiler for both games are counted in the
research `research/2026-10-14-what-the-compiler-ignores-silently.md`.

## Log
