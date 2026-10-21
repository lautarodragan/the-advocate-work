---
name: "A forced route that turns a switch on or off leaves its page out"
description: "Move commands 32 and 33 in a MoveEvent are refused, and the whole page with them: 33 pages of Vampires Dawn and one of Sunset over Imdahl on 2026-10-20"
type: bug
status: testing
assignee: taro
agents: [Mulita]
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

## It blocks Zounds' first dungeon (2026-10-20, Hornero)

taro, on 2026-10-20, in their words, translated, stuck in the dungeon
under the crack:

> Maybe what I was missing is the Silver Key, to open CENTRO (START)'s
> door?

It is. The Llave de Plata is only in map 103's (Cuarto 2) chest, event
10, whose page with the key needs switch 171 (D1-Cofre Aparecio). The
only thing in the whole game that turns 171 on is the route of the
autostart EV0015 there —after the six monsters, it drops the chest
(event 11, "Cofre Ke cae") with a route that changes its graphic, plays
two sounds and ends with **move command 32, switch 171 on**—. The
compiler refuses that route, so the page is left out (`culprits` on
Zounds' release: map 103, event 15, page 1, the `MoveEvent`), the chest
never appears and the door of map 59 can't be opened. Zounds joins
Vampires Dawn and Sunset in this task, and it goes first.

## Doing (2026-10-20, Mulita)

From the-advocate, the ports and the book at `hornero-integrate`
(`5971f850`, `899b2d0`, `ba7c87f`), on branches `mulita-route-switches`.

**What RM2k does**, easyrpg's `Game_Character::UpdateMoveRoute`:
`switch_on` and `switch_off` set the switch, call `Game_Map::Refresh()` on
the spot —every event's page, in the middle of the route— and go on to the
next command on the same frame; if the refresh gave the walking event a new
page, its own route starts over and the frame's commands stop there. Inside
a jump `BeginMoveRouteJump` only adds up moves and turns: a switch there is
not run.

**What the port does**:

* The compiler takes 32 and 33 in a `MoveEvent` with the switch's number
  in two bytes after the code, low first —`[32, lo, hi]` in OP_ROUTE's
  path, as 35 carries its sound—, checked against the game's switch table
  like `ControlSwitches` (`Indices::holds_switch`). Inside a jump it is
  dropped, as RM2k. No new event opcode: 0x59 is unused.
* A page's own route takes them too, with the numbers in a new
  `Page::route_switches` (the route is a bare list of codes). Four pages
  of the eight games: Sunset's map 56 event 5 page 1 and Vampires Dawn's
  map 163 event 30, three pages.
* The runtime: `route_switch` in `runtime/event_routes.s`, from the
  event's and the hero's route, calls `set_switch`, the `ControlSwitches`
  path. The refresh is the one `set_switch` asks for: the autostart pass
  runs on the same frame —routes run before the interpreter—, the full one
  at the start of the next. That is the divergence.
* What walks a compiled path skips the two bytes: `route_graphics` in
  `pages.rs` and the hero's graphic walk in `convert.rs` —which already
  misread 35's index: a low byte of 34 read as a graphic change—.

**Measured** (2026-10-20), `just culprits` on each `release`, before with
the tools at `hornero-integrate` (`5971f850`) and the ports at `0031803`,
after with `mulita-route-switches` (`9329f602`) and the ports at
`899b2d0`; "route-switch culprits" are pages whose culprit is a
`MoveEvent` with a 32 or 33 in its route:

| game | map pages that compile | route-switch culprits |
| --- | --- | --- |
| Zounds | 3982 → 3984 of 4012 | 2 → 0 (103/15/1 and 71/4/1) |
| Sunset over Imdahl | 1365 → 1366 of 1369 | 1 → 0 (56/5/2) |
| Vampires Dawn | 18091 → 18121 of 18773 | 33 → 0 |

Own routes walked (`own-route-not-walked` in `degradations.json`):
Vampires Dawn 5 → 2 (map 163's event 30, its three pages); Sunset's map 56
event 5 page 1 is still not walked: its route also changes graphic (34),
which an own route refuses.

Bank 0: the runtime costs 65 bytes in every cartridge (`just space`):
Sunset 140 → 75 B left, ABL's `release` 223 → 158, `test-change-system`
168 → 103, Zounds 250 → 185, Vampires Dawn 160 → 95.

The ROM test is the ports' `tests/test_zounds_silver_key.py`: the room's
monsters' switches written on, the hero lands under the chest on map 103,
171 turns on and A on the chest gives the Silver Key. Red at
`hornero-integrate` —"switch 171 did not turn on"—, green on the branch.

**Where it is** (2026-10-20, Mulita, saved mid-work): code, test and book
are committed on `mulita-route-switches` in the-advocate (merged with
`origin/main`), the ports and the book (merged with `main`). Left: the
final round on the merged tree —ABL's `just tests`, `just boot`, `just
test`, `just rust-test`, `just lint`— with
`install-local … project cartridge convert mapdata events battle screens
wally images`. The round before the merge had ABL reds and two Zounds
skill-screen reds that came from the global `images`/`screens`/`battle`
being older than the branch (the slot names, the skill results, the lava
tunnels, the skill screen's panorama), not from this change; the merged
round is the one that says so.

## To testing (2026-10-20, Mulita)

The final round, on the merged tree —the-advocate `cb6e0e07` (with
`origin/main`), the ports `c9442a4`, the book `4f26393`, all on
`mulita-route-switches`—, with `install-local … project cartridge convert
mapdata events battle screens wally images`: ABL's `just tests` 1590
passed, `just boot` 109 passed (the Silver Key's test among them), `just
test`, `just rust-test` and `just lint` green. ABL's `abl.sfc`
`082731cf58f2b990` (sha256, first 16). The earlier reds were the global
binaries being older than the branch; they are gone here.

**To install when merging**: `just install project cartridge convert
mapdata events` —`events` and `convert` changed, and `project` carries
the runtime's path—. No goldens moved.

**Not covered by a test**: the hero's route switch (`switch_hero`; no
game's route turns one on the hero), a page's own route with switches
(Vampires Dawn's map 163, compiled and in the unit tests, not played),
and the one-frame-late refresh the book's divergence describes. Also
fixed on the way, in its own commit: the effects' test in
`commons.rs` that the integration left without `sets`.
