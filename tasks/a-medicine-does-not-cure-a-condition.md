---
name: "A medicine does not cure a condition"
description: "Since the party holds conditions, a poison caught in battle stays on the map; an Antidote —a medicine whose state_set lists it— is not of use on the map nor offered in battle, so only an inn or a FullHeal take it away"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
---

Seen by Mulita on 2026-11-01, on the-advocate `3071048a` (branch
`mulita-conditions`), reading `runtime/medicine.s` and
`runtime/battle_items.s` after
[`the-partys-conditions`](the-partys-conditions.md) gave the actors their
conditions.

**What is seen**: in a game with RM2k's default database —A Blurred Line,
The Book of Three, El Dorado, The Frozen World— an enemy's Poison now
poisons an actor, and the poison outlives the battle and takes HP walking.
Using an Antidote (a medicine whose `state_set` lists Poison) from the menu
on the poisoned actor does nothing and the item is not spent: `medicine_use`
only looks at the first of `state_set`, the dead one. In battle a medicine
that only cures conditions is not in the list. Vampires Dawn's Painkiller,
Bandage, Serum and Vampire Stone are the same. A skill on its own side that
cures, used from the menu, cures nothing on the map either. Zounds' foods
cure, because they are common events with `ChangeCondition`.

**To reproduce**: in The Book of Three, get poisoned by an enemy's Poison
skill, win, and use an Antidote from the menu on the poisoned actor.

Measured in the inventory of `the-partys-conditions`: medicines that cure
conditions, 10 in ABL, 5 in The Book of Three, 4 in El Dorado and The
Frozen World, 5 in Vampires Dawn.
