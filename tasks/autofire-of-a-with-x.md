---
name: "Autofire of A with X"
description: "Holding X presses and releases A on its own, to skip through text and repeat choices without mashing the button"
type: feature
status: done
---

taro's idea, on 2026-09-25: RM2k uses two buttons and the SNES controller
has many more, so a spare one can act as autofire, as in the
emulators. **Only A, with X.** B was ruled out: on the map B opens the pause
menu and inside it closes it, so holding it would open and close it without
stopping.

**Where:** all input goes through `read_pad` (`rom/src/control.s`), which leaves
`pad` (JOY1H) and `pad_a` once per frame; nobody else reads `JOY1H`/`JOY1L`, and nobody
looks at X. With X pressed, `pad_a` turns on and off every **four
frames** —some 7.5 presses per second; taro asked for between 3 and 4 to
start with—, as a named constant so it can be tuned while playing. Since the game
looks at A's edge (RM2k closes the message with `Input::IsTriggered`), each
return to "pressed" is a new press.

**Watch out:** that A really pressed wins over the autofire; that releasing X does not
leave A stuck pressed nor fire an extra press; that the counter does not
live in uninitialised memory (`test_cores.py`).

**It is a divergence from RM2k, even though it only adds**: it is noted in
`workflow/divergencias/` so that nobody takes it for a bug.

**Tests:** no golden should change —the harness never presses X—. A
new test holds X and counts the A presses the game sees (for example,
how many messages in a row it closes), and another that releasing X does not leave anything stuck.

## How it turned out

In `read_pad`: with X pressed, `pad_a` is the real A OR the
autofire's phase, which comes from bit `AUTOFIRE_CUADROS` of a loop counter; with X
released the counter goes back to zero, so the next X presses on its first
frame. The counter is in low RAM (`autofire`, at the end of
`ram_baja.s`) and not in zero page, where three bytes were left: in absolute addressing
it costs four more bytes of code, and it is safe because `read_pad` already reads
`JOY1L` in absolute. `arranque` sets it to zero.

Cost, measured with the `.res` of `AGENTS.md` against the tree from before: **29
bytes** of `TABLAS`/`CODE` in the three cartridges (`release`, `tests/main`,
`tests/special`), one of BSS, nothing of zero page. The new case adds nothing
to bank 0.

Tests: `tests/rpgmaker/test_autofire.py` and `test_cores.py::test_autofire`,
with the case `autofire` —five messages in a row, and variable 17 counts the
closed ones—. Seen red by breaking the feature four times:

* `bit #PAD_X` changed to `bit #0` (no autofire): four red —the
  messages, the rhythm, releasing X and releasing X halfway—.
* `sta pad_a` of the path without X changed to `tsb pad_a` (releasing X leaves A
  stuck): red `test_releasing_x_neither_leaves_a_stuck_nor_presses_extra`, phase 1.
* `and #PAD_A` + `sta pad_a` of the path with X changed to `stz pad_a` (the real
  A does not win): red `test_the_real_a_wins` and
  `test_releasing_x_with_a_pressed_does_not_release_a`.
* without the `stz autofire` of the path without X: red the part of "the next X presses
  right away", phase 4.

What no test covers: the `stz autofire` of `arranque`, which only matters
with X pressed from power-on —the harness presses after startup—.

## For taro

* Hold X in a long dialogue: the messages advance on their own; is 7.5 per
  second too much? It is `AUTOFIRE_CUADROS` in `rom/src/control.s` (a power of
  two: 4 gives 7.5/s, 8 would give 3.75/s).
* Hold X in front of someone who talks: it talks to them again on closing.
* In the menus, the shop, the battle and the title: X repeats A (choose, buy).
* A and X together: it has to feel like A alone.
* Release X halfway: nothing has to stay pressed nor an extra press come out.

**Confirmed by taro playing on 2026-09-26: it works well.**
