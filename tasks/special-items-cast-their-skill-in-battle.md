---
name: "Special items cast their skill in battle"
description: "An item of kind special casts its skill when used, and in battle the list only offers medicines: Zounds' Piedra, Shuriken and Bomba Chica, which throw damage at an enemy, never show up"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

taro, on 2026-10-19, playing Zounds: "I think a feature of the game let you
throw some objects, like stones, in battle. I don't know if that was just
using the item in battle or a hero's special skill… but I couldn't
reproduce it", with item 20, "Tira una piedra al enemigo", and 21 and 22.
"Maybe they invoke a skill in battle, and we haven't implemented that yet?"

What Hornero saw on the-advocate `54ec3daf`: yes. `item_usable_in_battle`
in rm2k-snes-battle (`src/rules.rs`) takes only medicines, so
`ba_items_list` (`runtime/battle_items.s`) never lists a special item
(kind 9, `skill_id`). Zounds' items 20 Piedra, 21 Shuriken and 22 Bomba
Chica are special with skills 6, 8 and 9: normal skills, one enemy, power
18, 46 and 32. Zounds has 13 special items, A Blurred Line 18, The Book of
Three 15 and Vampires Dawn 4 (named ones, kind 9).

The sibling on the map is
[`items-that-cast-a-skill-outside-battle`](items-that-cast-a-skill-outside-battle.md),
todo.

## Log

**2026-10-19, Tijereta.** From the-advocate `54ec3daf` and the ports
`c2912ad`, on `tijereta-special-items` in both and in the book.

RM2k's rule, read in easyrpg: `Window_Item::CheckEnable` in battle asks
`Game_Party::IsItemUsable(item, actor)` —the acting actor's `actor_set`
first, then for a special item `Algo::IsSkillUsable` of its skill: a normal
one always in battle, a switch one with `occasion_battle`, teleport and
escape never—; `Scene_Battle::ItemSelected` sends a special item to
`AssignSkill(skill, item)`, the same target choice as a skill;
`Game_BattleAlgorithm::Skill::vStart` with an item calls `ConsumeItemUse`
instead of charging SP (an item with `uses` 0 is never spent); and
`GetStartMessage` with an item whose `using_message` is 0 —always, in
2000— is `GetItemStartMessage2k`, the medicine's line.

Model first (rm2k-snes-battle): `item_skill_in_battle` and `item_in_battle`
in `rules.rs`; the model answers `item_skill` per item and carries those
skills in `skills`; `play_turn` takes `[3, item, target]` for a special
item as a skill without SP (`Target::ItemSkill`, `Battle::cast`), and
refuses an actor its `actor_set` leaves out. `tests/special_items.rs`.

Runtime: the converter's `item_skill` (the skill's row or $FF);
`ba_items_list` lists a special item only for an actor its `actor_set`
allows (`ba_item_actor_can`, factored out of `ba_item_usable_on`); A on one
jumps into the skill's path (`h_assign`); `ba_record_skill` records it,
spends the item and marks `ba_item_cast`; `ba_skill_use` skips the SP and
the message is the item's line. Also: `ba_item_consume` no longer spends an
item without uses (the menu already did not), and a failed escape gives
back a special item as it does a medicine.

**The limit, measured on each dump** (special items with a name; "listed"
is `item_skill_in_battle`):

* Zounds, 13: 12 listed. Whole: Piedra, Shuriken, Bomba Chica, Látigo
  Descartable (damage) and Banda Azul and Roja (the party's four
  parameters up). Damage without their condition: Ala Eléctrica, Pétalo
  Violeta, Paralizador, Veneno, Ácido, Bola de Fuego. Not listed:
  Materializador, a switch skill only for the map (`occasion_battle`
  false), which RM2k does not offer in battle either. **Piedra's
  `actor_set` leaves Unamë out** (actors 4 to 10 only), and Shuriken's and
  Bomba Chica's leave everyone but Kazar: alone, Unamë never sees them, in
  RM2k too, where they show grey.
* A Blurred Line, 18: all listed and whole —three HP potions and four
  AGL/DEF ones on an ally, three bombs on every enemy, four batteries on
  one, three fields on the party—, except the placeholder "ABL 2.0 ITEMS"
  (328), whose skill also poisons.
* The Book of Three, 15: all listed. Whole: Volatile Shell, Frozen
  Crystal, Hurdy-Gurdy, Tectonic Shifter, the two Healing Runes, Annlaw's
  Jug (SP, `uses` 0: never spent). Spent whole on the first use: the bags
  of five (123, 124) and Sleeping Powder (2). Damage without their
  condition: Poison Dart, Sleeping Powder. Nothing at all: Web Weaver and
  the Runes of Sleep, Toxin and Darkness, which only give a condition.
* Vampires Dawn, 4: all listed. Whole: Flame Potion. Damage without its
  condition: Ice Dust, Holy Sand. Nothing: Itching Powder.

Not done (drafts): conditions from skills, the result line of any skill,
several uses. Equipment with `use_skill` is not offered either (in the
divergence); none of the four games has any.

**FAR2 ran out in Sunset.** `just boot` on the merged tree: Sunset over
Imdahl did not link —`FAR2` overflowed bank $C0 by 232 bytes—, because its
painted maps carry more code there (`paint_table`); A Blurred Line has
2 KB left in it. `message_waits.s` and `items_by_variable.s` moved to
`FAR3` (bank $C1, 28 KB free), whole procs entered by `jsl`/`jml` that read
everything with `f:`; what is left in Sunset's `FAR2` is what `just space`
prints for bank $C0 there. It is Sunset's tightest bank: whoever grows the
battle or the panoramas next will hit it.

**Branches**: `tijereta-special-items` in the-advocate (model, converter,
runtime), the ports (ABL's `test_battle_special_items.py` and its case
`battle-114-special-items`, Zounds' `test_zounds_special_items.py` and its
case `battle-piedra`, `Fight.give_command(("item", …))`) and the book
(`divergences/what-items-in-battle-do-not-model.md`, a line in Zounds'
known issues). **To install when merging**: `just install battle mapdata
convert` —convert links the other two as libraries—; the runtime comes
from the checkout.

**What taro should play**: Zounds with Kazar in the party —Piedra's
`actor_set` leaves Unamë out, and in RM2k it is grey for him—, Use Item in
a battle: Piedra, Shuriken and Bomba Chica are there, ask for an enemy,
hurt it and spend no SP; the message is the item's line —Kazar, the item and
the game's `use_item` term— and nothing more (draft `a-skill-in-battle-writes-no-result-line`). In A Blurred Line
the bombs, batteries, potions and fields of the late game.

**Verified on the merged tree** (the-advocate `40e95885`, with Mulita's
format, Calandria's events and Chajá's vblank; the ports `16c73cb`), with
the branch's tools plus main's `events` installed locally: `just test`,
`just rust-test`, `just lint` clean, ABL's whole suite green, and `just
boot` from the ports' root green, Zounds' and Sunset's tests included. The
new tests were red with main's tools first. Not covered by any test: the
failed escape giving a special item back, an item with `uses` 0 in battle,
a switch skill cast by an item, and Kazar's list leaving out what his
`actor_set` does not allow on the console (ABL's AG7-17 case covers the
routine). No golden moved.
