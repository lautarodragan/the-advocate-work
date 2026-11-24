---
name: "Links between tasks have a type and both ends"
description: "The 938 links between tasks are prose: nothing checks they resolve, and the other end does not show them. Typed relations in the frontmatter —blocks, part-of, duplicates, relates—, written on both ends and checked by `tasks.nu check`, shown on the page as a list before the log; and `check` catches broken links"
type: feature
status: testing
assignee: taro
agents: [huron]
author: taro
---

**Why**: tasks link each other in their prose —938 relative links on
2026-11-24— and nothing says what a link means, checks it resolves, or
shows it from the other task. That day a duplicate draft was deleted and
whoever linked it had to be found by hand.

> Could you give the tasks a bit more structure, this time regarding the
> links between tasks? In the UI, I would like it to appear as a list,
> before the work log. And we could have a new linter step that checks the
> links are fine (no broken URLs), and that links are bidirectional: if a
> task A links to a B, both have to show the link. They could have a kind
> of relation, like in Jira: "blocks" / "blocked-by", "part-of", etc.

(taro, 2026-11-24, in their words, translated; and "go ahead" to
Hornero's proposal below)

**What is asked**:

1. **Typed relations in the frontmatter**, each type with its inverse:

       links:
         blocked-by: [cartridges-runs-itself-to-assemble]
         part-of: [the-stages-speak-json-nobody-types]
         relates: [battle-tests-without-simulate]

   | type | inverse | for |
   |---|---|---|
   | `blocks` | `blocked-by` | "it goes after X" |
   | `part-of` | `has-part` | a big task and its steps |
   | `duplicates` | `duplicated-by` | a duplicate kept, instead of deleted without a trace |
   | `relates` | `relates` | related, no order |

   Few on purpose; one more is added when one is missing.
2. **Both ends written, and checked**: `nu tasks/tasks.nu link A <type> B`
   writes both files; `check` reports a side without its inverse, an
   unknown type and a link to a task that does not exist.
3. **Broken links in `check`, without the network**: relative links
   between tasks, in the prose and the frontmatter; links to this repo's
   tasks on GitHub; and links to the published book, checked against the
   book's `src/` (`<path>.html` is `src/<path>.md`) in a sibling checkout
   of the-advocate-docs —skipped with a message when there is none, as in
   CI if it has none—. Arbitrary external URLs are not checked: they need
   the network and fail at random, and a flaky lint gets ignored.
4. **The page shows them**: a list before `## Log`, grouped by relation,
   each linked task with its status, so whether what blocks it is done is
   seen at a glance.
5. **The prose links stay**, checked for existence only. The typed links
   are filled in on the open tasks —`draft`, `todo`, `doing`, `testing`—;
   the `done` and `cancelled` ones stay as they are, as with `author` and
   `game` when they came in. The chain written on 2026-11-24 is the first
   case: the stages as libraries, `one-advocate-command`, the cache key,
   the tests without oracles, ABL's test cartridges, the volume ceilings.
6. **The README says it**, in "A task's frontmatter".

## Log

### 2026-11-24, Hornero: taken by Hurón

Nothing done yet.

### 2026-11-24, Hurón: the links, the check and the page

Two commits, the tool apart from the judgement.

#### The tool (`bf4af30`)

* **`links` in the frontmatter**, `{<relation>: [<task>…]}`, with the
  four relations of the table and their inverses in `RELATIONS` of
  `tasks/tasks.nu`. **`nu tasks/tasks.nu link A <relation> B`** writes
  both ends —into the relation's line when there is one, flow `[a, b]` or
  a block of `- a`; as a new line at the end of `links`; or as a new
  `links` at the end of the frontmatter—, touching nothing else; a link
  already there is not written twice, and an unknown relation, a missing
  task or a task to itself stop it. Tried on throwaway tasks with every
  shape.
* **`check`** now also says, in every task whatever its state, which
  typed links do not hold —unknown relation, no such task, itself, or the
  other end without the inverse—; and the **broken links in the prose**:
  relative ones (another task, an image), this repo's files on GitHub,
  the published book against `src/` of a the-advocate-docs checkout
  —`<path>.html` is `src/<path>.md`, `index.html` its folder's
  `README.md`, a name in `book.toml`'s redirects holds— and the book's
  sources on GitHub. What is inside code is not a link. The book's
  checkout is the one next to this repo's **main** checkout, found
  through the git common dir so that it works from a worktree; `--docs`
  names another, and without one the book's links are skipped with a
  line that says so. CI does not run `check` (`pages.yml` only builds the
  page), so nothing there changes. Like the log check, the prose of
  `done` and `cancelled` tasks only with `--status`: their history is
  not rewritten. Shown red first on a throwaway task with each kind of
  break.
* **Speed**: the frontmatter is cut out with a regex instead of `open`'s
  Markdown parse, which was two of the four and a half seconds `check`
  took. The whole `check`, with the new parts and 630 typed links, takes
  about one second on an idle machine and two under a load of 18. The
  page built from the old and the new script was byte for byte the same
  before the links were added.
* **The page**: a "Links" list before the log —or at the end of a task
  without one—, one row per relation in the table's order, each task by
  its name, linked to its anchor, with a pill of its state; `done` in the
  page's green, `cancelled` struck through. A `div`, not a `section`: the
  page's script takes every section for a state's. On a phone the
  relation goes above its tasks.
* **The README**, "A task's frontmatter": `links`, the table, `link`, and
  what `check` checks.

#### The relations (`2e50a60`)

Every task in `draft`, `todo`, `doing` or `testing` that links another in
its prose got the relation, and the other end its inverse: **315 pairs,
630 links, in 326 tasks** —215 open, 104 `done` and 7 `wishlist` that
only carry the inverse of an open task's link—. 272 are `relates`; the
rest is where the prose says an order or a whole:

* the chain of 2026-11-24: `the-stages-speak-json-nobody-types` blocks
  `one-advocate-command` and `a-stage-s-cache-key-once-it-is-a-library`,
  is blocked by the emission's five style tasks ("it goes after the
  emission's writing style"), and has as parts Calandria's four drafts
  ("drafts that this task takes in"); `cartridges-runs-itself-to-assemble`
  is part of `one-advocate-command` ("its first step"), and
  `the-volume-ceilings-are-measured-without-a-rom` is blocked by it; the
  emission's screens draft is blocked by the fallbacks one ("best done
  after"); `abl-s-test-cartridges-become-test-game-cases` is part of the
  test game (`golden-game-and-two-repos`), blocked by
  `battle-tests-without-simulate` and
  `tests-without-the-stages-subcommands` ("a case is not moved still
  asking a stage what to expect"), with the EraseEvent move as its first
  part; `the-test-game-takes-the-harness-and-the-first-ten-tests` is part
  of the test game too;
* `abl-release-stops-at-the-first-night` is blocked by the six drafts it
  lists as what stops it; `variables-past-256` duplicates
  `variables-are-capped-at-256-slots` (its description says so), which
  blocks the summons and the victims' choice of Vampires Dawn and is part
  of `the-converter-caps-what-far-ram-no-longer-limits`; the skills menu's
  phases are its parts, each after the one it names; and a few more
  "after X", "done by X" and "the step of X".

**A draft found while doing another task is `relates`** to it: most of
the 272. None of the four relations says "found in", and the task asks
for few; if that one is wanted, it is one line in `RELATIONS` and a pass
over the `relates` whose prose says "Seen … while doing".

#### Broken links

`check` found **none in the open tasks** —the 933 relative links between
tasks all resolve—, and **one in a `done` one**, left as it is:
`book-of-three-the-intros-torches-stand-still` links the book's source
`src/divergences/more-than-four-still-events-that-animate.md` on GitHub,
a page the book no longer has under that name. `nu tasks/tasks.nu check
-s done` lists it; nothing in `cancelled`.

What to look at: the page's "Links" list, in any task of the chain
—`one-advocate-command` shows "blocked by" the stages task in `doing`,
"has part" `cartridges-runs-itself-to-assemble` in `testing`, and five
`relates`—. Nothing to install: this repo only.
