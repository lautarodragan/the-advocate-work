---
name: "the-advocate still speaks of the stages' gone binaries"
description: "LAYOUT.md says rm2k-snes-audio has an `msu` subcommand, gone on 2026-11-25, and several `stage.rs` doc comments still speak of the binary, its flags and its `--help`, which went on 2026-11-27"
type: docs
game: advocate
status: draft
agents: [chaja]
author: chaja
links:
  found-in: [the-tools-table-names-the-stages-gone-binaries]
  relates: [tests-without-the-stages-subcommands]
---

Seen by Chajá on 2026-11-28, in the-advocate at `0ba67b99`, doing
[`the-tools-table-names-the-stages-gone-binaries`](the-tools-table-names-the-stages-gone-binaries.md),
which fixed the same thing in the book:

* `LAYOUT.md`, under `rm2k-snes-audio/`: "Its subcommands `msu`, the
  MSU-1 tracks, and `volume-ceilings`, each song's headroom, are not
  stages". `msu` went on 2026-11-25 (`d1ffe356`); `main.rs` has only
  `volume-ceilings`, and the tracks are `advocate build`'s.
* `rm2k-snes/screens/src/stage.rs`: `Place`'s comment says "as the
  binary's flags give it … See the binary's `--help` for each", the
  module's header speaks of "the binary took", and lines 163 and 181 of
  "the binary's keys" and "the binary writes its keys sorted".
* `rm2k-snes/patches/src/stage.rs`, lines 29 and 67, and
  `rm2k-snes/mapdata/src/stage.rs`, line 67, "the binary's", in the same
  sense; `rm2k-snes/events/src/stage.rs` line 44 and mapdata's line 66
  speak of "the binary that links it", which is `advocate` now and may be
  right as it is.

Found with `grep -rn "binary's\|the binary\b\|--help"
rm2k-snes/*/src/stage.rs`. Nothing seen or heard changes: it is comments
and one line of LAYOUT saying what is true.

## Log

### 2026-11-28, Chajá: written

Not fixed: the assignment was the book, and these are the-advocate's.
