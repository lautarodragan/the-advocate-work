---
name: "The hero's jump ignores its speed"
description: "Events jump according to their speed and the hero always at the normal step's"
type: bug
status: done
---

**The hero's jump uses a fixed speed** —`SALTO_VELOCIDAD`, that of speed
4— while events take it from `salto_por_vel`, which is RM2k's
`jump_speed[move_speed - 1]`. An `increase_movement_speed` on the hero
changes its step and not its jump.

It showed up on 2026-09-22, while fixing `jump-that-hangs.md`, and
was noted in the comment of `salto_avanzar_heroe`. It was already like that
before: that fix didn't touch it.

Done means: the hero jumps with its speed, like the events, with a test that
checks it. Watch out: changing the jump's duration **moves the camera
faster** and the map is drawn one row per loop: see
`map-shifted-after-returning-from-a-cutscene.md`.

# What was done, on 2026-09-26

**The cause was the one above, exactly**: `armar_salto_heroe` started at
`SALTO_PASO - SALTO_VELOCIDAD` and `salto_avanzar_heroe` subtracted
`SALTO_VELOCIDAD`, both with the constant for speed 4. `git blame` gives
the commit that split `main.s`; `git log -S` leads to `a95ac7f`, which
introduced the jump when the hero didn't change speed, and the comment left
by the fix of the stuck jump already called it a divergence.

Now both ask `salto_del_heroe` for the decrement, which is `salto_por_vel`
—the same table as the events— indexed with `FAR_HERO_VEL`. It is read every
frame, like `Game_Character::Update`, which calls `GetMoveSpeed()` each time.
`SALTO_VELOCIDAD` disappeared from the `.inc` and from `eventos.py`; in its
place `eventos.SALTO_POR_VELOCIDAD` is the RM2k table the tests look at.

**The test** is `tests/rpgmaker/test_jump_speed.py`, with the cases
`jump-hero-slow` (speed 1) and `jump-hero-fast` (speed 6) plus the
usual `jump` (4): it counts the ticks with `ruta_salto` other than zero
against `ceil(256 / s) - 1`. Without the fix it gives red at both new speeds
—"a velocidad 6 … en RM2k está 3 ticks en el aire; acá estuvo 10"— and the
4 one passes, which is what says the count measures the same as RM2k.

**No golden moved.** No test in the suite or in the walkthrough makes the
hero jump at a speed other than 4.

## The camera

In the game, counting the speed from 4 at the start of each route, the
hero's jumps at another speed are twelve: eleven at 3 —slower, so the
camera goes slower than before— and one at 5 on map 3, of two cells in
x and one in y, which is about four pixels per frame. None goes past the row
per loop. What isn't checked is a speed that comes from an earlier route:
a long jump at 6 —five cells in four frames— would go past it, and there is
none in the game's routes that sets it up in the same route.

## What taro has to look at

The hero's jumps at speed 3 last sixteen frames instead of eleven: the
one on map 19 (three cells upward), 98, 105 and 132, among others.
