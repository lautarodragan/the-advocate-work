---
name: "The Book of Three's Reraise doesn't compile"
description: "Its last parallel common event, Reraise, stopped at an actor's HP branch; it compiles since 2026-10-15, and Eilonwy's Upgrades since 2026-10-14"
type: bug
status: testing
assignee: taro
agents: [Calandria]
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

**Measured again** (Calandria, 2026-10-14; [research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)):
the branch is on an actor's HP (6 uses, only in this game); the item count is
`ControlVars` operand kind 4
([`controlvars-from-an-item-count`](controlvars-from-an-item-count.md)). The
essences common event 21 counts are the ones Eilonwy's Absorb Essence adds in
battle, which does not compile either
([`changeitems-and-changemonsterhp-by-a-variable`](changeitems-and-changemonsterhp-by-a-variable.md)).

**Eilonwy's Upgrades compiles** since 2026-10-14 (Tijereta,
[`controlvars-from-an-item-count`](controlvars-from-an-item-count.md)): what
is left is `Reraise KO'd chars`, at the actor's HP branch.

### taro, 2026-10-15

"We can guess by the name… surely it does what it says. So it must be
important —auto-reviving fallen characters after winning battles—. It's
not the end of the world, but it's worth having it working."

### Calandria, 2026-10-15: the HP branch

**What the common event does** (18, parallel, no switch, so every frame of
the map and never in a battle): `ChangeCondition` removes death from the
party —in the ROM that is OP_ACTOR `ACT_REVIVE`, 1 HP to whoever is at 0—,
and then for each actor from 10 to 15 "has at least 1 HP?", with a
`ChangeHP` of 1 in the `else`. So whoever ends a won battle fallen walks
out with 1 HP. Nothing else in it was refused: the branch was the only
culprit.

**What was done**: `ConditionalBranch` case 5 sub 3, easyrpg's
`actor->GetHp() >= p[3]`, is OP_IF_ACTOR with sub 3 and the HP in its data
word; the ROM compares the actor's `FAR_HP` word (`op_if_actor`,
`runtime/interpreter_conditions.s`). In a troop page it reads the battle's
HP too, because each stretch runs between `ba_sync_out` and `ba_sync_in`.
`COND_ACTOR_HP` is emitted by `mapdata` into the header. No new opcode.

**Uses of the actor questions in the eight games** (`[5, actor, sub, ...]`,
maps, common events and troops): sub 3, the HP, only Book of Three's six.
Of the ones still refused: sub 2, the level, 321 in Vampires Dawn; sub 6, a
state, 9 in Vampires Dawn; sub 1, the name, none. The level is not free: an
actor without an experience slot answers `$FF` from `actor_level_of`, and
its level lives only in the cartridge's text strip, so the branch would need
the initial level too. Left out.

**Tests**: the compiler's
`the_hp_branch_asks_an_actor_for_at_least_that_many`, red without the arm;
and `tests/test_book_of_three_reraise.py` in the ports, with the case
`book-of-three/cases/reraise.json`: Taran and Gwydion against Denner (troop
85), Gwydion knocked out in the battle, won; 30 frames after it Gwydion has
1 HP. Red with main's tools (0 HP), green with the branch's. `just
culprits`: common events 25 of 25, and the converter's log says "4 run, 0
do not compile".

**What the suite does not cover**: the HP branch inside a troop page (no
game uses it), and the ChangeHP in the `else` with a real effect —in the
game the `ChangeCondition` before it already got everyone up—.

**Branches**: `calandria-reraise` in the-advocate (`d0061d21`), the ports
(`6ad461c`) and the book (`b9c79b8`: the progress page at 25 of 25, the
Known issues line gone, the ConditionalBranch decision). All three start
from today's main. Verified with the branch's tools: `just test` 27,
`just rust-test`, ABL's `just tests` 1531 (2 skipped), `just boot` 21.
**To install when merging**: `events`, `mapdata`, `convert` and
`cartridge` (it brings the runtime).
