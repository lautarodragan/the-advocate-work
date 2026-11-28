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
- `cancelled`: what taro decided not to do; its log says why. It stays,
  like every task, because its file name is linked from elsewhere

**A task's file name never changes**, even if its title does: it is its
address, and it is linked from the other repos and from the book
—`tasks/<name>.md` on GitHub—. It is taro's, from 2026-10-11, the same day
this repo went public. Until that day there was one folder per state, and
every task that moved broke the citations to it; old citations with a
folder —`testing/x.md`, `tasks/todo/x.md`— are `tasks/x.md`. The same
day, after translating the repo, every file was renamed once from its
Spanish name to one made from its English title, and that is the only
exception: a citation with an old Spanish name is found in
[RENAMES.md](RENAMES.md). A new task's name comes from its title the same
way —lowercase, hyphens, no leading article—.
`nu tasks/tasks.nu ls -s <state>` lists them.

**They are also a web page**, at
<https://lautarodragan.github.io/the-advocate-work/>: grouped by state,
with a filter, and each one opens to its body; `#<name>` links a task. It
is built by `nu tasks/tasks.nu html`, which fills the `<!-- TASKS -->` of
`site/index.html` —the page's style and script live there— and writes
`_site/index.html`; `.github/workflows/pages.yml` publishes it on each
push. It is taro's, from 2026-10-11.

**The page also writes**, with a fine-grained GitHub token for this repo
alone that taro pastes once ("write", at the top) and the browser keeps:
a task's `status` and `assignee`, a comment or a question for Hornero, and
the answer to a "question for taro" whose options are listed —each as a
log entry `### <date>, taro: …` with the text as a `> ` quote—. Each
change shows at once and waits in a queue in the browser; "Save" makes
the queue one commit on `main`, and a field someone else changed
meanwhile is flagged instead of saved. `nu tasks/tasks.nu inbox` lists
what taro wrote that Hornero has not answered, and
`.github/workflows/check.yml` runs `check --strict` on every push, so a
commit of the page that breaks a task shows. Since 2026-11-25.

**A task can carry images**: captures of what it is about —the bug as
it shows, the original next to it—. They go in `tasks/images/<task>/`,
named after what they show, and the task shows them with a Markdown image
at the place it talks about them, `![what it shows](images/<task>/x.png)`;
images written one after the other make a row. On GitHub they show as the
file does; on the page, small, and a tap opens each one whole. It is
taro's, from 2026-11-20, knowing that the repo is public and that a
capture of a port shows its game's graphics. Until that day captures were
left in a folder the task named, which only taro and the agents could
open. Each one is a PNG at the size it was taken —a capture of the console
is 256x224—: the page enlarges it without smoothing.

**This repo is public**: nothing written here can be private.

**A draft is not ready to be taken.** It is what an agent finds and does
not fix —a bug that is not part of its task, a path it did not cover, "the
next thing, measured"—: a short file with what was seen, in which game, at
which commit and how to reproduce it, with no `assignee` and without saying
how to fix it. **If what it found can be seen, it carries a capture of
it** (see "A task can carry images"), so that it is told apart at a
glance: taro's, from 2026-11-22. It leaves that state when someone defines it —to `todo` or
to `wishlist`— or it is deleted if something else fixed it. The difference
from `wishlist`: a task in the wishlist is defined and only needs to be
prioritised; a draft is not defined. It is taro's, from 2026-10-11: until
that day findings stayed in the "Hallazgos" section of the agent's task and
were buried with it.

**Decisions, divergences and research are not here**: they live in the
book, `the-advocate-docs`, in English, since 2026-10-10 —"the book is for
people and for AIs", taro's words—. Until that day `decisiones/` and
`divergencias/` were folders in this repo, and the research was in
`docs/research/` of the tools and of ABL. Each folder went to one of the
book:

* `decisiones/x.md` went to `src/decisions/`, except two of ABL's, which
  are in `src/ports/abl/decisions/`;
* `divergencias/x.md`, to `src/divergences/`;
* `docs/research/x.md` of the tools, to `src/research/`, and ABL's, to
  `src/ports/abl/research/`;
* `docs/port/x.md`, to `src/internals/`.

The file names kept their Spanish slugs until 2026-10-12, when they got
English ones made from their titles: the old name of a page, and where it
is now, are in the `[output.html.redirect]` table of the book's
`book.toml`, which also keeps the old URLs working.

**A task cites a page of the book with a link to it on the published
book**, `https://lautarodragan.github.io/the-advocate-docs/<path>.html`
—`research/x.md` is `…/research/x.html`—, keeping the citation's text as
the link's text, so it opens from the tasks page or from GitHub. It is
taro's, from 2026-10-12, the day the research cited in the tasks were
turned into links.

## A task's log

**What was done on a task goes in its last section, `## Log`**, one entry
per step, oldest first:

    ## Log

    ### 2026-11-20, Carpintero: the page folds the log

    What was done, checked, measured or reviewed, and what it left.

Above it goes what defines the task —what, why, taro's words, the plan as
decided, the images— and it is what one reads first; the log is its
history. Whoever works on a task adds an entry at the end, and does not
open a `## Done` or `## Checked (date, agent)` section above it; inside an
entry, its own subheadings are `####`. The page cuts the body at the
exact line `## Log` and shows what follows folded, closed, in a box with
its own scroll, labelled with how many `### ` entries it has; images work
there as anywhere in the task. `nu tasks/tasks.nu check` lists the tasks
not `done` with a heading above their log that reads like an entry, or
with a `##` section after it: a report to read, not a gate. It is taro's,
from 2026-11-20; the tasks that were not `done` that day were moved to it
by hand, and the `done` ones were left as they were.

## A task's comments

**The conversation with taro goes in `## Comments`, right above `##
Log`**: taro's comments, questions and answers, written from the tasks
page, and the questions for taro and the answers to them, Hornero's or an
agent's. Same entries as the log's, oldest first:

    ## Comments

    ### 2026-11-27, Cardón: a question for taro

    What there is to decide, the options and the recommendation.

    ### 2026-11-27, taro: a comment

    > Let's go with B.

    ## Log

`nu tasks/tasks.nu comment <task> <who> <title>`, with the text on
stdin, adds one, making the section if the task has none; the page does
the same with taro's. The page shows the comments open, above the folded
log, and a speech bubble after the task's pills: outlined when it has
comments, filled in the accent when it is taro's turn —the last comment
is someone else's, the task is assigned to taro and is not `testing` or
closed—, which the "waiting for you" toggle filters by; `nu tasks/tasks.nu
inbox` reads only this section —the log in tasks that have none—. What
was done stays in the log, even when it quotes taro. It is taro's, from
2026-11-27; the tasks not `done` or `cancelled` that day had their
conversation moved here, and the others were left as they were.

## A task's frontmatter

    ---
    name: "Short title"
    description: "One line: what it is, for the list"
    type: bug | feature | refactor | test | docs
    game: abl | [zounds, vampires-dawn] | …
    status: draft | todo | doing | testing | done | wishlist | cancelled
    assignee: taro
    author: taro | hornero | chaja | …
    links:
      blocked-by: [other-task]
      part-of: [a-bigger-task]
    ---

`type` and `status` are always there. **`game` is where it was seen and
where it has to be played to close it**: the game's directory in the ports
(`abl`, `zounds`, `book-of-three`, `test-game` for the test game…), or a
list. A task whose file name starts with the game's prefix —`abl-…`,
`zounds-…`— needs no `game`: the page reads it from the name. One that
belongs to no game —the tools' own— carries none. It is taro's, from
2026-11-17, to pick what to play from the page, and the page filters by it. `assignee` says who has it: `taro`
for their own and for those waiting on something from them —playing, looking
at some goldens—, and the agent's name for those in `doing`. See "Taking a
task" in `AGENTS.md`. In `todo`, with no `assignee`, whoever comes first
takes it. Many of those in `done` predate these fields and carry no
`assignee`.

**`author` is who the task comes from**, not who wrote the file —git
says that, with the first commit's trailer—: `taro` when it comes from a
report or a request of theirs, even if Hornero wrote it; the agent that
found it and opened it, for its own drafts and findings. Lowercase and
ASCII, as in the trailers' addresses (`taro`, `hornero`, `chaja`,
`huron`…). Every task carries one, `done` included; the page shows it and
filters by it, `nu tasks/tasks.nu ls -u <author>` lists them, and `nu
tasks/tasks.nu check` lists those without one. It is taro's, from
2026-11-20; that day every task got one, by a rule: a task that opens
with taro's words is theirs, and otherwise its first commit's trailer
says who opened it.

**`links` says how a task stands with others**: one relation per line,
each with a list of tasks by file name, and each relation with its
inverse on the other end:

| relation | inverse | for |
|---|---|---|
| `blocks` | `blocked-by` | "it goes after X" |
| `part-of` | `has-part` | a big task and its steps |
| `duplicates` | `duplicated-by` | a duplicate kept, instead of deleted without a trace |
| `found-in` | `found` | a finding, and the task it was found while doing |
| `relates` | `relates` | related, no order |

Few on purpose; one more is added when one is missing, in `RELATIONS` of
`tasks/tasks.nu`. **Both ends are written**, and `nu tasks/tasks.nu link
A <relation> B` writes them —`blocks: [B]` in A, `blocked-by: [A]` in B—
without touching the rest of either frontmatter. The page shows them as
a list before the log, each task with its state, so whether what blocks
a task is done is seen at a glance. The links in the prose stay as they
are, checked only for existence: they say why, and `links` says what
one task is to the other. It is taro's, from 2026-11-24; that day the
open tasks —`draft`, `todo`, `doing`, `testing`— got theirs from what
their prose said, and the `done` and `cancelled` ones only the inverses
of those. `found-in` came the same day, also taro's: most of those links
were a finding and the task it turned up in, which are not related as
tasks, and the page is navigated better by where something was found.

**`nu tasks/tasks.nu check` checks the links**, without the network: a
typed link with an unknown relation, to a task that does not exist or
without its inverse on the other end, in any task; and, in the prose of
those not `done` or `cancelled` —those, with `--status`—, a relative link
to a file that does not exist, a link to a file of this repo on GitHub
that is not there, and a link to the published book or to its sources on
GitHub that does not resolve against the book's `src/` in a checkout of
`the-advocate-docs` next to this repo's —or the one `--docs` names—: the
book's are skipped, saying so, when there is none. Any other URL is not
checked: it needs the network and fails at random.

**taro's words go in a quote block**, `> ` at the start of each line,
and not inline between quotes; in English like the rest of the task, and
when taro said them in Spanish, the line that introduces them says so
—"in their words, translated"—. It is taro's, from 2026-10-20, and it
applies to the tasks written before too.

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
