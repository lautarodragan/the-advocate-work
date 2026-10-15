---
name: "Items past 450 are silently left out"
description: "ITEMS_N is ABL's database size, fixed in the tools: a game with more items loses the ones past 450 without a warning, and Frozen World has 500"
type: bug
status: draft
agents: [Chajá]
---

Seen by Chajá on 2026-10-15, reading the tools at the-advocate `5b757bc7`
while doing [`the-item-index-in-16-bits`](the-item-index-in-16-bits.md);
not played.

`ITEMS_N` —the inventory's size, one byte per RM2k number in `FAR_ITEMS`,
and the length of `item_k`— is a constant, 451, "measured against A
Blurred Line" (`rm2k-snes/mapdata/src/engine.rs`, and its twin in
`rm2k-snes/events/src/compile.rs`). The converter's scan filters out every
item at or past it (`possible_items` and `drop_items` in
`rm2k-snes/convert/src/scan.rs`) and nothing says so: a shop, a
`ChangeItems` or a drop of one of them is lost in silence.

Measured on the dumps in the ports: Frozen World's database goes up to
item 500, so its items 451–500 are left out. The other ports are at or
below 250, ABL at 450.

The runtime places `FAR_ITEM_LIST` right after the inventory, at $2A00,
and asserts that the inventory does not reach it: `ITEMS_N` up to 512
fits as it is; more needs the inventory moved.
