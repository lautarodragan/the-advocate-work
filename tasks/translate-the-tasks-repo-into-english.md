---
name: "Translate the tasks repo into English"
description: "the-advocate-work goes entirely into English, like the book, its commits included: first the README, tasks.nu, AGENTS.md and .claude/; then the tasks that aren't done; then the done ones"
type: docs
status: done
agents: [Hornero, Chajá, Carpintero, Aguará, Cardón, Hurón, Mulita, Calandria, Tijereta]
assignee: taro
---

taro, on 2026-10-11, the same day the repo went public, in their words,
translated:

> could you translate the whole work repo into English? It can go in
> separate commits, starting with the readme and tasks.nu, then the tasks
> that aren't done, and then the ones that are.

File names are not translated: they never change, they are links.

## How it was split

By even size, with one shared guide —what to translate, what not to
touch, the book's vocabulary—:

- Chajá: `README.md`, `tasks/tasks.nu`, `AGENTS.md`, `.claude/`. It also
  wrote the new rule in `AGENTS.md`: this repo is in English, commits
  included; the other repos stay in Spanish, and the `Agente: <name>`
  trailer is the same in all four, so `git log --grep` still finds it.
- Carpintero and Aguará: the 130 tasks that aren't done, 65 each.
- Cardón, Hurón, Mulita, Calandria and Tijereta: the 227 done ones, ~46
  each.

Merged in that order. Hornero translated this one.

## Criteria the translators converged on

- Numbers in English notation (12,5 → 12.5; 7.761 → 7,761).
- Hand-written tables and notes inside indented blocks are translated;
  literal program output, code quoted from a source in another repo,
  quoted commit subjects and section titles of other documents stay as
  they were, because they are searched for verbatim.
- Spelling: mostly American ("color"), as most of the book.

## What it left

Content errors the translators saw and left as they were —each task is a
record of its date—: old paths (`/extras/…`, `tools/`, `rom/src/`), the
repos' old `snes-rm2k` names, a few inner contradictions in long done
tasks. What could be fixed without judgment went in one commit after the
merges: 30 old tasks without a `type`, two `testing` tasks whose
assignee was still an agent, and two citations that kept a state folder.

## Verified

`nu tasks/tasks.nu ls -s "*"` parses all of them. Each translator
compared the backticked spans of its files against the originals; the
only ones that changed are Spanish formulas written as prose inside
backticks.
