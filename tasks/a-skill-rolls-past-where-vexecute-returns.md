---
name: "A skill rolls past where vExecute returns"
description: "Once a skill's damage kills, or once one against enemies missed the HP or SP it touches, RM2k stops rolling and applying; the battle and its model still roll and apply the parameters and the attribute ranks after it"
type: bug
status: testing
assignee: taro
agents: [Cardón]
---

Seen by Cardón on 2026-10-20, **reading the code against easyrpg's**, with
the-advocate `3bc68ac4`, while doing
[`a-skill-in-battle-writes-no-result-line`](a-skill-in-battle-writes-no-result-line.md).
Not run in the original.

**What RM2k does**, in easyrpg's `Game_BattleAlgorithm::Skill::vExecute`:
two early returns. "If target will be killed, no further affects are
applied" —after the HP, when the damage leaves the target at 0— and
`if (!IsPositive() && !IsSuccess() && (skill.affect_hp ||
skill.affect_sp)) return` —a skill against enemies whose HP and SP rolls
did nothing—. From there it neither rolls for the SP, the four parameters
or the attribute ranks, nor applies them.

**What the port does**: `ba_skill_one` in `runtime/battle_skills.s` and
`skill_rolls` in `rm2k-snes-battle`'s `simulate.rs` roll and apply all of
them, every time. The two sides agree, so no test sees it; RPG_RT's
randomness goes out of phase from that roll on, and a missed or killing
skill that also lowers a parameter lowers it anyway —silently: since
2026-10-20 the result lines stop where `vExecute` returns—.

**How to see it**: making the model stop there moves 61 of the 400
battles of `rm2k-snes/battle/tests/model.rs`, whose hashes are the deleted
Python's and "not to be regenerated to make a test pass". Whoever takes it
needs taro's word on those hashes, and has to move the console with the
model.

## taro's decision (2026-10-20)

taro, in their words, translated:

> It makes sense to do nothing. If it missed, its effects should miss
> too. If it killed the enemy, applying effects stops making sense (for
> instance, poisoning it when it is already dead).

So: like RM2k, in the model and the console, and the hashes of the
battles it moves change, each looked at and explained in its commit.

## Work (Cardón, 2026-10-20)

From the-advocate, the-advocate-ports and the-advocate-docs at Hornero's
`hornero-integrate` (`fc4bfad7`, `59b5658`, `50cae07`), branches
`cardon-vexecute` in each.

**The model**: `skill_rolls` returns where `vExecute` does —after the
HP's line when the damage killed, and after the SP when a skill against
enemies that touches HP or SP wrote nothing—. Nothing is rolled, applied or
written past either. `tests/skill_results.rs` asks it on the randomness: a
killing or missed skill 14 leaves the generator where the same skill without
its defense would, and the dead target's defense at zero. Red before: the
defense at -6, and a different generator state on the miss.

**The console**: `ba_skill_one` jumps to its failure check after a killing
HP —`ba_res_killed`, which was `ba_res_quiet`— and after a missed HP/SP
against enemies. Nothing is written past the return any more, so
`ba_res_add` and `ba_attr_shift` stop asking whether to write.

**The 61 battles that move** of the 400 of `tests/model.rs`, measured by
logging each return that skipped a roll: the set of battles that cross a
return with something after it is exactly the set whose hash moves, 61 and
61. All of them by skill 14 of the small game —HP and defense against every
enemy, hit 95—: in 56 the first return crossed is a kill, in 5 a miss.
Before, the dead or missed target's defense was still rolled and lowered;
now it is not, so the dead enemy's `mod_defense` stays and the battle's
randomness goes on one roll earlier —every later roll, and with it the
rest of the battle, moves—.

**ABL**: no skill of ABL that RM2k lets be chosen in battle touches the HP
and something after it —Trip (141), Backstab (257), Fancy Swordplay (215)
and the Memories are not `occasion_battle`, and no enemy uses them—, so
neither return is reachable with the game as it is: the console change
moves nothing ABL plays. `test_a_kill_lowers_nothing_after_it`, in
`test_battle_skill_results.py`, makes the kill reachable the way
`test_dma_from_zero.py` does: a copy of `release` where MinorFire's
`skill_affects` byte also has the agility, Talan casting it on the Junkbot
at 1 HP, against the model of the plain MinorFire. Red with the runtime
before —"the console lowered the dead Junkbot's agility by 2"—, green
after. **Not covered by any ROM test**: the miss return; only the model's
`tests/skill_results.rs` covers it.

**Space**: bank `$C0` gains 5 bytes in every cartridge; nothing else moves
(`just space`, before and after, all cartridges).

**Branches** `cardon-vexecute`: the-advocate `26340150` (the code,
`35f4be5b`, and the hashes in their own commit), the-advocate-ports
`87ad685`, the-advocate-docs `9d07224` —the divergence "What a skill's
result lines do not model" drops the item and says it with what is the
same—. `main` of the three was still `hornero-integrate` when handing
back, so there was nothing to merge.

**Run**, with the tools of the branch first in the PATH: ABL's suite
(1587 passed, 2 skipped), `just boot` at the ports' root (102 passed),
`just test`, `just rust-test` and `just lint` in the-advocate, all green.

**To install when merging**: `battle` (the model) and, for the runtime,
nothing but the checkout: the runtime is read from it. `just install
battle` from `~/the-advocate`; the cartridges rebuild on their own.
