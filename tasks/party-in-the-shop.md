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

## Chajá, 2026-10-15

Started from the-advocate `91d55d39` and the-advocate-ports `8a9ab73`, on
branches `chaja-shop-party`.

### The original, again

The 2026-09-28 captures are gone; new ones under Wine, from a copy of the
game whose map 4 opens a type-0 shop at once with Talan, Arden, Kersh and
Emily in the party and the knife, the pipe, the leather jacket, the hard
boots and the +5 gloves (96, 92, 111, 113, 413). Between the five every
case shows: greyed out, "E" (Arden and her knife), up, down (Kersh's
trenchcoat against the jacket) and the dot (Emily's sweater against the
jacket). Measured on them: the window is RM2k's 136x48 at (184, 32), each
member at (+4 + 32i, +4) and the arrow at (+20, +24) of its member, which
is easyrpg's `Window_ShopParty`.

### Where the space comes from

Three mockups, cut and pasted from `shop-buy-2` and the original:

* **a**, chosen: the status band keeps its height; "Owned Items" and
  "Equipped Items" narrow to 120 and the party takes RM2k's 136 on the
  right, where the gold was. The gold goes to the right end of the
  message window, which in every mode that shows the party is one short
  line ("What do you want to buy?", "How Many", "Done").
* **b**: the list loses a row (four) for a band with the party; the
  message window grows to 48 to hold the gold.
* **c**: the 152-wide counts stay and the party is squeezed into the
  gold's 104, 24 apart, so each arrow falls on the next member.

Why **a**: the list keeps its five rows, which is what the 2026-09-28
layout fought for; the party window is RM2k's, pixel for pixel, so what
the original draws there is what the ROM draws; and the only thing that
moves is the gold, to a window that had room on its right. What it costs:
a game whose buy messages are long could run into the gold, and terms
longer than ABL's "Equipped Items" have 120 instead of 152. The converter
checks both, and says it as a degradation.

### How it is built

* **The stage** (`rm2k-snes-screens`): `party.rs` converts each possible
  member's CharSet —the database's— into its three front frames, twelve
  8x8 tiles each, with its fifteen colours and their grey (the luminance,
  `saturation_tone` at gray 0), and the System's sixteen arrows; it is also
  the rule (`shown`: `IsItemUsable`, "already on", and `CmpEquip` with
  `equip`'s two-hand rule) and the reference drawing, which `render`'s
  `shop` gets with `party`, `frames` and `phase`. The layout is `TI_PARTY_*`
  in `layout.rs`: the counts' window is 0..120 and the party's 120..256, and
  the gold is on the message's line.
* **The emission** (`rm2k-snes-mapdata`): `ti_party_tiles_<k>` behind
  `ti_party_ptr`, `ti_party_cgram` (colour and grey, 64 bytes a graphic),
  `ti_party_k` (actor -> graphic), the arrows, and the constants. Two
  actors with the same CharSet share it: ABL's 33 possible members are 19
  graphics, some 23.7 KB.
* **The runtime** (`runtime/shop_party.s`): objects 8x8 from the windows'
  base (`OBSEL` 2, `$4000`), the members' tiles right after the windows'
  and the arrows after them, all in what `load_map` restores. The OAM is
  written once at opening; per frame only the four arrows' entries change,
  the grey is the member's palette swapped, and a new walking frame is a
  384-byte DMA into the member's slot. All of it goes **between the text's
  uploads and its typesetting, and only while the scanline leaves room**
  (`room`): the windows and the text can take the vblank almost whole.
  `CmpEquip` borrows the equipment screen's `eq_parameter`, saving the
  shop's `comp_*` around it, and only runs when the item or the layer
  changes. Bank 1 had no room: `ti_party_compute` is in `FAR` and the rest
  in `FAR2`, with `jsl`.
* Found on the way: the shop opened right after a message has the objects'
  window mask (`WOBJSEL`) as the message window's HDMA left it, on, and
  `TMW` always applies it: every object was hidden. `ti_party_open` clears
  it.
* Degrades, not blocks: a member whose CharSet the game lacks leaves its
  place empty (`shop-party-missing`); a System whose windows fill the bank
  leaves no room and the shop has no party (`shop-party-no-room`, with
  `TI_PARTY_ON` 0); a buy message that runs into the gold, or a count's term
  wider than its window, is `shop-crowded`. ABL has none of the three.
