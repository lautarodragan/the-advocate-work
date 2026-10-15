---
name: "Route: the missing moves"
description: "The move commands the ROM didn't do: move forward, the relative turns, and the hero's diagonals and turns"
type: feature
status: testing
assignee: taro
agents: [Hurón]
---

# What

The move commands of a forced route that the ROM didn't understand. Of
`rpg::MoveCommand::Code` there were already the four directions, the four diagonals
**of an event**, move toward the hero (9), face it (21) and, since
2026-10-06, the random step (8), move away (10) and face away (22):
always on events.

What remained, and what was done on 2026-10-14:

* **The hero's diagonals** (4 to 7), which are what left the most pages out
  in the other games. Done: `try_diagonal` in `runtime/hero.s`.
* **The relative turns** —90 to the right (16), to the left (17), 180 (18),
  90 at random (19), face random (20)—, on events and on the hero. Done:
  `turn_relative` in `runtime/cells.s`, from `facing_now` on an event and
  from `hero_dir` on the hero.
* **Move forward** (11), on both. Done.
* **On the hero, 8, 9, 10, 21 and 22.** 8 draws a direction like on an
  event; the other four look at the hero, that is at himself, and the
  compiler writes them as what they are (`route::on_hero`).
* **Those of a page's own route** —10, 21, 22, 8, and now 11 and 16 to 20—.
  Done: `route::own` takes every command a forced route takes but the
  switches and the graphic change.

# Status

Done, on branch `huron-moves` of the-advocate, the ports and the book.
Main had not moved since the starting commits, so there was nothing to
merge. Two drafts came out of the measuring:
[`route-switch-commands-leave-the-page-out`](route-switch-commands-leave-the-page-out.md)
and [`moveevent-on-an-event-the-map-does-not-have`](moveevent-on-an-event-the-map-does-not-have.md),
the `MoveEvent` culprits left in Vampires Dawn and Sunset.

**Functions touched in `compile.rs`**: only `compile_route` and its test
(renamed `a_route_walks_every_move_on_events_and_on_the_hero`); the rest
is `route.rs` and `codes.rs`.
What has to be installed when merging: **`cartridge events convert`**
(the runtime and the compiler; `convert` links `events`).

## How RM2k does it (easyrpg's `Game_Character`)

* `Move(dir)`: `SetDirection(dir)`, `UpdateFacing()`, and then, for a
  diagonal, `MakeWay` of the vertical leg and the horizontal from the elbow,
  or else the horizontal and then the vertical. The diagonal cell is never
  looked at.
* `UpdateFacing` with a diagonal: the facing stays if it is one of the two
  components, and turns 180 if not; locked, nothing.
* The turn commands start with `SetDirection(GetFacing())`, turn the
  direction and `SetFacing(GetDirection())` —also when locked—.
* `move_forward`: `Move(GetDirection())` and then `SetFacing(prev_facing)`.
* On the hero, `GetDirectionToCharacter(self)`: both distances zero, so the
  vertical branch with `sy = 0`: **down**, and away **up**.

## What the ROM does differently

* **An event's forward goes toward its facing**, not its RM2k `direction`:
  the slot does not keep them apart, and they part only after a diagonal
  step or with the facing locked. No route of the eight games has an event
  go forward. Said in the comment of `forward` in `event_routes.s`.
* **A blocked hero diagonal turns him anyway**, as the straight ones did
  here already: RM2k gives back the facing when the route is skippable.
  The same model as before; the divergence of the skipped step holds.
* The random ones (8 on the hero, 19, 20) draw from the map's generator,
  like 8 on events.
* The action key after a diagonal step looks at the hero's own cell, which
  is what `XwithDirection` does with a diagonal; with the facing unlocked
  too, since the step leaves `hero_heading` on the diagonal.
* 11 and 8 inside a jump are refused, as 8, 9 and 10 were on events: no
  route of the eight games does it. On the hero, 9 and 10 inside a jump
  are a direction and add up.

## Measured

`just culprits`, `release`, map pages that compile, before (tools
`14e200fc`, ports `f775b66`) and after (`huron-moves`):

| game | before | after | `MoveEvent` culprits before → after |
|---|---|---|---|
| The Book of Three | 1273/1282 | 1275/1282 | 2 → 0 |
| Sunset over Imdahl | 1269/1369 | 1338/1369 | 77 → 1 (a route with a switch, 32) |
| Vampires Dawn | 17511/18842 | 17608/18842 | 134 → 34 (switches, 32, and routes on events not in the map) |

The own routes are not culprits —a page whose own route does not compile
stands still—, so the report does not count them: by the dump, the
commands now taken are on 21 pages of Sunset (8), 29 of Vampires Dawn (8)
and 34 of Desert Nightmare (21).

**Bank 0**, `just space` in ABL: `release` from 1,324 B free to 1,075
(−249: the hero's diagonal, the relative turns, forward and the dispatch).
The tightest after the change, `test-special` and the others, around
1,024 to 1,101.

**CPU**: the riverbank scene of The Book of Three's map 22, Taran and
Gwydion's party walking diagonally at once: one frame per tick on every
diagonal frame (32) and every straight one (48). A diagonal can build a
row and a column of the window on the same tick; it did not overrun there.
Not measured on Vampires Dawn's heavier maps.

## Tests

* ABL, `tests/rpgmaker/test_route_turns_and_diagonals.py`, nine tests on
  map 6, cases `hero-diagonal`, `hero-diagonal-second-leg`, `hero-forward`,
  `hero-turns`, `hero-random-turns`, `hero-random-steps`,
  `hero-faces-himself`, `npc-turns`, `npc-random-turns`. Red on main: the
  cartridge does not build, "the test page doesn't compile". Green after.
* The ports, `tests/test_route_moves.py`, three tests, snes9x only: Hen
  Wen's second talk (The Book of Three, map 4: switch 21 and Taran turned
  up), the riverbank scene (map 22: Taran walks the four diagonals to
  (24, 16), every diagonal frame moving both axes; it stops at the
  gwythaints' battle, which a level-1 Taran alone loses) and Desert
  Nightmare's shop owner (map 20, own route of a 21: faces the hero on
  three sides). Red on main, the three; green after.
* The suites with these tools: `just test` 27, `just rust-test`, ABL's
  `just tests` 1523 passed and 2 skipped, the ports' `just boot` 15.
  `test_painted.py` went red on the way: Sunset's square (map 2) has an
  arrival scene —event 43, a parallel page with no condition and a hero
  diagonal— that now runs, as in RM2k, and walked the hero in the middle
  of the test's walk. The test turns on its switch 76, as the scene seen;
  its goldens did not move. No golden moved anywhere.
* Not covered: an event's forward after a diagonal or locked (the
  divergence), 20 and 19 on the hero beyond "a quarter one way or the
  other", the own routes with 8, 10 and the turns —their machine is the
  forced routes', covered above—, and Sunset's and Vampires Dawn's own
  pages, none played.

# Why

**In ABL the nine together added up to +1 page**, and that's why this was noted
as "not worth it". In the other games it isn't so: 8, 10 and 22 unlocked pages of
Desert Nightmare, Vampires Dawn, El Dorado and Sunset, and were done on
2026-10-06; the rest, with the hero's diagonals, on 2026-10-14, because taro
wants The Book of Three perfectly playable and its riverbank scene —the way
to map 23— gave Taran four diagonal steps.

**Why the hero's diagonals weren't done before**: the hero's step is one
cell per axis. `try_up` and its three siblings move `hero_ptr` —the pointer into
the grid— one cell or one row, and check the permission to leave and to
enter with `step_dx_table` indexed by `hero_dir`, which only has four
entries. A diagonal asks for both legs of the L-shaped permission —what
`cell_allowed_diag` does for an event, which uses none of this—, the pointer in
both directions at once, `hero_blocked` on the destination cell and the
rule of where it ends up facing, which isn't "toward the diagonal".
**What it took**: less than it seemed. `cell_allowed` already asks every
leg with `walker` and `walker_layer`, which `hero_blocked` sets for the
hero, so `cell_allowed_diag` answers for him unchanged; the pointer is
`cell_ptr` of the destination; and `begin_step` and the advance were
already generic in `step_dx` and `step_dy`, and the camera follows the
hero's pixels, a row and a column per tick.
