---
name: "Split test_commands_golden"
description: "A test file that gathers many different RM2k commands"
type: test
status: wishlist
author: hornero
game: abl
---

`tests/rpgmaker/test_commands_golden.py` compares many different event
commands against goldens in a single file. Its header explains that they are
grouped by harness, not by command. In `tidy-up-pruebas` (2026-09-25) it was
decided not to split it: one file per command is a big change for what it
yields, and the index in `tests/README.md` already says what it covers. It
becomes worth it again if the file keeps growing or if two branches start
colliding there.

## Log

### 2026-11-22, Chajá: still applies, and its trigger has not come

The file is ABL's `abl/tests/rpgmaker/test_commands_golden.py` in the
ports (`abl/pruebas/rpgmaker/test_comandos_golden.py` until 2026-10-12,
see the ports' `RENAMES.md`); this task's file name keeps the old one, as
names do. At the ports `89f77b4` it is 725 lines and 22 test functions,
and its last change was on 2026-10-20 (`b8c87ab`, a box is typed): it
has not grown since the renames, and no merge collided in it. So it
applies as written, and what it waits for —the file growing, or two
branches colliding in it— has not happened. Stays in wishlist; `game:
abl` added.
