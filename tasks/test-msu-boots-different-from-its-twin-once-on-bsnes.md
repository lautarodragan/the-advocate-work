---
name: "test-msu boots different from its twin, once, on bsnes"
description: "In a whole run of ABL's suite, test_msu_twins.py's boot case on bsnes was red in 116 of 120 frames from frame 4; five runs of the file alone right after were green"
type: test
status: draft
agents: [Hurón]
---

Seen by Hurón on 2026-10-20, with the-advocate `07b002f5` (branch
`huron-slot-names`, which touches the slot screen's names and nothing of
the boot) and the ports' branch of the same name, in ABL's suite, with
other agents' suites running on the same machine.

**What is seen**: `tests/rpgmaker/test_msu_twins.py::test_the_boot_looks_the_same[bsnes]`
red once —"after booting, test-msu looks different from its twin in 116
of 120 frames, the first one 4"— in the second of two whole runs of the
suite; green in the first, and green in five runs of the file alone right
after, with the same cartridges. snes9x's twin was green every time.

bsnes starts WRAM with garbage and snes9x with zeros, so a red that comes
and goes on bsnes alone is what `test_cores.py` describes as a ROM that
reads memory nobody wrote; it can also be the harness. Not looked into.

**How to see it**: `just tests tests/rpgmaker/test_msu_twins.py` in `abl/`,
several times; the log of the red run is
`~/scratch/huron/slot-names/logs/suite2.log`.
