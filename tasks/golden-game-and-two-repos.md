---
name: "The test game"
description: "An RM2k game of our own, with free assets, that tests the engine, so that its ROM tests stop depending on ABL"
type: test
status: wishlist
---

Until 2026-10-12 this task was "The golden game and two repos", taro's
idea from 2026-09-17. The two repos are done: ABL left for its own on
2026-10-02 (`abl-to-its-own-repo.md`). What remains is the game.

# What

**An RM2k game made on purpose that tests the engine**, with public-domain
or freely licensed assets, living in `the-advocate`: one small,
deterministic map per feature, and the whole game is the golden. Porting
another game reuses it whole. ABL's suite stays for what only real content
finds, and each error found in a real game is abstracted into a case here.

# Why now

Since 2026-10-02 **the engine's ROM tests live in ABL**: a change in the
tools is verified by running ABL's suite, and `just test` runs no ROM (see
"The rule that holds everything up" in `AGENTS.md`). That is the risk the
study pointed out, and the argument for not delaying this.

# The plan

The study is [`research/2026-10-02-the-test-game.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-02-the-test-game.html) in the book;
phase 1, ABL out, is done. What follows is its phase 2, the minimal game:

* the seven assumptions of its section 3 —each a small change in
  `cartridge`, `convert` or `screens`, with its test—;
* a game of three or four maps, written as that section says, with the
  assets of its section 3;
* the harness split, its generic part to `the-advocate`;
* ten of ABL's M1 test files moved to try out the path; ABL's copies are
  deleted when taro has looked at the new goldens.

Phases 3 to 5 —the rest of M1, M2 with its assets, M3 on both— each become
a task when the previous one is done.

## Checked on 2026-10-16 (Carpintero)

Phase 2 started: the game lives in `test-game/` of the-advocate since
[`the-test-game-its-skeleton`](the-test-game-its-skeleton.md) (Calandria,
2026-10-15, in testing), built from text with `rm2k-sketch` and Ditto, and
cases have been added to it since —switches past 1023 brought from A
Blurred Line ([`switches-past-1023-tested-in-the-test-game`](switches-past-1023-tested-in-the-test-game.md)),
nested calls, the faces, the escapes, the map pictures, the System's
cursor—, run by `just test-game`. What this task still holds is the rest of
the plan: the harness split and ABL's M1 tests moved over, and phases 3
to 5.
