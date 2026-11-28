---
name: "the-advocate still speaks of the stages' gone binaries"
description: "LAYOUT.md says rm2k-snes-audio has an `msu` subcommand, gone on 2026-11-25, and several `stage.rs` doc comments still speak of the binary, its flags and its `--help`, which went on 2026-11-27"
type: docs
game: advocate
status: testing
assignee: taro
agents: [chaja]
author: chaja
links:
  found-in: [the-tools-table-names-the-stages-gone-binaries]
  relates: [tests-without-the-stages-subcommands]
  found: [mapdata-s-layout-pieces-has-no-caller, the-converter-leaves-an-events-request-nothing-reads, the-stages-error-kinds-outlived-their-exit-codes, the-stages-go-through-a-value-for-the-binaries-sorted-keys]
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

### 2026-11-28, Hornero: promoted to `todo`

Promoted by Hornero: found by grep with the lines, the binaries are gone,
so the fix is the comments and `LAYOUT.md` saying what is true; nothing
seen or heard changes.

### 2026-11-28, Chajá: taken, and the search widened

Since this was written the rest of the stages' binaries went too
(`rm2k-snes-audio`'s last, in `71ccb4eb`): the ones left are `advocate`,
`goombario` and `fxpak`. So the search is every gone binary's name and
"binary", "subcommand" and `--help` over all of the-advocate, not only
`stage.rs`. Branch `chaja-binaries-prose`, from `b4654a3a`; ROMs built
before and after with ports `aaa51a7c`.

### 2026-11-28, Chajá: the prose says what is true, and to testing

the-advocate `chaja-binaries-prose`: `5e60fb91`, comments and prose only,
and `f2b652e6`, main merged (`5f6d5d48`, a runtime change, no conflict).

#### What changed

Besides the lines above —the screens', patches' and mapdata's `stage.rs`;
LAYOUT.md's `msu` was already gone—, the wider search found, in the
present tense, binaries, subcommands and flags that no longer exist in:
`LAYOUT.md` (`rm2k-snes-audio` as an installed binary, `just install
wally` as the example), the `justfile` (the same example, the
`rm2k-snes-<something>` names, `rm2k-snes-audio` as a binary that links
`gunter`), the converter's `--help` text ("each one a program on the
PATH") and its `lib.rs`, `fail.rs`, `stage.rs`, `compiler.rs`, `maps.rs`,
`convert.rs` and `systems.rs`; the `fail.rs` headers of battle, wally,
screens and mapdata ("a script … different exit codes"); mapdata's README
(the binary's `pages`, `compress` and `vram` as present) and its
`json.rs`, `vram.rs` and `emit/custom_menu.rs`; screens' `answer.rs`,
`lib.rs`, `convert.rs` and `custom_menu.rs`; the audio stage's `Place`,
`Flags` and `Request`; `project`'s `log.rs` and `environment.rs`;
`cartridges.rs`; events' `request.rs`; battle's README. The screens
binary's `--help` for `--data`, `--system`, `--window-background` and the
rest became the doc comments of `Place`'s fields. And cartridge's README
listed "each song's volume headroom" in the fingerprint, gone since
`4699587d`.

Left right as they are: "the binary that links it" in events' `stage.rs`
(`advocate`), and every "until 2026-11-2x it had a binary" already in the
past.

Left on purpose: `tracks.rs` and `fail.rs` of `rm2k-snes-audio` are stale
too, but both are in `OWN_SOURCES`, the MSU-1 tracks' key by content, so
a comment there renders every track again. Added to Mulita's
[`game-rs-keeps-the-volume-ceilings-table-reader`](game-rs-keeps-the-volume-ceilings-table-reader.md),
which has the same cost and the same fix.

#### Verified

* ROMs: ports `aaa51a7c` in a worktree of their own, ABL's `just
  cartridges release` and the root's `just cartridges`, once with
  `advocate` installed from a clean worktree at `b4654a3a` and once with
  this branch's: all ten `.sfc` rebuilt (the binary differs, so the
  fingerprint does) and byte for byte the same —ABL's `release`
  `fbeabc99…`, and the eight other games' `release` and Zounds'
  `tests/exits`—.
* the-advocate, on `5e60fb91`: `just lint` (with `SOUNDFONT` FluidR3),
  `just test` and `env -u SOUNDFONT just rust-test`, green.

What no test covers: prose. It was read, not run.

#### Drafts

* [`mapdata-s-layout-pieces-has-no-caller`](mapdata-s-layout-pieces-has-no-caller.md)
* [`the-stages-go-through-a-value-for-the-binaries-sorted-keys`](the-stages-go-through-a-value-for-the-binaries-sorted-keys.md)
* [`the-stages-error-kinds-outlived-their-exit-codes`](the-stages-error-kinds-outlived-their-exit-codes.md)
* [`the-converter-leaves-an-events-request-nothing-reads`](the-converter-leaves-an-events-request-nothing-reads.md)

To install when merging: `just install advocate`.
