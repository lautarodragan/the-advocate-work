---
name: "Healing skills from the menu"
description: "Tech Skill on the map uses a healing skill: on one ally, on oneself or on the whole party, with RM2k's effect and the SP spent only if it was of use"
type: feature
status: done
assignee: taro
agents: [Mulita]
---

Phase 3.2 of [`the-skills-menu`](the-skills-menu.md), after the list
([`the-skills-screen`](the-skills-screen.md)) and the switch skills
([`switch-skills-from-the-menu`](switch-skills-from-the-menu.md)). The plan
is section 8 of the research
[`research/2026-10-12-the-skills-menu`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-12-the-skills-menu.html):

* `target_screen` generalised —or a twin outside bank 0— with the skill's
  name, the cost term and the cost, and the cursor on one, on the user, or
  on everyone, by the skill's scope.
* An effect routine with `CalcSkillEffect` from the user's `eq_parameter`,
  the variance, the HP and SP clamps and the revive of `medicine_use`; the
  SP spent only if it was of use; it stays on the choice, as RPG_RT does.
* Tests on the numbers, with the model's formula, as the medicine tests
  do.

Kersh's Healing Syringe heals from the menu already on the intro's
rooftop, in the original.

## Log

### Mulita, 2026-10-13: the original measured, the plan as built

Starting from the-advocate `81a0a9ce`, the ports `caf39ef`, the book
`a7f5e4d`; branches `mulita-healing-skills` in the three.

**The original, under Wine** (the 2015 RPG_RT, a copy of ABL whose map 4
makes the party Talan, Kersh, AG7-17 and Arden, teaches Talan SingleCure1,
AllCure1, LifeFromDecay, Raise and HighCure and AG7 LowRepair, hurts Kersh
and AG7 and fells Arden):

* the choice is `Scene_ActorTarget`: the name top left, "Cost" and the
  cost below it, the party on the right with HP and SP; the bar starts on
  the first row every time;
* A on a hurt one heals and **stays**; on a full one nothing, and no SP
  (Talan's stayed at 30); with fewer SP than the cost, nothing (HighCure
  with 0 left);
* a skill on oneself (LowRepair): the bar on the user, the arrows do
  nothing; one on the party (AllCure1): **one bar over the four rows**,
  the arrows do nothing, A heals each one —Talan full stays, Kersh +32,
  AG7 +29, Arden +30— for one cost;
* Raise, which revives without HP, left Arden at 4/46: 1 from the revive
  plus 46 × 10 / 100 − 1, easyrpg's percentage; a second Raise on her,
  standing, did nothing and spent nothing. LifeFromDecay (revive and HP)
  left her full;
* B goes back to the list with the cursor where it was.

**What reading the code changed from the plan**:

* The effect is **the battle's own code**, not a copy: `ba_skill_effect`
  and `ba_variance` over combatant 0's record, with the user's attack and
  spirit from `eq_parameter`, and the battle's randomness. So the model
  for the tests is the battle stage: a new `field-skill` request of
  `rm2k-snes-battle` (`field.rs`), which rolls in the same order —the
  critical at 0%, then the variance—.
* The choice is `target_screen` itself, in bank 0, told by a byte that it
  is for a skill: the A goes through `target_use` (medicine or skill), the
  arrows through `target_locks`, and everything else of the skill —its
  name, the cost's term, the cost, the bar over the party— is in
  `actor_choice.s`, outside bank 0. Bank 0 pays a `jsl` and a bridge.
* "Cost" is baked into BG1 like "Owned Items": the screens stage draws the
  choice a third time with the cost's term and with the bar over 1 to 4
  members, and the cartridge stores only the term's cells and the bar's
  distinct cell rows.
* The name's two lines: one byte per carried skill, where the first line
  ends (`skill_name_cut`); the line padded in the battle's message buffer
  so `tl_strip` composes it as a medicine's.

### Mulita, 2026-10-13: done, to testing

**Branches** `mulita-healing-skills` in the-advocate (`e2b8a514`), the
ports (`c06d4ea`) and the book (`b07d5c9`). **To install when merging**:
`battle` (the `field-skill` request), `screens` and `mapdata` (both compile
`rules`, which gained `skill::cures_death`; `rm2k-render` compiles it too
but uses nothing new). The runtime changes; `cartridge` needs no reinstall.

What it is: A on an enabled heal in the skills screen opens the actor
choice —the medicine's `target_screen`, for a skill—, uses it with the
battle's effect code and randomness, stays, and B goes back to the list.
The divergence is in the book,
`divergences/what-healing-skills-from-the-menu-do-not-model.md`; the
"Healing skills cannot be used" line left the Known issues of ABL, Book of
Three, Vampires Dawn, Frozen World and Dooms 2.

**What it costs**, `rm2k-snes-space` on ABL's `release` against main's:
bank 0 8 B, bank 1 543 B, bank `$C0` 622 B, far RAM 2 B. The tightest after
it: Sunset over Imdahl's `$C0`, 1,348 B left; Vampires Dawn's bank 1,
2,776 B, and its far RAM, 46 B.

**Verified**: ABL's suite with the branch's tools, 1302 passed, with
`test_healing_skills.py` (eight cases: an ally, the party, oneself, a
revive, a heal that does not revive, someone full, a second use without
the SP, B back to the list; the numbers against `field-skill`, the screen
against `render`), six of them shown red against main's runtime with the
branch's tools; no golden moved. `just boot`, 9 passed. `just test`, 27;
`just rust-test`, green, with `tests/field.rs` in `rm2k-snes-battle`.

**The other games**, with a throwaway script over each `release` (the
first party member made one who knows a heal, at 1 HP, the heal used from
the menu): Book of Three's Refreshing Wave, on the party, 1 → 31 HP, 99 →
94 SP; Vampires Dawn's Blood Healing, on an ally, 1 → 13 HP, 99 → 96 SP.
**Frozen World and Dooms 2 carry no heal**: the ones they teach are learned
only by actors that never join the party (Frozen World's 4 and 8, the
RTP's sample ones; Dooms 2's First aid, actor 8), so the cartridge carries
their pairs without the skill, or not at all. El Dorado teaches none.

**Not covered by the suite**: the other games' heals (only the script
above); the percentage revive without HP of its own —RM2k's Raise— in the
ROM: no actor that fights in ABL learns one, so only the model's test and
the Wine measurement cover it; a heal that touches SP (Obling Brew) in the
ROM; a party of fewer than four with a skill on the party (the bar's lists
for one to three members are emitted and no test runs them; Book of
Three's capture shows it over one); the skill's sound (not played: the
divergence).
