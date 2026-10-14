---
name: "The emitter stores identical data once"
description: "Identical samples are stored once per key, and identical actor tables once per map: storing each once saves about 418 KB of ABL's whole game, with no loss"
type: refactor
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Two of the lossless savings measured in
[`research/2026-10-14-fitting-the-whole-game-in-8-mb`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-fitting-the-whole-game-in-8-mb.html)
for [`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md);
taro said go on 2026-10-14:

* **Samples**: 17 groups with the same BRR, rate and loop, stored once per
  key: about 205 KB. Includes the draft
  [`identical-samples-are-stored-once-per-key`](identical-samples-are-stored-once-per-key.md)
  —and whether they also take ARAM twice—.
* **`actor_table_`**: 22 distinct tables repeated over 307 maps, shared
  whole: about 213 KB.

The third, the NPCs' poses shared whole, goes with the poses' new format in
[`poses-without-their-empty-tiles`](poses-without-their-empty-tiles.md),
which touches the same data.

## Log
