---
name: "Zounds' boot test once saw snes9x and bsnes arrive sixteen ticks apart"
description: "`just boot` failed once on zounds with 'snes9x and bsnes arrive differently': the same map, cell and direction, at tick 4437 and 4453; it passed alone right after"
type: bug
status: draft
---

Seen by Carpintero on 2026-10-17, with the-advocate `c116cd7b` (branch
`carpintero-lending`: main `b15c9408` and two changes to how wally lends a
palette) and the ports `80f0aba`, from the root of a worktree of the ports,
`just boot` with the branch's tools in the PATH, while other agents ran
their suites (the machine loaded).

**What was seen**: `test_boot.py::test_builds_and_reaches_the_first_map[zounds]`
red: "zounds: snes9x and bsnes arrive differently —(tick, map, hero, where
it walks)—: (4437, 7, (48, 601), 'down') and (4453, 7, (48, 601), 'down')".
The run before, with the same tools, it was green, and so was
`just boot -k "sunset or zounds or painted"` right after.

**What may explain it, not checked**: the two cores are run on the same
cartridge, and a difference between them is what `test_cores.py` reads as
uninitialised memory (bsnes starts WRAM with garbage); a difference that
comes and goes is that kind of bug's signature, going red only when the
garbage lands on a value that breaks. That it showed under load may be a
coincidence. Nothing in the branch touches Zounds' code paths besides the
colours of characters drawn with someone else's palette.

**How to reproduce it**: not reproduced. `just boot -k zounds` in a loop,
counting reds, would say how often; with main's tools, whether it is older
than the branch.
