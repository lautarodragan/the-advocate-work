---
name: "\"The tools\" names steps by the stages' gone binaries"
description: "The book's \"What goes in, what comes out\" table still calls each step by a subcommand of a binary that went on 2026-11-27 —rm2k-snes-events scan, wally map, rm2k-snes-screens window…—, when the stages are libraries advocate build calls"
type: docs
game: advocate
status: doing
assignee: chaja
agents: [chaja]
author: calandria
links:
  found-in: [ditto-becomes-advocate-import]
  relates: [tests-without-the-stages-subcommands]
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
