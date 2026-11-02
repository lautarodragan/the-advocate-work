---
name: "A medicine on the whole party heals one"
description: "A medicine marked entire_party opens the actor choice with the bar on one row and heals only that one, where RM2k puts the bar over everyone and heals the whole party"
type: bug
status: draft
---

Seen by Chajá on 2026-11-01, doing
[`items-that-cast-a-skill-outside-battle`](items-that-cast-a-skill-outside-battle.md),
reading the-advocate at `0ba09da4`; not run.

**What RM2k does**: easyrpg's `Scene_ActorTarget::Start` puts the bar at
-100, over the whole party, for an item with `entire_party`, and
`Game_Party::UseItem` with no target uses it on every member.

**What the console does**: `target_scope` in `runtime/actor_choice.s`
answers $FF for any medicine, so the bar goes on one row and moves, and
`medicine_use` in `runtime/medicine.s` heals the one chosen. The task
[`actor-selection-like-the-original`](actor-selection-like-the-original.md)
already wrote it down for ABL's Pocket Shelter (item 8) in 2026-09.

Medicines with `entire_party` in the nine games: the Pocket Shelter (8) of
ABL, The Book of Three, El Dorado and Frozen World —only outside battle,
100% of HP and SP—, and Vampires Dawn's Vampire Stone (13) and Healing
Powder (127), the last one also in battle.

To reproduce: give the Healing Powder in Vampires Dawn with a party of two
or more, hurt them, and use it from the items screen.
