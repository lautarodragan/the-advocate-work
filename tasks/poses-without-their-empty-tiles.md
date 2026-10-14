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
