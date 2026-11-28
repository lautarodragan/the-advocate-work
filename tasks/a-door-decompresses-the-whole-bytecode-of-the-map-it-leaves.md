---
name: "A door decompresses the whole bytecode of the map it leaves"
description: "When a page goes on after a Teleport —every door—, code_carry_after decompresses all of the left map's bytecode: Desert Nightmare's maps carry ~14 KB each, some two to five frames per door"
type: refactor
status: draft
assignee: taro
agents: [cardon]
author: cardon
links:
  found-in: [maps-load-faster-without-losing-anything]
  relates: [lashe-city-transitions-lag]
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

## Comments

### 2026-11-24, Cardón: a question for taro

Still so at `8b069fc2`: `code_carry_after` (`runtime/decompress.s`)
decompresses the carried map's whole stream with one `lz2_decompress`
whenever `CARRY_MAP` is set, which `code_carry_before` does whenever a
foreground page is active. Measured: 4.8 frames a door in Desert
Nightmare, 0.6-1.6 in Lashe City.

**To decide**: whether it is worth it. (a) The cheap one: not carrying
when the page's next opcode is its end —probably every plain door; not
checked—. (b) A stream per page or per group of pages for big-bytecode
maps: ROM and converter complexity. (c) Leave it.

**Recommendation**: (a) as a todo, measured on Desert Nightmare; (b) only
if (a) leaves doors slow.

## Log

### 2026-10-20, Tijereta: checked

Still so at the-advocate `8f290c39`: `code_carry_after`
(`runtime/decompress.s`) decompresses the carried map's whole stream with
one `lz2_decompress`, and `maps-load-faster-without-losing-anything`
(`testing`) left it as it was. What to do is not decided: the stream is
LZ2 and cannot start at the page's stretch, so it is either a stream per
page or per group of pages for the maps whose bytecode is big, or not
carrying it when the page has nothing left after its `Teleport` —not
checked whether a door's page does, nor whether the runtime already skips
that case—.

### 2026-11-22, Chajá: in Lashe City

Measured in [`lashe-city-transitions-lag`](lashe-city-transitions-lag.md)
at the-advocate `ec672f4c`: `code_carry_after` is 0.6 frames on Lashe's
doors and 1.6 leaving the Lazer Teeth HQ (map 11, 7 KB of bytecode).
Still small next to the load's LZ2.
