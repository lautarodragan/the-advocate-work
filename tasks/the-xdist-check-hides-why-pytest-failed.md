---
name: "The xdist check hides why pytest failed"
description: "machine.just's `_xdist` runs `pytest -p xdist --help` and, if it fails for any reason, says pytest-xdist is not installed; on 2026-11-25 ABL's `just tests` stopped there once, with xdist installed, and passed when run again"
type: bug
status: draft
author: hornero
links:
  found-in: [one-advocate-command]
---

Seen by Hornero on 2026-11-25, verifying step 4 of
[`one-advocate-command`](one-advocate-command.md) on the merged tree
(the-advocate `954256bd`, ports `67716e6`): right after `just install
advocate`, the-advocate's suites and the ports' `just boot`, ABL's `just
tests` stopped in `_xdist` with "the tests run in parallel with
pytest-xdist, and this pytest does not have it". xdist is installed
(`/usr/lib/python3.14/site-packages/xdist`); `just _xdist` gave 0 by hand
a minute later, and `just tests` passed whole (1694).

**Why it misleads**: `_xdist` in the ports' `machine.just` treats any
failure of `pytest -p xdist --help` as a missing plugin, and that command
loads ABL's `conftest.py`, which can fail for other reasons —run by hand
outside `just`, it fails with "GAME_DIR is missing"—. Whatever failed
that once was swallowed (`>/dev/null 2>&1`).

**Not reproduced**: what made it fail that once is not known.

**What would fix it**: check the plugin without loading the project's
conftest (`python3 -c 'import xdist'`, or `pytest --noconftest -p xdist
--help`), and print pytest's own error when it is something else.

## Log

### 2026-11-25, Hornero: written

Not reproduced; left as a draft.
