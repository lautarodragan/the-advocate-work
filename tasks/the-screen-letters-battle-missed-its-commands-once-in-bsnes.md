---
name: "The screen letters' battle missed its commands once in bsnes"
description: "test_screen_letters.py::test_the_battle[bsnes] went red once in a full test game run —the battle did not reach its command window in 1200 frames— and green in six runs after; bsnes starts WRAM with garbage, so it may be the ROM reading memory it never set"
type: bug
game: advocate
status: draft
author: hornero
---

Seen by Hornero on 2026-11-28, verifying the-advocate `bb4c4a4c` (the
packing that leaves unchanged generated files alone, which changes no
ROM byte: the nine ports' releases equal `/shared/builds`) with `just
test-game`: `tests/test_screen_letters.py::test_the_battle[bsnes]`
failed with "the battle did not reach its commands" —1200 frames
without `menu_open` and `BA_MODE` at `BA_M_COMMAND`—. snes9x's run of
the same test passed. Right after, the test alone five times and the
whole suite once more were green.

**Why it may matter**: bsnes starts WRAM with garbage and snes9x with
zeros (AGENTS.md, "The rule that holds everything up"), so a battle
that waits on something it never initialised can hang only in bsnes,
and only when the garbage lands on a value that breaks.

**How to reproduce**: not yet. `pytest tests/test_screen_letters.py -k
battle` in a loop, in `test-game/` of the-advocate, under load like a
full suite's; whether bsnes's garbage changes between runs, and how it is
seeded, is the first thing to find out.

## Log
