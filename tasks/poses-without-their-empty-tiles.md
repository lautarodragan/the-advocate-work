---
name: "Poses without their empty tiles"
description: "52% of the poses' tiles are empty: storing each pose without them, and the NPCs' poses shared whole, saves about 610 KB of ABL's whole game, with no loss, at the cost of a slightly heavier worst step in vblank"
type: refactor
status: doing
assignee: Calandria
agents: [Calandria]
---

Lossless savings measured in
[`research/2026-10-14-fitting-the-whole-game-in-8-mb`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-fitting-the-whole-game-in-8-mb.html)
for [`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md);
taro said go on 2026-10-14:

* **Poses without their empty tiles**: about 571 KB. A walking step
  uploads 240 B on average against 512 today; the worst step, +14% of the
  vblank (modelled, not measured: it is measured in the emulator before
  merging).
* **`npc_poses_` shared whole**: about 41 KB, with an index in the
  runtime.

## Log

### 2026-10-14, Calandria: the design

From the-advocate `1b4ff5ea`, the ports `9e47100`, the book `beed835`;
branches `calandria-empty-tiles` in the three.

* **The record**: a 16-bit mask —bit *i* is tile *i* of the 4x4, by
  rows— and behind it only the tiles that draw something, in order. It is
  built in the emitter (`record::poses`), from Wally's 512 bytes as they
  are: Wally does not change.
* **The empty tiles are zeroed by the slot, not skipped by the OAM.** A
  32x32 object reads its sixteen tiles whatever they hold, and splitting
  it into smaller objects is what the decision ruled out (128 OAM entries).
  Pre-clearing once per slot is not enough either: a tile drawn in one
  pose and empty in the next keeps the old one. So each slot remembers
  which of its tiles may hold something —a 16-bit mask per 32x32 block,
  32 of them, in far RAM— and the drain zeroes only those that go from
  drawn to empty, with a fixed-source DMA on channel 7. `load_sprite`
  sets all 32 to "anything", since the bank it uploads brings whatever
  the converter put there.
* **The drain, without new state in the queue**: the entry is still
  source and destination, so the hero-first rule is untouched. The mask
  is read from the source with the data bank pointed at it; the slot,
  from the destination (`block_tile`'s layout). Each row's runs come from
  a 16-entry table of nibbles —at most two runs per four tiles—, and the
  DMA source is not reprogrammed between runs: the A-bus address goes on
  advancing by itself, and the drawn tiles are stored contiguous.
* **`npc_poses_` shared whole**: stored once by its text, under the label
  of the first map that brings it; the record already carries a 24-bit
  pointer, so the runtime needs no index.
