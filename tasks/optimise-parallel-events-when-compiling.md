---
name: "Optimise parallel events when compiling"
description: "Detect patterns in the parallel pages and generate something cheaper: run less often, or only when something moves"
type: refactor
status: wishlist
---

taro's idea, on 2026-09-26, from what the chips investigation measured
(`expansion-chips-sa-1-and-s-dd1.md`): on map 11 the 13 parallel pages
without a wait eat ~123 of the frame's 262 lines, and almost all of them
compare coordinates. *"It is completely normal for compilers to
optimise code"*: the converter already is a compiler from RM2k to bytecode.

Ideas, from the cheapest to the most ambitious:

1. **Run the parallel ones every N frames** instead of every frame. It was tried
   on 2026-09-26 (`PARALELOS_CADA`, in `ef59e199`) and discarded on
   2026-09-30 without merging; the branch was deleted. What it measured:
   - on map 11 the average cost of the parallel ones went down from 125 lines
     per pass to 36 (N = 60), but **the worst frame didn't go down** (~344),
     because on the pass when they're due the 13 pages run together: to lower
     the peak they have to be spread across passes, not spaced out;
   - on the terrace the cost wasn't the parallel ones but the recomputation of
     the flashes' palettes, and on map 8 there was nothing to gain;
   - the reaction of "me atraparon" went from 62 frames to 65-69 with N = 4 and
     to 149-160 with N = 60; with N = 4, 7 cases of the suite failed,
     animations of parallel events with Wait in another phase and two of the stones;
   - the 50 % lag taro feels on map 11 wasn't reproduced in
     any emulator: his exact path is needed.
2. **A synthetic "on move" trigger**: besides "parallel", pages
   that run only when an event (or the hero) **changes cell** —not
   pixel—. The code that moves an event makes a call that walks over the
   pages with that trigger. The converter detects which parallel ones are
   "compare coordinates and do something" and compiles them that way. And at build time
   it is known whether a map has any: one boolean per map, so the runtime pays
   nothing on maps without them.
   - The case of the lights on map 11 is the first.
   - The second: **the parallel event that turns saving in the menu on and off
     depending on whether the hero is standing on a save point** (it compares
     coordinates). Today it isn't implemented.
3. **Bake patterns that repeat** in the parallel ones ("read an event's X
   and compare it"), into compound opcodes. Only in parallel ones, which are
   the ones that weigh.
4. **Eliminate code that can't run** and other classic optimisations,
   if they turn up.

What it has to take care of: RM2k's semantics (the order of `Game_Map::Update`,
what a page sees in the frame in which another one changes it), and that it be
general to the engine and not specific to ABL.

**On 2026-09-27 number 3 was done for one pattern**, the one of "is this character
on the cell of these variables?", which is the one of the race cars, the lights
on map 11 and some two hundred and fifty pages of the game: `OP_CELL_TEST`, and
a shortcut that runs those pages without the interpreter when they don't get past the
condition. See `race-2-at-60-frames.md`, which also has measured
the limit of number 2 for the race: zero on the heaviest tick,
because the hero changes cell every two ticks.
