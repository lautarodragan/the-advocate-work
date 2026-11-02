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

## Plan (Mulita, 2026-11-01)

Taken on the-advocate `0ba09da4`, the ports `31fb291`, the book `a9aa2bd`;
branches `mulita-medicine` in the three.

* The converter's `item_st_at` gives a medicine the conditions of its
  `state_set` but the dead one —which stays `MED_RAISES`—, in the same
  `st_lists` the skills and the equipment use.
* The map: `act_st_cure` in `party_states.s`, `RemoveState` of each one on
  the list and "it held one" back, which is `was_used |= HasState`. Called
  by `medicine_use` before the HP, as `Game_Battler::UseItem`, and by
  `sk_heal_one` with `skill_st_at`, as `UseSkill`. `item_usable` is not
  touched: a medicine already went in white and opened the choice.
* The battle: `item_usable_in_battle` lets in a medicine that removes a
  condition, and `ba_item_use` removes them after the HP and the SP,
  each a `BA_RES_TAKEN` line in the skills' result queue —its
  `message_recovery`—. `ba_execute` shows a pending SP line before the
  queue, so the order is RM2k's: `ProcessBattleActionParamEffects`, then
  `ProcessBattleActionStateEffects`. The model, `simulate.rs`, removes them
  too, with a "healed" result.
* Tests: ABL's `test_medicine_conditions.py` with cases
  `medicine-conditions` and `battle-114-medicine`.
