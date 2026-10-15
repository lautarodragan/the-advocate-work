---
name: "ChangeItems and ChangeMonsterHP by a variable"
description: "ChangeItems with the item or the amount in a variable, and ChangeMonsterHP with the damage in a variable, do not compile: Book of Three 54 and 52 uses (Eilonwy's Absorb Essence, Taran's Last Stand, six essence pages on the maps), Vampires Dawn 81"
type: feature
status: testing
assignee: taro
agents: [Chajá]
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)).

**What is seen** (not played):

* **Eilonwy's Absorb Essence** (switch `AbsorbEssenceON`, 270): a page in 48
  troops adds `AmountAbsorbed` (variable 24) Essences of Fire, Water or
  Thunder to the inventory. The page does not compile, so the command does
  nothing. The same `ChangeItems` is on six map pages (maps 31, 42, 46, 52,
  86 and 87) where the player gathers essences.
* **Taran's Last Stand** (`LastStandON`, 96): a page in 52 troops subtracts
  `LastStandRandom` (variable 6) from the enemies' HP. The page also uses
  `ShowBattleAnimationB`
  ([`show-battle-animation-b-in-troop-pages`](show-battle-animation-b-in-troop-pages.md)),
  so both are needed.

**Where it stops**: `CHANGE_ITEMS` in `compile.rs` refuses the item or the
amount "from a variable" (`q(1) != 0 || q(3) != 0`): `OP_ITEM` carries a
constant item and a signed byte. `CHANGE_MONSTER_HP | CHANGE_MONSTER_MP`
refuses `q(2) != 0` (the amount from a variable; the percentage is not an
option of the command) because `OP_ENEMY` carries a signed word.

**Uses in the eight dumps**: `ChangeItems` by a variable, Book of Three 54,
Vampires Dawn 81; `ChangeMonsterHP` by a variable, Book of Three 52, no
other game.

## Chajá, 2026-10-14

From the-advocate `51f05d7c` and the ports `5272c1e`, on branches
`chaja-by-variable` in both.

**No table was needed for the item.** The inventory is one byte per LDB
item in far RAM, indexed by the RM2k number (`FAR_ITEMS`, `ITEMS_N`
entries): a number read at run time indexes it as the constant one does.
`item_k` —the cartridge's subset, for the menus— is not touched: an item
the cartridge does not show still counts, as with the constant
`ChangeItems`.

* **`ChangeItems` by a variable** is a new opcode, `OP_ITEM_VAR` (0x4F):
  `how` (subtracts, item by variable, amount by variable), item and amount
  as words. Its bank 0 entry is a `jsl` and `jmp` (7 bytes); the work is
  `item_by_variable`, in the new `runtime/items_by_variable.s`, in `FAR2`.
  As `CommandChangeItems`: a value below zero does nothing, an item out of
  `[1, ITEMS_N)` neither, the count stays in `[0, ITEM_MAX]`, and it asks
  for the refresh. The constant one is still `OP_ITEM`, byte for byte.
* **`ChangeMonsterHP` and `ChangeMonsterMP` by a variable** go in
  `OP_ENEMY`, with two more bits in `what`: `ENEMY_BY_VARIABLE` ($20, the
  amount is the slot) and `ENEMY_SUBTRACTS` ($40). `ba_enemy_change` reads
  the variable. And a gain whose sum passes $7FFF went down as a loss
  —`bmi down`—: now it goes to the maximum (`bvs`), for the constant too.
  The HP's percentage (`[2]` = 2) still does not compile.
* **The variable sweep** (`command_variables`, indices.rs) names the
  variables of both commands, so one only they name gets its slot.

**Measured** with `just culprits`, before (the tools of `51f05d7c`) and
after:

* Book of Three: maps 1,275 → 1,281 of 1,282 pages compile, troops 499 →
  599 of 746. `ChangeItems` and `ChangeMonsterHP` are no longer culprits;
  what is left in the troops is Tijereta's `ControlVars` multiply (52,
  Cash Reward).
* Vampires Dawn: `ChangeItems` is no longer a culprit (81 uses), but no
  page more compiles: all of them had another culprit too.
* Bank 0: 9 bytes less on every cartridge of ABL (`just space`: the
  `jsl`/`jmp` and the dispatch entry).

**Tests**: `tests/test_book_of_three_by_a_variable.py` in the ports, with
three cases in `book-of-three/cases/` —the Last Stand on troop 110 (a
Burrboar, 150 HP: 50 to 100 off) and on troop 85 (Denner, 15 HP: left at
1), and the `ChangeItems` by a variable (amount, item, a value below zero,
the cap)—. Red with `51f05d7c`: the Last Stand page never ran, and the
items case did not compile, which stopped the cartridge. Two unit tests in
`compile.rs`. Green: `just test` 27, `just rust-test`, ABL `just tests`
1527 (2 skipped, no golden moved), `just boot` 20 (17 + 3).

**Not covered by the suite**: the six map pages of the essences and
Absorb Essence's troop page as the game runs them (the case runs the same
commands, not those pages), `ChangeMonsterMP` by a variable (no game uses
it), the `bvs` cap of a gain past $7FFF, and an item by a variable out of
the inventory.

**When merging**: reinstall `events`, `convert` and `cartridge` (the
bytecode declaration changed, and `rm2k-snes-assemble` writes the
opcodes). Opcode used: 0x4F, `OP_ITEM_VAR`. Functions touched: the
`CHANGE_ITEMS` and `CHANGE_MONSTER_HP | CHANGE_MONSTER_MP` arms of
`compile.rs`, `command_variables` in `indices.rs`, `ba_enemy_change` in
`runtime/battle_troop.s`; new `op_item_var` (end of
`interpreter_gold_and_items.s`) and `item_by_variable`
(`runtime/items_by_variable.s`, included right before `header.s`).

**Found and not fixed**: `ChangeGold` by a variable is not in
`command_variables` either; draft
[`changegold-by-a-variable-names-no-slot`](changegold-by-a-variable-names-no-slot.md).
