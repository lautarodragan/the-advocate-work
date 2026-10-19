---
name: "ABL: the chasing agents get stuck"
description: "In the scene where the agents chase the hero down the wooden scaffolding, they get stuck easily, and on the upper stretch they seem unable to reach the hero; to compare with the original"
type: bug
status: done
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-18, playing ABL on Mednafen: in the scene where you run
away from the agents chasing you —a rocky slope at night with pines on top
and wooden scaffolding across it—, it is easy to leave them stuck; taro
thinks they cannot reach you at all if you go along the upper stretch. taro
does not know whether the original does the same.

Done means: knowing whether the original does it (under Wine), and if it
does not, the chasers move like RM2k's —the "toward the hero" move and how
it goes around what blocks it—, measured in a ROM test on that map.

## Log

**2026-10-18, Calandria. The original does the same: not a bug.**

The scene is map 105, Mountain Path, and there is a single chaser: event
5, `AgencyGuardChasing!`, which event 4 puts at (69,18). Its pages on 328
and 329 walk an own route, repeating and skippable, at frequency 8 and
speed 5: `[9, 2, 9, 0, 9]` (toward the hero, down, toward, up, toward)
while Talan is on row 18 or below when the chase starts, `[9, 0, 9, 2, 9]`
once he has been above —the parallel event 6 only turns switches on, so
329 stays on—. "Toward the hero" is `GetDirectionToCharacter`: the axis
with more distance, the vertical on a tie, and no detour; blocked, a
skippable route goes on to the next command on the same frame. The
random component is only in the Approach move type, which this page does
not use.

With Talan up the slope, the step toward him (left or up) runs into
rock, and the route's up and down steps only move the guard back and
forth on the planks below. Where he stays, with Talan still and the guard
starting at (69,18):

    Talan at   the guard ends jiggling between
    (42,13)    (47,18) and (47,19)
    (36,11)    (45,19) and (45,20)
    (30,9)     (42,20) and (42,21), off screen
    (52,17)    reaches him in 21 steps, 4 frames each: battle 184

Measured three ways, and they agree cell by cell:

* **The original**, RPG_RT 2015 under Wine, from a copy of the game
  (`~/scratch/calandria/chase/wine/`) that starts with Talan, and with
  event 4 moved to his cell so the chase starts with him already on the
  slope. The guard's cell read off the video frames: at (42,13), exactly
  (47,18)<->(47,19); at (36,11) he jiggles in the bottom-right corner,
  column 45. With Talan walking up the slope instead of standing, the
  guard, twice as fast, catches him on the way.
* **The ROM**, same setup —switches 326 and 327 on, `go_to_map(105,
  cell)`, the guard written at (69,18)—, his path read from RAM every
  frame for 900 frames, with a scratch probe that was not committed.
* **EasyRPG's rule** on paper (`Game_Character::UpdateMoveRoute` and
  `GetDirectionToCharacter`), simulated over the map's passability: the
  same paths, step for step.

The runtime's `toward_hero` and the skippable branch of `move` in
`runtime/event_routes.s` (blame: 391930c4, 70fd1119, d97d089e, and
14dde765 for the 9 in a page's own route) are that rule, so nothing was
touched: no branch, no test, no golden, and the book's page needs no
Known issues line. taro's capture is that state: Talan on the slope, the
guard on the planks at the bottom right.

Captures, the original next to the ROM, in
`/shared/captures/2026-10-18-chase/`, with a README.

Seen and not looked into: a guard that starts at his map position
(69,0) —entering 105 with 327 already on— walks across the sky rows in
the ROM, whose passability lets them be walked; whether the original
does too was not checked, and playing normally the game never puts him
there.

**Nothing to install when merging.**

**2026-10-19, taro**: declared done.
