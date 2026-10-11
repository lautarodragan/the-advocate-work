---
name: "The playthrough picks option N"
description: "Let Recorrido move a ShowChoice's cursor before confirming"
type: test
status: done
---

# What

`Recorrido` —`pruebas/arnes/recorrido.py`— only confirms a `ShowChoice`
with the top option: it presses A without moving the cursor. We need to
**pick option N**: move the cursor down N times, check in RAM that it ended
up where requested, and only then confirm.

It is milestone 0 of `lashe-city-with-the-car-up-to-the-race.md` and can be done in
parallel with 1. Without this no Lashe City playthrough with the car can be
written:

- the choice on 36 is `Sector 32 / 33 / 34 / 35`, and the main stretch
  —37— is the **fourth**;
- Boss Wick's favour (40, event 7, page 4) has two choices in a row, and the
  "Refuse" branch is the second;
- the car's queue (36, page 2) is "Stay / We've got to get out of here": the
  one that leads to the limit is the second.

And it unblocks `other-branch-of-the-neon-vipers-cutscene.md`, which was left undone
precisely because of this.

# What is already known

- **A press can get lost**: the ROM reads the pad once per loop and a loop
  can last several frames. `Recorrido.mirar_a` already solved the same thing
  for turning while checking RAM; the same method is advisable (see
  `neon-vipers-walkthrough.md`, "Un agujero del arnés").
- **The window ignores the button while composing**: no presses in the
  first thirty frames since it opens (see `ESTADO.md`, "Lo que la tanda no
  cubre").
- Which RAM variable says where the cursor is: it is in the `OP_CHOICE`
  interpreter; the cartridge's symbol table exports it if it has a name.

# Done means

A test that picks option 2 of a two-option choice and checks that that
branch ran —in `release` there are candidates: the auditorium guard—, seen
red with the A press without moving the cursor.

---

## As of 2026-09-26: done

**The API**, in `Recorrido`: `elegir(opcion)` waits for the next
`ShowChoice` closing the earlier messages with A, moves the cursor down to
`opcion` —from zero— and confirms. They are two separate halves,
`marcar(opcion)` and `confirmar()`, so as to take a snapshot of the window
with the cursor in place.

Everything through RAM and no frames counted:

- **open** is `eleg_activo` and `msg_abierto` together, like `abierta` in
  `test_elegir.py`: `op_choice` turns on the first before the window
  finishes composing, and `eleccion_tick` does not look at the pad until the
  second;
- **the A that closes the messages** is pressed only with a message open and
  the choice not. It is the real trap: `esperar`'s patience presses A
  blindly, and a press that lands with the choice freshly composed takes the
  top option;
- **every down press is checked** in `eleg_sel` and repeated if it was lost;
  one that arrived is never repeated, because the window looks at edges;
- **resolved** is the window ceasing to be ready. If the branch opens
  another choice, that one is not composed yet and is not answered in
  passing.

`activar` still presses A blindly after the first press, so before an
`elegir` it has to be cut as soon as the page starts:
`activar(celda, lambda p: p.corriendo_una_pagina())`.

**The test**: `pruebas/abl/test_recorrido_vipers_otras_ramas_golden.py`,
which plays the "No" branch of the hotplate cinematic, the two options of
the fence and map 14 —see `other-branch-of-the-neon-vipers-cutscene.md`—. **Seen
red** with the top option instead of the second: the "No" one ends at
(44,13) without switch 38, which is the "Yes" branch, and the fence with
"Climb the Fence" instead of "Don't Bother".

The auditorium guard was not needed: the Neon Vipers cinematic is a
two-option choice where the second branch leaves a trace in RAM.
