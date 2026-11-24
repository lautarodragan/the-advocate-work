---
name: "The event compiler's left-out warning never reaches the log"
description: "rm2k-snes-events writes \"map N: WARNING, event E is left out\" on its stderr, and the converter runs it with .output() and drops stderr when it succeeds: the warning has never been in converter.log, where the other left-out warnings are grepped for"
type: bug
status: draft
author: calandria
links:
  found-in: [the-stages-speak-json-nobody-types]
  relates: [variables-are-capped-at-256-slots]
---

Seen by Calandria on 2026-11-24, reading the-advocate `0d9f187c` for the
design of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md).

**What**: `rm2k-snes/events/src/pages.rs` 482 (`cab6995d`, 2026-10-19)
prints `  map {id}: WARNING, event {e} is left out: {why}` with `eprintln!`
when an event is left out whole and `left_out_why` says to warn. The
converter runs the compiler through `stage::run_uncached`
(`rm2k-snes/convert/src/stage.rs`), which calls `.output()` and reads
stderr only when the stage fails: on success the line goes nowhere. From
the cache it is not even produced. The other "map N: WARNING" lines are the
converter's own `println!`s and do reach `converter.log`, which is where
the drafts for left-out events grep (`grep "map 83: WARNING"
build/release/converter.log`). The loss itself is recorded: it also goes to
`degradations.json` as `event-left-out`.

**How many it hides**, at ports `4c23c9e` with the global tools, running the
compiler by hand on each game's `build/release/events-request.json`:

* **Vampires Dawn: 448 lines**, all "a page's condition names variable
  N, which has no slot in far RAM" —the loss of
  [`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md),
  known and in its port's page; what is missing is the log saying which
  events, as it does for the converter's own left-out events—;
* the other eight games: none.

    rm2k-snes-events compile --request build/release/events-request.json \
        --data data --out /tmp/x 2>&1 >/dev/null | grep 'WARNING, event'

**What fixes it**: phase A of the stages' task, which calls the compiler in
the converter's process: the `eprintln!` then lands in `converter.log` with
no other change. Until then, a fix in the converter would be printing the
stage's stderr on success.
