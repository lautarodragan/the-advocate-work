---
name: "Vampires Dawn's world grid does not fit in WRAM"
description: "Map 1 of Vampires Dawn, the world (300x300), has a map_cells stream of 147,232 bytes against 64 KB of WRAM, so it is left out; the code half of the problem was solved by putting map code in ROM, the grid was not"
type: feature
status: draft
assignee: taro
author: hornero
agents: [cardon]
links:
  relates: [map-streams-that-dont-fit-in-wram]
---

Left open when taro closed
[`map-streams-that-dont-fit-in-wram`](map-streams-that-dont-fit-in-wram.md)
on 2026-11-16, which moved a map's code to ROM when it does not fit. Its
"Not done: the grid": the grid is read through `ptr_more`/`ptr_minus`
across two WRAM halves, so the same trick does not apply as is.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: whether and how Vampires Dawn's world, map 1 (300x300,
a 147,232-byte grid against 64 KB of WRAM), gets into the cartridge; it is
the biggest of the ten maps the book's page says are missing. The draft
says no way: the grid is read through `ptr_more`/`ptr_minus` across two
WRAM halves.

**Options**: (a) a map's grid read from ROM when it does not fit, with
what changes (tile substitutions) kept apart in WRAM; (b) a window of the
grid streamed into WRAM around the camera; (c) a game patch that splits
the world into maps; (d) leave the world out.

**Recommendation**: (a), designed first —how many reads of the grid assume
WRAM, and whether map 1 substitutes tiles—, since the ROM has room
(ExHiROM) and the console's view does not change. It is a new runtime path
with a cost, so it is yours.

## Log
