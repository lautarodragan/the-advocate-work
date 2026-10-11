---
name: "Race 2: at 60 frames"
description: "The race's three laps (49, 52, 54) without dropping frames while driving: profile where the time goes and measure the limit of each path"
type: refactor
status: done
assignee: taro
---

# What

Milestone 2 of `la-carrera-y-lo-que-sigue.md`. It starts from `main` at
`69e66ed`. It's considered done with dropped frames at zero or nearly so on
49, 52 and 54 while driving, and a test has to enforce it: the walkthrough
`pruebas/abl/test_recorrido_carrera_golden.py` already drives with a pilot.

What was measured before starting (milestone 1), driving and only on ticks
with switch 170, with no message or fade:

    map    hardware frames per tick
    49     2.07
    52     2.04
    54     2.04
    51     1.00   (13 pages)

Reserved numbers: opcode 0x31 (and 0x33 if a second one is needed) and far
RAM $7E7980-$7E799F. Used: 0x31 (`OP_CELL_TEST`) and the first 16 bytes of
the RAM (`NPC_FILA_APARTE`); 0x33 wasn't needed.

# Where the time goes

Measured with a line profiler that isn't committed: a mark at each boundary
reads the PPU's vertical counter (`SLHV`/`OPVCT`) and adds the lines since the
previous mark to the corresponding bucket. Each mark costs ~1.4 lines, so it's
run twice —one mark per site and two— and the cost is subtracted (`2 * simple
- doble`). The frame's work is everything that isn't waiting for vblank; **it
fits in one frame if it's under 262 lines**.

Lines per tick, at `69e66ed`:

    bucket                             49     52     54     51
    parallels' bytecode               201    195    196     27
    parallels' loop (state, list)      66     68     69     12
    finding the route slot + queue     41     36     10      2
    refrescar_npc of the moving ones   37     28      -      -
    cuadro_de_ruta_ev of moving ones    9      6      -      -
    build_oam                          44     43     40     20
    camera and stream                  26     21     20     15
    hero, menu, timer                  15     13     13      1
    start of vblank                    16     14     12     11
    everything else                    ~9     ~8     ~9     ~6
    WORK                              464    432    367     94

Per car parallel page (41 on each lap): ~4.8 lines of bytecode —`OP_VAR` class
6 twice, an `OP_IF_VAR` that fails and the `OP_DONE`—, ~1.6 of the loop that
loads and saves its state, and ~0.25 of finding whether it has a route slot.
The five moving cars on 49 (four on 52) cost ~16 lines each between their
route and `refrescar_npc`, and that isn't the parallels': it would be the same
with the pages not compiled.

To fit in one frame, 49 has to go from 464 to under 262, that is ~200 lines,
and with margin for the heaviest ticks.

# The paths, each with its measured limit

Each row is a step on top of the previous one, in the order it was done: work
lines per tick (average, corrected for the marks) and hardware frames per tick
while driving. What each step saves is measured, not estimated.

    step                                        work 49/52/54      frames/tick 49/52/54
    69e66ed                                       464/432/367       2.07/2.04/2.04
    1 variables via long addressing,              417/ - /325       2.03/2.03/2.04
      equality without comparar_var, class 6 first
    2 OP_CELL_TEST through the dispatch           352/324/262       2.02/2.01/1.53
    3 parallels' list and state, long             337/ - /248       2.02/1.92/1.36
    4 the route slot remembered (PAR_RANURA)      303/280/ -        2.00/1.75/1.23
    5 the shortcut: OP_CELL_TEST without the      280/252/207       1.61/1.29/1.07
      interpreter
    6 the NPC's row remembered in the slot        262/243/ -        1.32/1.18/1.07
    7 bank 1 through the fast mirror,                               1.18/1.13/1.05
      OP_CELL_TEST with offsets, par_dir at once  236/ - / -        1.12/1.09/1.05
    8 clear_oam unrolled in bank 1                226/ - / -        1.10/1.08/1.04
    9 the collisions and the step two cycles      220/ - / -        1.07/1.05/1.04
      cheaper: celda_bloqueada and pasa_con_evento
      back to front, npc_swap unrolled, build_oam's
      discard by X in the loop
   10 pasa_hay: with no tile events that impose,                    1.03/1.03/1.04
      pasa_con_evento walks nothing
   11 ptr_de_celda with the multiplier                              1.03/1.03/1.04
   12 the OP_CELL_TEST parallels in one go         p50 197/186/157  1.03/1.02/1.04
      (paralelos_celda, in bank 1)
   13 acomodar: find the place and shift the                        1.02/1.02/1.04
      rest with mvn/mvp, instead of swapping

(The 1.04 of 54 is a single tick of 27 frames when the lap starts, when the
theme plays and its samples get uploaded: with the car still at the start.
Without the ticks before the car sets off, see below.)

What each path says, as a limit:

* **The general interpreter** (step 1 and, estimated, a shorter dispatch): the
  bytecode drops from 201 to 155 lines on 49, 23%, and the dispatch with the
  opcode already doubled in the bytecode would save ~10 cycles per opcode,
  some eight more lines. With that 49 ends up at ~410 lines: **still at two
  frames per tick**. It isn't enough on its own, but it's general and it
  stayed.
* **The fused opcode through the dispatch** (step 2): it brings the bytecode
  down to ~90 lines, 2.3 per page. On its own, 49 and 52 **stay at two
  frames**: what was left was the parallels' loop (loading and saving each
  one's state), finding the route slot and the step of the moving cars.
* **The fused one without the interpreter** (steps 5 and 12): a page that
  starts with `OP_CELL_TEST`, isn't in the middle of anything and doesn't get
  past the condition needs neither `correr_codigo` nor saving its state. This
  design's floor is the condition itself —two writes and a comparison, ~200
  cycles, one line— plus reading the list and the state: **~1.7 lines per
  page**, ~70 for the 41 of a lap, against ~310 at the start.
* **"Run the parallels only when something changes cell"** (idea 2 of
  `optimizar-los-eventos-paralelos-al-compilar.md`): not done, and its limit
  is zero for what matters. The hero advances half a cell per tick, so he
  changes cell every two ticks and on those all 41 run anyway: the heaviest
  tick doesn't go down. Besides, all 41 write the same two variables (36 and
  37) every frame, and skipping them changes what's left in them.
* **The rest of the frame**, which isn't the parallels': the moving cars
  (their route, `refrescar_npc`, reordering their row), `build_oam`, the
  camera. With the parallels already at ~70, what dropped frames were **the
  ticks on which four or five moving cars start their step at the same
  time**: each new step asks whether it can enter the cell (`puede_celda`: the
  grid, the tile events, who's standing there) and the car changing lane
  jumps at once past the seven or eight of the neighbouring lane in the
  drawing order. Steps 6 and 8 to 13 are that, and they're general: any map
  with moving events takes advantage of them.

# How it ended up

Two commits: `2345738` (the variables and `OP_CELL_TEST`, with the compiler)
and `da466bb` (the parallels without the interpreter, the remembered slots and
rows, the collisions, `acomodar_npc` and the OAM); then the merge with `main`
and the ceilings. What each piece does is in its comment; here, what isn't
visible in the code.

* **`OP_CELL_TEST` doesn't change the semantics.** It does the two writes
  —with their refresh— and the two comparisons, each with its destination,
  same as the four separate opcodes. The compiler builds it with what they
  would emit (`_pieza_de_celdas`), so the validations are the same.
* **Neither does the shortcut**: it's the interpreter's first iteration and
  the second (`OP_DONE`), without going through the dispatch. What's skipped
  is saving a state that stays the same: with no wait and no page half run.
* **`PAR_RANURA` is cleared in `limpiar_paralelos`**, right next to
  `load_npcs`, which is where all the slots get released: within a map a slot
  is never released. The remembered row of `npc_de_ranura` and `pasa_hay` can
  go stale, and that's why the row is validated and `pasa_hay` is only ever
  turned on.
* **`acomodar_npc` leaves the same order** as the one-by-one swaps: it
  searches with the key of the row that changed and shifts the ones in
  between. The goldens of the walkthroughs that walk NPCs enforce it.

## Frames per tick at the end

Driving: with 170, no message or fade, on the same map at the start and end of
the tick, **and with the car off the starting line** (x >= 4). That last part
removes the ticks on which the lap sets its theme and its samples get
uploaded, with the car still: one of 27 frames on 54 and one of 8 on 52, which
were already there at `69e66ed` and aren't about driving.

    map    69e66ed        at the end
    49     2.06 (979)     1.02   (21 of 979 ticks with an extra frame)
    52     2.04 (546)     1.004  (2 of 546)
    54     2.00 (574)     1.00   (0)
    51     1.00           1.00

What's left for 49: the ticks on which the five moving cars start their step
at the same time —five `puede_celda`, and the reordering of their rows—,
which exceed 262 lines by 1 to 35.

## The test

`test_la_carrera_entera` counts the hardware frames of the driving ticks of
each lap, with the same criterion, and fails with more than `CUADROS_DE_MAS`
(5) extra per hundred. Against `69e66ed` it fails: "la vuelta del mapa 49
gastó 2017 cuadros de hardware en 977 ticks: 1040 de más".

## Space

Measured with `AGENTS.md`'s method on the merge with `main` (`fdf7593`):

    cartridge     bank 0             BSS   ZEROPAGE   bank 1
    release       344 B (189 before) 138   4          ~9.3 KB
    test-special  1,120 B            138   4          ~10.4 KB

(The 29 extra BSS bytes are `main`'s: the hero's route stopped being copied to
a buffer.) Bank 0 gained: `clear_oam`, `npc_swap`, `npc_va_antes` and
`acomodar_npc`'s loop went to bank 1, and the new code lives there.

## The ceilings

On the merge, `test_el_tema_no_recorta_en_su_pico[dcbest]` went red (two
samples at the cap); separately both branches passed. It's what that test
warns about: the peak moves with when each DSP write lands within the frame,
and the milestone changed the duration of almost every frame with moving
NPCs. `just techos` re-measured it (`33e78c4`).

# Tests

`just pruebas` green on `da466bb`, and on the merge with `main` with the
ceilings table re-measured. No golden changed. New cases in
`pruebas/herramientas/test_paginas.py`: the shape of `OP_CELL_TEST`, the
destination of the inner branch's `else`, and that without the exact shape it
doesn't get fused.

# What taro has to test while playing

* The three laps: that they feel at full speed and not at half, and that the
  steering responds the same as before. Crash, and that 50 returns to the lap.
* That the moving cars (the ones that change lanes up and down) are drawn
  right when crossing the others: who covers whom changes with
  `acomodar_npc`.
* On any other map with people walking —Lashe City, 11— that the drawing
  order and the collisions with NPCs stay as before.
* Map 11's lights and any page that checks whether the hero is on a cell: they
  go through `OP_CELL_TEST`.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including
the path of selling the Idol, bribing the guard and taking AG7 along; the race
without lag or bugs (the companion at the wheel, too). Separate from this: the
black hero after changing graphic on the same map (Lazer Teeth HQ, Boss Wick).
