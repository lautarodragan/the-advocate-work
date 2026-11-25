---
name: "The tasks page writes back"
description: "From the tasks page taro moves a task's state and assignee, comments, asks Hornero something or answers a question's options; each change applies at once and waits in a queue in localStorage behind an 'n pending changes [save] [discard]' bar, and saving is one commit to the repo through GitHub's API, with a token scoped to this repo; GitHub stays the source of truth"
type: feature
status: todo
author: taro
links:
  relates: [the-tasks-page-renders-filtered-and-fast]
---

**Why**: the page only reads. Moving a task, leaving a comment or
answering a question means a chat with Hornero or an edit by hand.

> How do you imagine we could integrate some more backend features? I like
> that GitHub is the source of truth. It would be interesting to move
> tasks from one state to another straight in the UI, or to ask you
> questions or leave comments. The first thing that came to mind is the UI
> offering those inputs and "save changes" opening a PR, but that would be
> rather bad UX...

> And to make the UI feel responsive, could we mix it with optimistic
> updates, keeping the pending changes in localStorage? Maybe it could
> show like the "copy selected / clear" bar, "n pending changes <save>
> <discard>"?

(taro, 2026-11-25)

**What is asked**:

* **Writing without a backend of our own**: a fine-grained GitHub token
  with write access to this repo alone, pasted once and kept in the
  browser's `localStorage`; without it the page reads as today. Not OAuth:
  its client secret would need a server.
* **What the UI changes**: a task's `status` and `assignee`; a comment or a
  question for Hornero, written as a log entry `### <date>, taro: …` with
  the text as a `> ` quote, the way Hornero writes taro's words; and the
  answer to a "question for taro" whose options are listed —a button per
  option, the choice written as such an entry—.
* **Optimistic, with a queue**: each change shows at once and waits in a
  queue in `localStorage`, which survives a reload and is shown over what
  is published; a bar like the selection's, "**n pending changes**
  [save] [discard]", which opens to the list so one can go alone. A
  change leaves the queue once the published page carries it.
* **Saving is one commit**: GitHub's git data API —a tree with every
  touched file, a commit, `main` moved— so "taro: 3 tasks" is one commit
  and all or nothing. If `main` moved meanwhile, the touched tasks are
  read again and the queue applied on top; a change to a field someone
  else changed is flagged, not saved blind.
* **Hornero hears it**: `nu tasks/tasks.nu inbox` lists taro's entries
  that no later Hornero entry answers, and Hornero reads it at the start
  of a session, with `doing` and `testing`; AGENTS.md says so. Hornero
  pulls (`--rebase`, only its own unpushed commits) before pushing.
* **The checks in CI**: a workflow runs `nu tasks/tasks.nu check` on every
  push to `main`, so a commit from the page that breaks a task shows.

## Log

### 2026-11-25, Hornero: written

Nothing done yet. To launch when the weekly usage allows it.
