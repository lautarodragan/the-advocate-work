---
name: "Culprits counts empty troop pages as a bad trigger"
description: "A troop page with no condition and no command is counted under 'a trigger the ROM cannot look at', which says The Frozen World compiles 0 of 80 troop pages and The Book of Three leaves out 95 for a trigger; nothing is lost, an RM2k page without a condition never runs"
type: bug
status: draft
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).

**What is seen**: `just culprits` prints, for The Frozen World, "troops: 80
pages, 0 compile, 80 with a trigger the ROM cannot look at", and for The Book
of Three 95 of 746. All 175 are pages with **none** of the seven condition
flags set and **no command** other than the closing one: the default page
every troop carries. `trigger()` in `rm2k-snes/events/src/troops.rs` returns
`None` for "looks at nothing" (a page that, in RM2k, never runs:
`AreConditionsMet` is false at once), and `culprits.rs` counts that `None`
under the same name as the real refusals (a fatigue condition, a number out
of range).

Nothing is lost. The effect is on the report: it said, in the survey and in
the Frozen World's page of the book, that the game's troops "do not
compile", when the game has no troop script at all (its combat is on maps 1
and 2).

**How to see it**: in `data/db/troops.json` of either game, a page whose
`condition.flags` are all false and whose `event_commands` has no entry with
a code other than 0.

**Elsewhere**: El Dorado is reported with the same "0 of 80" and may be the
same; not checked.
