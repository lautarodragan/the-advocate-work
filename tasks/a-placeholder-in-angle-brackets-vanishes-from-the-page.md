---
name: "A placeholder in angle brackets vanishes from the page"
description: "A task that writes `<who>` or `<date>` outside backticks loses it on the tasks page: cmark-gfm takes it for raw HTML and writes `<!-- raw HTML omitted -->`; six tasks read with a hole"
type: bug
status: done
author: huron
links:
  found-in: [the-tasks-page-renders-filtered-and-fast]
---

**What is seen**: on the tasks page, a sentence with a placeholder in
angle brackets written as plain text comes out without it. In
`the-attack-says-undamaged-for-a-miss`, line 36, `"<who> attacks the
enemy"` reads `" attacks the enemy"`; the same in
`experience-and-levelling-up` (line 29, `<nombre>`) and
`a-task-s-author-in-its-frontmatter` (line 57, `<date>`), and three more:
`desert-nightmare-the-intro-and-the-file-screen`,
`a-gradient-system-stops-the-converter-at-the-actor-choice` and
`a-message-and-the-choice-after-it-share-a-box-in-rm2k`.

**Why**: `render_body` in `tasks/tasks.nu` runs cmark-gfm without
`--unsafe`, so what parses as an HTML tag is dropped and replaced by an
HTML comment. GitHub's renderer drops unknown tags too, so the files
read with the same hole there.

**How to reproduce**: at `99d1fc7`, `nu tasks/tasks.nu html
--out <dir>` and `grep -c 'raw HTML omitted' <dir>/index.html`: 6. Or open
the first of those tasks on the page and look for "attacks the enemy".

Found while making the bodies lazy in
[the tasks page renders filtered, and fast](the-tasks-page-renders-filtered-and-fast.md),
which did not change it: the old page had the same six holes.

### 2026-11-24, Hornero: fixed by hand, done

The six holes escaped with `\<` in their tasks, and this task's own
reproduce line rewrapped so `<dir>` does not start a line. Not fixed in
the renderer: `--unsafe` would let a task's text inject HTML into the
public page, and a backslash costs nothing where it is needed. Built
again: `grep -c 'raw HTML omitted'` gives only the mentions of it inside
backticks.
