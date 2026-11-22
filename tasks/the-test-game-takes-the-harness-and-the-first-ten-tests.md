---
name: "The test game takes the harness and the first ten tests"
description: "Phase 2's last two items: split ABL's harness so its generic part serves the test game in the-advocate, and move the ten M1 tests of what RM2k does from ABL's suite to the test game"
type: test
status: doing
assignee: Tijereta
agents: [Tijereta]
author: taro
game: test-game
---

taro, on 2026-11-22, translated, about closing
[`golden-game-and-two-repos`](golden-game-and-two-repos.md):

> Go ahead! I'd like to take it on soon.

What is left of phase 2 of the book's
[`research/2026-10-02-the-test-game.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-02-the-test-game.html),
section 5, as Tijereta checked it on 2026-11-22 (the-advocate `0ae40e0a`,
the ports `89f77b4`):

1. **The harness split.** ABL's harness is whole in
   `abl/tests/harness/` in the ports, and `test-game/tests/game.py` in
   the-advocate calls itself "a stopgap" until the generic part comes
   over. The part that knows nothing of ABL —the cores, the session, the
   symbols, the captures and the comparison at 15 bits— goes to
   the-advocate, where the test game uses it; ABL's own stays in the
   ports and uses it from there.
2. **The ten M1 tests**: `test_variables`, `test_conditional`,
   `test_labels`, `test_jumps`, `test_same_door`, `test_speed`,
   `test_key`, `test_terrain`, `test_own_action` and `test_camera`, all
   still in `abl/tests/rpgmaker/` and with no copy in
   `test-game/tests/`. Each moves with its cases built in the test game's
   maps, and leaves ABL's suite only once its copy is green in both cores.

**Done** is both items: the stopgap gone, the ten tests run by `just
test-game` and by CI, and ABL's suite without them. With that,
`golden-game-and-two-repos` can be closed. Phases 3 to 5 are not part of
this.

## Log
