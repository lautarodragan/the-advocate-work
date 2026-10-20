---
name: "Items that cast a skill outside battle"
description: "The items screen greys the special items that cast a skill, like ABL's potions; with the healing skills done, they can be used on the map with the same effect"
type: feature
status: todo
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
