---
name: "A door that shows the screen after its jump still carries the map's bytecode"
description: "Desert Nightmare's doors are EraseScreen, a sound, Wait, Teleport, ShowScreen: the page goes on after the jump, so the whole bytecode of the map left is still decompressed on every door"
type: refactor
status: draft
assignee: taro
agents: [cardon]
author: cardon
links:
  found-in: [a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves]
---

Seen by Cardón on 2026-11-28, with the-advocate `cardon-doors` (`7a4faa29`,
on `b4654a3a`), counting each game's dump and measuring in snes9x.

**What was seen**: [`a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves`](a-door-decompresses-the-whole-bytecode-of-the-map-it-leaves.md)
stopped carrying a page whose next opcode after the `Teleport` is its end.
Desert Nightmare's doors are not such pages: 345 of its 363 plain doors
—one page, no condition, a touch or action trigger— are `EraseScreen`, a
sound, `Wait`, `Teleport`, `ShowScreen`. The `ShowScreen` runs after the
load, from the carried bytecode, so `code_carry_after` still decompresses
the whole stream of the map left —~14 KB in each of that game's maps— on
every door. Zounds' doors are the same shape (568 of its 718 foreground
`Teleport`s are followed by `ShowScreen`), with small streams.

**To reproduce**: Desert Nightmare's `just cartridges release`, walk into
any door —map 4's event 183, at (21, 9)— and read `CARRY_MAP` after the
fade: the map left, not `$FFFF`.

## Comments

### 2026-11-28, Cardón: a question for taro

**To decide**: whether Desert Nightmare's doors are worth more work.

* (a) **Carry only the page's tail.** The compiler knows, for each
  `Teleport`, how many bytes the page has after it and whether any jump
  from there lands before it. It would give that to the runtime —an
  operand of the `Teleport`, or a second opcode for "a short tail that
  only jumps forward"—, and `code_carry_before`, with the old map still
  loaded, would copy those few bytes to a small buffer, as it already does
  with the hero's route (`ROUTE_CARRY`). A `ShowScreen` and its end are
  three bytes. Cost: one byte per `Teleport` in ROM or one opcode, and a
  buffer of a few dozen bytes of far RAM.
* (b) **A stream per page or per group of pages** for maps with big
  bytecode, which the first task's question already listed: ROM and
  converter complexity, and it still decompresses something.
* (c) **Leave it**: a few frames inside a door's black, on one game.

**Recommendation**: (a), measured on Desert Nightmare's doors; it covers
the `TintScreen` and `PlayBGM` doors of A Blurred Line too.

## Log

### 2026-11-28, Cardón: found

Counted while doing the first task's (a): see its log for the table of
every game's `Teleport`s and what follows each, and the frames measured.
