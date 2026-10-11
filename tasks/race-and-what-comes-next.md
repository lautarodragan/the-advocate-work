---
name: "The race and what comes next"
description: "Plan: the car chase (49 to 54) and 64 in release, the end of the demo after the race, and the map rule by id"
type: feature
status: done
---

# What

What follows `lashe-city-hasta-la-carrera.md`. taro asked for it on
2026-09-27: if it fits, **the race** (49 to 54, and 55 if needed) **and 64**;
then, if there's still room, **83 and 84**, so that the rule for which maps
`release` carries stops being the `MAPAS_DEL_JUEGO` list in
`tools/ensamblado/cartuchos.py` and becomes "the maps with an id below X" plus
a short `--exclude-maps`. The end of the demo, which today is in the fork of
36 (`parches/manual/mapas/Map0036.json`), moves to after the race.

This is the plan; the milestones below become tasks of their own when
launched.

Everything measured here is from 2026-09-27 on `91a84c4` (the merge of Lashe
City's milestone 4), with variants of `release` built separately —neither
`release` nor `cartuchos.py` were touched—. The scripts were left in
`/extras/scratch/carrera-plan/`: `armar.py` builds a variant (`release` with
extra or fewer maps), `medir.py` gets the space with `AGENTS.md`'s method (a
`.res N, $00` in the segment and `ld65`'s message; bank 1, up to the last
non-zero byte), `far.py` measures bank 1 even when it no longer fits,
`culpables.py` is the previous plan's `medir.py` (which command stops each
page), `perdidos.py`/`seguir.py`/`foto.py`/`intro.py`/`volante.py` run the race
in the emulator, and `arreglos-temporales.diff` is the two converter fixes
that were needed to build the X = 85 variant (see milestone 4).

# The walkthrough

    36  "We've got to get out of here" ......... Teleport [49, 1, 26]  (today: end of the demo, fork)
    49  first lap. RaceControllerZERO: four messages, black screen,
        the controls sign (ShowPicture 'EscapeInst') and a
        KeyInputProc that waits for any key; turns on 171
        RaceController1 (autorun): theme, removes everyone from the party and
        adds CarRED (19) or CarBLUE (20) depending on 130/131, PanScreen,
        turns on 170
        RaceController2 (parallel, 170): pushes the hero to the right every
        frame and changes his lane with up/down (KeyInputProc without waiting)
        events 4 to 37 (parallel): the cars. Each one reads its cell
        (ControlVars class 6) and compares it with the hero's; if they match,
        it changes the car's graphic, animates the crash, turns on 172 and
        jumps to 50
        events 38 to 43 (parallel), x = 255: the finish line, jumps to 52
    50  ResetRace: counts the crashes (var 38); with five or more the companion
        offers to drive (ShowChoice) and jumps to 51; if not, it goes back to
        the lap it was on (49, 52 or 54, through switches 174 and 178)
    52  second lap: the same, without the intro. Finish -> 54
    54  third lap. Finish -> 51
    51  the bridge: 12 parallel pages on column 75, the jump (a forced route
        with sounds inside) -> 53
    53  RaceFinished (autorun): the reward according to the crashes —gold and
        items— -> 64
    64  Leaving Lashe City Scene (autorun): the scene with the companion; it
        ends in Teleport [66, 71, 29], the world map, which doesn't fit in VRAM

55 is the race's folder: nobody jumps there, and it isn't needed.

**83 and 84 aren't reachable**: 83 is reached from 82 and 84 exits to 66, and
both hang from the world (66), which doesn't fit. Putting them in is only for
the rule.

# Space

Measured with `medir.py`. "Bank 0" is what's left in `TABLAS`+`CODE`; `BSS`
and `ZEROPAGE` don't move in any variant (109 and 4 bytes) and are omitted.

    variant                                 cartridge bank 0  bank 1
    release today                            70.9%     211     10,266
    (a) + 49 50 51 53 54                     72.3%     205     10,266
        + 55                                 72.3%     205     10,266
    (b) + 64                                 71.1%     211     10,266
    (c) + 83 84                              71.1%     211     10,266
    (a)+(b)+(c)                              72.6%     205     10,266
    the race + 64 (milestone 1's)            72.5%     205     10,266
    (d) X = 65, all                          73.9%     201     10,266
        X = 65 without 15 22 46 55 58        72.5%     205     10,266
    (d) X = 85 without 66 67 69 (*)          82.3%     129     10,033
        X = 85 without 15 22 46 55 58 66 67 69  81.0%  133     10,033

    (*) only builds with milestone 4's two converter fixes

Lashe City's milestone 4 is already inside these numbers: the bank 0 it left
is the first row's. `test-special` carries none of these maps.

**The cartridge has room to spare**: what each map costs in ROM is tens of KB
and almost 30% is left free. **What's tight is bank 0**: the race eats 6
bytes, and each engine fix the race asks for costs on the order of ten (see
"What it's missing"). X = 85 eats 72 more.

Bank 1 has had slack since milestone 4, which moved `tropa_codigo` and
`mensajes_tropa` to RODATA. Before that X = 85 didn't fit: 76 (Sorbe Mountain)
brings new troops and overflowed by 2,314 bytes.

Without MSU-1, the race and 64 (two new themes, `Fire_Mustang_…` and
`prepara`) lower six (theme, instrument) pairs and raise two; the worst is
`wb3mlair` program 33, from 23.3 to 13.3 kHz. It goes to
`el-audio-despues-de-lashe-city.md`.

## What doesn't fit with X = 85

    66  Lashe Area: "can't carry a message window: it spends 527 background
        tiles and 222 sprite tiles" (the same reason it's left out today)
    67  Yun Town: "the timer doesn't fit: the map already uses the 8 sprite
        palettes"
    69  Sorbe Village: "with this VRAM layout, the overlay needs 157 tiles and
        128 fit"

And **two latent converter bugs**, which this variant uncovered and which
aren't X = 85's but any cartridge's with another layout:

* **A page's own route points to the wrong code block** when the block is
  deduplicated: `tabla_de_paginas` in `snes_convert.py` builds the route's
  pointer with `"evcodigo_%d" % numero` —the same bug its own docstring says
  was fixed for the code— and the assembly fails with "Symbol 'evcodigo_82' is
  undefined". The fix is to use the `evcodigo` label it already receives.
* **`actor_hpmax` and `actor_spmax` go to RODATA without `.bloque`**
  (`words_asm(..., declarar=False)`), so `bancos.py` can split them across two
  banks. With the X = 85 variant the cut fell in the middle of a word and
  `bancos.py` refused; if it falls between two words it doesn't refuse, and
  the ROM reads whatever is at `$xx:0000` for the actors at the tail. Need to
  check whether there are more tables like that.

## What comes out of X

**Recommended: X = 65**, that is the whole Lashe City chapter. They all
convert; the exclusion list would be

    58  Aura Tutorial: from another chapter (hangs from Tutorials, 161). It
        brings its own theme and two animations: 46.7 KB and 4 bytes of bank 0
    15 22 55   folders (Lashe City, The Rat Tracks, the race's): black,
        nobody jumps there
    46  Security Footage 2: an unreachable backup
        (the four together: 12.9 KB and no bank 0)

plus 164 (AG7's tutorial) as an explicit addition, because the rule by id
doesn't reach it, and the `MAPAS_DE_PRUEBA` as today (52 becomes part of the
game).

X = 85 brings in 18 maps that can't be reached (the world doesn't fit), costs
8.5% of the cartridge and 72 bytes of bank 0 more than X = 65, and its
exclusion list starts with eight ids. It makes sense the day 66 goes in.

# What it's missing to work

Counted with `culpables.py` on the variant with the race and 64:

    map   compile   what stops it
    49    43 of 44  KeyInputProc without waiting (RaceController2)
    50     1 of 1
    51     8 of 9   KeyInputProc without waiting
    52    42 of 43  KeyInputProc without waiting
    53     1 of 1
    54    42 of 43  KeyInputProc without waiting
    64     3 of 4   Teleport -> 66
    83    58 of 58
    84     3 of 4   Teleport -> 66

No event of these maps calls a common event, and no parallel or autorun common
event looks at the race's switches (AG7's 37 is left out: the race removes AG7
from the party).

**What was already known, corrected:**

* **Class 6 `ControlVars` isn't missing.** The race's 268 ask for x or y
  (sub-operands 1 and 2, 134 each), which the ROM has done since before this
  plan. The comment in `MAPAS_DEL_JUEGO` that says the race is left out
  "because of class 6 `ControlVars`" is stale.
* **Parallel pages: 41** on 49, 52 and 54 (40 cars and finish lines, plus the
  steering wheel) and **13** on 51. They fit in `PARALELO_MAX` (48).
* **`KeyInputProc` without waiting**: four pages, each lap's steering wheel.
  The `raise` of `KEY_INPUT_PROC` in `eventos.py` stops it for a reason that no
  longer exists —the Python reference went away on 2026-09-16—, and the ROM
  has it done.

**What was measured running the race** (a variant with
`TECLA_SIN_ESPERA=1`, which accepts the steering wheel), in order of how much
it unblocks:

1. **A `Teleport` from a parallel page isn't handled if no foreground page is
   running.** `op_teleport` sets `salto_hay`, and `eventos_tick` only looks at
   it after running a foreground page: with the foreground idle it exits
   through `nada`. On 49 the crash turns on 172 and the car stays at (104, 26)
   forever —400 ticks looked at—, without jumping to 50. **They're 126 pages,
   all the race's exits** —40 per lap plus 6 on the bridge— and no `release`
   map has one today: it's a path nothing runs. General (it's what RM2k does
   with any parallel), on the order of ten bytes of bank 0 and no RAM.
2. **The steering wheel doesn't turn.** `op_key` uses `tecla_valor`, which
   looks at **edges** (`pad eor pad_ant`) in both forms; easyrpg uses
   `Input::IsPressed` for the one that doesn't wait
   (`game_interpreter.cpp:3222`, `wait ? IsTriggered : IsPressed`), and the
   comment of `KEY_INPUT_PROC` in `eventos.py` says the same. Holding up,
   variable 33 stays at 0 and the car changes lane only once. General, about
   ten bytes of bank 0. Once that's fixed, need to check that the lane change
   survives the steering wheel setting the route to the right again every
   frame (the order between the hero's route and the parallels).
3. **The race runs at half speed.** With the 40 car pages, **each tick costs
   two frames**: 2.07 frames per tick on 49 and 2.02 on 52, measured with
   `cuadros_perdidos` over 300 ticks. 51, with 13 pages of the same shape,
   doesn't drop any, and neither does `release` on 52 (with the car pages not
   compiled). It matches what `chips-sa-1-y-s-dd1.md` estimated (~9 lines per
   page, ~370 lines). It's playable, but at 30 frames. The general thing is
   `optimizar-los-eventos-paralelos-al-compilar.md`: the 40 pages are the same
   pattern —read its own cell into two variables and compare them with two
   others— and a fused opcode would do it in native code. One opcode, on the
   order of ten bytes of bank 0 for its entry and a hundred of bank 1, plus the
   recognizer in the compiler. It also works for map 11's lights.
4. **The controls sign isn't visible.** The intro's `ShowPicture
   'EscapeInst'` is accepted without being done, and the ROM carries a single
   sign, which is the "One year previously" one. The player sees the black
   screen and has to press a key without anything telling them. It's a 276x205
   image on black with the text "Use the UP and DOWN arrow keys to change
   lanes, and avoid the traffic! Fewer crashes means better rewards! Press any
   key to begin."
5. **The bridge jump's sounds** (route order 35, six routes of 51) are dropped
   when compiling. It's `los-sonidos-adentro-de-las-rutas.md`.
6. **The end of the demo**: 64 jumps to 66, which doesn't fit. A fork of 64
   goes in with the same sign and the `ReturntoTitleScreen` that 36's has
   today, and 36's fork is deleted.

What worked, seen in the emulator: the intro with its messages and the wait,
171, the party change to the car, the `PanScreen`, the push to the right, the
cars that move on their own and the crash (the graphic that changes and the
animation). 50, 52 through its entrance, 51 through its entrance, 53 and 64
weren't reached: without point 1 you don't get out of 49.

**52's tests.** 52 is a test map (`test_caminar_golden.py`, `en-52`,
`grupo-11-en-52`, `pelea-en-52`, `ev41`). With 50 and 54 in the cartridge its
40 car pages compile, and with the steering wheel accepted the hero there gets
pushed to the right every frame: `KEY_INPUT_PROC`'s comment already warns that
`heroe 52` stops ending. Another big map has to be picked for `heroe`, and 52's
other goldens looked at before considering the milestone good.

# Milestones

**1. The race goes in and can be raced, at 30 frames.** 49 to 54 and 64 in
`release`; the end of the demo moves to 64's fork and 36's is deleted; the
`Teleport` from a parallel (1) and the steering wheel with `IsPressed` (2); the
`KeyInputProc` without waiting accepted, without the measurement switch. The
tests: 52 out of `heroe`, 52's goldens reviewed, the close of 36 which now
goes into 49 (`test_recorrido_lashe_*` change: "leaving ends the demo" becomes
"leaving leads to the race") and a walkthrough of the whole race, which the
harness can drive by holding keys. Bank 0: 6 bytes from the maps plus the two
fixes, on the order of twenty.

   **Done on 2026-09-27**, with questions 1, 3, 5 and 6 answered with the
   recommendation: see `carrera-1-entra-y-se-corre.md`.

**2. The race at 60 frames.** The fused opcode (3), or whatever the
measurement in `optimizar-los-eventos-paralelos-al-compilar.md` says. It's
considered done with `cuadros_perdidos` at zero —or almost— on 49, 52 and 54
while driving. Independent of 3 and 4.

   **Done on 2026-09-27**, with the fused opcode and what the measurement said:
   see `carrera-2-a-sesenta-cuadros.md`, which has each path's limit.

**3. What's seen and heard.** The controls sign (4) and the jump's sounds (5),
according to what taro answers.

   **Done on 2026-09-27**, with option (a) of question 4: see
   `carrera-3-lo-que-se-ve-y-se-oye.md`.

**4. The map rule by id.** `release` becomes "the maps with an id below X,
without those in `--exclude-maps`, plus the additions" —today 164— and the
test ones as up to now. First the two latent converter bugs (the deduplicated
own route and the actor tables without `.bloque`), each in its commit and with
the ROM byte for byte identical where nothing changes. Then the rule change,
which **must not move the ROM**: with X = 65 and the exclusion above, the
resulting list has to be the same as this milestone 1's, and that gets
compared. It can go before, in parallel with or after 2.

   **Done on 2026-09-27**: the bugs in `9d6c0d3`, the rule in
   `la-regla-de-mapas-por-id.md`. The exclusion isn't a converter flag but a
   value in `cartuchos.py`; the why is there.

**5. (Conditional) X = 85.** Only if taro wants it before the world goes in:
the 18 unreachable maps, with 66, 67 and 69 in the exclusion.

What has to be split if 1 and 2 go in parallel: 2's opcode, in
`tools/protocol/events.toml`; and `cartuchos.py`, which 1 and 4 touch.

# Questions for taro

1. **X = 65 or 85?** 65 is all of Lashe City and leaves 83 and 84 out: they
   can't be reached until the world (66) goes in. 85 brings them in together
   with another 16 equally unreachable ones, for 8.5% of the cartridge and 72
   bytes of bank 0. **Recommended: 65.**
2. **The X = 65 exclusion**: only 58 (the other chapter's tutorial, which is
   the costly one: 46.7 KB), or also the three folders and the backup (15, 22,
   55, 46: 12.9 KB)? **Recommended: all five**, so that what goes in is what
   can be stepped on.
3. **Is the race at 30 frames OK as an intermediate step** (milestone 1
   delivered before 2), or isn't it delivered until it runs at 60?
4. **The controls sign**: (a) a fork of 49 that swaps the `ShowPicture` for a
   `ShowMessage` with the same text —cheap, and the screen is already black—;
   (b) a second sign per ROM (`sistema-de-imagenes.md`); (c) debt.
   **Recommended: (a).**
5. **Where the demo ends**: at the end of 64's scene, instead of the jump to
   the world, or earlier, on leaving 53 with the reward? **Recommended: 64**,
   which closes the scene with the companion.
6. **`heroe`'s big map**: 52 stops being useful (the race runs there). Is it
   replaced by another of the big ones already in (8, 11 and 20 are already on
   the list), or is removing it enough?
