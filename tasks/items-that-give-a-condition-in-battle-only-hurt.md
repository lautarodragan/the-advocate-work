---
name: "Items that give a condition in battle only hurt"
description: "Since special items cast their skill, the ones whose skill poisons, paralyzes or puts to sleep are offered and spent, and do only their damage, or nothing: no skill gives conditions in battle yet"
type: bug
status: todo
agents: [Tijereta]
---

Seen by Tijereta on 2026-10-19, on the-advocate `54ec3daf` plus
[`special-items-cast-their-skill-in-battle`](special-items-cast-their-skill-in-battle.md).

No skill gives or takes a condition in battle —the book's
`divergences/what-battle-conditions-do-not-model.md`—, and a special item
casts a skill, so the items whose skill carries `state_effects` do only
the rest of what the skill does. Measured on each game's dump, the special
items the battle now lists whose skill gives a condition:

* Zounds: Ala Eléctrica (26), Pétalo Violeta (43), Paralizador (53),
  Veneno (67), Ácido (82) and Bola de Fuego (91) hurt and do not poison,
  paralyze or burn.
* The Book of Three: Poison Dart (102) and Sleeping Powder (103) hurt; Web
  Weaver (180), Rune of Sleep (181), Rune of Toxin (182) and Rune of
  Darkness (183) only give a condition, so they are spent and do nothing.
* Vampires Dawn: Ice Dust (116) and Holy Sand (120) hurt; Itching Powder
  (117) is spent and does nothing.
* A Blurred Line: only its placeholder "ABL 2.0 ITEMS" (328), which no
  event gives.

To see it: in Zounds, Kazar throws a Veneno at an enemy; the enemy loses
HP and is not poisoned.

## taro's decision (2026-10-20)

To todo, as Tijereta recommended: the fix is skills giving conditions to their targets in battle, which the runtime supports since `battle-conditions-for-real` —and with it these items do what they say—, not hiding the items.

**Done**: a skill with `state_effects` gives (or takes) its conditions to its targets in battle, with RM2k's hit chance, in the model and the console; Kazar's Veneno poisons an enemy in Zounds, in a test that is red before. **First step**: what `divergences/what-battle-conditions-do-not-model.md` in the book says is left, and how easyrpg's `Game_BattleAlgorithm::Skill` applies `state_effects`.
