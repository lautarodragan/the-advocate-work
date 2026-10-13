---
name: "Split test_commands_golden"
description: "A test file that gathers many different RM2k commands"
type: test
status: wishlist
---

`tests/rpgmaker/test_commands_golden.py` compares many different event
commands against goldens in a single file. Its header explains that they are
grouped by harness, not by command. In `tidy-up-pruebas` (2026-09-25) it was
decided not to split it: one file per command is a big change for what it
yields, and the index in `tests/README.md` already says what it covers. It
becomes worth it again if the file keeps growing or if two branches start
colliding there.
