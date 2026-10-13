---
name: "The battle flash test depends on the cycles before the battle"
description: "test_the_flash_lasts_what_the_page_says saw the flash's first level twice when the map's frames before the battle cost a few more scan lines"
type: bug
status: draft
---

Seen by Aguará on 2026-10-12, with the-advocate `25d93f0a` plus a first
version of `parallel-common-events-dont-run.md`, in ABL.

**What was seen**: with a `compar_tick` that cost some six scan lines on
the map's first frames, `tests/rpgmaker/test_battle_flash_golden.py`
went red: `test_the_flash_lasts_what_the_page_says` saw the flash's
first level twice —thirty frames lit instead of twenty-nine— and
`battle-inscribe-flash-15` differed in 38% of its pixels, one level
off. The only lost frame that changed, counted outside fades, was the
test's second frame, on the map, long before the battle; `boot_frames` ran
one ahead from there on. With the final `compar_tick`, two lines cheaper,
both are green again, and nothing was changed in the battle.

**What is not known**: whether the battle really loses a frame at the
flash's start depending on where in the frame its loop begins —the battle
does not count lost frames— or only the sampling moves. Either way, a
change that costs a few hundred cycles on the map's first frames can turn
that test red.

**How to see it**: add a few hundred cycles to `compar_tick` —reading the
line counter twice, `SLHV`/`OPVCT`, is what did it— and run that test.
