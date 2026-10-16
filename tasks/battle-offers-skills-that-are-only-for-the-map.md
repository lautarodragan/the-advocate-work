---
name: "The battle offers skills that are only for the map"
description: "A switch skill with occasion_battle off —Emily's Change Tape, Radin's Mix Formula— comes out white and usable in battle; RM2k greys it there"
type: bug
status: todo
---

Seen by Mulita on 2026-10-12, **reading the code**, with the-advocate
`28e66b35` and the ports `c97a0dd`, while studying the skills menu
(`the-skills-menu.md`). Not run in the ROM.

**What the code does**: the battle stage carries every skill of type normal
or switch an actor can know (`skill_usable` in `rm2k-snes-battle`'s
`rules.rs`, which looks at the type and the cost and not at
`occasion_battle`), and the battle's list greys a skill only when the SP do
not reach (`ba_skill_reaches`, in `ba_skill_window` of
`runtime/battle_skills.s`). Nothing in the runtime or the converter reads
a skill's `occasion_battle`.

**What RM2k does**: easyrpg's `Algo::IsSkillUsable`, in battle, answers a
switch skill's `occasion_battle`; `Window_Skill::CheckEnable` draws it grey
and `Scene_Battle` buzzes on it.

**Where it would show**: in A Blurred Line, Emily's Change Tape (261),
Radin's Mix Formula (260), Dig Ingredients (264) and Field/Battery Repair
(289), and Sern's Weapon Forging (266) are map-only switch skills; in
battle they would come out white, and choosing one would turn on its
switch —734, 805, 811, 859 or 979—, whose common event is an autostart that
would run when the battle ends. Book of Three and Vampires Dawn have map-only
switch skills too.

**How to see it**: a battle with Emily (actor 25, who knows Change Tape
from level 1) in the party, the skill list open.

## Defined

Todo, on 2026-10-16, by Cardón: in ABL a battle offers Emily's Change Tape and four more,
and choosing one turns on a switch whose autostart runs after the battle.
At the-advocate `f4709d0b` nothing reads a skill's `occasion_battle`.

**Done** means a switch skill with `occasion_battle` off is grey in the
battle's list and buzzes, as RM2k's `Window_Skill::CheckEnable`, in the
model and the console, with a golden of the list with Emily in the party
red before. **First step**: `skill_usable` in rm2k-snes-battle's
`rules.rs`, and whether the stage can still carry the skill and only mark
it grey.
