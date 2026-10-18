---
name: "Zounds: four maps have more events than the console's 120"
description: "Maps 47 (284 events), 51 (214), 57 (131) and 178 (327) lose 155, 88, 8 and 206 pages that run; they are grids of identical info/coin/rock events the twin folding does not catch because each carries its own commands"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

Seen by Aguará on 2026-10-15, in the study
[`port-zounds-an-rpg-maker-2003-game`](port-zounds-an-rpg-maker-2003-game.md),
with the-advocate `91d55d39`; from the converter's log.

**What happens**: the console's RAM holds 120 events per map. Three maps
are saved by the twin folding (14: 212 twins of 233; 50: 276 of 282;
112: 222 of 254; 113: 125 of 143) and four are not: 47 "Oeste de la
Grieta" (245 events "Info- Plantas", each a message with a face and its
own switch), 51 "Entrada de la Cueva" (194 "Info- Plantas"), 57 "Mining
Place" (119 "Roca 2": `ControlVars` + `CallEvent`), 178 "Kuak-Man" (314
"Coin" events: `PlaySound`, `ControlVars`, `EraseEvent`, collision
trigger, all with the same charset, a mini-game).

**Why the folding does not catch them**: a twin is "the same pages as an
earlier one, nothing drawn, still"; these differ by the switch or
variable they set, or draw a sprite (the coins). The Kuak-Man map is a
whole mini-game and loses 206 of its coins. What RM2k could do with a
single event and `ControlVars` by position these maps do with one event
per cell.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Side content —the info signs, a mine, the Kuak-Man mini-game—, and Zounds
is far from playable for other reasons, so wishlist. **Done** is those four
maps keeping every page that runs, or the measured limit written here. Two
ways are open and the agent picks and measures: twins that differ only in
the switch or variable they set or in their sprite, folded with a
per-instance operand; or more events per map, which the runtime's byte
index (`action_key.s`: "EV_MAX is 128") and every table sized by `EV_MAX`
make the more expensive one.

**Out of the wishlist, 2026-10-17** (Hornero): taro, playing the delivery
of that day (the-advocate `30786e0b`, the ports `1d93da4`), got to map 47
and events 198–203 —teleports to map 51 "Entrada de la Cueva"— and 204
do nothing, with no box saying why: they are among the events left out.
The story goes through there, so this is now on the way and not side
content. Besides the four maps keeping every page that runs, an event
left out that carries a `Teleport` must not be silent.

## Measured (2026-10-17, Carpintero; the-advocate `30786e0b`, ports `1d93da4`)

What each way leaves out, with the rule of `trim.rs` modelled in
`~/scratch/carpintero/zevents/scratch/ways.py` (rows needed / pages lost /
exits lost):

| map | now | twins on the hero's layer | one operand per family | both |
|-----|-----|-----|-----|-----|
| 47  | 280 / 155 / 7 | 38 / 0 / 0 | 270 / 150 / 7 | 28 / 0 / 0 |
| 51  | 213 / 88 / 1  | 26 / 0 / 0 | 203 / 78 / 1  | 16 / 0 / 0 |
| 57  | 131 / 8 / 0   | 16 / 0 / 0 | 130 / 7 / 0   | 13 / 0 / 0 |
| 178 | 327 / 206 / 4 | 327 / 206 / 4 | 327 / 206 / 4 | 327 / 206 / 4 |

The signs were never "different by their switch": in each grid almost all
are the same page, byte for byte. What kept them apart was their layer —the
hero's, so they block— and the twins were off it. The operand way (twins
that differ in one integer of one command: a switch, a variable, a
`Teleport`'s destination) folds only the edge strips of exits, a handful
per map, so it is not done. Map 178's coins are drawn, collide and erase
themselves: no folding keeps them, and the console's NPC table holds 104
drawn anyway. Its limit is 120 rows: 206 coins left out, its 4 exits kept
once exits rank above plain pages.

Hornero's note of 2026-10-17 —events 190 and 191 byte-identical, the exits
differing only in their destination row— is right, and the rule that
rejected the signs was the layer alone: they are not named, and an action
trigger never mattered. With that rule relaxed the per-instance operand is
not needed for any of the four maps to fit; it folds 10, 10, 3 and 0 rows
more. As runs or rectangles, the twin table of map 47 would have 104 or 44
entries instead of 246 cells (51: 37 or 20 instead of 188;
`~/scratch/carpintero/zevents/scratch/runs.py`). Not done.

## Done (2026-10-17, Carpintero)

- **Twins on the hero's layer, and invisible walls as twins**
  (`convert/src/trim.rs`). The hero's step into a twin's cell is refused if
  the first one's active page is on his layer: `hero_blocked_rest` in
  `runtime/twins_block.s`, a file of its own at the end of bank 0. Only the
  hero: an event walking into a twin's cell is not stopped. ABL's race is at
  the edge of its frames (57 extra on main, limit 58) and flips to 61 with
  the same check for every walker, with it in the middle of the bank, or
  reading the table's count on each step; so a direct-page byte,
  `twins_here`, set on loading the map, sends maps without twins straight
  to `cell_blocked` as before.
- **Exits rank above other pages** (`Loss::Exit`), below the named ones.
- **An exit left out shows a box**: one more event goes, the lowest exit
  left out keeps its row with its pages replaced by "An exit left out here:
  the map has more events than the console holds" (`boxed_exits` in the
  event compiler's request, `exit_left_out_box`), and the other exits left
  out are its twins. Why a box and not a warning only: a warning is in the
  converter's log and `degradations.json`, and the event left out was there
  when taro walked into it; the box is on the cell where it is missed. It
  costs one exit more than strictly needed. No map of the eight games
  reaches it with the real cap.
- Rows after the change: 47 → 38, 51 → 26, 57 → 16, nothing lost; 178 keeps
  its 4 exits and loses 206 coins: draft
  [`zounds-kuak-man-loses-its-coins`](zounds-kuak-man-loses-its-coins.md).

Tests, in the ports' `tests/test_zounds.py`: the exit on 47's east edge to
map 51 (red before, green after), the signs stopping the hero and talking,
and the box on a new cartridge `test-exits` with `--test-events-max 12`.
`build()` in `tests/games.py` takes a cartridge name for that.

taro's save from before map 47 does not load on this branch's ROM: the
save's format changed (172 variables to 173, a new `GAME_SIGNATURE`),
because the signs now kept use one more variable. As designed: a save of
another format is "no saved game".

Verified on the merged tree (the-advocate `8d525d94`, ports `dea6602`, with
this branch's `convert`, `events` and `cartridge`): ABL's suite, 1565
passed, no golden moved, and the race at 57 extra frames as on `main`;
`just boot` in the ports, 67 passed; `just test`, 29 passed; `just
test-game`, 44 passed. In one earlier full run ABL's
`test_cores.py::test_event` went red once (bsnes drew an empty box); alone
it passed eight times out of eight on the branch and three on `main`, and
the merged run was green. Not covered: an event walking into a twin's cell,
which is not stopped. Captures: `/shared/captures/2026-10-17-zounds-events/`.

Branches `carpintero-zounds-events` in the-advocate, the ports and the
book. When merging, reinstall `convert` and `events`; `cartridge` did not
change (the runtime comes from the checkout).
