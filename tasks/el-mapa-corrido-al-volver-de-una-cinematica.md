---
name: "The map shifted after returning from a cutscene"
description: "The drawn tiles end up one or two cells above the collision"
type: bug
status: done
---

Taro reported it on 2026-09-22, and says that **at some point it worked
fine**.

After the Neon Vipers sequence —map 14, `NV Get Talan to Work`— and leaving
through its cutscene to the Lashe City map it was entered from, **what's drawn
ends up shifted one or two cells upwards relative to the collision**: you walk
over walls and bump into thin air, and the teleports are shifted the same
amount. **The collision and the events agree with each other**: the one lying
is the drawing. **Any teleport fixes it.**

## The cause, with the code in front

`stream_map` redraws **a single row and a single column per iteration**, and
records the complete new position:

    lda camara_y / lsr a x3      ; la fila de 8 px
    cmp win_row / beq sin_fila
    sta win_row                  ; anota la fila nueva, salte lo que salte
    jsr build_row                ; pero dibuja UNA

Its own comment states the premise and who was going to break it: *"La
cámara se mueve como mucho dos pixeles por vuelta y sólo por un eje... Si
algún día la cámara pudiera saltar —un teleport, un cambio de mapa— eso no es
un ajuste de esta rutina sino un `fill_window` entero"*.

The premise no longer holds, and from two measured sides:

* **`PanScreen` moves the camera besides the hero** (`pan_px`/`pan_py` go
  into `follow_camera`). The ones of map 14 are horizontal at 2 px per frame,
  but the game has pans of **8 px per frame** (speed 6, `2 << vel` in 1/16 of
  a px);
* **the hero no longer always walks at 2 px**: `paso_medio_por_vel` is
  `2, 4, 8, 16, 32, 64` in eighths of a pixel, that is **up to 8 px per
  frame** at speed 6.

Both add up on the same axis. With more than 8 px in one iteration a row is
skipped, and since `win_row` is recorded as if it had been drawn, **the old
row stays there forever**: the window is a torus —cell `(mx,my)` lives in
slot `(my mod 32)`— so the effect is exactly "everything shifted one or two
cells". And any teleport fixes it because it refills the whole window.

## What's missing

Reproduce it in the harness —a fast route plus a pan, or map 14's sequence—,
fix it and leave the test. The likely fix is that `stream_map` catch up with
the camera in a loop instead of assuming one row, and that a big jump ask for
`fill_window`.

# What was done, on 2026-09-22

**The hypothesis above was the right one, and the pan is what dominates.**
What remained to be measured was how far the camera can jump in one
iteration, and it's **two rows**: 8 px of the hero at speed 6
—`paso_medio_por_vel` reaches 64 eighths— plus 8 px of a `PanScreen` at speed
6 —`2 << 6` sixteenths—, on the same axis. The hero's jump does **not**
reach it: the longest in the game is five cells in eleven frames, 7.3 px per
frame, measured over the 410 jumps in `data/maps/`.

Reproduced with two cases, `camara-veloz` and `camara-veloz-x`, and checked
against VRAM and not against the screen: it can't be got from a PNG, because
the window is a torus and a skipped row looks like a plausible map shifted
one cell. `Partida.ventana` asks which cell each slot holds and compares it
against the same thing arriving by a teleport. See
`pruebas/rpgmaker/test_camara.py`.

`stream_map` now does up to two rows and two columns per iteration, advancing
the edge **one at a time**: if some day the camera jumped further, `win_row`
falls behind instead of lying and what's missing gets drawn in the following
iterations.

What it costs, measured with `cuadros_perdidos` and map 11, which is the one
with the least margin: **zero** in the case that exercises the fix —two rows
per iteration for 120 frames, +44 dropped frames before and after— and up to
+2 out of 120 in normal walking.

## What showed up along the way, and is another bug

**A hero jump that is the last order of its forced route hangs forever**,
with the hero floating mid-arc. `move_hero` only calls `paso_de_ruta` while
`ruta_i < ruta_n`, and `paso_de_ruta` is the only one that lowers
`ruta_salto`; when the jump is the last order, the route is already consumed
on the next frame and nobody advances it any more. Measured with the case
`camara-salto-colgado`: `ruta_salto` stays at 232 and `hero_y` at 323 with
the destination cell at `tile_y = 22`, forever.

It's what taro describes on map 11 —Talan floating while the text is
shown—, and **196 of the game's 410 routes with a jump end in the jump**.
`hay_rutas` doesn't look at `ruta_salto` either, so a `ProceedWithMovement`
right after doesn't wait for the jump. It wasn't fixed here on purpose: it
goes in its own task.
