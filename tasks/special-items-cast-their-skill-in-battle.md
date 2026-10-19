---
name: "Special items cast their skill in battle"
description: "An item of kind special casts its skill when used, and in battle the list only offers medicines: Zounds' Piedra, Shuriken and Bomba Chica, which throw damage at an enemy, never show up"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, on 2026-10-19, playing Zounds: "I think a feature of the game let you
throw some objects, like stones, in battle. I don't know if that was just
using the item in battle or a hero's special skill… but I couldn't
reproduce it", with item 20, "Tira una piedra al enemigo", and 21 and 22.
"Maybe they invoke a skill in battle, and we haven't implemented that yet?"

What Hornero saw on the-advocate `54ec3daf`: yes. `item_usable_in_battle`
in rm2k-snes-battle (`src/rules.rs`) takes only medicines, so
`ba_items_list` (`runtime/battle_items.s`) never lists a special item
(kind 9, `skill_id`). Zounds' items 20 Piedra, 21 Shuriken and 22 Bomba
Chica are special with skills 6, 8 and 9: normal skills, one enemy, power
18, 46 and 32. Zounds has 13 special items, A Blurred Line 18, The Book of
Three 15 and Vampires Dawn 4 (named ones, kind 9).

The sibling on the map is
[`items-that-cast-a-skill-outside-battle`](items-that-cast-a-skill-outside-battle.md),
todo.

## Log
