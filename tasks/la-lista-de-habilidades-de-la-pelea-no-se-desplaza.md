---
name: "The battle's skill list doesn't scroll"
description: "The battle gathers at most 16 skills and shows 14: with more, the others can't be used, and the last two are picked without being seen"
type: bug
status: done
assignee: Chingolo
---

Carpintero found it on 2026-10-04, measuring the pair pool with Talan
knowing all 54 of his (`workflow/tasks/*/la-lista-de-habilidades-agota-el-pozo.md`).

`ba_skill_list` (`tools/runtime/battle_skills.s`) gathers the skills the
actor knows and the battle offers, up to `BA_SKILL_MAX`, 16, and the screen
draws `BA_SKILL_ROWS * BA_SKILL_COLUMNS`, 14. The cursor reaches the 16th
(`mode_skill`, in `battle_run.s`, only looks at `BA_SKILL_N`), so the last
two are picked without being seen, and from the 17th onwards they aren't
there. RM2k scrolls the list.

It matters for ABL: Talan learns skills with his aura system and can end up
knowing 54.

What it asks for: that the list scroll like the item list (`ba_item_see`,
the eight-row window), with the whole list in `BA_SKILL_LIST` —which today
holds 16 and is shared with the enemies' choice of actions— or gathering
only the visible page. The text layer is no longer the limit: the battle
has 447 pairs, a whole screen, and a row that says what another one said
takes its tiles.
