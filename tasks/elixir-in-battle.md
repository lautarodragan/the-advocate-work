---
name: "The Elixir in battle"
description: "Use in battle an item that only works on a fallen ally"
type: feature
status: done
assignee: taro
---

**Use in battle an item that only works on a fallen ally.**

The `Pungent Elixir-LIFE` (`ko_only`) already revives a fallen ally from the menu, but
the battle doesn't offer it: `batalla.item_usable_en_batalla` leaves out the
`ko_only` items, so taro couldn't use it on Arden with 0 HP.

What it asks for, as was measured when fixing the menu:

- that an item's target cursor can stop on a fallen ally;
- that the revived ally asks for orders again on the next turn and earns the
  experience on winning;
- change `battle.py` the same way, because `test_battle.py` predicts the HP against it.

Reviving is the same as in the menu: 1 HP and then the item's percentage
(`medicina_usar`). Reference: EasyRPG's `Scene_Battle` and `Game_Battler::UseItem`.

# How it turned out (2026-09-26)

- **The list** offers the `ko_only` items that revive —the first in `state_set`,
  the death state—: Phoenix Down, Pungent Elixir and Jumper Cable. A
  `ko_only` that doesn't revive would stay out: it wouldn't be any use to anyone.
- **The who cursor** stops only on the actors the item is useful
  for: fallen ones for one that revives, standing ones for one that isn't `ko_only`. A
  skill still stops only on those standing. It starts on the
  first one it's useful for; if it's useful for nobody —an elixir with nobody fallen—, A doesn't
  leave the list. **RM2k lets you stop on anyone** and the useless item
  is spent with no effect; here it's skipped, which is what the battle already did with
  the fallen. It's a simplification in the player's favour, declared in
  `ba_item_sirve_sobre`.
- **Reviving** is `max(1, curacion)` with the healing capped against the whole
  maximum: the `SetHp(1)` of `RemoveStates` and the `ChangeHp(hp - 1)` of
  `ApplyStateEffect`. The same as `medicina_usar` from the menu. The
  bottom line of the message is the death state's `message_recovery`,
  "Core has revived!", and not the HP one: `IsRevived` in `ePreHp`.
- **In passing**: a medicine that doesn't revive, on a target that died between being
  chosen and its turn coming, **no longer revives it**. Both sides added the
  healing to the zero HP; `ApplyHpEffect` doesn't touch a dead one. That path isn't
  run by any test: it needs the droid to kill the target before the one with the potion
  acts, and that depends on chance.
- **The revived one** asks for orders from the next turn and earns the
  experience on winning without touching anything: `ba_actor_siguiente` and
  `ba_exp_repartir` already looked at the HP.

## Debt that was seen

- The top line of "use an item" with a long name goes past the
  32 columns and the last letter falls in column 0 of the line below:
  "Kersh Pungent Elixir-LIFE  used." leaves the full stop in front of "Core has
  revived!". It's older —any item with a long name does it, and the
  name in the LDB has a trailing space—; it wasn't touched.
