---
name: "Sunset's towns: part of a crowd waits for a slot"
description: "On Sunset Over Imdahl's busiest painted maps more events can be on screen than the cache of slots holds, even with no still event animating, so the last drawn appear late"
type: bug
status: draft
---

Seen by Calandria on 2026-10-17, with the-advocate `eb16d48b` (branch
`calandria-rain-and-slots`) and the ports `14001eb`, measuring
[`rain-drops-cost-a-cache-its-slots`](rain-drops-cost-a-cache-its-slots.md).
Read from `degradations.json` and `wally map`, not played.

**What it is**: Sunset Over Imdahl's maps go painted, and the painted
layout leaves 256 sprite tiles, 16 blocks of 32x32. On maps with battle
animations the box takes four of them, and the hero and the turn one or
two more, so the cache gets about ten slots. By where they start, more
events than that can be on screen at once, and the ones `build_oam`
reaches last wait until someone leaves the screen —they appear late—:

| Map | Cache | At once by where they start |
|---|---|---|
| 3 | 9 | 18 |
| 4 | 10 | 21 |
| 12 | 9 | 15 |
| 56 | 14 | 19 |
| 58 | 10 | 36 |

It is so with no still event animating, and with no rain the cache would
have one slot more on each, not enough on any. "At once" counts every
event where it starts, including the ones whose page draws nothing at
load, so on screen it may be fewer.

What was looked at: the painted layout leaves $4E00-$4FFF free, 32 tiles
that OBJ's second name table reaches with name select 3: room for the
timer and the drops outside the bank, one slot. The battle animation's box
is the big one: four blocks that only an animation on the map uses.

**How to see it**: `events-wait-for-a-slot` in
`sunset-over-imdahl/build/release/degradations.json`; in the game,
maps 3 and 58 when they are full.
