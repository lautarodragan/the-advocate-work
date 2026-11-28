---
name: "The equipment screen could keep the slots' tiles under its list"
description: "taro's idea for going back from the list: the slots' rows kept in VRAM while the list is up, so they come back without typesetting; VRAM has room, far RAM and bank 1 barely"
type: feature
status: draft
assignee: taro
author: taro
agents: [Calandria, cardon]
links:
  found-in: [abl-the-equip-screen-s-cursor-runs-ahead-of-its-lists]
---

Measured by Calandria on 2026-11-17, in A Blurred Line, with the-advocate
at `7178ceee` (branch `calandria-equip-lag`) and the ports at `8042dc8`,
while doing [the equipment screen's lag](abl-the-equip-screen-s-cursor-runs-ahead-of-its-lists.md).

taro's idea there: if VRAM allows, do not overwrite the slots' list with the
item list, so going back does not rebuild it. Going back from the armour
list is the slowest transition left, 10 frames from the press, and five of
the eleven rows it changes are the slots', some 3 frames of letters.

What was measured:

* **VRAM has room.** The equipment screen's pool had 244 to 323 pairs free
  in every transition, of the 447; the five slot rows take some 36.
* **The bookkeeping is RAM.** The text layer finds a row's tiles to reuse
  by comparing records —what a row says, 56 bytes— against what other rows
  show; rows kept off screen need their record and their 32 tilemap words
  kept somewhere: 120 bytes a row, 600 for the five —320 without the
  records, if the screen vouches for what they say—. `release` had 565
  bytes of far RAM free, and bank 1, where the layer's code is, 963 bytes,
  390 in `test-msu`.
* `LZ2_BUFFER` is free while a pause screen is up —the debug screen's wide
  stage lives there—, but a big picture keeps its tilemap there while it is
  shown, and whether `back_to_map` restores it after the menu was not
  looked at.

## Comments

### 2026-11-24, Cardón: a question for taro

Your idea, measured: going back from the
armour list could save some 3 of its 10 frames, at 320 to 600 bytes of far
RAM (565 free in `release` that day) and code in bank 1 (390 B free in
`test-msu`). A cost to choose:

* **a)** do it, and pay the RAM and bank 1;
* **b)** `wishlist`, until RAM or bank 1 has room to spare;
* **c)** cancel: [the lag
  task](abl-the-equip-screen-s-cursor-runs-ahead-of-its-lists.md) was
  closed by you, playing, on 2026-11-17.

Recommendation: **b**.

## Log
