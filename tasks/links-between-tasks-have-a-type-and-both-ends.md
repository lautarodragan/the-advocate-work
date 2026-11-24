---
name: "Links between tasks have a type and both ends"
description: "The 938 links between tasks are prose: nothing checks they resolve, and the other end does not show them. Typed relations in the frontmatter —blocks, part-of, duplicates, relates—, written on both ends and checked by `tasks.nu check`, shown on the page as a list before the log; and `check` catches broken links"
type: feature
status: doing
assignee: huron
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
