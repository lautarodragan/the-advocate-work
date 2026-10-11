# State of the Work

This repo is a kind of home-made Jira: the tasks of every repo, and the
place work is done from —the `AGENTS.md` and `.claude/`—.

The tasks all live in `tasks/`, one file per task, and their state is the
`status` in the frontmatter:

- `draft`: findings and things that are not a task yet: something was
  seen, but what to do about it is still undefined
- `todo`: tasks not started
- `doing`: tasks in progress: whoever takes one moves it here before
  anything else
- `testing`: done and waiting for taro to test them by playing
- `done`: finished tasks
- `wishlist`: what we would like to do and nobody is doing

**A task's file name never changes**, even if its title does: it is its
address, and it is linked from the other repos and from the book
—`tasks/<name>.md` on GitHub—. It is taro's, from 2026-10-11, the same day
this repo went public. Until that day there was one folder per state, and
every task that moved broke the citations to it; old citations with a
folder —`testing/x.md`, `tasks/todo/x.md`— are `tasks/x.md`.
`nu tasks/tasks.nu ls -s <state>` lists them.

**This repo is public**: nothing written here can be private.

**A draft is not ready to be taken.** It is what an agent finds and does
not fix —a bug that is not part of its task, a path it did not cover, "the
next thing, measured"—: a short file with what was seen, in which game, at
which commit and how to reproduce it, with no `assignee` and without saying
how to fix it. It leaves that state when someone defines it —to `todo` or
to `wishlist`— or it is deleted if something else fixed it. The difference
from `wishlist`: a task in the wishlist is defined and only needs to be
prioritised; a draft is not defined. It is taro's, from 2026-10-11: until
that day findings stayed in the "Hallazgos" section of the agent's task and
were buried with it.

**Decisions, divergences and research are not here**: they live in the
book, `the-advocate-docs`, in English, since 2026-10-10 —"the book is for
people and for AIs", taro's words—. Until that day `decisiones/` and
`divergencias/` were folders in this repo, and the research was in
`docs/research/` of the tools and of ABL. File names were kept, so an old
citation is found by name:

* `decisiones/x.md` is `src/decisions/x.md` in the book, except two of
  ABL's, which are in `src/ports/abl/decisions/`;
* `divergencias/x.md` is `src/divergences/x.md`;
* `docs/research/x.md` of the tools is `src/research/x.md`, and ABL's,
  `src/ports/abl/research/x.md`;
* `docs/port/x.md` is `src/internals/x.md`.

## A task's frontmatter

    ---
    name: "Short title"
    description: "One line: what it is, for the list"
    type: bug | feature | refactor | test | docs
    status: draft | todo | doing | testing | done | wishlist
    assignee: taro
    ---

`type` and `status` are always there. `assignee` says who has it: `taro`
for his own and for those waiting on something from him —playing, looking
at some goldens—, and the agent's name for those in `doing`. See "Taking a
task" in `AGENTS.md`. In `todo`, with no `assignee`, whoever comes first
takes it. Many of those in `done` predate these fields and carry no
`assignee`.

**Everything is tracked here**: the tools and the runtime (`the-advocate`),
the ports (`the-advocate-ports`: A Blurred Line and the other games) and
the book (`the-advocate-docs`). It is taro's, from 2026-10-10, "to track
everything in one place".

Until that day this was the `workflow/` folder of `the-advocate`, and it
came out of there with its history (`git subtree split`). So:

* **a `workflow/…` written in another repo is the path here**, without the
  `workflow/`: `workflow/tasks/todo/x.md` is `tasks/todo/x.md`, which
  today is `tasks/x.md`;
* **the hashes that tasks and commit messages cite are from
  `the-advocate`**, or from `the-advocate-ports` when they talk about ABL:
  the commits here are copies with another hash and the same message.

From 2026-10-02 to 2026-10-10 ABL's tasks and decisions lived in its repo;
that day they went back to `the-advocate`, and from there they came along
with everything else.
