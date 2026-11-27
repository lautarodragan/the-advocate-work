---
name: "The encounter rate test expects our own dice"
description: "test_encounter_rates.py holds the ROM, step by step, to events.Encounters —a Python copy of the console's encounter count, with its generator—, down to the random state and whether an encounter came up: the same nature as simulate, for the random encounters"
type: refactor
game: advocate
status: draft
assignee: taro
agents: [cardon]
author: cardon
links:
  found-in: [battle-tests-without-simulate]
---

Seen by Cardón on 2026-11-27, classifying the battle tests, at the-advocate
`ab885b29` and the ports `dd440b5`; left out of
[`battle-tests-without-simulate`](battle-tests-without-simulate.md) on
purpose, as the assignment said.

**What it does**: ABL's `tests/rpgmaker/test_encounter_rates.py` walks the
hero over grass worth 100 and a forest worth 250 on map 5, and after each
step compares what the ROM keeps —`ENC_ACC`, the accumulated rate;
`ENC_IDX`, the table's row; `ENC_RNG`, the encounters' random state; and
`ENC_ASKS`, whether one came up— with `events.Encounters` in
`tests/harness/events.py`, fed the same rates and **the same seed**. That
class is the console's encounter count written again in Python, with its
xorshift: its docstring says whoever changes it has to change `runtime/`
in the same commit "otherwise the model and the console stop being the
same program". `test_encounter_steps.py` reads `Encounters.set_steps` for
the thresholds, and `tooling/test_encounters.py` holds the converter's
integer rewrite of `UpdateEncounterSteps` to it, without a ROM.

**What RM2k says** (easyrpg's `Game_Player::UpdateEncounterSteps`): the
accumulated rate and the row it climbs are deterministic —the terrains'
rates added up, `accumulated / steps` against the table—; whether an
encounter comes up on a step is a roll, `pmod / steps * rate / 100`. So the
first two can be exact, and `ENC_RNG` and `ENC_ASKS` are our dice: a
change of generator turns the test red with nothing wrong, as the battle
tests did.

## Log

### 2026-11-27, Cardón: a question for taro

Should it follow the battle tests? Options:

* **(a)** exact accumulated rate and row, from RM2k's rule (the rates of
  the terrains stepped on, and the table the converter writes, which
  `tooling/test_encounters.py` already holds to easyrpg's float); the
  encounter itself only "it can happen", with a bounded seed loop on the
  ROM like the battle's critical, and `ENC_RNG` no longer compared. The
  forest's ×2.5 then shows only in the row, not in how often encounters
  come. **Recommended**: it is the battle's answer 2 (a), applied here.
* **(b)** as (a), plus the encounter rate measured over many steps —the
  forest's 2.5 times the grass's within a bound—: a few hundred steps,
  some seconds of suite.
* **(c)** leave it: `events.Encounters` is a Python spec in the harness,
  not a model of ours in Rust, and the test is the only one that sees the
  console's generator step by step.
