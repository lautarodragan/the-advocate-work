---
name: "The three clocks of tocar"
description: "Partida.tocar counts in ticks, menu.tocar and Pelea.tocar in frames: three identical verbs with different clocks"
type: refactor
status: done
---

In the harness in `tests/` there are three `tocar`: `Partida.tocar` in ticks, and
`menu.tocar` and `Pelea.tocar` in frames, with different gaps between presses. The
same name for three clocks confuses whoever writes a new test.
It was left un-unified in `tidy-up-pruebas` (2026-09-25) because unifying them
**changes when each press lands**, and that can change what the tests see.
The docstring of `menu.tocar` explains the three.

The cheap option is renaming so the name says the clock; the expensive one, unifying and
measuring again every test that uses them. Measure first how many tests depend
on the exact gap.

## Done, 2026-09-26

Measured first: with `Pelea.tocar` changed to call `menu.tocar` —two
frames pressed instead of as many as the gap—, the five tests that use
`Pelea` (`test_battle`, `test_troop`, `test_victory`,
`test_experience_drawing`, `test_menu_battle_hp_drawing`: 45 cases)
stayed green, and none of them compares against a golden. So those two were
unified; the tick one cannot be, because on a screen that freezes the
clock it never finishes.

Two were left, with the clock in the name, and both in `Partida`:

* `Partida.play_ticks(*botones)`: the one that was `Partida.tocar`.
* `Partida.play_frames(boton, aire=4)`: the one that was `menu.tocar`.
  `Pelea.play_frames(boton="a", aire=3)` hands off to this one.

And two local ones that stay, with their names aligned: `Grabador.play_frames`
in `test_battle_fade.py` —the same press, photographing each frame— and
`_tocar_cuadros` in `test_stack.py` —without `Partida`, one frame pressed—.
The `tocar=` of `Partida.correr` was not touched: it is a scheduled list, not a verb.
