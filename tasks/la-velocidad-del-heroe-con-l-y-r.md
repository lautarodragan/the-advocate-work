---
name: "The hero's speed with L and R"
description: "L lowers and R raises the hero's movement speed"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-30: "being able to increase or decrease the hero's
speed with the R and L buttons". It is not something from RM2k: it is an addition of the port,
and it is noted in `divergencias/`.

## How it was

The hero walks at `FAR_HERO_SPEED` (from 1 to 6, 4 at startup): it is raised and lowered by
orders 28 and 29 of a route, **it stays set** —RM2k restores the
frequency when the route ends, not the speed— and it travels in the save. It is read
on every frame of the step, through `hero_anim_frames`, which incidentally gives how long
each frame of the walk lasts.

## What was decided

Everything is in `workflow/divergencias/la-velocidad-del-heroe-con-l-y-r.md` and
commented in `tools/runtime/hero_speed_keys.s`. In short:

* **an addition on top of the game's**, not the game's: L and R move
  `FAR_SPEED_BONUS` and the hero walks at the sum, with limits 1 and 6. That way the
  game's speed, which is state and travels in the save, is never touched;
* **it persists across map changes, it is not saved**; the reset clears it;
* **a route on the hero walks at the game's speed** while it lasts, its last
  step included, and then the addition comes back. For that `route_step` is set
  before attempting the route's step and not after (`hero_route.s`):
  `begin_step` already advances the first frame, and without this the first frame of the
  last step came out at the L and R speed —the test found it: 5 frames
  instead of 8—;
* **only with the hero free**: no route, message, page ahead nor events
  waiting. Menu, battle, shop and fades have their own loop or freeze the
  main one;
* **it is turned off with `--no-speed-keys`** in the cartridge's `flags`
  (`HERO_SPEED_KEYS` in `mapdata.inc`). It came out cheap because the cartridges already
  pass flags to the converter: there was no need to touch Rust. `test-special` carries it,
  so that the turned-off path has a test.

## Far RAM

`FAR_SPEED_BONUS = $25F0` and `FAR_SPEED_KEYS = $25F1`, in the gap between the
end of `FAR_PAIR_LIST` ($2580) and `FAR_ACCESS` ($25FC). **Nobody assigned them
to me**: I chose them far from "the next free one" ($25FB) on purpose.
On merging, check that no other branch has taken those two.

## The test

`rom/pruebas/rpgmaker/test_velocidad_con_l_y_r.py`: how many frames a
cell takes with the pad. Without the change, five of the seven red —R once gave 8
frames instead of 4, and the ones that read `FAR_SPEED_BONUS` did not find the
symbol—; the one that passed is walking without touching anything, which is the baseline.

## Space

Bank 0 of `release` went from 182 B free to 173 B (+9: two `jsl` in the
startup and the loop, and a `jsr` that became `jsl`); bank 1, from 4,679 B to
4,515 B.

## Verification

`just pruebas`: 908 green (900 from the baseline, 1 from the entrance mosaic and
the 7 of this one); `just -f tools/justfile test`: 46. No golden moved.
`NO_CACHE=1 just cartuchos` comes out byte-for-byte identical to the cached one (the only thing
in the converter that changed is one more constant in `mapdata.inc`).

## For taro

On any map, R and walk: one R is 5 (twice as fast), two is 6;
L goes down to 1, which is very slow. See whether it works for you that it is not saved in the
save and that a scene that moves the hero does so at its own speed.

On merging there is nothing to install: the runtime changed and the contents of three
converter scripts (`options.py`, `snes_convert.py`, `mapdata.py`),
none new or renamed, and no Rust crate. It does need checking that
nobody else has taken `$25F0` and `$25F1` of far RAM.
