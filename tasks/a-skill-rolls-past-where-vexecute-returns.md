---
name: "A skill rolls past where vExecute returns"
description: "Once a skill's damage kills, or once one against enemies missed the HP or SP it touches, RM2k stops rolling and applying; the battle and its model still roll and apply the parameters and the attribute ranks after it"
type: bug
status: draft
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
