---
name: "A forced route that turns a switch on or off leaves its page out"
description: "Move commands 32 and 33 in a MoveEvent are refused, and the whole page with them: about 55 pages of Vampires Dawn and one of Sunset over Imdahl"
type: bug
status: draft
---

Seen by Hurón on 2026-10-14, measuring with `just culprits` after
[`route-the-missing-moves`](route-the-missing-moves.md), with the-advocate
`huron-moves` (from `14e200fc`) and the ports `huron-moves` (from
`f775b66`), in Vampires Dawn and Sunset over Imdahl. Not played.

**What is seen**: in Vampires Dawn, 56 `MoveEvent` culprits in
`culprits.json` are routes with a 32 —`switch_on`, with its switch as
operand— on events (54) and on the hero (2); in Sunset over Imdahl, one,
map 56, event 5, page 2, a long route on "this event" that ends with
`32, 65`. The compiler refuses 32 and 33 in any route (`route::known`), so
those pages are left out whole. The hero's diagonals, which were the rest
of the `MoveEvent` culprits of both games, compile since that task.

**How to see it**: `just culprits` in `vampires-dawn/` or
`sunset-over-imdahl/` of the ports, and the pages of `culprits.json` whose
culprit is code 11330 with a 32 or 33 among the decoded commands (the
route's integers are RM2k's seven-bit format: see `route::decode`).
