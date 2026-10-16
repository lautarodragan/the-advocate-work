---
name: "Items past 450 are silently left out"
description: "ITEMS_N is ABL's database size, fixed in the tools: a game with more items loses the ones past 450 without a warning, and Frozen World has 500"
type: bug
status: todo
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

## Checked on 2026-10-16 (Carpintero)

Still open: `ITEMS_N` is 451 in `rm2k-snes/events/src/compile.rs` and
`rm2k-snes/mapdata/src/engine.rs` at the-advocate `759aa0ba`, and the scan
still filters past it in silence. The last paragraph is out of date: since
the linker places all of far RAM (`fb156a3e`, `d121156e`, 2026-10-16;
[`let-the-linker-place-the-far-ram-map`](let-the-linker-place-the-far-ram-map.md)),
the inventory is `far_items: .res ITEMS_N` in `runtime/far_ram_game.s` and
`FAR_ITEM_LIST` a `.res` of its own in `runtime/items.s`, so raising
`ITEMS_N` —or sizing it by the game— moves nothing by hand: what limits it
is the `FARBSS` pool, and `just space` says how much is left.

## Defined (2026-10-16, Carpintero)

Still open (see the check above). **Done**: `ITEMS_N` sized by the game's
database —the inventory a `.res` of that size in `FARBSS`— in both
crates from one place, or, if it does not fit, the items left out named
in `degradations.json`; Frozen World's 451–500 in its cartridge, and a
test that holds the size. **First step**: whether Frozen World's
pages, shops or drops name any item past 450, and how much `FARBSS` room
`just space` gives.
