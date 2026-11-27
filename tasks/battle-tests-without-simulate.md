---
name: "Battle tests without simulate"
description: "Twenty battle tests ask rm2k-snes-battle simulate, our own model of the battle, for the exact HP the ROM must leave: they test our implementation against itself. They should expect what RM2k's rules say —exact where RM2k is deterministic, a range or an average where it rolls—, computed from RM2k's formulas, and simulate goes"
type: refactor
game: advocate
status: doing
assignee: taro
agents: [cardon]
author: taro
links:
  blocks: [abl-s-test-cartridges-become-test-game-cases]
  relates: [one-advocate-command, the-stages-speak-json-nobody-types, tests-without-the-stages-subcommands]
  found: [a-hit-that-does-nothing-does-1-half-the-time-in-rm2k]
---

**Why**: the battle tests take their expected values from
`rm2k-snes-battle simulate` (`abl/tests/harness/model.py` in the ports),
our own model of RM2k's battle, and demand that the ROM leave exactly what
it says. So what they check is that two implementations of ours agree, in
every detail —the order of each step, each rounding, each roll—, not that
the battle does what RM2k does: they test implementation details, and the
model is one more thing to keep in step with the ROM. A test should state
what RM2k's rules say and nothing else, and then `simulate` has no reason
to exist.

The randomness is the clearest case, though not the main one: the model
plays "with the same randomness as the ROM", which is ours —RM2k's
sequence cannot be reproduced—, so an exact HP proves the two consume our
dice in the same order; changing the generator turns them red with nothing
wrong.

> If they are not part of what is needed to build a ROM, I would not put
> them in advocate.
>
> But I would like to review those tests. We should be able to test things
> without depending on implementation details. If we know an attack damages
> within a range, the test can expect the HP to drop within that range. We
> can also set a very high HP, land 20 hits, compute the average damage and
> expect it to be in a certain range for certain cases, and in another range
> if there is poison or if there are type advantages or disadvantages.

> [the name] Something about simulate going away, because we are testing
> implementation details; the random part is secondary.

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
2. **Then the tests, and `simulate` goes** —with the harness's `model.py`
   and whatever only it used—:
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

The other stages' subcommands the tests call —`rm2k-snes-screens window`,
`render`…— are a question of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md);
per taro, none goes in [`one-advocate-command`](one-advocate-command.md),
which is only what builds a ROM.

## Log

### 2026-11-24, Hornero: written

Nothing done yet.

### 2026-11-24, Hornero: renamed before anything linked it

Born as `battle-tests-expect-rm2k-not-our-dice.md` minutes earlier;
nothing in the four repos named it yet.

### 2026-11-27, Hornero: taken, to Cardón

> Go!

(taro, 2026-11-27, to doing this task together with step 7 of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md).)

Cardón does both, in one branch per repo: first this task's
classification, written here and shown to taro before any test changes;
then the tests, `simulate` and step 7's `model`, `lines`, `experience` and
`field-skill`, and the `rm2k-snes-battle` binary goes whole.

### 2026-11-27, Cardón: the classification

On the-advocate `ab885b29`, ports `dd440b5`, with the global tools
(installed from `ab885b29`). Nothing changed in the code repos. The twenty
files of the list, plus step 7's users of `model`, `lines`, `experience`
and `field-skill` in
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md),
plus `data.maxima()`, which plays an empty battle to read the actors'
maxima and is used by six more files (`test_heal`, `test_inn`,
`test_menu_conditions`, `test_menu_heal_drawing`, `test_menu_special_items`,
`test_troop_systems`).

#### What the suite spends on it today

The eighteen ABL files alone, in one process (`PROCESSES=0`,
`--durations=0`), nobody else running: **140 tests, 80 s of pytest**. By
file: `test_battle_scene_drawing` 40.5 s (37 s of it is the 153-troop
golden test, which asks no model), `test_battle` 16.3, `test_troop_events`
3.4, `test_experience_drawing` 2.7, `test_troop_systems` 2.5,
`test_battle_attributes` 2.2, `test_ag7_and_the_plant` 1.8,
`test_battle_skill_results` 1.8, `test_victory` 1.3, the other nine 0.5 to
1.1 each. With 8 workers the same files take 53 s of wall clock, which is
that one golden test. The root's two Zounds files, 4 tests, 0.6 s.

**Inside `rm2k-snes-battle`**, with the binary wrapped by a script that
logs each call: **296 calls, 17.8 s** of the 80 —`simulate` 270 calls and
17.4 s; `model` 7, `lines` 11, `field-skill` 7 and `experience` 3, 0.5 s
together—. By file: `test_battle` 6.6 s (67 calls), `test_battle_attributes`
2.7, `test_troop_events` 1.7, `test_battle_conditions_golden` 1.2,
`test_battle_attribute_shift` 1.1, `test_ag7_and_the_plant` 1.0 (73 calls:
it asks the model's enemy AI 60 times), the rest under 0.7 each. The
model's seed searches are in there: `test_battle`'s critical seed and
`test_victory`'s loot seed.

#### What RM2k says, and what is deterministic

easyrpg-player's `algo.cpp` is the reference:

* **The normal attack**: `max(0, atk / 2 - def / 4)`, through the weapon's
  attributes, ×3 if critical, then `VarianceAdjustEffect` at 4, then
  halved for a defender (`AdjustDamageForDefend`, after the variance).
* **A skill**: `power + phys * atk / 20 + mag * spi / 40`, against enemies
  minus `phys * def / 40 + mag * spi / 80`, never below 0, through the
  attributes, then the skill's variance. Out of battle
  (`Game_Battler::UseSkill`) a heal goes through the variance too.
* **`VarianceAdjustEffect`**: `adj = max(1, var * base / 10)`, and the
  result goes from `base - adj / 2` to `base + adj - adj / 2`. **Every
  skill the tests use has variance 4** (checked in the dump: the cures,
  the damage skills, Agency Badge, Heat Barrier, Flame Field,
  ShortCircuit, BombsAway, the Cloudy Potion's), so the range is about
  ±20 %, and nothing in battle but a medicine is variance 0.
* **Deterministic in RM2k**: the fighters' parameters (the LDB's curve at
  the level plus the equipment, clamped), the maxima, the critical chance,
  the escape chance, a medicine's heal (`rate * max / 100 + flat`,
  capped), the SP a skill costs, a weapon's SP, a modifier capped at half
  its base, a condition's halving and its `hold_turn`, poison and the like
  per act (`hp_change_max %` plus `hp_change_val`), a troop page's
  `ChangeHP` and `ChangeCondition`, experience and levels, gold, which
  items a list offers, which actions an enemy may choose (ratings 10 below
  the best weigh zero), and every text.
* **What rolls**: hit or miss, the critical, the variance, the enemy's
  action and target, a skill's condition (Shock on the droid, rank C,
  70 %), a condition's release after `hold_turn` (BarkWall, 50 %), the
  loot (35 % per Marauder), and the order of the turn.

#### What the tests would read instead of the model

Three things, shared by most files, replace `model.Battle`:

1. **The ROM's own log of each action.** While a message is up the battle
   holds who acted, on whom and what it did —`BA_MTYPE`, `BA_MWHO`,
   `BA_MTGT`, `BA_MDMG` ($FFFF a miss), `BA_MHEAL`, `BA_MEFFECT`—, which
   `watch_the_hits` in `test_battle.py` already reads. A harness helper
   steps a turn message by message and returns them, in place of the
   model's `log`.
2. **The bookkeeping, exact**: after each action the target's HP moved by
   exactly what the message said, capped at 0 and at the maximum; the
   dead neither act nor are targeted; the battle ends when one side is
   down. That keeps "the same number in every HP" without predicting the
   dice.
3. **RM2k's formulas in the harness**, per hit, written from easyrpg and
   the dump, as `test_battle_attributes.py` already does over the model's
   log: each damage or heal inside its variance range, ×3 for a critical,
   half for a defender; the parameters from the LDB's curve and the
   equipment. This replaces `model.actor_of`, `skills_of`,
   `actions_of_enemy`, `items_usable_in_battle`, `troop_gold`, `lines`,
   `exp_changes`, `field_skill` and `data.maxima()`;
   `harness/experience.py` stays, as it is.

**Where a range is too loose**, one average per formula, not per file:
Kersh attacking the droid with its HP written high, 30 hits, the mean of
those that are not critical within ±8 of RM2k's 123 (a single hit's sd is
about 14, a mean of 30 about 2.6; 3 sd). It catches `def / 2` (106) or no
defense (140), which a single hit's 99–148 does not. The same for one
damage skill. A droid battle of twelve actions costs 0.5 s in this
harness, so 30 hits are 1 to 2 s. **Most comparisons need no average**:
the attributes' ×2 and ×0.5, the critical's ×3 and the defender's half
give ranges that do not overlap with the neutral one, worked out below.

**Where the ROM has to land a roll** —a critical, a loot of one or two of
three, the poison taking hold, Shock—, the test does what the model did,
but against the ROM: it writes `BA_SEED` with 1, 2, 3… —or attacks
again— until the ROM's log shows it, in a bounded loop. A seed's play is
deterministic, so it is not flaky, and nothing predicts which seed works.

#### File by file

The ranges are worked out with the cases' fighters, the party at the
LDB's levels: Kersh attack 280, defense 147, spirit 85; Core 237/112/64;
Manta 187/77/64; Talan 15/19/20; AG7-17 37/33/34; Arden spirit 19; Emily
attack 38, 70 with the gloves; the Sentry Drone 100/68/25 with 450 HP; the
Junkbot 25/17/10.

* **`test_battle.py`** (39 tests, 16.3 s; the model in 22)
  * The opening slots (HP, attack, defense, agility), the HP and SP that
    start full, each actor's skills, the escape chance, the critical
    against the model: **deterministic, exact**, from the curve and the
    equipment, the learning table at the level (the literal lists the test
    already has), `InitEscapeChance`; the critical keeps its easyrpg
    computation and drops the model half. Stops catching nothing.
  * `the_whole_battle_gives_the_same_hp`, `a_party_critical…`, the
    elixir's battle, `winning_goes_on…`, the three song tests and the
    scene's dead droid (which use the model only to know when the battle
    ends): **rolls; the ROM's log, the bookkeeping exact, each hit in
    range**: Kersh on the droid 99–148, Core 81–121, Manta 61–91; the
    droid on Kersh 12–17, on Core 18–26, on Manta 25–37; a critical ×3
    (Kersh 296–443), got by attacking until the ROM lands one (3 %, some
    30 hits) instead of the model's seed.
  * `a_damage_skill…` (Fury Punch 534, 428–641, on a droid of 450),
    `a_healing_skill…` (Syringe 81, 65–97, on Core at 63 of 127: always
    capped, so **exact**, 127, unless the droid hits after),
    `a_skill_modifies…` (Agency Badge 81, 65–97, against caps of 50, 34
    and 25: **always capped, exact**), the switch skill: the SP
    **exact** (`sp_max - sp_cost`), the switch exact, damage in range.
  * The Potion, the elixirs, the ether, the water, the Miracle Drop:
    **exact** (50 flat capped at the maximum; `max(1, 25 % of max)`; 90
    and 12 SP; all of both), and the rest of the turn by bookkeeping.
  * The usable list and the SP medicines' list: **exact**,
    `Game_Party::IsItemUsable` in battle written in the test from the LDB.
  * `escape_is_the_partys`: **exact**, the droid's HP full (Kersh's attack
    lost), the party's by bookkeeping.
  * **Stops catching**: an off-by-one inside a range (the `adj / 2`
    rounding, a `/ 4` truncated elsewhere) unless the hit lands on the
    edge, which the average narrows to about ±8 but does not close; how
    many rolls each action takes and in which order —"the critical is
    rolled even at 0 %", "a switch skill rolls nothing"—, which is the
    implementation detail this task removes; and the turn order, which no
    test asserted apart from the HP.

* **`test_battle_attributes.py`** (3, 2.2 s): it already checks each hit
  against easyrpg's arithmetic, on the model's log: the same check on the
  ROM's log, and the HP by bookkeeping. **The ranges do not overlap with
  the neutral ones**: Kersh's Ray ×2 218–326 against 109–163, Manta's Cut
  ×0.5 36–53 against 72–107, MinorFire's Flame ×0.5 12–18 against 25–37.
  Stops catching only the exact rounding.

* **`test_battle_attribute_shift.py`** (2, 1.1 s): it already tells the
  Dragon's hits by their size; the same on the ROM's log, and the shift
  read in the sizes (no shifted Flame Field before the barrier, no
  unshifted one after). The model's `attribute_shift` and "the next
  barriers roll nothing" go: that is the randomness's phase. The attack
  (60–89) and the unshifted Flame Field (46–68) overlap, which the test's
  set of kinds already allows.

* **`test_battle_conditions_golden.py`** (3, 1.0 s): BarkWall's halving
  —26, 5, 7, and back to 52 and 14— **exact**; it lasts at least its
  `hold_turn` (an exact lower bound) and goes, with its message, within
  the test's turns (the 50 % rolls); Control: every hit of the droid's
  lands on its own side (an exact property), and it is free by the fifth
  turn at the latest (`hold_turn` 4, then 100 %) or as soon as it is hit;
  the messages, the LDB's exact texts in the order seen. The HP by
  bookkeeping. **Stops catching** on which turn the 50 % release lands.

* **`test_battle_scene_drawing.py`**: one test uses the model only to
  play the battle to its end: the ROM's mode instead. Nothing lost.

* **`test_battle_skill_results.py`** (5, 1.8 s): each line built from the
  LDB's terms with **the number the ROM shows**, which has to be in range
  (MinorFire 12–18; the battery by its skill's formula; the Cloudy
  Potion on Talan at 1 of 40, 45–67, always capped at 39 —exact, once
  easyrpg's shown value is checked to be the capped one—); Agency Badge's
  three lowerings **exact** (capped: 50, 34, 25); its Shock is a 70 %
  roll, so its line is checked when it comes, with a seed loop to see it
  once. The kill: **exact**. Stops catching the number's exact rounding.

* **`test_battle_special_items.py`** (4, 1.0 s): the battery's hit,
  already checked in range on the model's log, on the ROM's; the SP
  unchanged and the item spent, **exact**; the potion's heal in range or
  capped; its list, by the rule, exact.

* **`test_battle_weapon_past_255.py`** (2, 0.6 s): Emily's slot with the
  gloves, **exact** —attack 70, critical 18, the weapon's SP—, which is
  what "reads item 413 past the 255th" means; each hit 25–37 with them
  against 12–18 without, which a single hit tells apart.

* **`test_ag7_and_the_plant.py`** (7, 1.8 s): the troop and the AI —the
  three plant enemies that never use their skill— by the rating rule from
  the LDB, **exact**, instead of 60 rolls of the model's AI; the Tangle
  Wire's ShortCircuit is used within the turns (50 %, with the "measures
  nothing" guard), each use costs exactly 12 SP and each of AG7's attacks
  exactly 1; the hits in range. BombsAway: 65, 52–78, on a wire of 23 and
  a rat of 20 HP, no attribute: **both die, exact**, and the SP
  `60 - 16`. Stops catching the AI's exact 50/50 and the order of its two
  rolls.

* **`test_event_experience.py`** (4, 0.5 s): `model.exp_changes` →
  `harness/experience.py` (already RM2k's curve), the learning table and
  `SetLevel`'s HP trim, **exact**; the level-up pages from the LDB's
  terms; `model.actor_of(AG7, level=1)` → the curve. Nothing lost.

* **`test_experience_drawing.py`** (12, 2.7 s): `beat_the_droid` plays
  with the model and reads who is alive from it → the ROM's mode and HP;
  `actor_of(level=30)` → the curve and the equipment, **exact**. Nothing
  lost.

* **`test_healing_skills.py`** (8, 0.9 s): `field-skill` → each heal in
  range, the SP **exact**: SingleCure1 31, 25–37; HighCure 151, 121–181
  (Kersh at 18 ends at 139–168); AllCure1, each its own roll; LowRepair
  43, 35–52; LifeFromDecay 46, 37–55, capped at Arden's 46. Stops
  catching the exact number. The `-healed` goldens show the rolled
  numbers, so they stay tied to our generator, as any golden is to what
  it drew.

* **`test_materials.py`** (6, 1.1 s): `actor_of(a).agility` → the curve
  plus the equipment, plus 1 with the pill, **exact**; the list's rule,
  exact.

* **`test_medicine_conditions.py`** (5, 0.5 s): the list's rule only,
  **exact**.

* **`test_menu_special_items.py`** (5, 0.5 s): the potion's heal in range;
  but **who casts it** —the highest level who may— shows only in the
  caster's spirit, and Kersh's 56 (45–67) and Arden's 51 (41–61) overlap:
  a range cannot tell them apart. Kersh at level 50 (spirit 300: 72,
  58–86) and **an average of five uses** can (sd about 4 against a gap of
  21). Or it is lost, if the average is not wanted. `maxima` → the curve.

* **`test_troop_events.py`** (6, 3.4 s): the Rat King's rats show up
  exactly when the ROM's own king crosses 60 % and 30 % of its HP (the
  page's condition against the ROM's HP, **exact**), on different turns
  (a guard); the HP by bookkeeping and ranges. The hidden one's
  experience and gold, **exact** (already literal from the LDB). The
  victory's first page: the LDB's terms, checked as "the words in order,
  each row fits", like `battle.says`, since its wrapping in pixels is the
  port's.

* **`test_troop_systems.py`** (11, 2.5 s): the summon's swap and the
  droid's HP back in the save, **exact** (the ROM against itself); Life
  For Strength (Talan 0, the Giant `max - 70`) and the Sacrifice
  (`[1, 0]`), **exact**; the turns after, bookkeeping and ranges.
  `maxima` → the curve.

* **`test_victory.py`** (6, 1.3 s): the experience and the gold **exact**
  (the gold as the members' sum, 285); the lines from the terms, as
  above; the loot: the ROM's `BA_DROP_N`, the inventory and the lines
  agree, and a seed loop on the ROM until it drops one or two of three
  (68 % of seeds do) instead of the model's search over up to 4000
  battles. **Stops catching** the 35 % itself.

* **The root's `test_zounds_special_items.py`** (0.4 s): the Piedra's hit
  in range (already checked on the model's log), from the ROM's HP drop;
  the SP unchanged, **exact**. **`test_zounds_veneno.py`** (0.1 s): the
  poison takes hold by a roll (the hit, then 70 % at rank B): a seed loop
  on the ROM instead of the model's seed 3; once held, what it takes when
  the shark acts is the condition's `hp_change_max %` of the maximum plus
  its flat, **exact**.

#### What the whole change stops catching

* **Exact rounding inside a variance**: an off-by-one or a truncation in
  the wrong place passes unless a hit lands on the range's edge. The
  averages narrow a bias to a few percent, not to one point.
* **The rates**: the hit chance, the 3 % critical, the AI's 50/50, the
  35 % loot, BarkWall's 50 % release. Each is only "it can happen" now; a
  binomial test needs hundreds of trials (the loot over 120 rolls would be
  40 battles, some 20 s, for bounds of 22 % to 48 %).
* **The randomness's phase**: how many rolls each action takes and in
  which order. It is not RM2k's —its sequence cannot be reproduced—, and
  it is what turned the tests red on a generator change: no loss against
  RM2k.
* **The turn order**, which only showed through the HP.

#### Time, before and after

Before: the numbers above, 80 s of pytest in one process for the 140
tests, 17.8 s of it inside `rm2k-snes-battle`. After, an estimate to be
measured when the tests change: the 17.8 s go; the averages and the seed
loops add a few seconds of emulation (30 hits are 1 to 2 s, and there
would be two or three; a seed loop is one or two battles); the harness's
formulas cost nothing. Something like 65 to 70 s.

#### Questions for taro

1. **Per hit, a range and the bookkeeping exact; an average only where
   the ranges overlap** —one for the normal attack, one for a skill, and
   the menu potion's caster—. **Recommended.**
2. **The rates** —hit, critical, the AI's choice, the loot, a condition's
   release—: (a) only "it can happen", looping seeds on the ROM until it
   does, **recommended**; (b) a binomial test each as well, some 20 s of
   suite apiece; (c) a forced chance, writing the ROM's critical or
   escape byte, which tests less of the real path.
3. **The menu potion's caster**: (a) Kersh at level 50 and an average of
   five uses, **recommended**; (b) let it go: the test checks only that
   the heal is in either caster's range.

#### Seen along the way

* **RM2k rolls the variance of a 0**: easyrpg's `VarianceAdjustEffect`
  rolls when the base is 0 if the engine is the legacy 2000
  (`Player::IsLegacy()`), so a hit that does 0 does 0 or 1; ABL's
  `RPG_RT.exe` has no version info and three logos, which easyrpg reads as
  that engine. The ROM and the model skip the roll, so the Junkbot never
  scratches Kersh. The draft
  [`a-hit-that-does-nothing-does-1-half-the-time-in-rm2k`](a-hit-that-does-nothing-does-1-half-the-time-in-rm2k.md).
  A range of 0 to 1 holds both, so the new tests do not depend on it.
* `test_encounter_rates.py` holds the ROM to `events.Encounters`, a
  Python model of the encounter steps with our own generator, step by
  step: the same nature as `simulate`, and not in this task's list.

### 2026-11-27, Hornero: a question for taro

Cardón's classification above is phase 1, and phase 2 waits on taro's
answers to its three questions: (1) a range per hit plus exact HP
accounting, an average only where ranges overlap —recommended yes—; (2)
the rates —crit, loot, the AI's 50/50, BarkWall's release— as only "can
happen", proved with seeds against the ROM (a, recommended), a binomial
test each (b, ~20 s each), or forcing the odds in RAM (c); (3) who throws
the menu's potion, Kersh at level 50 with an average of 5 uses (a,
recommended) or let it go (b). Assignee to taro while waiting; back to
Cardón with the answers. The 0-or-1 draft stays a draft until it is seen
in Wine: it was read in easyrpg's code, not reproduced.

### 2026-11-27, taro: a comment

> Let's go with the recommendations for 1 and 3. 
>
> Can you elaborate 2.a?

### 2026-11-27, Hornero: 1 and 3 decided; 2.a, elaborated

1 and 3 go as recommended. Question 2 stays open; what (a) means:

**Today** a test that needs a rare event —a critical, the loot dropping,
poison taking hold— asks the model which seed makes it happen: the model
plays the battle with our generator, seed after seed, up to thousands,
and the test writes the seed it found to `BA_SEED` and expects the ROM
to do exactly that. Tied to our dice: change the generator and the
model's seed no longer gives the event in the ROM.

**With (a)** the model goes and the ROM is the one tried: write 1 to
`BA_SEED`, play, read the ROM's log; no critical, try 2, 3… up to a
bound (a few dozen; for the 3 % critical, attacking again within the
same battle is cheaper). When the event shows, the test checks **what
it did** with RM2k's rules —the critical is ×3 and in range, the loot
is an item of that enemy's, the poison takes what it takes per step—.
Each seed's play is deterministic, so it is never flaky; the bound only
makes it fail if the event never happens at all, which is a bug (a
critical that can never land).

**What it does not check**: how often. A critical at 30 % instead of 3 %
passes, as long as the ×3 is right. That is what (b) would add, at some
20 s of suite per rate; and (c) forces the chance by writing the ROM's
byte, which skips the real roll.
