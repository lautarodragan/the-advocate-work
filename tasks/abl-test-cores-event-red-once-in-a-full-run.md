---
name: "ABL's test_cores test_event went red once in a full run"
description: "bsnes drew an empty message box over the event case and snes9x did not; alone the test passes"
type: bug
status: todo
agents: [cardon]
author: carpintero
links:
  relates: [abl-test-cores-big-picture-return-red-once-in-a-full-run, the-test-games-ci-job-went-red-once]
  duplicated-by: [abl-test-cores-big-picture-return-red-once-in-a-full-run]
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

## Log

### 2026-10-19, Carpintero: seen again

**Seen again** by Carpintero on 2026-10-19, the same way —bsnes drew an
empty box over a black screen, snes9x the tinted map, 89% of the pixels—,
in a full run on the branch `carpintero-faces` merged with `main`
(the-advocate `148d2fe2` plus `b168c362`, ports `bfebe37`), with that
branch's tools and `events` installed from it. Alone, `test_event` passed
twenty times out of twenty on the same tree, and two full runs before the
merge were green. That branch's change only writes the message face, never
reads uninitialised memory: it was not proven to be unrelated either.

### 2026-11-24, Cardón: to todo

Seen three times (2026-10-17, 2026-10-19, and the big picture case of
[`abl-test-cores-big-picture-return-red-once-in-a-full-run`](abl-test-cores-big-picture-return-red-once-in-a-full-run.md),
now a duplicate of this one), all with bsnes drawing a message window
piece snes9x did not. A red in `test_cores.py` is what AGENTS.md says it
means: the ROM reads memory nobody wrote; a bug, nothing to choose. Not
seen in a task since 2026-10-19, so the first step is to make it reproduce
—several bsnes power-ons of those two cases— and then find the read.
