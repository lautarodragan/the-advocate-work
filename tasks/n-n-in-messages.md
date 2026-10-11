---
name: "\\N[n] in messages"
description: "A box with \\N[n] (an actor's name) leaves its page out; in The Frozen World that cuts the opening cutscene to black (map 4). Cheap: bake the default name when no ChangeHeroName changes it"
type: feature
status: testing
agents: [Aguará, Carpintero]
assignee: taro
---

From Aguará's (Sonnet) brief analysis, on 2026-10-05, of what taro saw playing the ROMs of the other games. It is the first thing it recommends: the cheapest and the most general (4 games).

## Done (Carpintero, 2026-10-05)

`with_names` in `compile.rs` bakes the database name into each
`\N[n]` when no `ChangeHeroName` in the game (maps, troops, common
events) touches that actor (`indices::hero_names`). `\N[0]` (the leader) and
renamed actors still leave the page out: the ROM's compositor doesn't write a
name at runtime and giving it that isn't cheap. Today `ChangeHeroName`
doesn't compile either, so a page that renames is already out.

Verified: crate test (`an_actors_name_is_baked_into_the_text_unless_it_can_change`);
ABL doesn't use `\N[` in its `data/`, so it doesn't change; Frozen World rebuilt
with these tools gets past the black and shows the DARK WIZARD in snes9x.
A Blurred Line's suite wasn't run.
