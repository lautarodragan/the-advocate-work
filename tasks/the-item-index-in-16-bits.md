---
name: "The item index in 16 bits"
description: "The cartridge's item tables are indexed with a byte, so ABL's whole release leaves out the items past 255 (a TEMPORARY hack in the converter): index them with a word and remove the hack"
type: feature
status: testing
assignee: taro
agents: [Chajá]
---

ABL's whole `release` carries 264 items; the item tables index with one
byte, so the converter leaves out the ones past 255 (411, 413–416,
418–421) and an enemy dropping one drops nothing —both marked TEMPORARY,
in `items_all` of `rm2k-snes/convert/src/convert.rs` and the enemy drop
table of `rm2k-snes/mapdata/src/emit.rs`—. Emily's and Sern's shops on map
321 open empty because of it. See
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).
taro, on 2026-10-14:

> the right fix is 2 bytes

On 2026-10-15, after the identical pages, go.

## Log

Chajá, 2026-10-15, from the-advocate `978c0d25` and the ports `08551c6`:
branches `chaja-items16` in both.

* What holds a `k` in a byte, found by reading the runtime: `item_k`
  itself (byte, $FF none); the items screen's list `FAR_ITEM_LIST`
  ($2A00, a byte per entry), which the equipment screen and the shop's
  selling list share; the shop's buying list `FAR_SHOP` ($2B00, right
  after it); the battle's list `BA_ITEM_LIST`, each actor's chosen item
  `BA_ACC_ITEM` and the message's `BA_MITEM`; the victory's drops
  `BA_DROP_K`; and the routines that pass a `k` in an 8-bit A
  (`item_count`, `item_from_list`, `ti_k_of`, `ba_item_*`…). The per-item
  tables are already in RODATA and indexed with a 16-bit X: they do not
  change, only who indexes them. The inventory, `FAR_ITEMS`, is by RM2k
  number: **the save does not change**.
* Far RAM: `FAR_ITEM_LIST` and `FAR_SHOP` take 256 bytes each, and with
  words each would hold 128. The plan: the items list takes both
  ($2A00–$2BFF, 255 words); the shop's buying list borrows the battle's
  state —`FAR_BATTLE`, as the skills screen already does—, which is not
  alive with a shop open; the battle's list borrows `FAR_ITEM_LIST`, not
  alive in a battle, and the bytes it leaves in `FAR_BATTLE` take the
  chosen items as words.

### Done, Chajá, 2026-10-15

the-advocate `chaja-items16` (`5b757bc7`, main merged in), the ports
`chaja-items16` (`69ec068`, the tests). As planned above, plus:

* The cuts go: `items_all` carries every item, and an enemy dropping one
  the cartridge does not carry stops the build again, as before
  2026-10-14. The emit's cap is now `item_up`, read at 12k in sixteen
  bits: 5461 items.
* `pick_n` is still a byte, so the items screen lists at most 255
  different items, and the equipment list 254 plus the empty line: it
  stops, it does not wrap. RM2k has no cap. The battle's stays at 64.
* **The save does not change**: the inventory is by RM2k number.
* Measured on ABL's `release`: 264 items, bank 0 1001 B free, BSS 18 B
  (the new `item_sel`), far RAM 13 B —nothing new in `FARBSS`—. The
  converter's log and `just culprits` cut no item and no shop.
* ABL's suite with these tools: 1545 green and 2 skipped after fixing
  `test_materials`, which read `item_k` as bytes. No golden moved.
  `just test` 27, `rust-test` green —the mapdata test against the Python
  takes `item_k` back to bytes—.
* Tests, red with main's tools and green with these: Emily's shop on
  map 321 (draw and buy), the items screen naming two, the equipment
  screen listing and putting on 413, and Emily wearing 413 in battle
  against a Junkbot, against the model (case `battle-114-emily-413`).
  **Not covered**: a drop past 255 —no enemy of ABL drops one, so the
  victory's word path runs only with smaller `k`s— and a medicine past
  255 —none is—.

To install when merging: `mapdata` and `convert`; the runtime goes with
the merge.
