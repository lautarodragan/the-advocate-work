---
name: "A skill with a physical attribute does not ask for the weapon"
description: "RM2k grays out an actor's skill with a physical attribute unless a weapon it holds carries it; the battle offers it like any other: Saldra's Trip, AG7-17's ArmLaser and TillTheyGlow in A Blurred Line"
type: bug
status: wishlist
agents: [Chajá]
---

Seen by Chajá on 2026-10-15, at the-advocate's branch `chaja-attributes`
(from `497be031`), while bringing the attributes into the battle
([elemental-attributes-are-not-applied-in-battle](elemental-attributes-are-not-applied-in-battle.md)).

**What is seen**: not played. `Game_Actor::IsSkillUsable` in easyrpg-player:
a skill without `affect_attr_defence` that carries a physical attribute is
usable only if one of the actor's weapons carries that same attribute;
otherwise RM2k grays it out in the battle list and the menu. The battle's
list (`rules::skill_usable` in rm2k-snes-battle, and the console's) does not
look at the weapons. The divergence is
[What attributes do not model](https://lautarodragan.github.io/the-advocate-docs/divergences/what-attributes-do-not-model.html).

**Where in A Blurred Line**: with their starting weapons, Saldra (17)
learns Trip (Martial) and her Bent Staff-RL carries only Thud; AG7-17 (18)
learns ArmLaser and TillTheyGlow (Ray) and the ArmCannon-!R carries none.
Measured over the dump and the release cartridge's skill pairs; another
weapon may carry them.

## Defined

Wishlist, on 2026-10-16, by Cardón: it is written as a divergence of the book, "What
attributes do not model", and it costs nothing in play but three skills
being usable that RM2k greys.

**Done** means an actor's skill with a physical attribute and without
`affect_attr_defence` is greyed in the battle list and the menu unless a
weapon it holds carries the attribute, in the model (`rules::skill_usable`)
and the console, and that bullet leaves the divergence page. **First
step**: where the battle list decides grey (`ba_skill_reaches`), and what
the cartridge already carries of each weapon's `attribute_set`.
