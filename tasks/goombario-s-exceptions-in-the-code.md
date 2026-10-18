---
name: "Goombario's exceptions in the code"
description: "A line Goombario flags on purpose says so with a comment on that same line, with its why, like an eslint-disable comment; the two exception lists —ABL's and the test game's— go away"
type: tooling
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-18: "the exceptions into the code, like with js/ts
linters". Until now they live in `linter-exceptions.txt` of `abl/` in the
ports —sixteen, each with its why above it— and, since the GitHub workflow
(`a-github-workflow-for-the-tools`), in a copy in `test-game/` of
the-advocate, which has to be kept in step by hand.

Why in the code: a why that protects a line goes as a comment on that line
(AGENTS.md); whoever edits the routine sees it; and the exceptions are
reviewed in the runtime's diff instead of a list in another repo.

Done means: Goombario reads an exception from a comment on the flagged
line (the check named, and its why required), the sixteen move there, both
lists and their loading go away, an exception that no longer matches
anything is still an error, and both ROMs come out byte for byte the same.

## Log

**2026-10-18, Mulita.** Started from the-advocate `e7794b18`, the ports
`74068b8`, this repo `d6088e1`; branches `mulita-goombario-inline` in
both. Besides `goombario`, `project`, `cartridge` and `convert` go into
`.local-tools/`: the runtime's path is compiled into `project`, so without
them the cartridges would assemble `~/the-advocate`'s runtime and not the
annotated one, and Goombario would read its source. They are installed to
build, not touched. The baseline ROMs are built with them before
annotating anything.

The format: `; goombario: <check>: <why>`, the comment starting with
`goombario:`. On a line with code it covers that line; alone on its line
it covers the next line with code, with only comment lines in between
—they carry on the why—, for the lines with no room. A blank line in
between, a missing why, a check that does not exist, and an annotation
that allows nothing are findings. It covers that check and that line only:
the two `rts` of `slots_screen`, which one list entry covered, take one
each, so there are sixteen annotations for the fifteen entries.
`--allow` went: nothing else used it.

Measured: the sixteen findings without the list are the same in ABL's
`abl.sfc` as the list's entries. Every cartridge —`test-game.sfc`,
`abl.sfc` and ABL's eight test ones— built byte for byte equal before and
after the annotations. The old Goombario with the old list is still green
over the annotated runtime, so the runtime commit stands on its own.
Removing `set_switch`'s annotation turns both linter tests red, naming
`runtime/variables.s:114`.

the-advocate: `508cf48d` (the runtime's comments), `dba52dd1` (Goombario,
the test game's list). The ports: `ae81b1c`. Run besides: Goombario's
crate tests, `just test`, the test game's suite, and ABL's `tests/tooling`
whole; not the rest of ABL's suite, since the ROMs are byte for byte the
same.

To install when merging: `goombario` alone (`just install goombario`):
nothing else compiles it in.
