---
name: "Battle tests expect RM2k, not our dice"
description: "Twenty battle tests ask rm2k-snes-battle simulate for the exact HP the ROM must leave, which holds only because the model and the ROM roll our own random sequence in the same order; they should expect what RM2k's rules say —exact where RM2k is deterministic, a range or an average where it rolls—, computed from RM2k's formulas and not from our model"
type: refactor
status: todo
author: taro
---

**Why**: the battle model, `rm2k-snes-battle simulate`, plays RM2k's
battle "with the same rules and the same randomness as the ROM"
(`abl/tests/harness/model.py` in the ports), so a test can demand the exact
number each HP ends at, turn by turn. But that randomness is ours: RM2k's
sequence cannot be reproduced. An exact HP proves the ROM and the model
consume our dice in the same order, not that the damage behaves as RM2k's
does; changing the generator, or the order a roll is taken in, turns them
red with nothing wrong. It is a test tied to an implementation detail.

> If they are not part of what is needed to build a ROM, I would not put
> them in advocate.
>
> But I would like to review those tests. We should be able to test things
> without depending on implementation details. If we know an attack damages
> within a range, the test can expect the HP to drop within that range. We
> can also set a very high HP, land 20 hits, compute the average damage and
> expect it to be in a certain range for certain cases, and in another range
> if there is poison or if there are type advantages or disadvantages.

(taro, 2026-11-24)

**What uses the model today** (`import model`, or `simulate(` in Zounds'):
in ABL's `tests/rpgmaker/`, `test_battle.py`, `test_battle_attributes.py`,
`test_battle_attribute_shift.py`, `test_battle_conditions_golden.py`,
`test_battle_scene_drawing.py`, `test_battle_skill_results.py`,
`test_battle_special_items.py`, `test_battle_weapon_past_255.py`,
`test_ag7_and_the_plant.py`, `test_event_experience.py`,
`test_experience_drawing.py`, `test_healing_skills.py`, `test_materials.py`,
`test_medicine_conditions.py`, `test_menu_special_items.py`,
`test_troop_events.py`, `test_troop_systems.py`, `test_victory.py`; at the
ports' root, `tests/test_zounds_special_items.py` and
`tests/test_zounds_veneno.py`.

**What is asked**:

1. **First the classification**, written here before any test changes:
   for each file, what it asserts, whether that case is deterministic in
   RM2k —a fixed heal, a skill with variance 0, poison per step, a
   victory's experience and gold— or rolls, and what it would expect
   instead. Shown to taro.
2. **Then the tests**:
   * **exact where RM2k is deterministic**;
   * **a range where it rolls**, its bounds from RM2k's formula —liblcf
     and easyrpg-player, in `~/ref`, are the sources, as for the rest of
     what RM2k means—, not from our model;
   * **an average over many hits where a range is too loose to catch
     anything**, and where what matters is a comparison: with and without
     poison, with and without an attribute's advantage. The ROM's generator
     is deterministic for a given play, so it is not flaky; the bounds have
     to be tight enough to catch a real error.
3. **What is lost, measured and said**: a range misses what an exact
   number caught —a rounding, an off-by-one in a formula— where the case
   rolls; and many hits per case cost suite time. The task says, per file,
   what it stops catching and how long the suite takes before and after.

If no test asks `simulate` any more, whether the subcommand stays —as a
tool to ask, or not at all— is decided with
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md),
where the stages' subcommands the tests call are already a question; per
taro, they do not go in [`one-advocate-command`](one-advocate-command.md),
which is only what builds a ROM.

## Log

### 2026-11-24, Hornero: written

Nothing done yet.
