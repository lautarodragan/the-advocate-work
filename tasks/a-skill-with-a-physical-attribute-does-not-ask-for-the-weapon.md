---
name: "A skill with a physical attribute does not ask for the weapon"
description: "RM2k grays out an actor's skill with a physical attribute unless a weapon it holds carries it; the battle offers it like any other: Saldra's Trip, AG7-17's ArmLaser and TillTheyGlow in A Blurred Line"
type: bug
status: testing
assignee: taro
agents: [Chajá, Tijereta]
---

Seen by Chajá on 2026-10-15, at the-advocate's branch `chaja-attributes`
(from `497be031`), while bringing the attributes into the battle
([elemental-attributes-are-not-applied-in-battle](elemental-attributes-are-not-applied-in-battle.md)).

**What is seen**: not played. `Game_Actor::IsSkillUsable` in easyrpg-player:
a skill without `affect_attr_defence` that carries a physical attribute is
usable only if one of the actor's weapons carries that same attribute;
otherwise RM2k grays it out in the battle list and the menu. The battle's
list (`rules::skill_usable` in rm2k-snes-battle, and the console's) does not
look at the weapons. The divergence is
[What attributes do not model](https://lautarodragan.github.io/the-advocate-docs/divergences/what-attributes-do-not-model.html).

**Where in A Blurred Line**: with their starting weapons, Saldra (17)
learns Trip (Martial) and her Bent Staff-RL carries only Thud; AG7-17 (18)
learns ArmLaser and TillTheyGlow (Ray) and the ArmCannon-!R carries none.
Measured over the dump and the release cartridge's skill pairs; another
weapon may carry them.

## Defined

Wishlist, on 2026-10-16, by Cardón: it is written as a divergence of the book, "What
attributes do not model", and it costs nothing in play but three skills
being usable that RM2k greys.

**Done** means an actor's skill with a physical attribute and without
`affect_attr_defence` is greyed in the battle list and the menu unless a
weapon it holds carries the attribute, in the model (`rules::skill_usable`)
and the console, and that bullet leaves the divergence page. **First
step**: where the battle list decides grey (`ba_skill_reaches`), and what
the cartridge already carries of each weapon's `attribute_set`.

## Tijereta, 2026-10-18

Worktrees `tijereta-attr-weapon` in the three code repos, from the-advocate
`b066b885`, ports `74068b8`, docs `239069e`.

**easyrpg, read**: `Game_Actor::IsSkillUsable` has no 2000/2003 branch.
Unless the skill has `affect_attr_defence`, **each** of its attributes that
is physical has to be on `GetWeapon()` or on `Get2ndWeapon()` —not
necessarily the same one—; `Get2ndWeapon` is whatever weapon is in the
shield's slot, so a two-weapon actor's second weapon counts and a shield
never does. `Window_Skill::CheckEnable` asks the same, so the menu greys by
it too.

**What the cartridge already carried**: `skill_attr` and `item_attr`,
rows of `attr_sets` per skill and item, and `attr_magic`; not
`affect_attr_defence`. Rather than teach the console that flag and the
kinds, the converter emits `skill_weapon`: per skill, the row of the
attributes it asks a weapon for (row 0, the empty set, for almost all).

**In ABL**: Trip (141, Martial), TillTheyGlow (236) and ArmLaser (243), Ray.
Saldra (17) starts with weapon 267 and can equip no Martial weapon; AG7-17
(18) starts with 269 and can equip 275, ArmMountedLaser-!R, which carries
Ray. (Attribute types in ABL: Ray, Thud, Martial, Cut, Bullets are
physical; Sword, oddly, is magical.)

Plan: the rule in `rm2k-rules` (`skill::weapons_allow`,
`weapon_attributes_asked`), used by `rm2k-snes-battle` (rules, the played
battle refuses an order for a grey one, the field skill does nothing), by
`rm2k-snes-screens` (the skills screen's grey, a new `held` in the
request) and by the converter (`skill_weapon`); on the console,
`ba_weapons_allow` in `battle_skills.s`, called by `ba_skill_reaches`
(battle list: grey and A) and `sk_usable` (menu).

**Done, in the-advocate `tijereta-attr-weapon`**: the rule in `rm2k-rules`,
the model and the screens stage, the converter's `skill_weapon`, and the
console's `ba_weapons_allow` in a new `runtime/battle_weapons.s` —after
`battle_attributes.s`, whose `weapon_row` it calls: ca65 cannot reach a
proc's labels before the proc—. ABL's `test_skills_weapons_drawing.py`,
four new cases (`skills-weapons`, `-laser`, `battle-114-skills-weapons`,
`-laser`): red with main's tools (TillTheyGlow and Trip white), green with
these.

The first whole suite caught one of mine: `ba_skill_reaches` kept the skill
in `BA_T1`, which the list's row holds across the call (where its line
starts), and every name after the first went to the wrong place —six
goldens of `test_battle_golden` and `test_long_list`—. Now on the stack.

**The menu cannot show it with ABL**: Trip, TillTheyGlow and ArmLaser target
enemies, so the map greys them anyway, and no skill of ABL the map can use
carries a physical attribute (the eight that carry one: 141, 142, 145, 236,
243, 299, 347, 379; 145 is a battle-only switch skill). The menu's lists are
compared against `screens.skills`, which greys by the same rule, but the
console only reaches the weapon walk after `skill_on_map` says yes.

## Verified, and what to install

With main merged (the-advocate `846ecc5b`, ports `0da079e`) and the tools of
`tijereta-attr-weapon` installed locally (`cartridge battle mapdata convert
screens`): `just test` 29 passed; `just crate-test` of battle, rules,
mapdata and screens, green; ABL's `just tests` 1575 passed, 2 skipped;
the other games' `just boot` 67 passed (run before the merge, which only
brought comments to the runtime and Goombario). **No golden moved.**
`abl.sfc` sha256 `75bf33fe…5fddcf`.

`just space`, `release`: bank $C0 2,766 → 2,623 B free (the routine), the
gaps 30,404 → 29,930 B (`skill_weapon` and the four cases); bank 0 194,
bank 1 676, BSS 57, far RAM 2,670, unchanged. `test-special`, the same
143 B of $C0.

What the suite does **not** cover, in so many words: the menu's weapon walk
(no skill of ABL the map can use carries a physical attribute); a
two-weapon actor's second weapon, a skill with two physical attributes
split between the weapons, and `affect_attr_defence`, only in the
`rm2k-rules` and battle-crate tests; a troop page's `ChangeEquipment`
greying or whitening a skill mid-battle.

**On merging, install** `battle mapdata convert screens` (`rules` changed,
but only those use what it added; the runtime comes from the checkout).
Branches `tijereta-attr-weapon` in the-advocate, the-advocate-ports and
the-advocate-docs.
