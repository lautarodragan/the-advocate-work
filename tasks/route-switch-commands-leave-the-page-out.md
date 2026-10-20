---
name: "A forced route that turns a switch on or off leaves its page out"
description: "Move commands 32 and 33 in a MoveEvent are refused, and the whole page with them: 33 pages of Vampires Dawn and one of Sunset over Imdahl on 2026-10-20"
type: bug
status: todo
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

## Defined (2026-10-16, Carpintero)

Still open: `route::known` refuses 32 and 33 at the-advocate `f4709d0b`.
Whole pages go, one of them in Sunset, which is being played. **Done**: a
forced route turns a switch on and off when it reaches the command, and
refreshes the pages like `ControlSwitches`; the pages compile, `just
culprits` drops them in Vampires Dawn and Sunset, and a ROM test sees the
switch change at its step. **First step**: the route's opcode for it, with
the switch number past 1023 in mind
([`branches-and-switch-commands-past-switch-1023`](branches-and-switch-commands-past-switch-1023.md)).

## Checked (2026-10-20, Chajá)

Still refused: `route::known` leaves out 32 and 33 at the-advocate
`8f290c39`. `rm2k-snes-events culprits --every-map` with the global tools
(installed from that commit) over each game's `release` built that morning
(ports `68bf55b`), decoding each `MoveEvent` culprit's route: **33 pages**
of Vampires Dawn with a 32 or 33 in the route, against the 56 culprits
above —those may have been commands, several to a page; why it went down
was not traced—, and Sunset's one, map 56, event 5, page 2,
which is now one of the last four pages Sunset leaves out
([`sunset-nine-pages-still-left-out`](sunset-nine-pages-still-left-out.md)).
