---
name: "Battle conditions for real"
description: "A condition system in battle —duration, restrictions, the controlled one's AI, what each changes— so that ChangeMonsterCondition stops being a debt: ABL's Control and BarkWall"
type: feature
status: todo
---

taro, on 2026-10-12: after `monster-conditions-and-flashscreen-in-battle.md`
accepts `ChangeMonsterCondition` as debt, this makes it real.

ABL uses two, both from troop pages (`Inscribe`, switch 799, and
`ControlMachines`, 803): 22, `Control` —"is being controlled!",
restriction 3, four turns, released by damage— and 23, `BarkWall` —lowers
attack, defense and agility, two turns—. Battle has no conditions today;
making them is a system: duration, restrictions, the controlled one's AI,
what each one changes. EasyRPG: `Game_Battler`'s `AddState`. Measured in
[`research/2026-10-05-los-comandos-que-faltan.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-los-comandos-que-faltan.html),
"The battle ones".
