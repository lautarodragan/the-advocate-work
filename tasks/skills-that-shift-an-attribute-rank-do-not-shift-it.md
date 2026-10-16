---
name: "Skills that shift an attribute rank do not shift it"
description: "A skill with affect_attr_defence —Heat Barrier, Cold Barrier— should move its target's rank in its attributes for the rest of the battle; the battle does its damage or healing and the ranks stay"
type: bug
status: wishlist
agents: [Chajá]
---

Seen by Chajá on 2026-10-15, at the-advocate's branch `chaja-attributes`
(from `497be031`), while bringing the attributes into the battle
([elemental-attributes-are-not-applied-in-battle](elemental-attributes-are-not-applied-in-battle.md)).

**What is seen**: not played. In RM2k a skill with `affect_attr_defence`
rolls, per attribute it carries, a shift of its target's rank by one step
—weaker on one it targets as an enemy, more resistant on an ally— that
lasts the battle, at most one step either way
(`Game_BattleAlgorithm::Skill::vExecute`, `Game_Battler::ShiftAttributeRate`
in easyrpg-player). Neither the model (`rm2k-snes/battle/src/attributes.rs`)
nor the console reads the flag: the ranks are the database's all battle
long. The divergence is
[What attributes do not model](https://lautarodragan.github.io/the-advocate-docs/divergences/what-attributes-do-not-model.html).

**How much it is used**: Heat Barrier and Cold Barrier in A Blurred Line,
The Book of Three, El Dorado and The Frozen World; six skills in Vampires
Dawn (Fire Barrier, Ice Barrier, Black Aura, Weakening twice,
Schattenmauer). Counted over each dump's `skills.json`: `affect_attr_defence`
with some `attribute_effects`.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
A fidelity detail of the battle: the barriers still heal or hurt, only the
rank does not move. **Done** is the model in `attributes.rs` and the
console keeping a per-battler, per-attribute shift of -1, 0 or +1 that a
skill with `affect_attr_defence` rolls as easyrpg's `ShiftAttributeRate`
does and that the damage reads, reset when the battle ends; a battle test
where Heat Barrier and then a fire skill do the shifted damage; and the
divergence page losing that paragraph. First step: read
`Game_BattleAlgorithm::Skill::vExecute` and `Game_Battler::ShiftAttributeRate`
for the roll and the bounds.
