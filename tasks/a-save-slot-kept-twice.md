---
name: "A save slot kept twice"
description: "Each save slot written in two copies, so a torn save —a power cut in the middle of writing it— falls back on the other one instead of losing the slot"
type: feature
status: wishlist
author: taro
links:
  relates: [a-torn-save-slot-shows-and-loads-a-new-game]
---

The third step of [`a-torn-save-slot-shows-and-loads-a-new-game`](a-torn-save-slot-shows-and-loads-a-new-game.md),
which keeps the first two —a CRC-16 per slot, and a slot whose sum fails
shown as damaged—.

> Let's go with the recommendation, with save doubling as a new wishlist
> task.

(taro, 2026-11-28)

**What it costs**, from Cardón's reading in that task: a new SRAM layout,
twice the room per slot, so saves from before it stop loading. Worth it
if a torn save is ever seen.

## Log

### 2026-11-28, Hornero: written

Nothing done yet.
