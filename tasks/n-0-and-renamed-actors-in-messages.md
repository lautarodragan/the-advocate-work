---
name: "\\N[0] and renamed actors in messages"
description: "A box with \\N[0] (the leader) or with the \\N[n] of an actor that some ChangeHeroName renames leaves out its whole page"
type: feature
status: doing
assignee: Mulita
agents: [Carpintero, Mulita]
---

Debt that Carpintero declared on 2026-10-05 when baking the names
(`n-n-in-messages.md`): `with_names`, in
`rm2k-snes/events/src/compile.rs`, writes the name from the database
into each `\N[n]` only if no `ChangeHeroName` in the game touches that
actor. `\N[0]` —the leader, which depends on who is in the party— and the
renameable actors stay as they are, and a box with that doesn't compile: the
page drops whole. It is still like that in the-advocate `fc6f7456`; the test
`an_actors_name_is_baked_into_the_text_unless_it_can_change` pins it.

What is known about the cause: the ROM's compositor doesn't write a name
at run time. `ChangeHeroName` doesn't compile today either, so a
page that renames is already out on its own (the
`EnterHeroName` screen is something else: `hero-name-screen.md`).

**Not measured today**: how many pages it leaves out in each game. On 2026-10-05
`\N[n]` in general affected four games —The Frozen World cut
its opening cutscene in map 4— and the baking unblocked that; what
remains is `\N[0]` and the renamed ones. `rm2k-snes-events culprits
--every-map`, on each game's `compile` request, says it.

taro, on 2026-10-15: do it even without `EnterHeroName`; `\N[0]` can be
tested by reordering the party.
