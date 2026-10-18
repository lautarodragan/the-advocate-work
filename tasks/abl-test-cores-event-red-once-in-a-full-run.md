---
name: "ABL's test_cores test_event went red once in a full run"
description: "bsnes drew an empty message box over the event case and snes9x did not; alone the test passes"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-17, in a full run of ABL's suite on the
branch `carpintero-zounds-events` (the-advocate `5b3c2a9f` before merging
`main`, ports `f2beb59`), with that branch's tools.

`tests/rpgmaker/test_cores.py::test_event` failed: snes9x and bsnes differed
in 31.72% of the pixels, and bsnes's capture had an empty message window
over the bottom of the screen. bsnes starts the WRAM with garbage, so it
says something read memory nobody wrote.

It did not come back: `test_cores.py` alone passed eight times out of eight
on the branch and three on `main` (ports `1d93da4`), and the next full run,
on the merged tree, was green. The branch's one new variable that could be
read before it is written, `twins_here` (direct page), only decides whether
the twin table is walked, and on a map without twins that walk answers "no
twin" anyway; it was not proven to be unrelated.

**How to reproduce it**: `just tests` in `abl/` of the ports, several times;
the captures stay in `tests/snapshots/cores/`.
