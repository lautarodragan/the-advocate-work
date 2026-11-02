---
name: "Lowering unreachable above tiles decides itself"
description: "`[graphics] unreachable_above_below` is a per-game switch, on in eight games and off in ABL because there it costs banks; with always / auto / never and auto by default, leaving the key out should give each game its best"
type: feature
status: wishlist
---

Follows [`above-tiles-no-character-can-reach-go-below`](above-tiles-no-character-can-reach-go-below.md):
Aguará's branch moves to BG1 the above tiles no character can reach,
only over nothing and only where the map loses no colour, but behind a
project key, `[graphics] unreachable_above_below = true`, on in the
eight games and off in ABL, whose release had no bank left once ceiling
edges over grass came down too (126 of 126).

taro, on 2026-11-02, in their words, translated:

> It would be nice not to need configuring it per game. If it can be
> analysed statically, maybe there should be options like "always",
> "auto", "never", defaulting to "auto". Can you leave this as a
> wishlist item? That way leaving the entry out _always_ results in the
> best case for each game.

**Done**: the key takes `always`, `auto` or `never`, and without it
`auto`: lower what the map can lose nothing for, and what the cartridge
has room for —the bank count is what stopped ABL—, so no game's
`advocate.toml` needs the key; `never` and `always` stay for measuring.
What "has room" means across maps decided one at a time (the banks are
known only after the packing) is the first thing to settle.
