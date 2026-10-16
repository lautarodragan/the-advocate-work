---
name: "A 2003 actor is capped at level 50"
description: "RPG Maker 2003's actors go to level 99 by default and the rules clamp max_level to RM2k's 50; Zounds' actors read 99 since Ditto reads 2003, and their curves have 50 entries, so nothing shows there yet"
type: feature
status: draft
---

Seen by Aguará on 2026-10-15, while making Ditto read RPG Maker 2003
([`ditto-does-not-read-the-2003-fields`](ditto-does-not-read-the-2003-fields.md)),
with the-advocate at `0f611cdf` and Zounds as the game.

**What happens**: `max_level` in `rm2k/rules/src/actor.rs` is
`Game_Actor::GetMaxLevel`'s, "RM2k's, capped by `final_level`", and it
clamps to `LEVEL_MAX`, which is 50. In a 2003 database an actor's
`final_level` defaults to 99 —liblcf's `Actor::Setup(is2k3)`—, and since
Ditto reads the version, Zounds' five actors read 99 where the study read
50 (the chunk is absent in the file: it held the version's default, which
the 2000 reader took for 50). The parameter curves of a 2003 actor can
have 99 entries; Zounds' have 50, so in Zounds nothing changes: the clamp
and the curve agree. A 2003 game whose actors level past 50 would stop at
50 in the port, and its experience table and curves past that level would
not be read.

**To reproduce**: `just dump` in `zounds/` and read `final_level` in
`data/db/actors.json`; then `max_level` over one of them, and the length of
`parameters.maxhp`.
