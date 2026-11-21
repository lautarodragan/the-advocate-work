---
name: "The playthrough's pending goldens"
description: "119 of the playthrough's shots have no golden (pending.txt, 2026-11-17; the 26 debug-* go without one on purpose): take them, have taro look at them, and approve them or fix what they show"
type: test
status: todo
author: irupe
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

## From `goldens-of-the-neon-vipers-playthrough`

On 2026-10-20.

That task was closed as a duplicate of this one. Its warning still applies
to the vipers shots: the game started through "Begin the Story" has
DummyHero as leader (actor 10, no graphic), so Talan does not appear in
the shots of `test_playthrough_vipers_golden.py`; the line that solves it
elsewhere is `set_party(14)` before the final shots.

## Log

### 2026-10-16, Carpintero: checked

Still open. The list is `abl/tests/golden/playthrough/pending.txt` in
the-advocate-ports (it was `rom/pruebas/golden/playthrough/pendientes.txt`),
and its count is no longer the one above: some stretches got goldens and
new shots were added. How many are left is said by the file. It includes
the vipers' shots, which
[`goldens-of-the-neon-vipers-playthrough`](goldens-of-the-neon-vipers-playthrough.md)
also asked for.

### 2026-11-17, Hornero: reviewed

`abl/tests/golden/playthrough/pending.txt` in the ports has 145
entries: 26 `debug-*`, which the list already marks as "without a golden
on purpose", and 119 others; 48 goldens are approved. The paths above
still cite the old `rom/pruebas/...`; today they are under `abl/tests/`
in the ports.
