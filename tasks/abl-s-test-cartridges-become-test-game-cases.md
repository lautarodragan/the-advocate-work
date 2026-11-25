---
name: "ABL's test cartridges become test game cases"
description: "ABL builds eleven cartridges, ten of them only for engine tests that need what A Blurred Line does not have —faces, ChangeSystemGraphics, twins, a missing teleport, a 4bpp title, the MSU-1 path, a vblank probe—, and its release carries 367 test pages besides the game; those are the engine's cases, and they move to the test game as real situations, without test pages that jump into a state"
type: test
game: test-game
status: todo
author: taro
links:
  has-part: [abl-s-eraseevent-tests-leave-for-the-test-game, the-test-game-lacks-content-abl-s-runtime-branches-need]
  blocked-by: [battle-tests-without-simulate, tests-without-the-stages-subcommands]
  part-of: [golden-game-and-two-repos]
  relates: [a-stage-s-cache-key-once-it-is-a-library, the-test-game-lacks-content-abl-s-runtime-branches-need]
---

**Why**: since 2026-10-02 the engine's ROM tests live in A Blurred Line,
"using ABL as a stage", until the test game existed
([`golden-game-and-two-repos`](golden-game-and-two-repos.md)). It exists and
runs in CI; meanwhile ABL keeps building, for every change, ten cartridges
that exist only for cases the game does not have, and its `release` carries
367 test pages besides the game. Each test cartridge's reason is in its
comment in `abl/advocate.toml` in the ports:

* `test-special`: actors 12 and 13's sprites, flags and text padding that
  would change every other case's images;
* `test-encounter-every-step`: one of `test-special`'s cases with another
  `--test-encounters`;
* `test-twins`: map 255, with 59 twins;
* `test-teleport-missing`: a `Teleport` to a map no cartridge carries;
* `test-msu` and `test-msu-rom`: the same content read from the `.msu` and
  from the ROM;
* `test-change-system`: `ChangeSystemGraphics`, which ABL never uses;
* `test-faces`: faces, which ABL never shows;
* `test-vblank`: a probe that costs every vblank a few lines;
* `test-title-4bpp`: the 4bpp title, which ABL does not need.

It matters more now: while the stage cache keys every answer by the
converter's binary
([`a-stage-s-cache-key-once-it-is-a-library`](a-stage-s-cache-key-once-it-is-a-library.md)),
every change to the converter rebuilds all eleven from cold.

> Yes! They should move to the test game as cases without mocks.

(taro, 2026-11-24)

**"Without mocks"** is the point: a case in the test game is a real
situation —a map made for it, reached by playing, with the assets that
show it—, not a test page that starts the ROM straight into a state, nor a
flag that only a test cartridge carries. It is the same rule as taro's of
2026-11-22, when a separate `play` cartridge was proposed to keep goldens
from moving: "mocking is a code smell". Where a case needs something a
build flag gives today (`--test-encounters`, the vblank probe,
`--title-4bpp`), the task says whether the game itself can ask for it or
why it has to stay a flag.

**What is asked**:

1. **The classification first**, shown to taro: of the 367 cases of
   `release` and the ten cartridges, which test the engine —and move—
   and which test A Blurred Line itself —its content, its maps, its
   story— and stay. The first move of this kind is already on its way:
   [`abl-s-eraseevent-tests-leave-for-the-test-game`](abl-s-eraseevent-tests-leave-for-the-test-game.md).
2. **Then the moves, one subsystem at a time**: the case made in the test
   game, its test there, its goldens looked at by taro before the merge,
   and ABL's case, test and goldens deleted in the same change.
3. **ABL's test cartridges go** as they empty; ABL ends up with
   `release` and the tests only real content finds.

The tests that move also follow
[`battle-tests-without-simulate`](battle-tests-without-simulate.md) and
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md):
a case is not moved still asking a stage what to expect.

## Log

### 2026-11-24, Hornero: written

Nothing done yet. The cartridges and the 367 cases are from
`rm2k-snes-cartridges --list` on the ports' `4c23c9e`.
