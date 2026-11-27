---
name: "ABL's just tests splits a quoted -k expression"
description: "`just tests tests/x.py -k \"a and b\"` in abl/ hands pytest `-k a and b`: the recipe interpolates its arguments unquoted, so a -k or -m expression with spaces selects nothing"
type: bug
status: draft
author: mulita
agents: [Mulita]
links:
  found-in: [tests-without-the-stages-subcommands]
---

Seen by Mulita on 2026-11-27, doing step 5 of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md),
with the ports at `4821050`.

**What happens**: ABL's `tests` recipe (`abl/justfile` in the ports) is
`pytest {{xdist}} {{args}}`, and just joins `args` with spaces without
quoting them, so an argument with a space reaches pytest split:

    $ just --dry-run tests tests/rpgmaker/test_music_writes.py -k "says and escape"
    pytest -n 8 --dist worksteal tests/rpgmaker/test_music_writes.py -k says and escape

Run for real, it collects no test (exit 5) instead of the one asked for.
A single word after `-k`, as the recipe's own comment shows (`-k
tracks`), works; a node id with brackets
(`"tests/x.py::test_y[escape_newyork]"`) works too, which is the way
around it today.

**The fix is not in doubt**: the root's `boot` already does it right,
with `[positional-arguments]` and `pytest {{xdist}} "$@"`.
