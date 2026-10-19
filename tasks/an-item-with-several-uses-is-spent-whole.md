---
name: "An item with several uses is spent whole"
description: "An item whose `uses` is above 1 —The Book of Three's bags of five— goes on the first use, in battle and on the map: RM2k counts its uses in the save"
type: bug
status: draft
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
