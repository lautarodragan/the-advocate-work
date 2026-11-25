---
name: "The event compiler's left-out warning never reaches the log"
description: "rm2k-snes-events writes \"map N: WARNING, event E is left out\" on standard error; since A2 of the stages' task it reaches converter.log, but only when the compiler runs: an answer from the cache brings no warning, and each event is told three times, after everything else"
type: bug
game: advocate
status: todo
author: calandria
agents: [cardon]
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
other "map N: WARNING" lines are the converter's own `println!`s, which is
where the drafts for left-out events grep (`grep "map 83: WARNING"
build/release/converter.log`). The loss itself is recorded: it also goes to
`degradations.json` as `event-left-out`.

Until step A2 of the stages' task the converter ran the compiler as a process through
`stage::run_uncached`, which reads its stderr only when it fails: on
success the line went nowhere.

Since A2 —the-advocate `cardon-a2`— the compiler is
a function in the converter's process, and the `eprintln!` lands on the
converter's stderr, which `rm2k-snes-cartridges` appends to
`converter.log`. Measured at ports `4c23c9e`, `NO_CACHE=1 just cartridges
--force` in the nine games, against the tools before the step:

* **Vampires Dawn: 672 new lines** at the end of `converter.log`, **224
  events in 89 maps, each one three times** —the compiler walks each map's
  pages once in `scan` and twice in `compile`—, all "a page's condition
  names variable N, which has no slot in far RAM" (the loss of
  [`variables-are-capped-at-256-slots`](variables-are-capped-at-256-slots.md),
  known and in its port's page);
* the other eight games: none.

**What is still wrong**:

* **an answer from the cache brings no warning**: the stage's answer is
  `events.json` alone, and the line is printed only while the compiler
  runs. So whether `converter.log` names the left-out events depends on
  whether that build found the compiler's answer in the cache, which is
  the usual case for a second cartridge of the same request or a build
  after one with the same converter;
* **they come after everything else** —stderr is appended after stdout—,
  not next to the map's other warnings;
* **each event three times**.

To see it: build Vampires Dawn twice with the same tools, the first with
`NO_CACHE=1`, and compare `grep -c 'WARNING, event' build/release/converter.log`
after each: 672, then 0.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: the `eprintln!` at
`rm2k-snes/events/src/pages.rs` 483. The fix is not in doubt —the warning
travels in the compiler's answer, so the cache keeps it, and the converter
prints it once beside the map's other warnings— and changes no ROM.
