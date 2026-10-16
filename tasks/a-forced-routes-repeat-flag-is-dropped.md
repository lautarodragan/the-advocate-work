---
name: "A forced route's repeat flag is dropped"
description: "A MoveEvent with 'repeat' set runs its route once: OP_ROUTE has no bit for it and the compiler only reads the flag to check the frequency"
type: bug
status: todo
---

Seen by Cardón on 2026-10-14 (`what-the-compiler-ignores-silently.md`),
tools `14e200fc`, ports `f775b66`.

**What is seen**: not played. In RM2k a `MoveEvent` whose route has
"repeat" set walks it for ever; `compile_route` reads that parameter only
to walk the frequency check and emits `OP_ROUTE` (target, frequency, count,
commands) with no repeat, so the route runs once.

**How much ABL uses it**: 6 of its 3,327 forced routes, the cars of maps 8
and 9 (events 2, 3, 20, 21 on map 8; 20, 21 on map 9), all in parallel
pages that issue the route again every time they run, which hides it. Other
games: Vampires Dawn 27, Dooms 2 3, Frozen World 1; their trigger was not
looked at.

**How to see it**: changing the parameter (index 2 of code 11330) in those
commands leaves `events.json` unchanged.

**Checked on 2026-10-16** at the-advocate `759aa0ba`, by Cardón: still
runs once —`OP_ROUTE` has no repeat bit—, but it is no longer silent:
since `3a954b30` (2026-10-15) `compile_route` notes it as the loss
`route-repeat-dropped`, which the converter writes to `degradations.json`
next to the ROM. That is now the way to see it, instead of `events.json`.

## Defined

Todo, on 2026-10-16, by Cardón: still dropped at the-advocate `f4709d0b`, now as the loss
`route-repeat-dropped`. ABL hides it; Vampires Dawn (27), Dooms 2 (3) and
The Frozen World (1) may show a character that should patrol for ever
stopping after one lap.

**Done** means a repeating route walks for ever until the page or another
route replaces it, as RM2k's, with a repeat bit in `OP_ROUTE` and the
runtime's route slot looping, and the loss gone; a test-game case with a
repeating route over more frames than a lap. **First step**: look at the
pages of those 31 routes in the other games, to know which ones show and
pick one as the ports' case.
