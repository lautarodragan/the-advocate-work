---
name: "The party in the shop"
description: "The party's sprites and the 'can equip it' arrows in the shop, like Window_ShopParty"
type: feature
status: doing
assignee: Chajá
agents: [Chajá]
---

From taro, on 2026-09-28, when approving the shop with windows: leave it in the
wishlist.

In RM2k (`Window_ShopParty` in easyrpg), when buying there is a 136 by 48
window at the top right with the party:
- each member's charset, facing front and walking in three frames;
- greyed out, whoever can't equip the selected item;
- next to each one, one of the four arrows from the System (8x8, four
  frames) that says whether the item raises or lowers their parameters, with
  the `CmpEquip` calculation.

The captures of the original are in
`/shared/captures/2026-09-28-tienda/original-comprar-arco.png` and
`original-comprar-chaqueta.png`.

The ROM's shop (`shop-like-the-original.md`, Aguaribay) doesn't
have it: at 256 wide the list runs across and "Owned Items" with the gold
below, so that window has nowhere to go without taking rows away from the
buy list, which already has five. Before implementing it, it has to be
decided where that space comes from.

taro, on 2026-10-15: "maybe we could try to implement it? It would be nice
for ABL too." Where the space comes from is decided by the agent with a
first version, measured against the original's captures; taro adjusts by
playing.
