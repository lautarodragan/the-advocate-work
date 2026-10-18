---
name: "Goombario's exceptions in the code"
description: "A line Goombario flags on purpose says so with a comment on that same line, with its why, like an eslint-disable comment; the two exception lists —ABL's and the test game's— go away"
type: tooling
status: doing
assignee: Mulita
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
