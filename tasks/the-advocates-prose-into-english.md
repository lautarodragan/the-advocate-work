---
name: "the-advocate's prose into English"
description: "README, LAYOUT, GLOSSARY, the justfile's comments, the tests' prose and the few Spanish comments left in runtime/: what changes no byte of any build"
type: chore
status: doing
agents: [Tijereta]
assignee: Tijereta
---

taro, on 2026-10-12: `the-advocate` goes in English entirely, commits
included (see "The independent projects are in English" in `AGENTS.md`).
This is the half that cannot affect a build: prose only. The other half,
the Spanish names left in code, is
`the-advocates-spanish-identifiers-into-english.md`, in parallel.

## Tijereta, 2026-10-12

Branch `tijereta-prosa` in the-advocate, from 57abdca3. Most of the
repo was already English: `LAYOUT.md`, `GLOSSARY.md` (its Spanish
column is the point of it), the `justfile`, `tests/`, `Cargo.toml` and
`pytest.ini`. What was not:

* `README.md`, whole;
* the comments of `.gitignore` and `.git-blame-ignore-revs`;
* in `runtime/`, a `; ver`, three section titles quoted in Spanish and
  the old Spanish names of five tasks; an `.assert` message that named
  `MENSAJES_PASO` in `events.py`;
* stale citations along the way: `tasks/todo/`, `divergencias/` and
  `decisiones/` of this repo, now in the book or a `status`; `tools/`
  in `.gitignore`; "Sub-agentes" in `LAYOUT.md`.

Left: the `workflow/decisiones/` and `workflow/divergencias/` file
citations in `runtime/`, which are found by name in the book, and
taro's quote in `level.s`, which carries its English.
