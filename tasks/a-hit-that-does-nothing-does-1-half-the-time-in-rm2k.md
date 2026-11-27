---
name: "A hit that does nothing does 1 half the time in RM2k"
description: "In the legacy RM2k 2000 a normal attack or a skill whose effect comes to 0 still rolls its variance, and does 0 or 1; the console and the battle model skip the roll, so a weak enemy never scratches a strong actor"
type: bug
game: advocate
status: draft
assignee: taro
agents: [cardon]
author: cardon
links:
  found-in: [battle-tests-without-simulate]
---

Seen by Cardón on 2026-11-27, classifying the battle tests, at the-advocate
`ab885b29`, by reading code; **not yet seen under Wine**.

**What RM2k does**: easyrpg-player's `Algo::VarianceAdjustEffect`
(`src/algo.cpp`) rolls when `var > 0 && (base > 0 || Player::IsLegacy())`.
With a base of 0, `adj = max(1, var * 0 / 10)` is 1 and the result is
`0 + rand(0, 1) - 0`: **0 or 1**. `IsLegacy()` is the 2000 or 2003 engine
before the official updates; easyrpg tells it from the executable
(`EXEReader::FileInfo::GetEngineType`): no version info and three logos is
the old RPG2k. ABL's `RPG_RT.exe` has no version info and carries
`LOGO1`, `LOGO2` and `LOGO3`, so easyrpg plays it as that engine.

**What the console does**: `ba_attack` in `runtime/battle.s` jumps over the
variance when the damage is 0 (its comment: "zero rolls no variance
—`VarianceAdjustEffect` asks for `base > 0`—"), and `ba_variance` in
`runtime/battle_skills.s` the same for a skill; `apply_variance` in
`rm2k-snes/battle/src/simulate.rs` too. Both comments describe easyrpg's
condition without its `IsLegacy()` half.

**Where it shows in ABL**: any hit whose `atk / 2 - def / 4` is 0 or
less, which at the game's start is most enemies on Kersh (defense 147):
the Junkbot (attack 25), the Lumbering Giant (52). In RM2k they do 1 about
half the time; on the console, always 0.

**To confirm**: under Wine, Kersh defending against the Junkbot of
`battle-114-attributes` for a dozen turns; the original should show
"1 HP" losses among the zeros. If it does, the fix is the console's
`ba_attack` and `ba_variance` rolling on 0 —one more roll, which moves
every battle golden whose seed passes through such a hit—, and the
model's, unless it is gone by then
([`battle-tests-without-simulate`](battle-tests-without-simulate.md)).
