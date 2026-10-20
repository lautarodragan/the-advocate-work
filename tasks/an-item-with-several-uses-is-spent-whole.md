---
name: "An item with several uses is spent whole"
description: "An item whose `uses` is above 1 —The Book of Three's bags of five— goes on the first use, in battle and on the map: RM2k counts its uses in the save"
type: bug
status: testing
assignee: taro
agents: [Tijereta, Aguará]
---

Seen by Tijereta on 2026-10-19, on the-advocate `54ec3daf`, while making
special items cast their skill in battle
([`special-items-cast-their-skill-in-battle`](special-items-cast-their-skill-in-battle.md)).

The Book of Three's BagOfVolatileShells and PouchOfPebbles (items 123 and
124, special, `uses` 5) and Sleeping Powder (103, `uses` 2): RPG_RT spends
one of them every `uses` uses —easyrpg's `Game_Party::ConsumeItemUse`,
with the count in the save's `item_usage`—. The cartridge only knows
whether an item has uses at all (`MED_USES` in `item_medicine`, the `2` of
`item_use`): `ba_item_consume` in `runtime/battle_items.s` and the menu's
`medicine_use` take one off on every use, so a bag of five is a single
shell. One with `uses` 0 is never spent, on both sides, since 2026-10-19.

To see it: give The Book of Three's party a BagOfVolatileShells and throw
it in a battle: it is gone after the first.

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39`: still so. `MED_USES`
(`runtime/far_ram.s`) is a flag, "it has uses: using it spends one", and
the three that read it —`battle_items.s`, `battle_run.s` and
`medicine.s`— take one item off on every use. **Done**: an item with
`uses` above 1 is spent every `uses` uses, with the count per item kept
in the save as RPG_RT's `item_usage` (`Game_Party::ConsumeItemUse`), in
battle and on the map; The Book of Three's BagOfVolatileShells throws
five shells; a test that uses one twice and still has it. **First step**:
how the converter emits `uses` today (only whether it is zero), and where
a byte per item fits in the save.

## Doing (2026-10-20, Aguará)

From the-advocate `3bc68ac4` and the ports `3cd810d`, branches
`aguara-item-uses` in both.

What RM2k does, read in easyrpg (`game_party.cpp`): `ConsumeItemUse`
returns for the normal items and the equipment and for `uses` 0; for the
rest it counts `item_usage[idx]++` and, when it reaches `uses`, takes one
off the count and puts the usage back at zero. `AddItem` with an amount
below zero —`RemoveItem`, `ChangeItems` taking away, selling— puts it back
at zero too; adding does not. **The menu shows only the count**:
`Window_Item::DrawItem` writes `GetItemCount` and nothing of the uses, so
nothing changes on screen.

The first step's answers: the converter emitted only whether `uses` was
zero —bit 2 of `item_use` and `MED_USES` of `item_medicine`—, and the
three readers took one off on every use. The save has room to spare: a
slot is a whole 8 KB bank.

What it became:

* the converter emits `item_uses`, a byte per `k`: `uses`, or 0 for the
  normal items and the equipment. The two flag bits are gone, with their
  readers;
* `FAR_ITEM_USAGE`, a byte per LDB number right after `FAR_ITEMS`,
  cleared with it and in the save after it —**the save format changes**:
  older saves read as "no saved game"—;
* `item_spend` (`ConsumeItemUse`) and `item_unspend` in `medicine.s`, with
  `jsl`: the menu's medicines and switch items, the battle's choice and
  the failed escape's give-back call them;
* the usage goes back to zero where an item is taken away: `op_item`,
  `item_by_variable` and `eq_inv_move` (selling).

Tests: The Book of Three's `test_book_of_three_item_uses.py` —the bag
thrown five times by two actors, red before ("the bag is gone after 1
throws of its 5"), and a failed escape that gives the throw back— and
ABL's `rpgmaker/test_item_uses.py`, on a copy of the ROM with the Agility
Pill at three uses: three uses from the menu, and the count in the save.

## Done (2026-10-20, Aguará)

Branches `aguara-item-uses`: the-advocate `58064b7f` (the change and
mapdata's Python comparison, which with `item_uses` taken out and the two
bits rebuilt gives the same two digests as before: the emission changed in
nothing else), the ports `de61e95` (the tests, ABL's index, main merged)
and the book `9f2f077` (the divergence "What items in battle do not
model": the bullet of the items of several uses goes, with its link here).

Run, with the branch's tools first in the PATH: ABL's suite, 1579 passed
and one red that was this branch's —`test_index.py`, the new test missing
from the README, fixed and run again—; no golden moved. The ports' `just
boot`, 102 passed. The test game, 51 passed (with a free SoundFont,
FluidR3). `just test`, `just rust-test` and `just lint`, green.

`just space`, before → after, every cartridge of every game: bank 0
**+26 B** everywhere (the switch item's spending left bank 0 for
`item_spend`; the tightest are now Sunset 51, Vampires Dawn 71 and ABL's
test-change-system 79), bank 1 **−90 B** everywhere (`item_spend`,
`item_unspend` and `item_number`; the tightest, Vampires Dawn at 235 and
ABL's test-msu at 258), `$C0` +48 and `$C1` −15, far RAM **−449 B** (the
451 of `FAR_ITEM_USAGE`, less `MED_ID`, which went; the tightest, Vampires
Dawn at 1706 and ABL's release at 1345).

**Saves break**: the save is `ITEMS_N` bytes longer, so a slot saved
before reads as "no saved game".

What no test covers: `ChangeItems` taking items away and selling one
putting the count at zero —`op_item`, `item_by_variable`, `eq_inv_move`—;
no game takes away an item with uses counted, and the ABL suite only sees
those paths with items of one use, where the count is always zero. Nor
the switch items of several uses, which no game has.

To install when merging: `mapdata` (the emission, `rm2k-snes-mapdata`),
and the runtime goes in with the checkout the tools are installed from.
`project`, `cartridge` and `convert` were installed locally only to point
at this worktree's runtime: their code did not change.
