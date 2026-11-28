---
name: "The attack says undamaged for a miss"
description: "A missed normal attack writes the target's undamaged line instead of RM2k's dodge one, and a hit of zero writes '0 health lost' instead of the undamaged one"
type: bug
status: testing
assignee: taro
author: cardon
agents: [Cardón, Calandria]
links:
  found-in: [a-skill-in-battle-writes-no-result-line]
---

Seen by Cardón on 2026-10-20, **reading the code against easyrpg's**, with
the-advocate `3bc68ac4`, while doing
[`a-skill-in-battle-writes-no-result-line`](a-skill-in-battle-writes-no-result-line.md).
The original shows it: the 2015 RPG_RT under Wine, in the battle test of
troop 114, wrote "maneuvers out of the way!" under the Junkbot's missed
attack on Talan (the capture, in `/shared/captures/2026-10-20-skill-results/`).
Not run in the ROM.

**What RM2k does**, in easyrpg's `Scene_Battle_Rpg2k`: a normal attack
that misses goes to `ProcessBattleActionFailure`, which writes
`GetPhysicalFailureMessage` —`<target><dodge>`, A Blurred Line's
" maneuvers out of the way!"—; one that hits for 0 goes to
`ProcessBattleActionDamage`, which writes `GetUndamagedMessage`
—`<target><enemy_undamaged>`, " avoids taking damage."—.

**What the port does**: `ba_message`'s `attack:` branch, in
`runtime/battle.s`, writes the undamaged line for a miss (`BA_MDMG` at
$FFFF) and `<target> 0 health lost.` for a hit of zero. A skill's damage
line of zero goes through the same code since 2026-10-20 and is right
—undamaged—; the `dodge` term is in the cartridge since that day,
`BA_TXT_DODGE`.

**How to see it**: any battle where a party member's attack misses —the
droid of A Blurred Line's map 2 dodges sometimes—: the line under
"\<who> attacks the enemy" says "Droid avoids taking damage."

## Comments

### 2026-11-27, taro: a question for Hornero

> So we're currently showing "avoids taking damage" in places we should show "maneuvers out of the way" in ABL, for example?

### 2026-11-27, Hornero: yes, every missed attack

Yes. Every normal attack that misses, the party's or an enemy's, writes
"\<target\> avoids taking damage." where RM2k writes "\<target\>
maneuvers out of the way!" —RPG_RT's own capture, troop 114—; and the
rare hit for 0 writes "\<target\> 0 health lost." where RM2k writes the
undamaged line. Still so on the-advocate `bf18d71e`:
`runtime/battle_message.s` sends `BA_MDMG` $FFFF to `failed` (lines
87-98), and `BA_TXT_DODGE` is in the cartridge unused. Skills are right
since 2026-10-20. Still `todo`, waiting for taro's go.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `ba_message` in `runtime/battle_message.s`
(78-118) goes to `failed`, the undamaged line, for `BA_MDMG` $FFFF, and writes
`<n> health lost` for a zero; `BA_TXT_DODGE` is in the cartridge. A text
towards RM2k, with RPG_RT's capture already taken: nothing to choose.

### 2026-11-28, Calandria: taken, and the fix

From the-advocate `b4654a3a` and the ports `aaa51a7c`, branches
`calandria-miss-line` in both. `git blame` of the two places: the `cmp
#$FFFF` / `jmp failed` of `damage` comes from the first battle message
(`5f395e0c2` only moved it back under its comment), when an attack had
nothing between a hit and the undamaged line; the `dec a` in `damaged`,
which turned a skill's zero into $FFFF, is `a2cb6c151` (2026-10-20), which
reused the attack's miss on purpose, because then the miss *was* the
undamaged line. Neither is a choice against RM2k.

The change, in `runtime/battle_message.s`: `damage` tells three cases
apart —$FFFF, the attack's miss, writes `<target><dodge>`
(`BA_TXT_DODGE`, `GetPhysicalFailureMessage`); 0 writes the undamaged
line; anything else the damage one— and `damaged` stores a skill's zero
as zero. `BA_MDMG` at $FFFF still means the attack missed for
`ba_hit_sound` and the harness's `Act`; a skill never stores $FFFF.
The-advocate `b640b6e1`.

### 2026-11-28, Calandria: the test, and to testing

#### The test

ABL's `tests/rpgmaker/test_battle_attack_results.py`, the ports
`2e8747f8` on `calandria-miss-line` (with its line in the tests'
README): the droid's battle of map 2, every attack message's rows against
RM2k's lines put together from the terms —`<who><attacking>`, then
`<target><dodge>`, `<target><x_undamaged>` or `<target> <n><x_damaged>`—,
what happened read from the ROM's record (`battle.Act`).

* a miss: seeds tried until one attack misses (`until_it_happens`);
* a hit of zero: the droid's `BA_DEF` and `BA_BDEF` written to 999 in the
  battle's RAM, as the skill results' test leaves the Junkbot at 1 HP:
  no hit of zero happens naturally in ABL's early battles.

Red with the global tools (the bug): seed 3, "Kersh avoids taking
damage." under the drone's miss; seed 1, "Sentry Drone 0 health lost.".
Green with this branch's.

#### What was run

* the-advocate: `just lint` (SOUNDFONT FluidR3_GM), `just test`, `env -u
  SOUNDFONT just rust-test`, `just test-game` (with SOUNDFONT): green.
* ABL, with `advocate` from this branch: the new file, then every
  `test_battle*`/`test_troop*` (119 passed, no golden moved), then the
  whole `just tests`: green but for `test_index.py`, which wanted the new
  file in the README, fixed and rerun.
* the ports' `just boot`, with this branch's `advocate`: 209 passed.

**No golden moved**: no battle golden of ABL's suite is taken on a miss
or a hit of zero, so there is nothing in `/shared/captures/`.

The book: the line of ABL's "Known issues" goes, on the docs branch
`calandria-miss-line` (`91b0aa3`).

To install when merging: `advocate`.
