---
name: "The jump that hangs"
description: "A jump at the end of a forced route leaves the hero floating forever"
status: done
---

**A hero jump that is the last order of its forced route never
ends**: the hero stays floating halfway through the arc. taro saw it on map 11,
when Talan jumps in fright and stays halfway while talking.

Measured on 2026-09-22, with the case `camara-salto-colgado` which was left in the repo
without a test: `ruta_salto` stays at 232 and `hero_y` at 323, with the
destination cell at `tile_y = 22`, indefinitely.

The cause: `move_hero` calls `paso_de_ruta` only while `ruta_i < ruta_n`, and
`paso_de_ruta` is the only one that lowers `ruta_salto`. With the jump as the last
order, the counter has already reached the end and nobody finishes it. And `hay_rutas` does not
look at `ruta_salto` either, so a `ProceedWithMovement` right after does not wait for it.

**196 of the game's 410 routes with a jump end in the jump**, so it is not
an edge case.

Done is: the jump ends, the hero lands, and there is a test that looks at it.

# What was done, on 2026-09-23

**The cause was the one above, exactly.** The countdown moved from `paso_de_ruta`
to `salto_avanzar_heroe`, and `move_hero` calls it in the same place where it already
finishes a step in progress: that is what RM2k does, where the one that lowers the jump is
`Game_Character::Update` —it asks `IsJumping()` **before** looking at whether there are
orders left, because being in the air is not being still: `IsStopping()` is
`!(IsMoving() || IsJumping())`— and the one that turns it off is
`Game_Character::UpdateMovement`. With the route still having orders it stays
exactly as before, because there `paso_de_ruta` looked at the jump first
anyway.

And `hay_rutas` now looks at `ruta_salto`: it is `IsAnyMovePending`, and there
`MoveRouteFinished` is set inside `UpdateMovement`, that is, on landing.
It goes bare, without the care `step_left` needs, because the only one that sets
`ruta_salto` is `armar_salto_heroe` and that one is called only by `paso_de_ruta`: no jump
comes out of the pad.

**The events did not have it.** `mover_eventos` calls `cuadro_de_ruta_ev` for them
once per frame for every occupied slot, without looking at the order counter, and
`hay_rutas` already looked at their `ruta_ev + 13`. A test holds it, so that it
shows if someone gives them the guard `move_hero` had.

**No golden moved, and that does not mean the fix does not show**: the only case
in the suite that steps on map 11 is `en-11`, which goes in and nothing more —it is used by
`test_paralelos`, without a golden—. The moment taro sees is not executed by any
test, which is the usual failure mode.

## The camera jerk, checked

With the fix **there is no case left that slides the camera more than one row per
loop other than the hero at speed 6 plus a pan**. Measured over the cases
of the test cartridge, 240 loops each, counting only the loops without
a map change or a cell jump: the only ones over 8 px are
`camara-veloz` and `camara-veloz-x`, with exactly 16 px, which is the worst case that was already
measured.

What showed up while measuring: **no case in the cartridge reproduces the jerk of the sudden landing**,
neither before nor after the fix. The big jerks
of `en-4` and `talan` —256 and 192 px— are teleports to the same map, which
write `hero_y` and call `fill_window`, so they never owed a row to
`stream_map`.

And from there came the only thing that needed care: that teleport shortcut does not
touch `ruta_salto`, so with an arc pending the hero would move up to 29 px
from where the teleport put him, with the window just filled. **It does not happen, because of
timing**: the `Teleport` costs the fade —some ninety ticks until the new
cell appears— and a jump lasts eleven. The case
`salto-teleport-en-el-aire` was left with its test, so that it is known if that order stops
holding.

## What was not done

* **The hero's jump does not respect speed.** `SALTO_VELOCIDAD` is fixed, the one
  of speed 4, while the events take it from `salto_por_vel` like
  RM2k's `jump_speed[move_speed - 1]`. An `increase_movement_speed` on the
  hero changes its step and not its jump. It was already like that, and this fix does not touch it.
* **taro has not played it yet.** What was run is `just pruebas`.

# Played

taro played it on 2026-09-23 with the build of `3e028a0`: the jump no longer
hangs.
