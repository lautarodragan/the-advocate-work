---
name: "EraseEvent: no test looks at what is seen"
description: "That an erased event stops being drawn, stops blocking, and that a parallel one that erases itself is cut, is enforced by no test: it was looked at playing Desert Nightmare"
type: test
status: draft
---

Hurón left it on 2026-10-06 in `eraseevent-de-verdad.md`: the
`EraseEvent` tests (three from the events crate and
ABL's `pruebas/rpgmaker/test_borrar_evento_de_verdad.py`, in
`test-special`) "do not cover that the event stops being drawn, that it stops
blocking or that the parallel is cut: the test event has no graphic
and is not parallel. That was looked at playing Desert Nightmare, no
test enforces it."

They are three runtime paths that exist only for this: `apply_pages`
hides the erased event's row and releases its route, `conditions_ok`
takes it off the list of parallels, and `pair_ev` cuts the parallel that
runs it (`op_erase_event`, `runtime/interpreter_movement.s`). ABL uses
`EraseEvent` in the quarry (map 150 and common event 36), and Desert Nightmare in
157 parallel pages without a graphic.

**How to see it**: in the cases of `test_borrar_evento_de_verdad.py`, an
event with a graphic and on the hero's layer that erases itself (that it is not drawn and
that its cell can be walked through), and a parallel that erases itself in the middle of
its page (that what comes after does not run).
