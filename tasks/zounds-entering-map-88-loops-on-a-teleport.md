---
name: "Zounds: entering map 88 loops on a teleport"
description: "Entering 'Desierto de Urbaddun / Mountains / Oeste de la Grieta / Secreton / 4 - Desert' (map 88) leaves the hero unable to move or leave: Get Outta Map's autostart pages, conditioned on variables 7 and 8, seem to fire with both still at 0 and teleport in a loop"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-19, playing Zounds (delivery of that day, the-advocate
`54ec3daf`, the ports `c2912ad`), going north of the desert for the pyro
sword: on entering that map they loop and cannot move or leave. taro's
reading: the event `Get Outta Map` triggers one of its pages conditioned on
X or Y although those should not hold, and loops on a teleport; X and Y are
never loaded into the variables. "I suppose RPG Maker ran page zero first,
which is a Parallel Process, and always managed to set the variables.
Maybe in our case those variables are at 0, 0 by default and nothing sets
X, Y."

What Hornero saw in `zounds/data/maps/Map0088.json`: Get Outta Map has four
pages. Page 0, no condition, trigger parallel, 2 commands. Pages 1-3,
autostart, 7 commands each: variable 7 <= 1, variable 8 <= 1, variable 8
>= 38 (compare operators as liblcf numbers them; check). In RM2k the
active page is the highest one whose conditions hold, so with both
variables at 0 page 2 is active and page 0 would never run there either:
something else probably sets 7 and 8 before (a parallel common event, the
map the hero comes from, the teleport). To find out, against EasyRPG's
source and the original under Wine if needed.

## Log

2026-10-19, Calandria. Worktrees in `~/scratch/calandria/map88/`, branch
`calandria-map88` on both repos, from the-advocate `54ec3daf` and the
ports `c2912ad`.

**The cause: the converter dropped RPG Maker 2003's page comparison.**
`Game::convert` in `rm2k-snes/events/src/game.rs` kept the variable and
its value and `pages.rs` wrote `CONDITION_OPERATOR`, `>=`, for every page,
a constant from when only 2000 games were read. The page record already
had the comparison byte —the timer travels there as `<=`— and
`conditions_ok` already evaluates `CheckOperator`'s six codes. So map 88's
"X <= 1" and "Y <= 1" were "X >= 1" and "Y >= 1": page 2 (Y >= 1) was
active anywhere on the map, autostart, and its `Teleport` to (30,30) ran
forever. Zounds has 328 pages with a variable condition; only 15 ask `>=`
(242 `==`, 36 `>`, 29 `!=`, 5 `<=`, 1 `<`), on 14 maps. The other games
are 2000 and do not have the field.

What sets 7 and 8: common event 3, "Set Gloval Variables", a parallel
with no switch, copies the hero's X and Y (`ControlVariables`, operand 6,
event 10001, fields 1 and 2), and then, with switch 315 "READING KEYS" on
—map 1 turns it on and nothing turns it off for good—, **waits for a key
press** (`KeyInputProc` waiting, all keys) before going round again. So
X and Y are copied once per key press, not per frame. Map 88's page 0, a
parallel with no condition, copies them every frame while it is the active
page. Compare operators are liblcf's: `0 ==`, `1 >=`, `2 <=`, `3 >`, `4 <`,
`5 !=`; `Game_Event::AreConditionsMet` uses them in 2003 and only `>=` in
2000.

**What RM2k does too, and is not a bug of ours**: a step off map 87's
west edge started with a fresh press on its last cell (x = 1) leaves X at
0 —the common event copies it the frame after the press, when the hero's
cell is already x = 0—, so map 88 is entered with "X <= 1" active and the
hero is bounced to (30,30) until a key is pressed, which lets the common
event copy X again. Holding the arrow from further east, X stays stale
at the cell where it was pressed and nothing bounces. With the fix the
ROM does the same: measured, the bounce ends at the first tap that does not
fall on a fade.

Reproduced first in the ROM, red: `test_into_the_desert_west_of_map_87`
in the ports' `tests/test_zounds.py` —"on map 88 at (30, 30), not at (38,
29)"—. The fix, the-advocate `c60cea53`: the comparison travels in
`Condition::variable`, from the page for a 2003 game and `>=` for a 2000
one; one outside the six asks for nothing, as in EasyRPG. Plus a unit
test in `game.rs`. Only `rm2k-snes-events` changes; ABL is a 2000 game.

On the way, a divergence that was not the cause: what a parallel common
event writes is refreshed a frame late —draft
[`a-parallel-common-events-write-refreshes-pages-a-frame-late`](a-parallel-common-events-write-refreshes-pages-a-frame-late.md)—.

Verified on the branches, with `rm2k-snes-events` installed locally
(`just install-local .local-tools events`): `just test` in the-advocate
green; the ports' `just boot`, 68 passed, Zounds' tests among them, the
new one too; ABL's `just tests`, 1577 passed and 2 skipped, and its
`abl.sfc` byte for byte the one main's tools build
(`11375e00…`) —ABL is a 2000 game, so nothing of it changes—. What the
suite does not cover: the other 13 Zounds maps whose pages compare with
`==`, `>`, `!=` or `<`, which now behave differently and nobody has played
through; it is taro's to see playing.

**To install when merging**: `just install events`, from
`~/the-advocate`. Only that crate changed.

To test: walk into the desert west of map 87 —the way north to the pyro
sword— and across it; at its west, north and south edges the hero is sent
back to the middle, and a key press gives control back.

