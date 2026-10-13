---
name: "Paths that do not exist"
description: "A test that fails if a .md or a comment names a file that is no longer there"
type: test
status: wishlist
---

# What

A small test that looks for repo paths between backticks —in the
`.md` files and in code comments— and fails if any does not exist.

# Why

On 2026-09-24, after moving and renaming several things, references were left
to paths that were no longer there: `juego/`, `pruebas-manuales/capturas-batalla/`, an
explanation of `cartridges.py` that had been deleted. taro found them by reading,
and they confused him. Nothing caught them.

The alternative of a markdown linter was looked at —markdownlint, mdformat,
Prettier— and it does not address this: they check the form, not whether what is named exists. If
some day the form becomes a bother, mdformat only for the `.md` files is the cheapest.

Another case, on 2026-09-25: the index of `README.md` links to an
"El MSU-1" section that does not exist, and the docstring of `tools/audio/msu.py` cites it.
A markdown anchor is one more path: the test should look at them too.

# What it does not cover

Statements that stopped being true without naming a path: those come out
of reading.

# Status

Noted on 2026-09-24 in the wishlist: taro does not consider it important.
