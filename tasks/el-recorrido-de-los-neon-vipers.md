---
name: "The Neon Vipers walkthrough"
description: "A long playthrough that covers the scene where the two bugs showed up"
type: test
status: done
---

**A test that plays the Neon Vipers stretch end to end**: start
in the Lashe City street, climb up the pipe, cross the rooftop, enter the HQ,
walk until the cutscene triggers, go through all the dialogues and return to the
street. taro asked for it on 2026-09-22.

The point isn't coverage in the abstract: **that's where this week's two bugs
showed up** —the jump that got stuck and the map that got shifted— and no
test ran them. Of map 11 the suite only has `en-11`, which enters and nothing
more; of 12 and 14, nothing. Along the way it exercises two teleports and several kinds
of event: touch, autorun, parallel and the jump.

The maps: the street is **8** (`Lashe City - 34,35`) and the HQ is **12**
(`Trash Dump 004`), where `Conda`, `NVone`, `NVtwo`, `NVthree`,
`NV Lookout` and `NV hotplate` are. 12 also has two 5-cell jumps, which are
among the fastest in the game: 7.3 px per frame.

The model is `pruebas/abl/test_recorrido.py`, which already plays from the title to
the auditorium with `Mundo`/`Recorrido` —the graph of islands and the plan by doors—,
and saves one capture per milestone.

Done means: the test runs in the suite, and **it was seen failing against the ROM from
before the two fixes**, which is what says whether it truly covers what taro
found while playing.

---

## As of 2026-09-23: the test is there, and it covers one of the two

`pruebas/abl/test_recorrido_vipers.py`. Path, all by state and with a cap:
it starts at (73,32) of map 8 —the cell the map itself teleports to
from (0,56)— with switch 24; the pipe is event 41 at (52,23), which leaves the
hero at (55,18); the rooftop crossing is 45 at (58,17), which leaves him at
(64,17); the HQ door is 47 at (71,14), **one of those you talk to from
next to it**; inside, you go down to the `NV hotplate` at (5,39), which is touch-triggered and
fires the cutscene; and the "Yes, I'll do it!" branch —the one you get by pressing A
without moving the cursor— returns to (44,13). It takes 1.2 s, 1807 ticks.

**The stuck jump: caught, and seen red.** Against `main.s` of the parent of
`f50d654` the test fails. What triggers it is the **in-place** jump of the
cutscene —`begin_jump` and `end_jump` back to back, Talan jumping from the scare— which is
the last command of its route: `ruta_salto` stays at 232 with `ruta_i == ruta_n`
for 49 consecutive samples of the watcher, six of them with a message on
screen; with the fix, one. **That jump isn't visible**: with no displacement
`salto_posicion_heroe` leaves `hero_y` where it was, so no golden would have
noticed it and `hero_y == tile_y * 16` doesn't give it away either. The only thing that
gives it away is `ruta_salto`.

**The shifted map: this stretch can't reproduce it, and that's measured.** Building the
ROM that has the jump fixed and `stream_map` not —reverting `9997bf2` on
HEAD— this test **passes**, and the two in `test_camara.py` fail. The reason,
measured loop by loop on that ROM and outside the fades: in the whole stretch
the camera doesn't move more than **5 px** per loop —the peak is the pipe's
jumps— and skipping a row takes more than 8. The two things that add up to 16
are the hero at speed 6 and a `PanScreen` at speed 6 on the same axis, and this
scene has neither. The window check goes in anyway at the
two milestones where it can, and the docstring says that today it can't go red.

**A hole in the harness that showed up along the way**: `activar` talked from the side without
turning. It turned with a one-tick tap and a tick can be lost entirely, because the
ROM reads the pad once per loop and a loop can last several hardware
frames. Measured just after arriving at the cell: it doesn't turn with one or two ticks
held, and it does with four. It was hidden by the fact that `caminar_a` leaves the hero facing
his last step; the HQ door is one where it doesn't. Today `Recorrido.mirar_a` turns,
and checks it in RAM.

**What's left uncovered** —this test does none of the three—: the
"No, it's a waste of time!" branch of the cutscene, which is the one that walks down and leaves
through the fence with **the two 5-cell jumps**; event 1 at (1,47), the fence
with its "Climb the Fence" `ShowChoice`; and map 14, which neither of the two
branches enters with these switches.
