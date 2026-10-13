---
name: "Battle conditions for real"
description: "A condition system in battle —duration, restrictions, the controlled one's AI, what each changes— so that ChangeMonsterCondition stops being a debt: ABL's Control and BarkWall"
type: feature
status: testing
assignee: taro
agents: [Chajá]
---

taro, on 2026-10-12: after `monster-conditions-and-flashscreen-in-battle.md`
accepts `ChangeMonsterCondition` as debt, this makes it real.

ABL uses two, both from troop pages (`Inscribe`, switch 799, and
`ControlMachines`, 803): 22, `Control` —"is being controlled!",
restriction 3, four turns, released by damage— and 23, `BarkWall` —lowers
attack, defense and agility, two turns—. Battle has no conditions today;
making them is a system: duration, restrictions, the controlled one's AI,
what each one changes. EasyRPG: `Game_Battler`'s `AddState`. Measured in
[`research/2026-10-05-the-missing-commands.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-the-missing-commands.html),
"The battle ones".


# Status

2026-10-12, Chajá, from the-advocate `25d93f0a`, the ports `742e127` and
the book `381001b`, on the branches `chaja-condiciones` of the three.

## The plan, after reading EasyRPG

What RM2k does with a condition in battle, and therefore what the console
and the model (`simulate.rs` of `rm2k-snes-battle`) have to do, rolls in the
same order:

* **`AddState`** (`ChangeMonsterCondition` from a troop page): held again
  from 1; the ones ten points of priority below the highest go; if the
  restriction is no longer normal, the action it had this turn is lost.
  **`RemoveStates`**: if the restriction changed, the same.
* **`CreateEnemyActions`**, through `SetStateRestrictedAction`: one that
  cannot act records "nothing" —it still takes its place in the order—; one
  that attacks its own side (Control, restriction 3) or the other picks a
  living one there, one roll.
* **`PrepareBattleAction`**, when its turn comes: the same again, with a
  second roll for the target, and "nothing" if the action was lost.
* **`BattleStateHeal`** at the start of its action: per condition, by LDB
  number, if held more than `hold_turn`, a roll against
  `auto_release_prob`; if not, one more turn. Then the message of the one
  with the highest priority: released, its `message_recovery`; held, its
  `message_affected` if not empty.
* **The hit**: `reduce_hit_ratio` of the source lowers its chance before
  the agility; a target that cannot act is always hit; a hit that does not
  kill rolls `release_by_damage` per condition (Control: 100), and a skill
  that damages, at `physical_rate * 10`.
* **The parameters**: `affect_*` halve attack, defense, spirit or agility,
  after the modifier, never below 1 (BarkWall: three of them).

Only enemies get conditions: no skill, attack or item gives them, and the
actors have none. That is the scope; what stays out goes to a divergence.

## Done so far

* The opcode, `OP_MONSTER_STATE` (0x4E): place, remove, condition.
  `ChangeMonsterCondition` left `ACCEPTED_UNDONE`; taking the dead one away
  does not compile (no game asks for it: Book of Three only adds it).
* The model: `StateInfo`, `Held`, the steps above. The 400 battles of
  `tests/model.rs` keep their hashes: the answer only says `states`,
  `restriction` and `state_log` where there are conditions.
* The ROM: `runtime/battle_states.s`, the places —four per combatant, a
  word each, condition and turns, in LDB order— and the routines; the hooks
  in `ba_enemy_actions`, `ba_execute`, `ba_attack`, `ba_skill_hp`,
  `ba_skill_one` and `ba_message`. The converter emits `state_*`, one row
  per LDB condition, and their two messages as texts.
* The test: `tests/rpgmaker/test_battle_conditions_golden.py` in the
  ports, with the new case `battle-control` (troop 111, the droid and the
  rat, 803 on) and `battle-inscribe`.
* The book: the divergence `what-battle-conditions-do-not-model`, and the
  three that said the battle had none.

# What was done (2026-10-12, Chajá)

Branches `chaja-condiciones`, with main merged in all three: the-advocate
`af6758b6` (far RAM grows) and `7e3049cd` (the conditions), the ports
`792cae2` (test and case) and `53e5390` (goldens), the book `23951b0`.

**What works**: the database's conditions on the enemies, given and taken
by a troop page —see "The plan" above for what each part does—; ABL's two,
`Control` and `BarkWall`, behave as RM2k's: the controlled droid hits its
own side until a hit or its turns free it, and the giant behind the wall
has attack, defense and agility halved and hits less until it shakes it
off. Generic over the LDB: duration, release by turns and by damage, the
four restrictions, the halved parameters, the hit ratio, the priority
purge and the two messages. Book of Three's `ChangeMonsterCondition` on
the dead condition kills.

**What does not**, in the divergence `what-battle-conditions-do-not-model`:
only enemies have conditions (no skill, attack or item gives them, the
actors have none, nothing persists after the battle); no HP or SP per turn
and no sealed skills; four at once; taking the dead one away does not
compile; the release by a hit in a window of its own, the first only; no
white flash on the holder; a physical skill's hit ignores conditions.

**Far RAM**: `FARBSS` was full —two bytes left in release, 24 short in
`test-change-system`—, so it grew over a medicine's $7E6800-$7E68FF, whose
21 bytes moved into the segment (its own commit). The conditions take 120
bytes of it.

**Cost**, in release: 120 B of far RAM; 1,642 B of code in
`battle_states.s` and 268 B in the hooks, in bank $C0, which keeps 6,048 B
free; ten bytes per LDB condition in tables and their messages as texts.

**Culprits**: ABL's converter log says "troop pages: 2045 of 2045" before
and after, with 187 bodies instead of 185 (two pages that were equal when
the command emitted nothing now differ by the enemy's place) and 58 B more
of code; the warning about `ChangeMonsterCondition` is gone. The other
games do not move by construction: the command was already accepted, and
the only new refusal —taking the dead condition away— no game asks for.
`rm2k-snes-events culprits` was not run.

**Verified**: ABL's suite whole with these tools, green after merging main (1261 cases), the fingerprint of `abl.sfc` `ebfaf414…`, with the new
`test_battle_conditions_golden.py` red with main's tools; `just test`,
and `cargo test` of battle, events, mapdata, cartridge and bytecode;
`just boot` of the ports, the eight, green. Compared with the original
under Wine (troop 111 with ControlMachines on turn 0): the droid is freed
by a hit and says so, under the damage.

**On merging, install** `cartridge events battle mapdata convert`
(`bytecode` goes into events and cartridge).

**What the suite does not cover**: Control going away by its turns (the
model's unit test does; in the case the droid hits itself on turn 1); the
restrictions "does nothing" (1) and "attacks the other side" (2); a skill
releasing a condition; the dead condition from a page; two conditions on
one enemy and the priority purge on the console; a fifth condition.

**What taro should play**: ControlMachines (Talan's skill, switch 803) in a
random encounter with a machine and something else —the droid and the rat
of troop 111—: the machine hits its own until it is freed. And Inscribe
after a wall of bark (729): the enemy hits softer and misses more, and
"shakes off the wooden barbs!" comes some turns later.

Captures: `~/scratch/chaja/capturas/2026-10-12-condiciones/`, with its
`LEEME.txt`. Draft: `arrancan-sunset-stale-right-after-built.md`.
