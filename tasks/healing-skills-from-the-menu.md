---
name: "Healing skills from the menu"
description: "Tech Skill on the map uses a healing skill: on one ally, on oneself or on the whole party, with RM2k's effect and the SP spent only if it was of use"
type: feature
status: todo
---

Phase 3.2 of [`the-skills-menu`](the-skills-menu.md), after the list
([`the-skills-screen`](the-skills-screen.md)) and the switch skills
([`switch-skills-from-the-menu`](switch-skills-from-the-menu.md)). The plan
is section 8 of the research
[`research/2026-10-12-the-skills-menu`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-12-the-skills-menu.html):

* `target_screen` generalised —or a twin outside bank 0— with the skill's
  name, the cost term and the cost, and the cursor on one, on the user, or
  on everyone, by the skill's scope.
* An effect routine with `CalcSkillEffect` from the user's `eq_parameter`,
  the variance, the HP and SP clamps and the revive of `medicine_use`; the
  SP spent only if it was of use; it stays on the choice, as RPG_RT does.
* Tests on the numbers, with the model's formula, as the medicine tests
  do.

Kersh's Healing Syringe heals from the menu already on the intro's
rooftop, in the original.
