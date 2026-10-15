---
name: "A MoveEvent on an event the map does not have leaves its page out"
description: "Vampires Dawn moves events 18 on map 58 and 26, 43 and 44 on map 224, which those maps do not have; the compiler refuses the target and the whole page goes"
type: bug
status: draft
---

Seen by Hurón on 2026-10-14, measuring with `just culprits` after
[`route-the-missing-moves`](route-the-missing-moves.md), with the-advocate
`huron-moves` (from `14e200fc`) and the ports `huron-moves` (from
`f775b66`), in Vampires Dawn. Not played, and RM2k's behaviour not checked
in the original.

**What is seen**: three pages —map 58, event 17, page 1; map 224, events 32
and 47, page 1— have `MoveEvent`s whose target is an event id the map does
not have in the game's own data (map 58 has no event 18; map 224 none of 26,
43, 44). `target_of` refuses them and the page is left out whole, with
whatever else it does. In easyrpg, `GetCharacter` of a missing id gives
nothing and the command is skipped.

**How to see it**: `just culprits` in `vampires-dawn/` of the ports; those
three pages are the `MoveEvent` culprits without a 32 or 33 in the route.
