---
name: "A revived actor keeps its conditions in battle"
description: "An actor that falls in battle keeps its places until the battle ends, where the death's purge runs; raised in the same battle by a Phoenix Down it gets up still poisoned, where RM2k's death had already taken the poison"
type: bug
status: draft
---

Seen by Mulita on 2026-11-01, reading `runtime/battle_states.s` and
`runtime/battle_items.s` on the-advocate `mulita-medicine` (from
`0ba09da4`) while doing
[`a-medicine-does-not-cure-a-condition`](a-medicine-does-not-cure-a-condition.md).
Not reproduced on the console.

**What it is**: in RM2k, dying is `AddState(kDeathID)`, and `State::Add`
drops every condition ten points of priority below death's: a fallen actor
holds nothing else. The port's battle does not purge when an actor falls
—`act_st_battle_end` does it on the party when the battle ends, see its
comment in `runtime/party_states.s`—, so the fallen keep their places in
`ba_states`. A medicine that revives in battle (`ba_item_use`'s `fallen`
path, `MED_RAISES`) gives the HP back and leaves the places as they were:
the actor gets up with the Poison it fell with, and its next turns take HP,
which in RM2k they would not.

**To reproduce**: in A Blurred Line, an actor poisoned by `ChangeCondition`
falls in battle and another gives it a Phoenix Down (item 5) in the same
battle: it should stand with no condition.

**Where it would go**: the purge `ba_st_add` runs after a condition is
given, at the revival in `ba_item_use` —or, closer to RM2k, when an actor's
HP reach zero—. FAR2 has little room in Sunset over Imdahl: `just space`.
