---
name: "Frozen World: the custom battle system"
description: "Frozen World's combat is made of events on maps 1 and 2, excluded today: which limits of the runtime, the tools and the console it hits, and which creative ways out the events' patterns allow"
type: research
status: testing
assignee: taro
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

### Carpintero, 2026-10-15

Started from the-advocate `497be031`, the ports `0ddf815`, the book
`6ae64a9`. Read maps 1, 2, 3 and 14 and the common events they call;
built a throwaway `release` with maps 1 and 2 put back, in a worktree of
the ports (`just cartridges release` stops at map 1's flash, after leaving
the compiler's request), and ran `just culprits` and `rm2k-snes-events
compile` on it. Two measuring switches in a local build of the compiler,
never installed and not committed: `CallEvent` as a three-byte call instead
of a paste, and `ChangeActorFace` as nothing plus switches up to 2,047.

**The research**: [Frozen World's battle system](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-15-frozen-worlds-battle-system.html),
`src/research/2026-10-15-frozen-worlds-battle-system.md` in the book.

**In short**:

* The combat is a menu walked as maps (1 battle screen, 3 command grid, 14
  items, 2 plate placement), made of action pages called as subroutines.
  Per frame: two parallel pages on map 1 (`BackdropSetter`, 113 switch
  tests and a `ChangePBG`, ~100 of 262 lines estimated; event 29,
  `CalculateHPPercents`, whose writes ask for a refresh of all of map 1's
  pages every frame) and one on map 2.
* **What keeps map 1 out**: `CallEvent` to a map event is pasted, four
  levels deep: map 1 is **3,993,422 bytes** of bytecode, and
  `CombatController` page 6 "stops at the page as a whole" because pasted
  it passes 64 KB, the reach of an absolute 16-bit jump (the chase names
  195 `EndBranch` and 194 `ElseBranch`). With calls as calls: **90,339**,
  **69,227** with identical pages once; page 6 at 5,177 bytes. Whole game:
  4.17 MB → 243 KB. A Blurred Line: 161 → 154 KB (map 11, 10.5 → 3.4 KB).
* **WRAM**: 19,968 bytes for a map's code; map 2 needs 38,185, map 1 even
  with calls 69 KB. Frozen World's `release` has 54 free banks: the big
  maps' code goes in the cartridge, uncompressed (~110 KB). No MSU-1.
* Small ones behind: switches up to 1,077 (1,051 named), `ChangeActorFace`
  (9 on map 1), the converter's flash check (a false positive: added to
  `flashing-hero-shares-a-palette-with-an-npc`), chains of six calls
  (`CALL_MAX` 4 drops past four silently, the stack has 3 levels), the HP
  percentages (= the HP meters on the battle screen).
* Fidelity: `ChangePBG`'s picture is ignored (17 backdrops), 55 graphics
  on map 1 for 8 palettes, map 2's plates through a route-graphic table of
  8 (20 changes ignored).
* Compiler optimisations measured: empty `else` (6,752 of 7,773 on the
  maps, 3 bytes and a jump each), parallel pages run when what they read
  changes, refresh only on change, multiply-then-divide fused (3 of 3 in
  the game); constant folding (1 branch in the game), unrolling (2 loops)
  and inlining gain nothing.
* Recommended: calls as calls, identical pages once, big maps' code in the
  cartridge and the five small ones; then fidelity; then the IR, starting
  with labels instead of offsets.

**Not done**: no fight was run, since the maps are not in the cartridge;
the interpreter's cost per operation is counted by hand, not measured; the
refresh's cost on map 1 was not measured. No code merged.

**Branches**: `carpintero-fw-battle` in the book (the research). Nothing
to install when merging.
