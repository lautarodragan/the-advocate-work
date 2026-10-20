---
name: "An item with several uses is spent whole"
description: "An item whose `uses` is above 1 —The Book of Three's bags of five— goes on the first use, in battle and on the map: RM2k counts its uses in the save"
type: bug
status: todo
agents: [Tijereta]
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
