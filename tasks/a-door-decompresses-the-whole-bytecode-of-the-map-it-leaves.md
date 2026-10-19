---
name: "A door decompresses the whole bytecode of the map it leaves"
description: "When a page goes on after a Teleport —every door—, code_carry_after decompresses all of the left map's bytecode: Desert Nightmare's maps carry ~14 KB each, some two to five frames per door"
type: refactor
status: draft
---

Seen by Cardón on 2026-10-18, measuring
[`maps-load-faster-without-losing-anything`](maps-load-faster-without-losing-anything.md),
with the-advocate `b066b885`, in snes9x.

**What was seen**: a page that goes on after its `Teleport` keeps running
from the map it left, so `code_carry_after` (`runtime/decompress.s`)
decompresses that map's bytecode stream into `CODE_CARRY` at the end of
the load, all of it, though the page needs only its own stretch. Every door
of RM2k is such a page. The streams, from each game's `map_code` table:

    game                 maps   median     p90      largest
    Desert Nightmare      189   14151 B   14778 B   16076 B
    A Blurred Line        313     238 B     975 B   12175 B
    Zounds                188     120 B     526 B    4451 B

In Desert Nightmare, where the harness's jumps happened to find a page
running, that step was 4.8 frames of every load on average. In ABL it is
negligible except for its few big maps.

**To reproduce**: Desert Nightmare's `just cartridges`, and a door of any of
its maps; the time is the step from `code_carry_after` in
`enter_map_no_events`, with the probe described in that task's log.
