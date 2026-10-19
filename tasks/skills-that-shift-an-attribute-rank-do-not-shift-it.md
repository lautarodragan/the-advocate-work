---
name: "Skills that shift an attribute rank do not shift it"
description: "A skill with affect_attr_defence —Heat Barrier, Cold Barrier— should move its target's rank in its attributes for the rest of the battle; the battle does its damage or healing and the ranks stay"
type: bug
status: testing
assignee: taro
agents: [Chajá, Aguará]
---

Seen by Chajá on 2026-10-15, at the-advocate's branch `chaja-attributes`
(from `497be031`), while bringing the attributes into the battle
([elemental-attributes-are-not-applied-in-battle](elemental-attributes-are-not-applied-in-battle.md)).

**What is seen**: not played. In RM2k a skill with `affect_attr_defence`
rolls, per attribute it carries, a shift of its target's rank by one step
—weaker on one it targets as an enemy, more resistant on an ally— that
lasts the battle, at most one step either way
(`Game_BattleAlgorithm::Skill::vExecute`, `Game_Battler::ShiftAttributeRate`
in easyrpg-player). Neither the model (`rm2k-snes/battle/src/attributes.rs`)
nor the console reads the flag: the ranks are the database's all battle
long. The divergence is
[What attributes do not model](https://lautarodragan.github.io/the-advocate-docs/divergences/what-attributes-do-not-model.html).

**How much it is used**: Heat Barrier and Cold Barrier in A Blurred Line,
The Book of Three, El Dorado and The Frozen World; six skills in Vampires
Dawn (Fire Barrier, Ice Barrier, Black Aura, Weakening twice,
Schattenmauer). Counted over each dump's `skills.json`: `affect_attr_defence`
with some `attribute_effects`.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
A fidelity detail of the battle: the barriers still heal or hurt, only the
rank does not move. **Done** is the model in `attributes.rs` and the
console keeping a per-battler, per-attribute shift of -1, 0 or +1 that a
skill with `affect_attr_defence` rolls as easyrpg's `ShiftAttributeRate`
does and that the damage reads, reset when the battle ends; a battle test
where Heat Barrier and then a fire skill do the shifted damage; and the
divergence page losing that paragraph. First step: read
`Game_BattleAlgorithm::Skill::vExecute` and `Game_Battler::ShiftAttributeRate`
for the roll and the bounds.

## Aguará, 2026-10-18

Worktrees `aguara-attr-shift` in the three code repos, from the-advocate
`b066b885`, ports `74068b8`, docs `239069e`.

**easyrpg, read** (`game_battlealgorithm.cpp` `Skill::vExecute`,
`game_battler.cpp`): after the damage, the parameters and the states, if
`affect_attr_defence`, `shift = IsPositive() ? +1 : -1`, and for each
attribute the skill carries, in database order,
`CanShiftAttributeRate(id, shift) && PercentChance(to_hit)` —the `&&` means
**a rank already at the bound rolls nothing**—; the shifts are applied
after the action. `CanShiftAttributeRate` is
`clamp(prev + shift, -1, 1) - prev`; `GetAttributeRate` is
`clamp(base + shift, 0, 4)`, the actor's base already clamped with its
armor's step. The shifts are cleared by `ResetBattle` and when the dead
state is added. `IsImmuneToAttributeDownshifts` is EasyRPG's own field,
false in a 2000 game. `EnemyAi::IsSkillEffectiveOn` counts a skill with
`affect_attr_defence` and some attribute as effective on an ally: the model's
`rules::skill_works_alone` did not, so an enemy that has a barrier never
chose it; no ABL enemy has one.

**Model** (`attributes.rs`, `simulate.rs`): `Received` carries the base
rank, the shift and the five rates; `shift_by` / `can_shift` are easyrpg's.
`skill_on` rolls the steps after the parameters. A `ChangeEquipment` keeps
the shifts; an actor that gets up —an item, `FullHeal`, the
`ChangeCondition` that revives— loses them (same, seen from outside, as
easyrpg's clearing at death). The answer carries `attribute_shift` only for
whoever has one, so no hash of `tests/model.rs` moves.

**Console**: `ba_attr_shifts` in `FARBSS`, `BA_COMB_MAX * ATTR_SHIFT_N`
bytes: the converter numbers first the attributes a carried skill with
`affect_attr_defence` carries (`ATTR_SHIFT_N`), so the far RAM is only for
those —in ABL's `release`, only Flame (5), since only the new case teaches
Heat Barrier—. `ba_attr_shift` after the four parameters in `ba_skill_one`;
`rank` in `ba_attr_apply` adds the shift. Cleared at `battle_run`'s start,
on an item's revive, on a page's revive or join (`ba_sync_in`) and for the
field heal's borrowed combatant 1 (`sk_heal_one`), which would otherwise
read the last battle's row —or garbage before the first battle: boot does
not clear far RAM—.

**Test**: `tests/rpgmaker/test_battle_attribute_shift.py` in ABL, case
`battle-69-attribute-shift` (Kersh, taught Heat Barrier, alone against
troop 69, a sample Dragon that attacks or throws Flame Field). Kersh casts
the barrier every turn: the first shifts, the rest find the bound and roll
nothing. Console HP against the model turn by turn, and the model's log
against easyrpg's arithmetic (each Dragon hit told by its size; turn 2's
Flame Field does 30 where unshifted it is ~57). Red with main's tools,
green with these. It is also the first console test of an enemy's skill
with an attribute on an actor.

**A latent bug it uncovered**: `test_long_list.py` wrote Talan's skills
with `release`'s pair index on `test-special`'s cartridge; they were
already one off, so its four goldens showed Talan without Detect Aura. The
new case made it two off. Fixed (it asks for the cartridge that carries
`battle`), and the goldens re-taken: the list now starts with Detect Aura.
Side by side in `/shared/captures/2026-10-18-attribute-shift/`.

## Verified, and what to install

With the tools of `aguara-attr-shift` (`cartridge battle mapdata` installed
locally), on the tree merged with main (the-advocate `846ecc5b`, ports
`0da079e`): ABL's `just tests` 1573 passed, 2 skipped; the other games'
`just boot` 67 passed (before the last merge, which only brought comments
to the runtime); `just test` 29 passed; `just rust-test` green;
`SOUNDFONT=FluidR3_GM just test-game` 45 passed, 1 skipped. Goldens moved:
only the four of the long list, explained above. `just space`, `release`:
bank `$C0` 2,766 → 2,469 B free, far RAM 2,670 → 2,658 B (12 bytes: one
shiftable attribute times twelve combatants), bank 0 194 B as before.

What the suite does **not** cover, in so many words: a shift on an enemy
(no ABL skill targets enemies with `affect_attr_defence`; the model's unit
tests do it), an actor getting up or coming back without its shifts, the
field heal clearing combatant 1's row, `ChangeEquipment` keeping them, and
an enemy choosing a barrier (`skill_works_alone`; no ABL enemy has one).

**On merging, install** `cartridge battle mapdata`. Branches
`aguara-attr-shift` in the-advocate, the-advocate-ports and
the-advocate-docs.
