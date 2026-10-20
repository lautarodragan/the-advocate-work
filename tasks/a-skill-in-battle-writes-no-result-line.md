---
name: "A skill in battle writes no result line"
description: "A skill —or a special item that casts one— shows only its using message: RM2k's next lines, the damage or the heal on each target, are not written"
type: bug
status: testing
assignee: taro
agents: [Tijereta, Cardón]
---

Seen by Tijereta on 2026-10-19, on the-advocate `54ec3daf`, while making
special items cast their skill in battle
([`special-items-cast-their-skill-in-battle`](special-items-cast-their-skill-in-battle.md)).

In any game, any battle: an actor's skill —Talan's MinorFire in A Blurred
Line's `battle-114-attributes` case— shows `<name><using_message1>` and
`<using_message2>`, and the battle goes on to the next action. RPG_RT
follows it with the result on each target —"Junkbot takes 12 damage",
"Talan recovers 40 HP", "the attack goes up"—, which is easyrpg's
`ProcessBattleActionParamEffects` after `GetStartMessage`. The attack and
the medicines write theirs here; the skills do not: `ba_message`'s `skill:`
branch in `runtime/battle.s` writes the two using lines and stops. Since
2026-10-19 a special item's skill does the same, with the item's line
—"Uname Piedra used"— and nothing after it.

Declared in the book's `divergences/what-items-in-battle-do-not-model.md`
for the items; the skills have no divergence of their own.

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39`: still so —`ba_message`'s
`skill:` branch (`runtime/battle.s`) writes `skill_msg1` and `skill_msg2`
and goes to `ba_flow`—. Not the same as Cardón's `doing`
[`battle-offers-skills-that-are-only-for-the-map`](battle-offers-skills-that-are-only-for-the-map.md),
which is which skills are offered. **Done**: after a skill's using lines,
each target's result line as RPG_RT writes it —the damage, the HP
recovered, the parameter that goes up or down, a miss—, with the terms
the attack and the medicines already use; the `battle-114-attributes`
case's golden shows Talan's MinorFire with its damage line, looked at and
committed apart. **First step**: which of easyrpg's
`ProcessBattleActionParamEffects` lines the attack's path already writes,
and whether the skill's path can go through it.

## Done (2026-10-20, Cardón)

From the-advocate `3bc68ac4`, the ports `3cd810d` and the book `0b96ba4`,
on branches `cardon-skill-results`; main merged into each before handing
back.

**The first step, answered.** The attack's path writes one line of
easyrpg's —`ProcessBattleActionDamage`'s `GetDamagedMessage`, and the
undamaged one when `BA_MDMG` is $FFFF— and the medicine's the HP and SP
recovered of `ProcessBattleActionParamEffects`; neither was code the
skill's path could go through as it was: the attack's is a branch of
`ba_message` with its one target, and a skill has a line per target and
per thing it moved. So the skill records its lines while it executes and
`ba_execute` shows them one message each, under the using lines, as RM2k
pushes each result under them and pops it for the next
(`battle_action_results_index`, `PopUntil`). The damage line does go
through the attack's code, from a label of its own, and the recovery and
parameter ones through `ba_put_stat`, which the medicine's line now uses
too.

**What was done**:

* the-advocate, the model (`rm2k-snes-battle`): `results` in the answer,
  `[turn, target, what, number]` —`damage`, `hp`, `sp`, `attack`,
  `defense`, `spirit`, `agility` or `miss`—, only when a skill wrote one.
  Success is `vExecute`'s `SetIsSuccess`. `tests/skill_results.rs`, which
  does not compile without it; `tests/model.rs` takes `results` out before
  comparing with the Python's hashes, which did not move.
* The converter (`mapdata`): the terms the lines need —`skill_failure_a`
  to `_c`, `dodge`, `parameter_increase` and `_decrease`, the four
  parameters' names, and `health_points` and `spirit_points`, which RM2k's
  recovery line asks for (The Book of Three's short ones are `H` and `M`)—,
  after every other text, and `skill_fail`, a byte per skill. English
  stand-ins for a 2003 game; Zounds gives its Spanish ones in
  `[battle.terms]`. `tests/python.rs`: the text without them is the old one
  byte for byte.
* The runtime: **the battle's message moved to FAR3 first, alone**
  —`battle_message.s`—: the lines did not fit in Sunset over Imdahl's FAR2
  (154 bytes left, they took some 380). Then the lines: `ba_res_add` in
  battle_skills.s, `result` in `ba_message`, a third line in `BA_MBUF`.
  After the two places `vExecute` returns —a kill, an offensive skill that
  did nothing to the HP or SP it touches— nothing more is written.
* The ports: `test_battle_skill_results.py` —MinorFire's damage on the
  Junkbot, a Carbon Battery's damage and a Cloudy Potion's recovery under
  the item's line, Agency Badge's three parameters on the droid—, against
  the model's `results` written with the database's terms; red before the
  runtime commit. Its golden `battle-skill-damage`, in its own commit:
  "Talan casts MinorFire." over "Junkbot 13 health lost.".
  `test_jumps_between_banks.py` knows the new file's data bank.
* The book: the divergence "What a skill's result lines do not model"; the
  items' and the 2003 terms' divergences and Zounds' Known issues no longer
  cite this task.

**The original**, RPG_RT 2015 under Wine, in the battle test of troop 114
with Talan alone taught MinorFire in a copy of the database: the using line
first, alone, then the result under it, as the ROM now does. Its runtime
drops the name and the number —it reads ABL's terms as templates—.
Captures: `/shared/captures/2026-10-20-skill-results/`.

**Ran**, with the branch's tools first in the PATH: ABL's whole suite,
1582 passed and 2 skipped; the ports' `just boot`, 100 passed; the-advocate's
`just test` (29), `just rust-test` (1058) and `just lint`, clean;
`just test-game`, 51 passed and 1 skipped.

**Space**, `just space` before and after on every cartridge of the nine
games: bank 0 does not move on any. FAR2 (`$C0`) gains 797 bytes on each
—the message's 1,018 out, the recording's 221 in—: Sunset's 154 to 951.
FAR3 (`$C1`) pays the message and the result lines, 1,219: Sunset's
20,974 to 19,755. Bank 1 does not move.

**Not covered by any test**: a skill's `sp` line and its failure line
(`miss`) in the ROM —the model's tests have both—; a skill on several
targets in the ROM (`a_skill_on_every_enemy_says_each_one` in the model);
the result going on the third line under a second using line; Zounds' and
the other games' lines, which only `just boot` runs through without
reading them. And the ports' main merged into the branch brought
Aguará's `test_item_uses.py` and `test_book_of_three_item_uses.py`, not run
here: their runtime was not in the-advocate's main yet. The bag of shells
is a special item, so it now writes its skill's lines; the test passes
turns until the commands come back, which should not mind.

**Found and not fixed**, drafts:
[`a-skill-rolls-past-where-vexecute-returns`](a-skill-rolls-past-where-vexecute-returns.md)
—the rolls and what they apply after `vExecute` returns, which moves 61 of
the model's 400 hashed battles— and
[`the-attack-says-undamaged-for-a-miss`](the-attack-says-undamaged-for-a-miss.md)
—a missed attack says "avoids taking damage." where RM2k says the dodge
line, seen in the original—, with its line in ABL's Known issues.

**To install when merging**: `battle`, `mapdata`, `convert`, `cartridge`,
`screens` and `events` —the runtime changes, `rm2k-snes-cartridges`
assembles the checkout it was installed from, and `screens` and `events`
link `rm2k-snes-battle`—.
