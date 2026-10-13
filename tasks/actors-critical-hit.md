---
name: "The actors' critical hit"
description: "The LDB gives almost every actor a critical hit, and the ROM sets it to zero with a comment saying none of them has one"
type: bug
status: done
assignee: taro
---

Cardón found it on 2026-09-30, while moving the battle model to Rust
(`rust-the-battle-domain.md`). taro asked for it as a task that day.

`tools/runtime/battle.s`, when setting up an actor for battle, stores
`BA_CRIT` as zero with the comment "no actor in ABL has a critical hit".
The dump contradicts it: `critical_hit` is turned on in almost every
actor of `rom/data/db/actors.json`, the party's included —Kersh, Core,
Manta, Talan, Arden, AG7—, almost all with `critical_hit_chance` 30. In RM2k
that is a 1 in 30 chance, not 30 %: confirm it in easyrpg
(`Game_Actor::GetCriticalHitChance`) before touching anything.

The old Python didn't read the field either, so the ROM and the model were
wrong in the same way and no test saw it. The Rust model
(`rm2k-snes-battle`, `Combatant::actor`) keeps it on purpose, with a
comment: fixing it **moves the ROM and the randomness of every battle**, and the
model has to move along with it, because the tests compare them step
by step.

The comment in `battle.s` predates the translation into English
(`456dd0d4`): `git blame` with `-C --diff-algorithm=histogram` says when
it's from and whether it was a decision or an assumption.

Done means: the actors' critical hit read from the LDB on both sides, a
test with an actor that has it and a random seed that triggers it, seen red
before, and the battle goldens that move shown to taro.

# What was done (Cardenal, 2026-10-02)

**What the blame said.** The comment is born in `9527063d`, "Las peleas de la
intro se pueden pelear", the first version of the battle (2026-09-12): "no
actor in ABL has a critical hit". It was an assumption, not a decision: the
model back then (`tools/batalla.py`) read `critical_hit` with a
`getattr(..., False)`, and the LDB reader back then (`tools/lcf.py`) didn't
read that field of the actor —only the enemy's—, so it gave false for
all of them and the docstring said "in ABL none has it". The ROM was written
against that model. Nobody measured it against the dump.

**What it is in RM2k** (easyrpg, `Game_Actor::GetCriticalHitChance` and
`Algo::CalcCriticalHitChance`): `1 / critical_hit_chance` if it has
`critical_hit`, plus the best `critical_hit` of the equipped weapons —in
percent—, added **in float** and then `* 100.0` truncated. With 30 it's 3 %.
The float matters: `1/25` gives 3 and not 4, and a weapon of 12 without its own critical gives
11. No party actor has a weapon with a bonus today, but there are 70 weapons
that have one.

**How it ended up.**

- `rm2k-snes-battle`: `rules::critical_percent` does the arithmetic in f32, and
  `Combatant::actor` and a page's `ChangeEquipment` use it. The
  enemies go through the same function (in ABL they give the same as before).
- The console doesn't add: the converter writes `crit_table`, with one row for
  each distinct own part and one column for each distinct bonus, and the ROM
  indexes it with `actor_crit_row` and the best of the columns of slots 0 and
  1 (`item_crit_k`). `ba_crit_of`, in `battle.s`, is called by `ba_actor_setup`
  and `ba_reparam`.
- **The randomness didn't move**: the critical roll was always made already, with 0.
  That's why no golden changed: in the suite's battles no party critical
  comes up with the factory seed.
- The test game of `rm2k-snes-battle` (`tests/game/dump`) had its
  actors with a critical; now they don't, so that the Python's hashes
  —which never read it— remain the correct answer. See the header
  of `tests/model.rs`.

**Tests** (in ABL, `tests/rpgmaker/test_battle.py`):

- `test_each_actor_enters_the_battle_with_its_critical`: `BA_CRIT` of Kersh,
  Core and Manta against an easyrpg computation done in the test —from the dump,
  in float— and against the model. Red before: "el actor 11 entró con un
  crítico de 0 y easyrpg le da 3".
- `test_a_party_critical_gives_the_same_hp_as_the_model`: the first
  seed with which someone in the party lands a critical against the
  droid, written into `BA_SEED`, turn by turn against the model. Red
  before: with the old model, "con ninguna de 200 semillas le sale un
  crítico a nadie del grupo".
- `test_the_critical_formula_is_easyrpgs`: the test's computation with
  1/25, and that the party has a critical.
- In Rust: `the_critical_hit_adds_in_floating_point`.

**How much the balance changes**, measured with the model: 2000 seeds per battle,
everyone attacking the first enemy, without the troop's pages. A party
critical comes up in ~3 % of the hits that land.

| battle | turns before → now | victories |
| --- | --- | --- |
| the droid (82), Kersh, Core and Manta | 2.10 → 2.03 | 100 % |
| the LT gang (86), the three | 2.00 → 2.00 | 100 % |
| the Lazer Teeth (86), Kersh and Talan | 4.24 → 4.18 | 100 % |
| the Rat King (97), AG7 alone, without rats | 10.63 → 10.19 | 78.0 % → 81.4 % |
| the agents (102), Kersh | 4.25 → 4.19 | 100 % |
| the marauders (222), the three | 1.87 → 1.85 | 100 % |

Between 1 % and 4 % shorter; the only noticeable one is the Rat King, which
AG7 alone wins three more times out of every hundred.

**What's left out**: `PreventsCritical` —the Talisman (item 76) has
`prevent_critical`, and in RM2k it cancels the enemies' criticals against
whoever carries it—. Neither the ROM nor the model looks at it, since before this.

# What taro has to look at

- **Any battle, several times**: every now and then —one in every
  thirty hits that land— a party hit does triple. The screen
  doesn't announce it differently: RM2k 2000 doesn't say "critical" with the normal
  attack either, only the number shows it.
- **The Rat King with AG7 alone**, which is where it shows most (78 % → 81 % of
  victories in the model).

# When merging

- Install globally: `just -f tools/justfile install battle mapdata`
  (and `cartridge`, which builds with the checkout's runtime).
- Branches: `worktree-agent-a33a321932dffd972` here, `cardenal-textos-y-critico`
  in ABL's clone (`/extras/scratch/cardenal/abl`).
