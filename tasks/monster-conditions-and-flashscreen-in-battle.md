---
name: "Monster conditions and FlashScreen in battle"
description: "ChangeMonsterCondition leaves out 164 troop pages —140 with FlashScreen—: Inscribe (799) and ControlMachines (803), at least 66 of them from release encounters. FlashScreen in the scene is cheap; real conditions are big, and taro decides whether they get done or are accepted as debt"
type: feature
status: doing
agents: [Aguará, Chajá]
assignee: Chajá
---

From Aguará's study, [`docs/research/2026-10-05-los-comandos-que-faltan.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-los-comandos-que-faltan.html); measured by `rm2k-snes-events culprits`. taro, on 2026-10-05: leave them in todo, without launching yet. taro's decision on conditions is still pending.

## taro's decision, 2026-10-12

**First as debt, then for real.** `ChangeMonsterCondition` is accepted
without doing it, as a declared debt, and `FlashScreen` —with `TintScreen`
and `TerminateBattle`, small— is done for real in the battle scene: that
unblocks the 164 pages of `Inscribe` and `ControlMachines`, knowing that
`Control` and `BarkWall` don't happen yet. The real condition system is a
task of its own, in todo: `battle-conditions-for-real.md`.

