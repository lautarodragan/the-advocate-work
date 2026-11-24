---
name: "A task's author in its frontmatter"
description: "An `author` field says who the task comes from —taro for their reports and requests, the agent that found it for its own drafts—; the page shows it and filters by it; every task gets one, done included"
type: feature
status: done
assignee: taro
author: taro
agents: [Carpintero]
---

taro, on 2026-11-20, translated:

> Maybe we can add an "author" field with "taro" or "tijereta", etc, in
> the front matter

Agreed the same day: `author` is **who the task comes from**, not who
wrote the file —git already says that, with the first commit's trailer—:
`taro` when it comes from a report or a request of theirs, even if
Hornero wrote it; the agent that found it and opened it, for its own
drafts and findings. Lowercase and ASCII, as in the trailers' addresses
(`taro`, `hornero`, `chaja`, `huron`…).

- **The page** shows it in the task's meta line, next to the assignee and
  the agents, and filters by it, next to the game and type filters.
- **Retroactive, every task, `done` included**: a task that opens with a
  quote of taro's is taro's; otherwise, the agent named in the first
  commit's trailer (`Co-authored-by`, or `Agente:` before 2026-10-11);
  without one, Hornero —or taro, when the file says they asked for it—.
  The doubtful ones, by hand.

## Log

### 2026-11-20, Carpintero: the field, the page, and every task's author

#### The tooling

`tasks.nu` reads `author`; `ls -u <author>` filters by it, ignoring case
and accents like `-a`; `check` lists, after its log report, the tasks
without one in every state, `done` included. The page shows `author: x`
in the meta line, before the assignee, and has an author filter under the
game one, with the same mechanics —most used first, counted for the
chosen status, `none` for those without one, `?author=` in the URL—.
Checked by building the page and loading it in headless Chromium with
`?status=all&author=taro`. The README's frontmatter section documents the
field, and the roster tells an agent to write its own name in what it
opens. Nothing to install when merging.

#### The backfill

791 tasks, one commit per status; the two in `doing` that other branches
carry were skipped, and their authors go in when they are merged. A
script inserted one line after `assignee:` —or `status:`— and nothing
else: `git diff --numstat` gave 1 and 0 for every file, and every added
line was `author: <name>`.

How each was decided: 294 opened with taro's words (187 a quote, 107
"taro, on \<date>" or the like at the top), 301 by the trailer of the
commit that created the file —`git log --follow --diff-filter=A`—, 122
had no trailer and no sign of taro's and went to Hornero, and 74 were
read and decided by hand. The ones by hand followed two readings:

- **An agent's finding that taro only triaged is the agent's**: the
  commands of Aguará's study (`eraseevent-for-real`,
  `maps-loose-commands`, `monster-conditions-and-flashscreen-in-battle`),
  the survey's `window-with-more-than-15-colors` and
  `ignore-the-color-codes-in-messages-for-now`, Cardón's
  `encounters-with-two-byte-indices` and `actors-critical-hit`, and the
  ones whose text opens "X found it" with X not the trailer's agent.
  But what came from **what taro saw playing** —Aguará's analysis of
  the other games' ROMs: `changesystemgraphics`, `n-n-in-messages`…— is
  taro's.
- **A step of a plan has its plan's author**: `the-skills-screen` and
  `identical-pages-stored-once` are taro's;
  `poses-without-their-empty-tiles` and
  `the-emitter-stores-identical-data-once` are Cardón's, like
  `abl-the-whole-game-does-not-fit-in-8-mb`.

Eight tasks were found by seven agents from before the roster, and carry
their names: `yaguarete`, `irupe` (two), `surubi`, `zorzal`, `tordo`,
`tacuarita`, `guayabo`. `changefacegraphic-in-the-declared-debts` was
created by Codex, and is Aguará's, who found it.
