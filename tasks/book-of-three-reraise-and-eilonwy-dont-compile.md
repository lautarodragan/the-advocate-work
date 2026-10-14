---
name: "The Book of Three's Reraise and Eilonwy's upgrades don't compile"
description: "Two of its four parallel common events stop at an actor's HP branch and at ControlVars from an item count"
type: bug
status: draft
---

Seen by Aguará on 2026-10-12, with the-advocate `6ed7c4a0` and the ports
`0e1d9ba` (`parallel-common-events-dont-run.md`), in The Book of Three.

**What is seen**: of its four parallel common events, `DisableSaving` (16)
and `LegendariesActivated` (22) run; `Reraise KO'd chars` (18) and
`Eilonwy's Upgrades` (21) do not compile. Not looked at in play.

**Where they stop**: 18 at the branch "actor N has at least 1 HP"
(`[5, 10, 3, 1, 0, 1]`, one per actor from 10 to 15); 21 at `ControlVars`
from the number of an item held (operand 4).

**How to see it**: the line "parallel common events" of
`book-of-three/build/release/converter.log`.

**Measured again** (Calandria, 2026-10-14; [research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)):
the branch is on an actor's HP (6 uses, only in this game); the item count is
`ControlVars` operand kind 4
([`controlvars-from-an-item-count`](controlvars-from-an-item-count.md)). The
essences common event 21 counts are the ones Eilonwy's Absorb Essence adds in
battle, which does not compile either
([`changeitems-and-changemonsterhp-by-a-variable`](changeitems-and-changemonsterhp-by-a-variable.md)).
