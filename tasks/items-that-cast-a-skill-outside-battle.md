---
name: "Items that cast a skill outside battle"
description: "The items screen greys the special items that cast a skill, like ABL's potions; with the healing skills done, they can be used on the map with the same effect"
type: feature
status: doing
assignee: Chajá
agents: [Chajá]
---

Phase 3.3 of [`the-skills-menu`](the-skills-menu.md): the research
[`research/2026-10-12-the-skills-menu`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-12-the-skills-menu.html),
section 8, item 3. It needs
[`healing-skills-from-the-menu`](healing-skills-from-the-menu.md) first:
the effect and the target choice are the same, and the items screen stops
greying the items whose kind is "special" and whose skill is usable on the
map.

## Checked (2026-10-20, Chajá)

Still open, and no longer blocked: `healing-skills-from-the-menu` and
`the-skills-menu` are done. At the-advocate `8f290c39` `item_usable` in
`rm2k-snes/screens/src/texts.rs` is white only for switch items usable on
the field, medicines and materials, so a special item is still grey on the
map, and `items.s` does nothing on A for a grey one. In battle a special
item does cast its skill since Tijereta's `be763ab2` (2026-10-19: the
battle's model in `3713bcd1`, the runtime in `8662e9d5`, tested in ABL and
Zounds in the ports' `bec9396`), which is the precedent to follow.

**Done**: a special item whose skill is usable on the map
(`rm2k_rules::skill::usable_on_the_map`) goes in white on the items screen
and, on A, opens the actor choice and does the skill's effect as the skills
screen does —spending the item if it has uses, not the SP—, as RPG_RT's
`Scene_Item`; with a ROM test in ABL over one of its potions, red before.
**First step**: how the skills screen reaches `sk_heal_one`, and whether
the items screen can call it with the item's skill.

## Plan (2026-11-01, Chajá)

From the-advocate `0ba09da4` and the ports `31fb291`, on
`chaja-items-cast-skills` in both.

**The first step's answer**: the skills screen reaches `sk_heal_one`
through `sk_heal` → `target_screen` (with `sk_target_on` at 1) →
`target_use` → `sk_heal_use`, which checks the SP, loads the user's attack
and spirit into combatant 0, seeds the battle's randomness, calls
`sk_heal_one` on whom the scope says and pays. The middle part —everything
but the SP— goes out to its own `sk_cast`, and the item calls it with the
item's skill and its own caster. `sk_heal_one` is called as it is.

What RPG_RT does, from easyrpg's `Scene_Item`, `Scene_ActorTarget` and
`Game_Party::UseItem`/`IsItemUsable`:

* a special item is white if `Algo::IsSkillUsable(skill)` outside battle,
  which is `rm2k_rules::skill::usable_on_the_map`; for a normal skill it
  also asks for someone in the party able to act and let use it by
  `actor_set` — dynamic, so here it is asked on A and not by the grey;
* a switch skill: `ConsumeItemUse`, the switch on, back to the map —the
  switch item's path; the converter gives the item the skill's switch in
  `item_switch`, so the runtime's bank 0 does not change (Zounds'
  Materializador is the only one in the nine games)—;
* any other: `Scene_ActorTarget` with the item —its name and count, as a
  medicine's—, the bar over everyone for a skill on the party and **free**
  for one on oneself (only the skills screen locks it);
* the caster is `GetHighestLeveledActorWhoCanUse` —standing, no "does
  nothing" condition, in `actor_set`, the first of a tie— except on
  oneself, where it is the one chosen; the item is spent if it was of use.

The pieces: `item_casts_on_the_map` in rm2k-rules, `item_skill_on_the_map`
in the battle's rules and its `item_map_skill` in the model, emitted as a
byte table; the screens stage's `item_usable`/`item_needs_actor` take the
skill; in the runtime `item_skills.s` (FAR2) with `item_cast_use`, and
`target_use`/`target_scope`/`target_count` in `actor_choice.s` learn the
item. ABL's potions —Cloudy, Milky, Opaque, items 316–318, skill on an
ally— are the test's.
