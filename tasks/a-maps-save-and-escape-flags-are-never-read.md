---
name: "A map's save and escape flags are never read"
description: "The tree's per-map can-save, can-escape and can-teleport tri-states are not read by anything: ABL forbids saving on 75 of its 308 maps"
type: bug
status: draft
---

Seen by Cardón on 2026-10-14 (`what-the-compiler-ignores-silently.md`),
tools `14e200fc`, ports `f775b66`.

**What is seen**: not played. Each map of the tree has `save`, `escape` and
`teleport` set to inherit, allow or forbid, and `rm2k-rules`' tree resolves
only the music and the battle background by inheritance. Nothing reads these
three, so the pause menu's Save follows only `ChangeSaveAccess`, where RM2k
also greys it on a map that forbids it.

**How much ABL uses it**: resolved over the parents, 75 of the 308
cartridge maps forbid saving, all under "The Kingdom of Surl" (map 210:
Memnosyne's Adobe, the Surl roads and ruins), and map 105 forbids escaping.
Other games: Dooms 2 forbids saving on 88 of 92 maps; Vampires Dawn on 430
of 430, escaping on 377 and teleporting on 422.

**How to see it**: `maps.json` of the dump, `save` of node 210 is 2
(forbid) and its children inherit with 0; nothing in the Rust names the
field outside Ditto's schema. Not played: from the code, the pause menu's Save on one of those maps
follows only `ChangeSaveAccess`.
