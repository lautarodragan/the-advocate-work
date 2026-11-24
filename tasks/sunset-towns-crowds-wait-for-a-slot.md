---
name: "Sunset's towns: part of a crowd waits for a slot"
description: "On Sunset Over Imdahl's busiest painted maps more events can be on screen than the cache of slots holds, even with no still event animating, so the last drawn appear late"
type: bug
status: draft
assignee: taro
author: calandria
agents: [cardon]
links:
  found-in: [rain-drops-cost-a-cache-its-slots]
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

## Log

### 2026-11-24, Cardón: a question for taro

Still so: the ports' Sunset
`build/release/degradations.json` of 2026-11-24 says `events-wait-for-a-slot`
on maps 3, 4, 12, 47, 56 and 58 (58: 36 at once, 10 slots). What to decide
is how much of Sunset's towns is worth paying for, and it is the game's:

* **a)** `baked_events` on those maps, as Frozen World's map 128 did: the
  still crowd goes into the background. Those events already stand still
  here (`still-animation-dropped` on 3 and 12), so little is lost; it costs
  background tiles, which a painted map may not have.
* **b)** engine work for every game: the battle animation's four blocks only
  while an animation plays, or OBJ's second name table at $4E00 for the
  timer and drops —one slot each—. Neither reaches 36.
* **c)** leave it, as a Known issue (it is already one).

Recommendation: **a**, tried map by map, and **c** for whatever does not fit.
