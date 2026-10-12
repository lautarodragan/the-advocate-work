---
name: "Everything in English: the book's file names and URLs"
description: "The book's pages keep the Spanish file names they had before the translation: give them English names, redirect the old URLs, and fix every citation in the four repos"
type: chore
status: doing
assignee: Cardón
agents: [Cardón]
---

taro, on 2026-10-12: "I want the URLs and file names in English too. Let's
find and fix all the references. Let's not modify the git history. I also
want the ports repo in English. Basically, EVERYTHING in English, but
without modifying the git history." The rule is in AGENTS.md, "The
independent projects are in English".

This task is the book and the citations of it; the ports are
[`everything-in-english-the-ports`](everything-in-english-the-ports.md).

* Every page of `the-advocate-docs/src/` with a Spanish file name or
  directory gets an English one, made from its title.
* The old URLs keep working: one `[output.html.redirect]` entry per page in
  `book.toml`, which is also the table an old citation is looked up in.
* Every citation of an old name in the four repos is fixed: the book's own
  links and `SUMMARY.md`, comments in the-advocate —also the stale
  `workflow/divergencias/…`, `decisiones/…` paths—, tasks, `AGENTS.md`,
  `.claude/`, and the ports. Verbatim quotes of old commits stay.
* Leftover Spanish in the-advocate and in this repo that is not a quote:
  `.claude/agentes.md` gets an English name.

## Log
