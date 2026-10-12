---
name: "The tools without ABL's data or code"
description: "What in tools/ names or brings in something of ABL outside the comments: test data, fixtures copied from the game, defaults and literals in the code; the comments stay because of the tools decision"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02, on seeing that a test of the event compiler uses
`PhoneCallDiff` as data: "go ahead". A `grep` of ABL names (characters,
places, pictures, the acronym) gives 125 lines in some 50 files of `tools/`.

**The engine comments that name ABL stay**, as
`decisions/the-tools-split-from-abl.md` says ("for now, out of
care"), and the limits measured against ABL keep their comment. What is
cleaned up is the rest: test data and fixtures, defaults, literals in the
code. And it is needed for the test game: this repo must not carry anything of
ABL (`plan-an-rm2k-game-for-tests.md`).

# What was found (Monterita, 2026-10-02)

The request's `grep` gives, on `3bf9aaf5`, 125 lines in 53 files. They were
classified by stripping each file of its comments with the same rules as the
guard (below):

| class | lines | files | what was done |
|---|---|---|---|
| runtime comments (`;`) | 41 | 26 | they stay, by the decision |
| comments and docstrings of the crates and of the Python | 53 | 17 | they stay; except those of the compiler's tests that cited ABL maps |
| `.md` prose | 14 | 3 | they stay as context, except one that was stale |
| test data and literals in tests | 15 | 9 | changed |
| literals in code | 2 | 2 | they stay: they are comments of the emitted `.inc` |

But the `grep` did not see everything. To find the rest, each literal of
`tools/` outside the comments was crossed against all the texts of ABL's dump
and the names of its files that are not from the RTP (a throwaway script),
and these showed up: speakers in capitals (`KERSH`, `MANTA`, `TALAN`,
`CONDA`, `CORE`), dialogue lines without any name, the victory term, a
battler (`sentry drone`, `BLmouse`), a CharSet (`Future2`), pictures
(`AdvoInstr`, `smoke1`), "What's the password?", and the `abl-*` of the
`justfile`. What matched was almost always a common word (`Sword`, `Potion`,
`Sign`, `Thunder`, `Attack`): that stayed.

**The fixtures that were a copy of the game**, all text —the test pictures are
formula-made, they were checked—:

* `rm2k-snes-text`: the boxes of `tests/refit.rs` (all ABL dialogue except
  one), two cases of `tests/escapes.json`, and in `tests/python.rs` a name and
  two speakers;
* `rm2k-snes-screens`: the frames of `tests/game/` (map 1 and common event
  1), the same lines;
* `rm2k-snes-events`: the speaker of the box that gets rebuilt, in
  `compile.json`, `scan.json` and map 1 of the small game;
* `rm2k-snes-mapdata`: the names "Talan's Pad" and "Lashe City - 34,35" of
  `tests/maps.json` (the rest of the fixture is made up);
* `rm2k-snes-patches`: the battler with a space.

They were replaced with made-up text **of the same length word by word**, with
the same punctuation and speakers of the same shape, because that is what the
split and the escapes look at. The hashes against the Python that changed
(nine: two of text, four of mapdata, one of events, one of screens, one of
patches) were changed on purpose, checking that the new answer, with the old
names put back, is the old one byte for byte; in screens, that each box breaks
at the same places. Each test's comment and the commit say so.

The test comments that were rewritten are those of the compiler
(`compile.rs`), which said which ABL map each case came from. Those of the
test in `mapdata/src/vram.rs` stay: they are a measured limit.

**The guard** is `tools/tests/test_no_game_names.py`: it strips the comments
of each file of `tools/` (`;`, `//`, `/* */`, `#`, docstrings), skips the
`.md` and searches for a list of ABL words. Exceptions: the file itself,
`test_project.py` (it writes `ABL_*` on purpose) and the two lines of the
emitted `.inc`, by piece of text and with a test that fails if they no longer
match. A `const _RED: &str = "PhoneCallDiff";` in
`rm2k-snes/text/src/refit.rs` turns it red. On `3bf9aaf5` it found 64
occurrences in 15 files. What it does **not** see: a copied line without any
name inside.

The suites: `just -f tools/justfile test` went from 32 to 52 (the guard, the
exceptions one and eighteen cases of the net); `cargo test -p` of the eight
crates touched, green. No binary changes —the `.rs` files touched are so in
their tests—, so the ROM cannot move; even so ABL's suite was run in a clone,
with these tools first in the PATH.

**When merging there is nothing to install**: no binary changes, nor the name
of any script.

ABL's suite, in a clone of `/shared/abl-snes` (`a942b02`) with this
worktree's local `bin/` first in the PATH: 993 green before and after, and
`abl.sfc` `8c9e670f8c86d7c4…` both times. It does not say much, and it is fine
that it does not: there is nothing in the ROM that this can move.
