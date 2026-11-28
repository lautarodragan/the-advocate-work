---
name: "\"The tools\" names steps by the stages' gone binaries"
description: "The book's \"What goes in, what comes out\" table still calls each step by a subcommand of a binary that went on 2026-11-27 —rm2k-snes-events scan, wally map, rm2k-snes-screens window…—, when the stages are libraries advocate build calls"
type: docs
game: advocate
status: testing
assignee: taro
agents: [chaja]
author: calandria
links:
  found-in: [ditto-becomes-advocate-import]
  relates: [tests-without-the-stages-subcommands]
  found: [the-advocate-still-speaks-of-the-stages-binaries]
---

Seen by Calandria on 2026-11-27, in the book at `40b0a62`, doing
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md):
`src/tools.md`, "What goes in, what comes out", names each step by a
command —`rm2k-snes-events scan`, `rm2k-snes-screens window`, `wally
map`, `rm2k-snes-battle tables`, `rm2k-snes-events compile`,
`rm2k-snes-screens convert`, `rm2k-snes-images …`, `rm2k-snes-battle
model`, `rm2k-snes-mapdata emit`, `rm2k-snes-patches`, `rm2k-snes-audio
cartridge`—. Those binaries went on 2026-11-27 with
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)
(LAYOUT.md in the-advocate says which), and the steps are the stages'
libraries, which `advocate build` calls through their `stage` modules.
Its first row, Ditto's, is `advocate import` since the same day.

What to do: name each row by its stage and crate —"Wally's map stage"—
or by what it answers, as the rest of the page already does, and keep
the reads and writes as they are.

## Log

### 2026-11-27, Calandria: written

Not fixed: the rows are another task's, and only Ditto's was this one's.

### 2026-11-27, Hornero: promoted to `todo`

Promoted by Hornero: the table is in the book, and the binaries it names
are gone; the fix is the book saying what is true, nothing seen or heard
changes, and the task says what to do.

### 2026-11-28, Hornero: taken, to Chajá

> Querés encarar la tarea de la fecha de modificación y lo del libro ahora?

(taro, 2026-11-28)

### 2026-11-28, Chajá: the table, the road and the pages that ran them

On the-advocate-docs branch `chaja-tools-table`, from `8ffc6a7`, checked
against the-advocate at `0ba67b99`: `LAYOUT.md` and each crate's
`stage.rs`, whose functions keep the gone subcommands' names.

* `src/tools.md`: each row of "What goes in, what comes out" is its stage
  and crate —"the events' scan, `stage::scan` in `rm2k-snes-events`"—,
  reads and writes untouched; the road's diagram names the steps
  `events::scan`, `wally::map`…, with a paragraph saying what that
  notation is and that until 2026-11-27 most were also subcommands. While
  there: "Both sides" no longer says each stage has a binary;
  `rm2k-snes-audio`'s `msu` is told as gone on 2026-11-25 (`d1ffe356`),
  the tracks being `advocate build`'s; "Running them by hand" no longer
  speaks of stage binaries and of subcommands printing their requests.
* Outside `research/`, where a gone binary was still a command to run:
  the two "How to reproduce it" that said `wally map` give the project
  key that reaches Wally's map stage (`[graphics] baked_events`,
  `decorative_events`); `rm2k-snes-events culprits` as today's tool is
  `culprits.json` and `just culprits` (`a-skipped-call`; a note in
  `engine-vs-rm2k` and `what-erasing-an-event…`, which are measurements
  and keep the command they ran); `rm2k-snes-screens window` is the
  screens' `window` stage (two divergences, one decision,
  `lossy/colours`); `rm2k-snes-audio cartridge` is the music stage
  (`lossless/audio`); `--window-background` is `Place`'s
  `window_background`; `ditto unpack` and `pack` get "`advocate
  import`/`export` since 2026-11-27" where told in the present (a
  decision, the test game's skeleton).
* Left as they are: what is already history ("until 2026-11-27 …"), the
  two `$ wally layers` / `$ rm2k-snes-screens window` examples, which
  already say the binary went, and the crates named as crates.

Checked: the relative links of the thirteen pages touched, by script,
none broken; `mdbook build` clean. Merged main (already up to date).

Found and not fixed:
[`the-advocate-still-speaks-of-the-stages-binaries`](the-advocate-still-speaks-of-the-stages-binaries.md),
LAYOUT.md's `msu` subcommand and the `stage.rs` comments about the
binary.

Nothing to install: docs only.
