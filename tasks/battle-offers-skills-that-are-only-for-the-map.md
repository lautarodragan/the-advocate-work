---
name: "The battle offers skills that are only for the map"
description: "A switch skill with occasion_battle off —Emily's Change Tape, Radin's Mix Formula— comes out white and usable in battle; RM2k greys it there"
type: bug
status: testing
assignee: taro
agents: [Cardón]
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

## Doing

By Cardón, from 2026-10-20, with the-advocate `8f290c39` and the ports
`68bf55b`; branches `cardon-map-only-skills` in both and in the book.

**What RM2k does, read in easyrpg** (`Algo::IsSkillUsable`, which
`Game_Battler::IsSkillUsable` ends in and `Window_Skill::CheckEnable` asks
for each row): in battle, a `switch` skill is usable only with
`occasion_battle`, and a `teleport` or `escape` one never; a `normal` skill
always is —it has no occasion flags: the editor shows them only for switch
skills, and `occasion_field` is only read for them on the map—. RM2k 2000's
`Window_Skill::CheckInclude` lists every skill the actor knows in battle, so
the unusable ones are there, grey, and `Scene_Battle` buzzes on them.

**Who it touches**, counting learning lists and fixed `ChangeSkills`: in ABL
Emily's Change Tape, Radin's Mix Formula, Dig Ingredients and Field/Battery
Repair, Sern's Weapon Forging, and actor 15's Pick Locks —a switch skill
with both occasions off—; in Book of Three six, in Vampires Dawn seventeen.
And Zounds' party learns Teleport (skill 30), a `teleport` skill: RM2k lists
it grey in battle and this battle leaves it out of the list, since
`skill_usable` carries only `normal` and `switch`. That one is not fixed
here: a draft.

**What was done**, the-advocate `cardon-map-only-skills`:

* `usable_in_battle` in rm2k-snes-battle's `rules.rs`: the rule above. The
  stage still carries the skill —`skill_usable` is unchanged— and the
  converter emits a byte per skill, `skill_in_battle`, outside bank 0;
  `ba_skill_reaches` reads it before the cost, so the battle's list greys
  it and A refuses it on the path the SP and the weapons already used.
  `item_skill_in_battle` asks the same rule.
* The model refuses an order for one, like one its weapons do not allow
  (`simulate.rs`); `tests/map_only_skills.rs`, red without that check.
* The deleted Python let any skill be ordered: the battle test game's
  switch skill 2 got `occasion_battle`, and the three battles of
  `battles.json` that order its teleport or escape skill are refusals now,
  said at the top of `tests/model.rs`. `mapdata`'s `tests/python.rs` takes
  the new table out, all 1 there.

The ports `cardon-map-only-skills`: `test_battle_map_only_skills.py`, on
the case `battle-114-emily-413` —Emily alone—: Change Tape grey, Play Radio
white, A leaves the list open, and after a turn switch 805 is off. Its
golden, `battle-map-only-skills`, is red with the global tools (178
pixels, the grey). The original, RPG_RT 2015 under Wine with a copy of the
database whose battle test party is Emily and Radin, greys Change Tape
and Radin's three the same way. The list readers of
`test_skills_weapons_drawing.py` went to `Fight` in the harness.

**Not covered in the ROM**: Radin's, Sern's and Pick Locks, which are the
same table and the same routine. A case of its own with Radin moved the
farm's celebration golden: draft
[`the-celebration-golden-moves-when-a-case-is-added`](the-celebration-golden-moves-when-a-case-is-added.md).
And Zounds' Teleport, left out of the list instead of grey: draft
[`the-battle-leaves-teleport-and-escape-skills-out-of-the-list`](the-battle-leaves-teleport-and-escape-skills-out-of-the-list.md).

**Bank 0** does not move on any cartridge of the eight games; bank `$C0`
—FAR2, the battle's code— loses 6 bytes on all of them (Sunset's had 160
left, 154 now).

**To install when merging**: `battle`, `mapdata`, `convert` and
`cartridge` —the runtime changes, and `rm2k-snes-cartridges` assembles the
checkout it was installed from—.

Captures: `/shared/captures/2026-10-20-map-only-skills/`.
