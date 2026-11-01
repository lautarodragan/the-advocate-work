---
name: "Terrains: encounter rates and bushes"
description: "The next two parts of terrains-do-what-rm2k-does: a terrain's encounter rate multiplies the steps to a battle, and its bush depth draws the lower part of a character half-transparent"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

The two parts left in [`terrains-do-what-rm2k-does`](terrains-do-what-rm2k-does.md)
—"What is left"— that need no vehicles nor 2003 sounds. That task stays
in `testing` with its first part, the damage; this one takes the next
two. taro, on 2026-11-01, in their words, translated, asked to launch
every pending one that could run in parallel:

> Go ahead! All the ones that can run in parallel without leading to
> conflicts that are too complicated to resolve.

**Done**:

* **Encounter rate**: a terrain's rate multiplies the steps to a battle
  as RM2k does it (easyrpg's `Game_Player` encounter steps), on every
  game; Vampires Dawn's sea, at rate 0, never has a battle; the model in
  `rm2k-snes/battle/src/encounters.rs` and the ROM agree, and ABL's
  `tests/tooling/test_encounters.py` says so.
* **Bush depth**: the lower part of a character on a bush terrain is
  drawn half-transparent, as RM2k does; Book of Three's "Water in
  Tylwyth" and Vampires Dawn's forests; captures looked at.

Each part its own commit, red before.

## Encounter rate: what was done

By Aguará, on 2026-11-01, on branches `aguara-terrain-rates` of
the-advocate and the ports.

* **The model**, `rm2k-snes/battle/src/encounters.rs`: the rows'
  thresholds are the accumulated rate, `row * steps` —`rate_thresholds`,
  words—, and a terrain's rate is a factor in 1/256, `rate * 256 / 100`
  truncated —`factor`—; the chance is `base * factor`, shifted by the
  row's `pmod`, over 256 —`chance`—. With 100 it is the old shift, bit for
  bit. `RATE` is gone; `STEPS_MAX`, 364, is the most steps a word holds
  —the nine games go up to 100—, and past it the converter stops and
  `ChangeEncounterSteps` does not compile.
* **The ROM**, `encounter_step` in `runtime/encounters.s`: the terrain of
  the cell the step goes onto —`hero_terrain`, the damage's—, its rate
  added to `ENC_ACC`, a word that saturates, and one 16x16 multiplication
  by shift and add per step. `terrain_encounter_rate` and
  `terrain_encounter_factor` go next to `terrain_damage`, from the
  mapdata stage. `OP_ENCOUNTER_STEPS` carries words now; the events
  compiler takes `base` and `rate_thresholds` from the battle crate
  instead of its own copy.
* **What the nine games' sea at 0 means**: Vampires Dawn's terrain 10 is
  not passable below, so the hero only walks it where an upper tile lets
  it —1100-odd cells of map 1, like the row of five at (104..108, 6)—.
  **Map 1 is not in the cartridge** —`excluded` in its `advocate.toml`,
  "a stream of map_cells is 147232 bytes"—, so the case is map 396,
  *Strand4 (1)*, whose (18..22, 16) are sea with a passable upper tile.
* **Tests**: ABL's `tests/rpgmaker/test_encounter_rates.py`, the ROM against
  `events.Encounters` step by step on map 5's forest (250) —map 5 has no
  encounters, so it writes them—; the ports'
  `tests/test_vampires_dawn_encounter_rates.py`, five steps of sea at the
  surest chance and none comes up, then grass and one does; ABL's
  `tooling/test_encounters.py` drops "every terrain is worth 100" and checks
  the integer model against the float formula. Red with main's tools:
  `test_encounter_steps` (the thresholds' layout), the rates test (by a
  missing symbol, `ENC_ACC`) and Vampires Dawn's (an encounter on the first
  step of sea). Commits: the-advocate `4d69f278`, ports `ae86583`, book
  `dc343c0`.
