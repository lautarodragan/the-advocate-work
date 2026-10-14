---
name: "Route: the missing moves"
description: "The move commands the ROM doesn't do yet: move forward, the relative turns, and the hero's diagonals and turns"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

# What

The move commands of a forced route that the ROM doesn't understand. Of
`rpg::MoveCommand::Code` there are already the four directions, the four diagonals
**of an event**, move toward the hero (9), face it (21) and, since
2026-10-06, the random step (8), move away (10) and face away (22):
always on events.

What remains:

* **The hero's diagonals** (4 to 7), which are what leaves the most pages out
  in the other games: about 50 in Sunset and 45 in Vampires Dawn, measured on
  2026-10-06 with `culprits`. It's the expensive one: see below.
* **The relative turns** —90 to the right (16), to the left (17), 180 (18),
  90 at random (19), face random (20)—, which on an event are computed from the
  direction it already starts from, like `face_diagonal`, and on the hero with
  `hero_heading` if it's locked and `hero_dir` if not. Sunset: about 8 pages.
* **Move forward** (11): Sunset, 3 pages, together with an 18 on the hero.
* **Those of a page's own route** —9, 10, 21, 22, 8—, which its compiler
  rejects: none of ABL's own routes use them.

# Status

Noted, **with no plan**. The hero's ones, because of what's measured below.

# Why

**In ABL the nine together added up to +1 page**, and that's why this was noted
as "not worth it". In the other games it isn't so: 8, 10 and 22 unlocked pages of
Desert Nightmare, Vampires Dawn, El Dorado and Sunset, and were done.

**Why the hero's diagonals weren't done**: the hero's step is one
cell per axis. `try_up` and its three siblings move `hero_ptr` —the pointer into
the grid— one cell or one row, and check the permission to leave and to
enter with `step_dx_table` indexed by `hero_dir`, which only has four
entries. A diagonal asks for both legs of the L-shaped permission —what
`cell_allowed_diag` does for an event, which uses none of this—, the pointer in
both directions at once, `hero_blocked` on the destination cell and the
rule of where it ends up facing, which isn't "toward the diagonal". It's a new
hero step and not four copied routines. **What wasn't measured**: how much
of that touches the camera and the stripes of the tile window; `begin_step` and the
advance are generic in `step_dx` and `step_dy`, so it may be less than
it seems. And there's nothing to compare against: no game we have measures a
hero diagonal against RM2k. It costs a task of its own, and yields about a hundred
pages in two games out of seven.
