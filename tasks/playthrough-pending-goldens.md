---
name: "The playthrough's pending goldens"
description: "127 of the playthrough's 135 shots have no golden: take them, have taro look at them, and approve them or fix what they show"
type: test
status: todo
---

Irupé measured it on 2026-09-29 (`tests-without-silent-holes.md`):
of the 135 shots that the playthrough tests take, only the 8 in
`apertura/` and `talan/` had a golden. The other 127 are in
`rom/pruebas/golden/playthrough/pendientes.txt`, grouped by test. Until
now those tests looked at the game state, but at no pixel.

Approving a golden is taro's (AGENTS.md, "Changing a golden is a deliberate
act"). What has to be done:

- take the 127 captures from a `main` build, stretch by stretch;
- show them to taro side by side with the original when there is a capture of the
  original, or alone; a new golden bakes in whatever bug it has, so they are
  looked at before approving them;
- the ones he approves leave `pending.txt` and go into git; the ones he doesn't
  are a task each.

A decision for taro before starting: the 14 `debug-*` of
`test_debug_map.py` go without a golden **on purpose** according to their docstring.
Are they pending or permanent? If they are permanent, the list should
tell them apart, so they don't remain as debt.
