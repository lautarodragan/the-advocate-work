---
name: "A task's log in its own section"
description: "The work done on a task goes in a final `## Log` section, one dated entry per step; the page folds it into a scrolled box, closed by default; the tasks not done are moved to it by hand"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-20, translated:

> I've been thinking I'd like to minimise the tasks' UI a bit, or make
> them more navigable, by introducing more structured/typed sections.
>
> Today, tasks have a log of the work, by convention. It is usually a
> heading that says `Done`. I'm thinking I'd like that to be collapsed by
> default, and to be able to expand it, and I think I'd like it to have a
> maximum height, and the scroll to happen inside its little box. [...]
>
> Maybe that box with the work log should also be told apart visually,
> and not only given a scroll. It could have a slightly different
> background, some padding... something similar to what we already do for
> code, but without monospaced fonts, among other things.
>
> I'd like this to be retroactive, but clearly we can't identify the work
> log blocks deterministically, so maybe it's better for an agent to do
> it, judging each task by hand.
>
> To reduce the load, I'd ignore the ones already `done`.

Agreed the same day: the log goes **in the same file**, as **a final
`## Log` section** —a separate `<task>.log.md` would break "one file per
task" and the `tasks/*.md` glob, and split the task from its history on
GitHub—, with one entry per step, `### <date>, <who>: <what>`. Above it,
what defines the task —what, why, taro's words, images— stays always
visible.

- **The page** (`tasks/tasks.nu html`, `site/index.html`) cuts the body at
  the exact line `## Log`; what follows goes in a `<details>` closed by
  default, labelled with how many entries it has ("Log · 4 entries"), in
  a box with a maximum height (about 20em) and its own scroll, a slightly
  different background and padding, in the normal font.
- **A check** in `tasks.nu` warns when a task not `done` has log-like
  headings (Done, Checked, Defined, Reviewed, Work, What was done…)
  outside `## Log`.
- **The convention**, written in this repo's README and in
  `.claude/roster.md`, so that agents write their entries there from now
  on.
- **The migration**, by hand, of the 243 tasks not `done` (89 draft, 46
  todo, 51 testing, 55 wishlist; the two in `doing` when their agents are
  merged): what is history goes to `## Log` with its date and agent when
  they can be told, without rewriting what it says.
