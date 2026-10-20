---
name: "ABL: the limits it is close to"
description: "With the whole game in release, which hard limits of the tools and the runtime —one-byte indices, tables with a cap, segments and banks— ABL is at or close to, measured"
type: research
status: done
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-14, after the whole game reached main with the items cut
at 255:

> Let's keep the forced 1-byte limit for now. Let's measure what other
> limitations like that ABL has.

## Log

### Cardón, 2026-10-14: measured

Nothing built or changed: read from the whole-game `release`'s
`converter.log`, `mapdata.inc`, `memory.cfg` and `just space`, against every
cap in `rm2k-snes/{mapdata,events,screens,battle,wally,cartridge}`. The
page, with 35 limits sorted by value over limit, the degradations counted by
kind and a one-line fix for the top ones, is in the book:
`src/ports/abl/research/2026-10-14-the-limits-abl-is-close-to.md`
(the-advocate-docs, branch `cardon-limits`).

Already **over**: route slots (75 events sent walking in map 285 against 12),
the item text's tile pairs (202 of 184), the event cache of map 127 (33 of
30), items (264 of 255, the hack), background tiles of maps 148 and 250
(544 of 543, fused). **Full** (nothing left): sprite slots, tiles and
palettes of the busiest maps, CGRAM in 29 maps, the slot screen's composed
names (48 of 48), the message pairs (158 of 158), the route graphics table
(8 of 8). Memory: direct page 3 B left, program RAM 20 B, far RAM 13 B, bank 0
1,324 B, 121 of 127 data banks. Not measured: the LZ2 caps, pictures per
map, switches named by commands.
