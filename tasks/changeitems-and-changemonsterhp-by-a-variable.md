---
name: "ChangeItems and ChangeMonsterHP by a variable"
description: "ChangeItems with the item or the amount in a variable, and ChangeMonsterHP with the damage in a variable, do not compile: Book of Three 54 and 52 uses (Eilonwy's Absorb Essence, Taran's Last Stand, six essence pages on the maps), Vampires Dawn 81"
type: feature
status: draft
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).

**What is seen** (not played):

* **Eilonwy's Absorb Essence** (switch `AbsorbEssenceON`, 270): a page in 48
  troops adds `AmountAbsorbed` (variable 24) Essences of Fire, Water or
  Thunder to the inventory. The page does not compile, so the command does
  nothing. The same `ChangeItems` is on six map pages (maps 31, 42, 46, 52,
  86 and 87) where the player gathers essences.
* **Taran's Last Stand** (`LastStandON`, 96): a page in 52 troops subtracts
  `LastStandRandom` (variable 6) from the enemies' HP. The page also uses
  `ShowBattleAnimationB`
  ([`show-battle-animation-b-in-troop-pages`](show-battle-animation-b-in-troop-pages.md)),
  so both are needed.

**Where it stops**: `CHANGE_ITEMS` in `compile.rs` refuses the item or the
amount "from a variable" (`q(1) != 0 || q(3) != 0`): `OP_ITEM` carries a
constant item and a signed byte. `CHANGE_MONSTER_HP | CHANGE_MONSTER_MP`
refuses `q(2) != 0` (the amount from a variable; the percentage is not an
option of the command) because `OP_ENEMY` carries a signed word.

**Uses in the eight dumps**: `ChangeItems` by a variable, Book of Three 54,
Vampires Dawn 81; `ChangeMonsterHP` by a variable, Book of Three 52, no
other game.
