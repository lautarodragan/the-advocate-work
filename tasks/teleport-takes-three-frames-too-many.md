---
name: "The teleport takes three frames too many"
description: "Against RPG_RT, each Wait+Teleport of map 16's scene lasted 161 ticks in the ROM and 158 in the original: one in the wait and two in the fade. Fixed; the merge waits for taro to look at the goldens"
type: bug
status: done
assignee: taro
---

It showed up on 2026-09-29 while measuring against RPG_RT the three
divergences that came from the Python reference
(`three-divergences-against-rm2k.md`, Caranday). The one in
`move-event-tras-teleport-interno.md` didn't hold, but measuring it this came
out.

## What was measured

Map 16's scene —the run to work— is four rounds of the hero's `MoveEvent`,
`Wait 15` and a `Teleport` to the same map. In the 2015 RPG_RT under Wine, on
a copy of the game whose map 4 EV0001 starts with `Teleport 16 (53,7)`,
recording Wine's desktop at 60 frames per second; in the ROM (`release`),
with `ir_al_mapa(16, 53, 7)` and one screenshot per tick. In both, the camera
shift frame by frame and the mean brightness are measured, and from that come
four marks per round: **S**, the hero's first step; **F**, the first darker
frame of the fade that erases; **J**, the last one that brightens on showing.

|                         | RPG_RT | ROM |
|-------------------------|--------|-----|
| from J to the first step (S) | 2      | 2   |
| from the first step to F     | 89     | 91  |
| the fade, from F to J        | 67     | 68  |
| the whole round, S to S      | 158    | 161 |

The same in the three inner rounds and in two RPG_RT recordings. That is:
what goes from the arrival to the steps is the same, and **the ROM takes two
more frames to go from the wait to the teleport and one more in the fade**. A
visible effect: in the third round the route lasts longer than the wait, and
the hero gets to walk one more frame —2 pixels— before it's cut off.

This other thing, from the `timer-cero` page, may be on the same side: the
`TintScreen` that comes after a `Wait 2` shows **13** frames after the timer
appears in the ROM and **12** in RPG_RT. It may be the wait, or it may be
`divergencias/ticks-de-pantalla-despues-del-interprete.md`, which describes
precisely a one-frame lag in what the screen shows; they weren't separated.

## What isn't known

Which of the two frames is the wait and which the start of the fade: it would
take a page that waits without teleporting, and none in the suite does that on
a map where it's visible. And the RPG_RT measured is the 2015 one, not the
2000 one the author used (see what the Wine recipe says about that).

The screenshots, with the relative frame number in the name, are in
`/shared/capturas/2026-09-29-divergencias/mapa16-*` and `cronometro-*`.

## Taken on 2026-09-29

taro accepted that the ROM change to match RM2k. If the fix moves goldens,
**it isn't merged until taro sees them**, side by side.

## Where the three came from (Benteveo, 2026-09-29)

Measured in the ROM tick by tick —the hero's position, `ev_waiting`, `fade`
and `brightness` through RAM— with the same save as Caranday (`en-5`,
`ir_al_mapa(16, 53, 7)`). In the round of the numbers above, the page runs the
`MoveEvent` and the `Wait` on tick 71, the hero takes the first step on 72,
the `Teleport` runs on **162**, the first darker tick is 163 and the
brightness comes back fully on 231; the page continues on 232.

* **One is the wait.** `op_delay` stored the whole ninety frames in
  `ev_waiting` and cut the tick, so the next order ran 91 later. In easyrpg
  `SetupWait` leaves `wait_time` and the interpreter loop goes back to the top
  **in the same frame**, where `wait_time--; break;` already spends one
  (`game_interpreter.cpp:447`): the next one runs 90 later. It's also the tint
  of `timer-cero`: with the wait one tick shorter, it comes out one tick
  earlier, which is RPG_RT's +12 and not the ROM's +13.
* **The other two are the fade**, and they aren't the wait: with the wait
  already fixed, 90 remain from the step to the fade and 68 of fade, against 89
  and 67. In RPG_RT the first dark frame **is the jump's** —the 90th after the
  wait—, and the whole fade, from that one to the last, lasts 68 frames
  counting it; the page continues on the next. Here the jump's tick showed
  lit, the next one darkened, and the fade froze 69 more: 70 from the jump to
  the page, against 68.
* That the first dark frame is the jump's is confirmed by the water: in RPG_RT
  it stays still from the first frame of the fade to the last, both included
  (Caranday measured it). So the jump's tick doesn't count for the animations
  either.

easyrpg is no use as a referee for the fade: its transitions —35 frames of
`Update` plus those of `AsyncNext`— take longer than the RPG_RT measured. What
rules is the measurement.

## The fix

* `op_delay` stores one less, except for zero (a `Wait 0` still cuts the tick,
  which is easyrpg's "0.0 waits 1 frame"). It applies to every wait that
  compiles to `OP_DELAY`: `Wait`, and those of `TintScreen`, `FlashScreen`,
  `ShakeScreen`, `FlashSprite`, `MovePicture` and `ShowBattleAnimation` with
  "wait".
* `start_fade` paints the fade's first step on the same tick as the jump —the
  brightness and nothing else: the loading is still `fade_tick`'s— and adds
  that tick to `frozen_ticks`.
* The fade lasts `FADE_TOTAL = 68` ticks counted from the jump's; the ramp is
  still 24 steps each way, and the black in the middle loses two.
  `FADE_FRAMES` and `FADE_BLACK` are gone. The cut starts at half minus one
  (`FADE_CUT`), so the jump's tick is already black and the next one loads:
  before, the black fell on the next one.

## The numbers

With the new test, `rpgmaker/test_teletransporte_contra_rm2k.py`, which
measures the same through RAM:

|                         | RPG_RT | ROM before | ROM now |
|-------------------------|--------|-----------|-----------|
| from the first step to F | 89     | 91        | 89        |
| the fade, from F to J    | 67     | 68        | 67        |
| from J to the first step | 2      | 2         | 2         |
| the whole round          | 158    | 161       | 158       |

And the third round: by the image, with Caranday's scripts, the camera moves
**90 frames** (dx 96, dy -84), same as in RPG_RT; before, 91 (dy -86). The
water: `frozen_ticks` goes up during the 68 ticks from F to J, included.

## What moved as a side effect

* **`Recorrido.esperar_el_control` no longer presses A with control
  returned.** With the fade two ticks shorter, on arriving at Sector 35 the page
  finished before the A of the eight-tick window, and the A talked to the car,
  which is in front: back to 36 with the choice open, and ten tests stuck
  there. The A of that wait is for the messages; now it asks whether there's a
  page running right before pressing. With that no golden of the playthroughs
  changed.
* `test_borrar_con_el_corte` now asks for black on the jump's tick (0) and the
  load on the next (1).
* **44 goldens of the suite**, in a separate commit with only goldens. All of
  them are shifts in time: the wait one tick shorter, or everything that
  happens after a teleport two ticks earlier (and the ChipSet animation two
  steps less frozen, in those that arrive through `ir_al_mapa`). Separated by
  building with the wait alone: the wait alone already moves `lugar`,
  `parar-rutas`, `savepoint-guarda`, `tram`, `autos9`, `core-puerta`,
  `sacudir`, `sacudir-borde`, `cinematica`, `apertura`, `8-left`, `manta` and
  `cartel`; only the fade, `3-down-56`, `8-right`, `fuego-20`, `talan`,
  `puerta-8-9-120` and the four of `transicion-*`, which are the ramp itself
  halfway through. Side by side, with the difference in red, in
  `/shared/capturas/2026-09-29-teletransporte/`.

**The merge awaits taro's approval of those goldens.**

## What's left

* `PanScreen` with a wait has the same extra tick —`op_pan` stores the whole
  `GetPanWait()` and cuts the tick— and wasn't touched: there's no RPG_RT
  measurement asking for it, and it moves other goldens. Zero was already fine.
* The tests' save that arrives through `ir_al_mapa` still freezes one tick
  more than a real `Teleport` (68 against 67 plus the jump's), as before: it's
  the harness, which requests the fade from outside.
* What `just pruebas` doesn't cover: the cut measured against RPG_RT. It was
  moved by analogy with the fade, not recorded.

## When merging

Nothing to install: no Rust project changes and no script gets renamed, and
the runtime is read by the global `rm2k-snes-cartridges` from the main
checkout. With `main` merged (`2be90714`), `just pruebas` and `just -f
tools/justfile test` green.

What to look at while playing: any door or `Teleport` —the fade starts on the
same frame as the jump and is two frames shorter— and the cutscenes' waits,
one frame shorter each.
