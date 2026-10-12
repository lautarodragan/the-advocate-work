---
name: "The arrows repeat in the menu"
description: "Holding an arrow in the menu moves the selection on its own after a delay, like RM2k's Input::IsRepeated"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-28: "when holding down a directional arrow inside the
menu, after ~1s, it should start moving the selection continuously in that
direction, at a rate of ~10 items per second (check easy rpg's code to
confirm)".

## What the original does

- **easyrpg** (`src/input.cpp`): `start_repeat_time = 23` and `repeat_time =
  4`, in frames, with `repeated = press_time == 1 || (press_time >= 23 &&
  press_time % 4 == 0)`, and `press_time` is 1 on the frame of the edge. That
  is, it fires on frame 0, on 23, on 27, on 31…: **0.38 s of delay and 15 per
  second**, not the second and the ten that taro remembered.
- **RPG_RT, measured**: the 2015 one with Wine, recording with `ffmpeg -f
  x11grab` at 60 frames the area of the title screen's cursor while `xdotool`
  held down for 2.5 s, and finding the row with the red bar frame by frame.
  The changes land **23 frames after the first and then every 4, without a
  single exception** in thirty-odd repetitions, and they wrap around from the
  last to the first. It matches easyrpg. The 2000 one, which is the one the
  author used, was not measured (it needs `Harmony.dll`).
- **Who repeats**: in easyrpg, everything that is a `Window_Selectable` moves
  the cursor with `IsRepeated` —the menu, items, equipment, the title, a
  message's choices, End Game—, and also `Window_Shop`, `Window_ShopNumber`,
  `Window_BattleStatus` and `Scene_File`. A, B and X do not: they are
  `IsTriggered`.
- **Wrapping around while repeating**: `Window_Selectable` distinguishes press
  and repeat, but with `endless_scrolling = true` —the default; only a Maniacs
  command turns it off— the repeat wraps around anyway. RPG_RT's title wraps
  too, measured. **`Scene_File` does not**: there only the press wraps around,
  and the repeat stays at the end.
- **The key input** (`KeyInputProc`) with wait is `IsTriggered`
  (`game_interpreter.cpp:3222`): it does not repeat.

## What differed in the ROM

All the screens looked only at the edge: holding an arrow moved the cursor
once.

## What was done

- **A single place, `read_pad`** (`rom/src/control.s`), which calls
  `flechas_repetir` in bank 1. All the screens compute the edge the same way
  —`pad` against `pad_ant`—, so on the repeat frame the held arrows are
  cleared from `pad_ant` and each screen sees it as a new press. **No screen
  was touched** to get the repeat: the menu, items, equipment, slots, title, a
  message's choices, the shop, the battle and End Game have it. The actor
  choice that Ñandú is redoing will have it too if it looks at the edge the
  same way.
- A counter, `flechas_cuadros`, which is reset to zero with a new arrow or with
  none, and on reaching 23 fires and goes back to 19. It never goes past 23.
- `flechas_repetidas` says which bits were faked this frame, for the two places
  that have to tell the difference:
  - `tecla_valor` (`menu.s`, the key input with wait) removes them, with an
    `ora` and an `eor` that do not touch the carry it depends on.
  - `ranuras.s` does not wrap around if the arrow comes from the repeat.
- The two variables in `ram_baja.s`, at the end, and zeroed in `arranque`.

## What is not included

- **One counter per arrow**, like RM2k: it is one for all four. See
  `divergences/one-counter-for-all-four-arrows.md`.
- **easyrpg's other press/repeat differences** were not looked at one by one:
  `Window_Selectable` has them but wraps around anyway, and
  `Window_BattleStatus` and the shop repeat without distinguishing. Whether
  any other RPG_RT screen stops at the end like the slots, is not known.
- `Scene_File` was taken from easyrpg: it was not measured in RPG_RT.

## Tests

- `pruebas/rpgmaker/test_repeticion.py`, hardware frame by frame:
  - in the pause menu, down and up held move on the frame of the edge, at 23
    and every 4;
  - releasing stops it, and pressing again waits the full 23;
  - B held does not repeat (the menu does not open again);
  - in the slots, down held reaches the fourth and stays; a press wraps
    around.
- `test_tecla.py::test_sostener_una_direccion_no_contesta` already covered the
  key input: it goes **red** without the `tecla_valor` guard (the variable
  stays at 2). The menu ones in `test_repeticion.py` go red without the `jsl`,
  and the slots one without its guard: the three things verified by removing
  them.
- **What no test executes**: the repeat in the title, in a message's choices,
  in items, equipment, shop, battle and End Game. It is the same mechanism and
  no screen changed, but there is no case that holds an arrow there.
- No golden changed, and `test_musica_techos.py` stays green: `just techos` was
  not needed.
- `just cartuchos` and `just pruebas` on the branch, with `main` merged in
  (`535b19fd`, without new commits): all green except `test_indice.py`, which
  asked for the new test in `pruebas/README.md`; it was added and that one
  alone was run, green.

## Space

`just espacio`, before and after, in `release` and `test-special`: bank 0
costs 30 bytes (the `jsl`, the `tecla_valor` guard, the two of the slots and
the two `stz` of the startup); the rest, 48 bytes, goes in bank 1; and 2 of
BSS.

## What taro has to look at

Playing, in the pause menu, in items and in a message's choice: holding down,
that after 0.38 s it goes down on its own and at fifteen per second. If it
feels fast, it is what the original does; the two numbers are
`REPETIR_ESPERA` and `REPETIR_CADA` in `control.s`. And in the save screen,
that holding down stays on the last one.
