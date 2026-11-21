---
name: "A second event on a cell is never asked"
description: "The action button, a bump and a step look at the first event standing on the cell and stop there; RM2k fires every one whose trigger matches. Desert Nightmare's box puzzle on map 12 cannot be climbed, and the middle of the gate on map 2 leads nowhere"
type: bug
status: done
assignee: taro
game: desert-nightmare
agents: [Hurón, Calandria]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, playing Desert Nightmare's `release` through the harness
(snes9x) for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**:

* **Map 12, the box at the wall** (day 1, right after the dog): pushed to
  (12, 4), the box (event 81, its page 2 an action page with no
  commands) stands on the same cell as event 87, the touch page that
  climbs to map 13 once variable 202 is 5. Bumping into it from (12, 5)
  does nothing. With the box's row moved off the cell by hand —its
  `ev_pos_buf` entry, row 80, written to (0, 0)— the same bump climbs to
  map 13 at once.
* **Map 2, the gate north** (day 1, after Jake opens it): the three cells
  (12, 0), (13, 0) and (14, 0) are the same teleport to map 4, events 150
  to 152, two of them twins of the first. The two sides teleport; the
  middle one, the straight way through the gate, does not: the dog
  (event 148), sent there by Jake's scene and invisible since, has its row
  on (13, 0) and is found first, so twin 151 behind it is never asked.

`event_in_cell` (`runtime/action_key.s` in the-advocate) returns the first
row whose cell matches, and the twins only when no row does; RPG_RT —and
easyrpg's `Game_Player::CheckEventTriggerThere`— walks every event on the
cell and fires each whose page has the trigger sought.

**To reproduce**: the stages `twins`, `box` and `box_proof` of
`~/scratch/huron/dn/stages.py` (Hurón's throwaway playthrough, with save
states in `~/scratch/huron/dn/states/`). Captures in
`/shared/captures/2026-11-19-desert-nightmare/two-events-on-a-cell.png`.

## Taken (2026-11-20)

By Calandria, from Hurón's ranking in `desert-nightmare-what-it-takes-to-be-playable`. taro: "dale!".

## Log (Calandria, 2026-11-20)

From the-advocate `4f38ea03` and the ports `a34b393`, branches
`calandria-cell-events` in both.

**The rule, from easyrpg-player** (`game_player.cpp`):
`CheckEventTriggerThere` and `CheckEventTriggerHere` walk the whole list of
the map's events —`Game_Map::GetEvents()`, by id— and call
`ScheduleForegroundExecution` on **every** one standing on the cell whose
active page has a trigger in the set and the layer the side asks for
(`Layers_same` in front, anything else on the hero's own cell). There is
no "first wins": each matching one is marked waiting, and the interpreter
then runs them one after the other, by event order. Each one turns toward
the hero. The four callers: the bump (`UpdateNextMovementAction`, touched
and collision in front), the step that ends (`UpdateMovement`, touched and
collision under the hero), the button (`CheckActionEvent`: touched and
collision in front, action under the hero, action in front) and, every
frame the hero stands still, collision under the hero
(`UpdateSelfMovement`). The event's own touch —the event walking into the
hero, `CheckCollisonOnMoveFailure` and `CheckEventCollision`— is per event
and asks no cell, so it is not this bug: `collide_with_hero` in
`runtime/event_routes.s` already does it per event.

**In the runtime** the only cell lookup for firing is `action_in_cell`
(`runtime/action_key.s`), under the three paths: `try_bump`, `try_touch`
and `try_action`. Its `event_in_cell` returned the first row on the cell
and a twin only when there was no row. Now `action_in_cell` walks every row
back to front and then every twin, and queues each through
`queue_by_action`. `cell_blocked` and `pass_with_event`, which decide the
step, already walked every row.

**Tests, shown red first** with the global tools:

* the test game's `test_two_events_on_a_cell.py`, on a new map 11, the
  crossing, with four cells of two events each —a bump past an empty
  action page below, a step onto a touch page under an empty one, two
  touch pages that both run in order, the button past an empty action page
  on the hero's layer—: 8 red (both cores), 8 green with the change;
* the ports' `tests/test_desert_nightmare_cell_events.py`: map 12's box on
  the ladder, map 2's dog on the gate's twin: 2 red.

Both DN tests needed care to be red for the right reason: map 12's
autostart (Sandra finding the blood) walks the hero off on the first
entry, so the test enters, taps through it and enters again; and map 2
must not wait for control, because the intro of map 1 is still pending
and takes the hero to the motel.

**The cost**, on Mesen2's core with the line profiler
(`~/scratch/calandria/cell/measure.py`, throwaway), on DN's map 4 —120 rows
and 36 twins, the most twins of any DN map—: the lines from `try_bump` to
`request_menu`, one bump a tick, the hero held against

                              before   after
    the top edge, no event       27      15
    the first row                15      27
    the 113th row                38      29

so a step onto an empty cell and a bump against a wall —most calls— cost
less, the worst bump is cheaper, and a bump into an event early in the
table costs more: the old walk found it at once. The first version of the
walk was 17/30/32; holding `cell_x` in A for the compare took three lines
off. What is left: the 36 twins are about five of those lines, walked
whole. Sorting the twins by row in `rm2k-snes-mapdata` would let the walk
stop past the cell's row; not done, the twins only exist on maps over
`EV_MAX`.

**The sweep** (`~/scratch/calandria/cell/sweep.py`, throwaway, static):
each event's possible cells are its start, every constant
`SetEventLocation` to it and its start plus each `MoveEvent` route aimed
at it (alone, and a page's routes added up); listed where two meet and a
higher-numbered one has a page that fires (action, touched, collision)
with commands —which is where the old lookup hid it, and where the change
can show—. It does not model a box pushed over several activations: DN's
map 12 is not in it. "set" is a `SetEventLocation`, "route" a `MoveEvent`;
a cell where more than six gather is a parking spot.
* **abl**, 30:
  map 1 (59, 41): 5 (set), 7; map 2 (35, 73): 3 (set), 4 (set), 15; map 2 (96, 98): 3 (route), 4 (route), 21; map 8 (48, 20): 48 (set), 55; map 9 (41, 18): 5 (set), 6 (set), 7 (set), 8 (set); map 11 (19, 46): 14 (route/routes), 38; map 11 (54, 82): 20 events parked; map 19 (10, 3): 1 (route), 15; map 21 (14, 17): 3 (route/routes/set), 5; map 21 (20, 17): 3 (route/routes/set), 8; map 26 (49, 47): 6 (set), 11; map 38 (6, 18): 19 (set), 25; map 38 (57, 56): 19 (set), 20; map 38 (57, 57): 19 (set), 21; map 69 (25, 18): 4 (route/routes), 12; map 81 (8, 7): 2 (set), 7 (route, start); map 105 (14, 16): 2 (set), 7; map 105 (69, 18): 1, 5 (set); map 114 (9, 13): 1 (route), 7; map 121 (10, 29): 2 (route/routes), 7; map 130 (5, 12): 4 (set), 10; map 148 (28, 40): 22 (route/routes), 77; map 159 (14, 4): 3 (set), 9; map 159 (46, 12): 5 (route/routes), 6; map 178 (13, 10): 3 (route), 7; map 223 (15, 11): 22, 24 (set); map 233 (22, 21): 5 (set), 8; map 246 (11, 5): 5 (set), 6 (set), 7; map 278 (6, 10): 3 (route/routes), 4; map 285 (59, 0): 75 events parked.
* **book-of-three**, 1:
  map 5 (11, 4): 3, 7 (route).
* **desert-nightmare**, 36:
  map 2 (13, 0): 148 (route/routes/set), 151; map 16 (4, 7): 13, 26 (route); map 22 (2, 7): 13, 18 (set); map 22 (17, 7): 14, 18 (set); map 24 (12, 11): 13, 14 (set); map 25 (6, 11): 12, 17 (set); map 28 (7, 8): 22, 23 (set); map 28 (14, 6): 3 (route/routes), 23 (set), 31; map 47 (11, 8): 5, 26 (set); map 47 (19, 9): 24, 26 (set); map 48 (0, 29): 81, 88 (set); map 86 (7, 7): 12 (route/routes), 22; map 93 (3, 11): 25 (route), 28, 30 (set); map 105 (25, 10): 13 (route/routes), 14; map 106 (5, 9): 21 (route), 23 (route), 24 (set, start); map 106 (7, 6): 11, 21 (route), 23 (route), 24 (route); map 106 (16, 5): 21 (route), 23 (set, start), 24 (route); map 106 (25, 15): 21 (route/set, start), 23 (route), 24 (route); map 107 (5, 5): 11 (set, start), 12 (route); map 107 (5, 9): 11 (route), 12 (set, start); map 107 (16, 7): 11 (route), 12 (route); map 108 (1, 10): 9 (route), 10 (route); map 108 (8, 5): 9 (route), 10 (set, start); map 108 (15, 8): 9 (set, start), 10 (route); map 111 (0, 10): 12 (set), 14; map 132 (6, 9): 6, 15 (set); map 136 (8, 7): 11, 24 (set); map 136 (12, 7): 6 (set), 10; map 136 (14, 7): 8 (set), 20; map 138 (10, 17): 34 (set), 35 (set), 43; map 138 (11, 20): 7, 34 (set), 35 (set); map 138 (12, 8): 34 (set), 35 (set); map 143 (8, 6): 30, 31 (set); map 145 (10, 7): 19 (route), 23; map 145 (11, 8): 20 (route), 24; map 145 (12, 7): 21 (route/routes), 25.
* **dooms2**, 1:
  map 21 (10, 14): 1 (route/routes), 2.
* **el-dorado**, 30:
  map 2 (15, 10): 3 (route), 8; map 3 (5, 4): 7 (route), 16; map 4 (0, 0): 3 (set), 9, 69 (set); map 4 (7, 6): 27, 39 (set); map 4 (12, 2): 4, 49 (set); map 4 (18, 5): 36 (set), 47; map 5 (0, 0): 6, 37 (set); map 5 (6, 9): 1, 5 (set), 8 (route/routes); map 5 (18, 5): 45 (set), 46; map 6 (3, 5): 2 (route), 37; map 6 (3, 6): 2 (route), 10; map 6 (3, 7): 2 (route), 36; map 6 (3, 9): 17, 24 (set); map 6 (9, 3): 11, 38 (set); map 6 (9, 4): 3 (route), 34; map 6 (13, 5): 29 (route/routes), 32; map 6 (14, 10): 25, 28 (set); map 6 (15, 7): 4 (route), 22; map 7 (3, 9): 17 (set), 20 (route); map 9 (3, 8): 23 (route), 24 (route); map 9 (10, 7): 19, 36 (routes); map 10 (1, 7): 11 (route/routes), 27; map 10 (13, 7): 8, 38 (route); map 11 (0, 0): 4 (set), 10, 33 (set), 34 (set), 35 (set); map 11 (6, 11): 24, 27 (set); map 11 (8, 7): 14 (set), 16; map 11 (11, 7): 14 (set), 19; map 12 (4, 11): 41, 74 (route); map 12 (15, 2): 17, 34 (set); map 12 (19, 4): 34 (set), 37.
* **frozen-world**, 9:
  map 1 (12, 6): 2 (route), 6; map 34 (4, 2): 13 (set), 15; map 39 (6, 2): 1 (route/routes), 3; map 55 (10, 9): 5 (route), 8; map 60 (0, 10): 5, 6 (route/routes); map 69 (17, 5): 28 (route/routes), 29; map 108 (12, 0): 4, 5 (route); map 129 (10, 15): 6 (set), 7; map 155 (10, 3): 1 (route), 2 (route/routes), 3 (route/routes), 8.
* **sunset-over-imdahl**, 5:
  map 4 (35, 12): 41 (route), 42; map 12 (4, 19): 3, 35 (route); map 13 (2, 26): 19 (route), 22; map 13 (15, 29): 7, 19 (route/routes); map 28 (10, 6): 2 (route), 3.
* **vampires-dawn**, 46:
  map 7 (8, 10): 8 (route), 11; map 57 (20, 31): 83 (route), 112 (route), 115; map 58 (16, 15): 4 (route), 7; map 87 (4, 6): 28 (route), 30; map 87 (5, 6): 29 (route/routes), 31; map 94 (14, 9): 55 (route), 57; map 99 (65, 65): 80 (route), 89; map 161 (10, 0): 123, 266 (route/routes); map 161 (69, 2): 43 (route/routes), 66; map 200 (26, 5): 6 (route/routes), 8; map 219 (23, 14): 1 (route/routes), 78; map 220 (29, 30): 22, 97 (route); map 222 (11, 6): 25 (route/routes), 35, 44 (route/routes), 45 (route); map 222 (12, 7): 23 (route), 37; map 222 (15, 6): 26 (route/routes), 39, 43 (route/routes); map 224 (24, 8): 23 (route), 24 (route), 25; map 290 (11, 13): 27, 30 (route); map 290 (14, 14): 19, 30 (routes); map 329 (9, 14): 4, 6 (route/routes); map 346 (29, 12): 2 (route/routes), 103; map 376 (16, 39): 2 (route), 8; map 376 (24, 39): 3 (route), 15; map 426 (5, 4): 1 (set), 2 (set), 6; map 426 (5, 7): 1 (set), 2 (set), 7; map 426 (5, 10): 1 (set), 2 (set), 8; map 426 (9, 4): 1 (set), 2 (set), 11; map 426 (9, 7): 1 (set), 2 (set), 10; map 426 (9, 10): 1 (set), 2 (set), 9; map 426 (13, 4): 1 (set), 2 (set), 12; map 426 (13, 7): 1 (set), 2 (set), 13; map 426 (13, 10): 1 (set), 2 (set), 14; map 427 (7, 7): 21 (route), 22 (route); map 427 (8, 7): 21, 22 (route), 23 (route); map 427 (9, 7): 21 (route), 22, 23 (route); map 427 (10, 7): 21 (route), 22 (route), 23; map 427 (11, 7): 22 (route), 23 (route); map 429 (17, 12): 40, 253 (set); map 429 (26, 12): 48, 243 (set); map 429 (41, 12): 62, 244 (set); map 429 (67, 12): 109, 248 (set); map 429 (91, 11): 133, 249 (set); map 429 (119, 12): 163, 250 (set); map 429 (143, 9): 198, 252 (set); map 429 (150, 12): 209, 254 (set); map 435 (12, 8): 1 (set), 3 (set), 4 (set), 5 (set); map 455 (14, 9): 55 (route), 57.
* **zounds**, 7:
  map 71 (20, 12): 4 (route/routes), 5 (set); map 96 (4, 25): 81 (set), 82; map 105 (19, 9): 2 (set), 3 (set); map 144 (1, 22): 16 (set), 20; map 144 (27, 16): 4, 10 (route); map 146 (15, 8): 10, 20 (set); map 146 (15, 10): 9, 20 (set).

**Verified** on the branches (main had not moved), with
`.local-tools` built from `cartridge` only —the runtime comes from the
checkout—:

* ABL's suite, `test_cores.py` in it: all green, no golden moved; so
  nothing to show side by side, and `/shared/captures/2026-11-20-cell-events/`
  was not made;
* `just boot` (the other eight games, Zounds' goldens among them): green;
* the test game: green except four reds that are on main as they are,
  same pixel counts with the global tools at `4f38ea03` —drafts
  [`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md)
  and
  [`goombario-reads-widths-from-an-untaken-if-branch`](goombario-reads-widths-from-an-untaken-if-branch.md)—;
* `just test` in the-advocate: green;
* `just space`: bank 0 is 65 bytes smaller in every cartridge and far RAM
  one byte (`cell_queued`); `$C0` and `$C1` do not change —the code is in
  bank 0—. The tightest bank 0 is ABL's `release`, then Sunset's.

**Not covered by any test**: a twin and a row on the same cell is only DN's
gate test; the order in which two matching pages run is only the test
game's touch pair, not the button; the turn toward the hero when several
fire —one turn slot, the lowest-numbered wins; RM2k turns each— is not
tested; and the sweep's candidates were not played, only guarded by the
suites that already cover those maps.

**When merging**: nothing has to be reinstalled for the change to run —it
is all `runtime/`—. `rm2k-snes-convert` changed only a doc comment
(`trim.rs`); reinstall `convert` only if the merge wants the global
binaries to match the tree.

Branches: `calandria-cell-events` in the-advocate (test game, runtime),
the ports (DN's test) and the-advocate-docs (internals, the twins' pages,
DN's known issue removed).
