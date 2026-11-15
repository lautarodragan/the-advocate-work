---
name: "ABL: the chase on the lower path"
description: "Compare the guard of map 105 against the original with Talan walking, along the lower path too, and make the ROM test check the page that the parallel event 6 picks"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-11-15, reading map 105 in RPG Maker:

> Looking at the event now, I see it stores the hero's Y position in
> `0053: AgentsChasingHeroY`, and then uses it to decide which switch it
> turns on (`0328: AgentGoSouth` / `0329: AgentGoNorth`). [...] Maybe we
> have a bug or a missing implementation of that system, and that is why
> the agent did not chase me properly, and we reached the wrong
> conclusion back then.

And, on launching this:

> It seems to be a bug of ABL itself, but better to test it against the
> original and get rid of the doubt.

What was already known, from
[`abl-the-chasing-agents-get-stuck`](abl-the-chasing-agents-get-stuck.md)
and [`abl-the-agents-on-the-road-to-paradise-do-not-come`](abl-the-agents-on-the-road-to-paradise-do-not-come.md),
and from reading the data (Hornero): event 6 never turns 328 or 329 off
—only the ambush, event 7, does—, the chase starts on row 17 (event 4 at
(52,17)), so 329 is on from the first frame and page 3, the higher one,
wins for the rest of the chase. Page 2 is only reached if Talan were on
row 18 or below when 327 turns on, which normal play does not do.

What the October comparison did **not** cover: every position measured
was Talan standing still on the upper path. The lower path, and Talan
walking while chased, were never compared with the original. And
`tests/abl/test_paradise.py` names 328 and 329 only in a comment.

Done means: the original and the ROM compared with Talan walking along
the lower path (and the upper one, walking), with the guard's cells; if
they differ, the cause found and fixed; either way, the ROM test checks
that 329 is on and the guard is on page 3.

## Log
