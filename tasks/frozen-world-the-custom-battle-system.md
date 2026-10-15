---
name: "Frozen World: the custom battle system"
description: "Frozen World's combat is made of events on maps 1 and 2, excluded today: which limits of the runtime, the tools and the console it hits, and which creative ways out the events' patterns allow"
type: research
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-10-15: research Frozen World's custom battle system: which
limits it hits —of the current runtime, of the tools, of the console's
hardware—, and look for patterns in the events that allow "creative"
solutions:

* rethinking those events to be more efficient without stopping being
  RM2k, as was done with ABL's stone-throwing minigame
  ([`map-11-redesigned`](map-11-redesigned.md));
* optimising certain event patterns the way a modern C++/Rust compiler
  would: removing code, unrolling loops, etc.;
* building on the idea of optimising commands when compiling and of
  synthetic commands: inventing a kind of IR that RM2k's commands compile
  to; it would cover the 32-bit arithmetic
  ([`frozen-world-hp-percentages-past-327-hp`](frozen-world-hp-percentages-past-327-hp.md)),
  etc.;
* streaming commands from the ROM or the MSU-1 if it came to that —an
  extreme case taro would rather avoid—;
* etc.

What is known: maps 1 ("Battle Screen", ~29,000 commands on 48 events)
and 2 ("Plate Placement", ~12,000 on 51) are the combat; both excluded in
Frozen World's `rm2k-snes.toml` —map 1 because a page makes the hero
flash and actor 11 is drawn with a graphic an NPC also uses; map 2
because a stream of `map_code` is 38,179 bytes and 19,968 fit in WRAM—;
map 1's `CombatController` (1,801 commands) "stops at the page as a
whole"; 324 pages on 72 maps teleport into them. See
`progress/book-of-three-and-frozen-world.md` in the book, and
[`optimise-parallel-events-when-compiling`](optimise-parallel-events-when-compiling.md).

## Log
