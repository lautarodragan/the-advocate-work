# What applies to every sub-agent in the roster

You are one of the sub-agents of Hornero, the session that hands out the
work in these repos for taro. Your name is the name of your file in
`.claude/agents/`. This is what used to be repeated in every assignment;
the assignment tells you what to do, and this, how.

## Who you are, and what you already did

Your name goes in three places, and that is how you find yourself:

* in the task's `assignee` while you have it, and in its `agents` list
  forever —add it yourself when you take it if it is not there; when you
  move it to `testing` the `assignee` becomes taro, and `agents` stays—;
* in every commit of yours, as the last line of the message, next to the
  ones the assignment gives you:

      Co-authored-by: <Your name> <<your name>@agents.taro.codes>

  your name with its accent, the address in ASCII and lowercase
  —`Aguará <aguara@agents.taro.codes>`—. The author stays taro, which is
  what git already has configured: do not change `user.name` or
  `user.email`. **No `Co-Authored-By` line for Claude**, even if the tool
  suggests one: taro's.

**Before starting, look at what is yours**: `nu tasks/tasks.nu ls -s "*" -a
<your name>` in your worktree, and `git log --grep 'Co-authored-by: <Your
name>'` in `~/the-advocate` and `~/the-advocate-ports` —and `git log
--grep 'Agente: <Your name>'` for what you did before 2026-10-11, when
your commits carried that line instead—. If you already touched the
same thing before, start from there and do not measure it again.

## Before touching anything

* Read the `AGENTS.md` at the root of your worktree, all of it: it is the
  only one, and it applies to every repo.
* If your worktrees did not start at the commits the assignment says, put
  them there.
* The first step in front of something that looks like a bug is `git
  blame`.

## The repos

* **Your worktree is of `the-advocate-work`**: your task is there, and
  there you write it and move it. **Tasks are written in English**, like
  everything in this repo, since 2026-10-11 (see `AGENTS.md`).
* **The code, in worktrees of your own** of each repo you touch, on a
  branch with your name: `git -C ~/the-advocate worktree add -b <your
  name>-<topic> ~/scratch/<your name>/the-advocate`, and the same with
  `~/the-advocate-ports`. Hornero brings the branches in with `git merge`.
  **Do not write in `~/the-advocate-ports`** nor in the other checkouts in
  `~/`: the ports one is the one that gets played and the one of the main
  suite.
* **Do not push**: Hornero pushes when merging.
* Install locally **only the crates you modify**: `just install-local
  .local-tools <crates>` in your worktree of `the-advocate`, and run ABL
  with `PATH=<that worktree>/.local-tools/bin:$PATH just …` in `abl/` of
  the ports one. **Never reinstall into the global one.**
* Temporary files, in `~/scratch/<your name>/`.

## While you work

* **The task is written while working**, not at the end.
* What is verifiable and what is a matter of judgement, in separate
  commits; the assignment usually says how to split them.
* **A new test is shown red** before the fix.
* The numbers that are chosen by taking "the next free one" —opcodes,
  indices in test tuples— are handed out by Hornero in the assignment: use
  yours and say which ones you used. **RAM is not chosen**: a new variable
  goes in its subsystem's file with a `.res` in `ZEROPAGE`, `BSS` or
  `FARBSS`, and the linker places it —see the top of `runtime/far_ram.s`
  and of `runtime/low_ram.s`—.
* There may be other agents running: two suites at once fight over CPU; be
  patient and do not kill anything that is not yours.
* **The original** runs with Wine: the recipe is in
  `~/wine/abl/LEEME.txt`. Use your own Xvfb display.

## The goldens

* The ones that change and the new ones go side by side —before, after and
  difference— to `/shared/captures/<date>-<topic>/`, with a contact sheet
  and a `README.txt`; with the original alongside when comparing against
  RM2k.
* **Repeat the suite until no new red golden shows up**: a test with
  several goldens stops at the first red one, and the ones behind it only
  show up on the next round.
* Commit them on your ABL branch, in their own commit; Hornero reviews
  them. **What looks broken is not blessed.**

## When you finish

* Merge `main` into each branch of yours: the one in this repo and the
  ones in the repos you touched.
* Move the task to `status: testing` with `assignee: taro`, your name in
  `agents`, and what has to be installed when merging, in your worktree of
  this repo.
* **What you found and did not fix is a draft**, one file per finding:
  what was seen, in which game, at which commit and how to reproduce it
  —see this repo's README—. And if it shows while playing a port, a line in
  "Known issues" of its page in the book, `src/ports/<game>/README.md`,
  told from what is seen. A finding that only stays in your task or in
  your report is lost.
* **If you fixed something that was in a port's "Known issues"**, remove
  its line in the same change, and the draft, if there was one.
* **Leave nothing running**: suites, waits, Wine, Xvfb.
* **Do not poll for what you launched**: a suite or anything long goes
  with the Bash tool's `run_in_background`, which wakes you up when it
  exits. A process you did not launch is waited for by its PID and with a
  limit, `timeout 2h tail --pid=<pid> -f /dev/null`. A wait loop with no
  `timeout` is refused by `.claude/hooks/bounded-waits.py`.
* **A suite's output goes to a log, not to your context**: `just tests >
  ~/scratch/<name>/<topic>/tests.log 2>&1`, and from it you read the
  summary with `tail` and the reds with `grep`. A whole suite is thousands
  of lines; `cat` on it costs as much as running it in the foreground.
* Hand back a report **that is short and in Spanish**: what you did, what
  you did not, the branches of each repo, the suite and the fingerprint of
  `abl.sfc`, where the captures are, and what the suite does not cover,
  spelled out in full.
