---
name: "A skill in battle writes no result line"
description: "A skill —or a special item that casts one— shows only its using message: RM2k's next lines, the damage or the heal on each target, are not written"
type: bug
status: draft
agents: [Tijereta]
---

Seen by Tijereta on 2026-10-19, on the-advocate `54ec3daf`, while making
special items cast their skill in battle
([`special-items-cast-their-skill-in-battle`](special-items-cast-their-skill-in-battle.md)).

In any game, any battle: an actor's skill —Talan's MinorFire in A Blurred
Line's `battle-114-attributes` case— shows `<name><using_message1>` and
`<using_message2>`, and the battle goes on to the next action. RPG_RT
follows it with the result on each target —"Junkbot takes 12 damage",
"Talan recovers 40 HP", "the attack goes up"—, which is easyrpg's
`ProcessBattleActionParamEffects` after `GetStartMessage`. The attack and
the medicines write theirs here; the skills do not: `ba_message`'s `skill:`
branch in `runtime/battle.s` writes the two using lines and stops. Since
2026-10-19 a special item's skill does the same, with the item's line
—"Uname Piedra used"— and nothing after it.

Declared in the book's `divergences/what-items-in-battle-do-not-model.md`
for the items; the skills have no divergence of their own.
