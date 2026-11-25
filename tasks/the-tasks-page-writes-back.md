---
name: "The tasks page writes back"
description: "From the tasks page taro moves a task's state and assignee, comments, asks Hornero something or answers a question's options; each change applies at once and waits in a queue in localStorage behind an 'n pending changes [save] [discard]' bar, and saving is one commit to the repo through GitHub's API, with a token scoped to this repo; GitHub stays the source of truth"
type: feature
status: testing
assignee: taro
agents: [huron]
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

### 2026-11-25, Hornero: how Hornero hears it, while working

> Would it make sense for you to have a `git fetch` running in a loop,
> once every 15 minutes, say, and `git log ..origin/main`, and that this
> alerts you, with a Claude Code monitor or some custom plugin? It would be
> good that it does *not* message/wake you if there is nothing to look at.

> And maybe you could start that monitor automatically when a session
> opens? With a hook?

(taro, 2026-11-25) For Hornero to do when merging Hurón's work, beside
`tasks.nu inbox`:

* **A Monitor** (Claude Code's tool: it wakes Hornero only when its command
  prints): every 15 minutes `git fetch`, and the commits on
  `origin/main -- tasks/` without an agent's `Co-authored-by` trailer —the
  page's—, printed once each, nothing printed otherwise. Under a
  `timeout` (24 h), as `.claude/hooks/bounded-waits.py` asks.
* **A `SessionStart` hook** in this repo's `.claude/settings.json`: `git
  pull`, `nu tasks/tasks.nu inbox` as context, and a reminder to launch
  the Monitor —a hook cannot launch it: the tool is Hornero's—; AGENTS.md
  says so too.

### 2026-11-25, Hurón: the page writes, against a fake GitHub

* `nu tasks/tasks.nu inbox`: taro's entries (`### <date>, taro: …`)
  with no later Hornero entry in the same task. `check --strict` exits 1
  on a task without an author, a typed link that does not hold or a
  broken link —the log-like headings stay a report—, and
  `.github/workflows/check.yml` runs it on every push to `main` that
  touches `tasks/`, with the book checked out for its links. AGENTS.md
  has Hornero read the inbox when starting and `git pull --rebase`
  before pushing; the README says what the page writes.
* The page (`site/index.html`, "Writing back"): a "write" button at the
  top asks for the token once and keeps it in `localStorage`; it is sent
  only in the `Authorization` header to `api.github.com`. With it, an
  opened task gets a form at its end —state, assignee, a comment, "Ask
  Hornero", and a button per option when its last "a question for taro"
  has no taro entry after it—. Each change shows at once (the task moves
  to its state's section and stays in view until the state filter is
  clicked; the assignee in its meta; the entry at the end of its log,
  marked pending; a bar of the accent on the task) and waits in the
  queue, behind the bar "n pending changes [save] [discard]", which opens
  to the list, each change with its ×.
* Saving: main's ref, its commit, each touched task read at that commit,
  the queue applied on top; a blob per file, one tree over main's, one
  commit, the ref moved without force. A field whose value on main is
  neither the queued change's base nor its value is flagged ("main has
  X", with "keep mine") and not saved; one already so leaves the queue.
  A 422 on moving the ref —main moved— reads it all again, up to three
  more times. A saved change stays shown as "publishing" until the page
  is built from a commit as recent as its own: the build writes its
  commit and date in `<meta name="tasks-commit">`.
* Verified in headless Chromium with `fetch` stubbed by a fake of the git
  data API kept in `localStorage`, 37 checks: no form without a token;
  the queue surviving a reload; the requests in order (ref, commit, two
  contents, two blobs, tree, commit, ref); a 422 with another push in
  between re-reading everything and committing once on top of it; the
  assignee someone else changed flagged and not saved, then saved with
  "keep mine"; the entries' Markdown; every request to `api.github.com`
  with the token; the saved changes leaving once the page's commit is
  later; a refused token saving nothing. Over the 42 tasks that mention
  a question for taro, the option buttons come out for the 33 whose
  question letters its options. **GitHub's real API was not
  exercised**: there is no token here. Load cost within noise, with the
  script and without it: 676 against 630 ms to DOMContentLoaded at CPU
  4x, 3 runs each.

### 2026-11-25, Hurón: to testing

Nothing to install: no Rust, only `tasks/tasks.nu`, `site/index.html` and
the new `.github/workflows/check.yml`. The page's commits are made with
taro's token and carry no agent's `Co-authored-by` —their message starts
"taro, from the tasks page"—, which is what the Monitor planned above
tells them apart by. Left to taro: the first real save —the token, a
change, "Save"—, the commit on `main`, and the page carrying it after its
build. The page built from this branch is in the captures'
`2026-11-25-tasks-page-writes/`; it saves to the real repo, so a change
made from it lands on `main`.
