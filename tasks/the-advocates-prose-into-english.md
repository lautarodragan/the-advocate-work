---
name: "the-advocate's prose into English"
description: "README, LAYOUT, GLOSSARY, the justfile's comments, the tests' prose and the few Spanish comments left in runtime/: what changes no byte of any build"
type: chore
status: done
agents: [Tijereta]
assignee: taro
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

Verified: `just test` green on the branch, and ABL's `release` (ports
db41f0c, in a worktree of its own) built first with the global tools
and main's runtime, then with `cartridge` installed from the branch and
its runtime: `abl.sfc` byte for byte equal, sha256
`e00d899465b5906ed0d339b2bcc1235086f05c30595c81da927fed2ea36df349`, and
`abl.msu` too. Nothing to install when merging: only prose and comments
change, and the runtime is read from the checkout.
