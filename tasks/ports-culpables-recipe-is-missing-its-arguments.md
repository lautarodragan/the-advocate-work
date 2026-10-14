---
name: "The ports' `just culprits` does not run"
description: "The recipe of the seven games calls `rm2k-snes-events culprits` without --data, --request and --out, and the request is not left anywhere"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Calandria on 2026-10-12, with the-advocate `28e66b35` and the ports
`c97a0dd`.

**What is seen**: `just culprits` in any of the seven games that are not
ABL —book-of-three, desert-nightmare, dooms2, el-dorado, frozen-world,
sunset-over-imdahl, vampires-dawn— stops with "the following required
arguments were not provided: --data, --request, --out". The recipe is
from the day each project was born, 2026-10-05.

**What is missing**: `--data` is the game's `data/`, but the request is
what the converter writes to a temporary directory and deletes
(`stage::run` in `rm2k-snes/convert/` of the-advocate), so there is no
file to pass it.

**How the report was obtained instead**, for the forge
(`book-of-three-the-forge-and-a-walkthrough`): a `rm2k-snes-events` first
in the PATH that copies its `--request` aside and execs the real one, a
`just cartridges release`, and `culprits` by hand on the copy.

### Hornero, 2026-10-14

taro asked which pages of ABL's whole game are left out and why, now that
`release` carries every map (with the items past 255 cut). Tijereta fixes
the recipe and runs it.

### Tijereta, 2026-10-14

**The recipe.** The converter now leaves the `compile` request it sends to
`rm2k-snes-events` as `build/<cartridge>/events-request.json`
(`keep_request` in `Compiler`, `rm2k-snes/convert/`), and every game's
`just culprits [cartridge] [args]` —ABL had none; it has one now— passes
`--data data --request build/<cartridge>/events-request.json --out
build/<cartridge>`, writing `culprits.json` next to the ROM. The request is
a new file next to the ROM, nothing else changes: ABL's `release` `abl.sfc`
is `21084b5b…cf52` before and after (built with the stock tools, then with
`convert` from the branch, and again with `--force`). ABL's suite was not
run for that reason. `just crate-test convert` and `events` below.

**A second fix, in `culprits`.** It judged a common event with a graphics
registry, and the converter compiles a shared body without one, so it did
not list the commons the converter leaves out ("left out, not compiling:
42, 44"). `judge` now takes `shared_body` for the common events' loop. With
it the report agrees with the converter.

**ABL `release`, the whole game (items past 255 cut), what `just culprits`
says**

| Kind | Pages | Compile | Left out |
|---|---|---|---|
| map pages | 5601 | 5601 | none |
| common events | 60 | 57 | 32, 42, 44: all `MoveEvent` alone |
| troop pages | 4588 | 4451 | 137, none lost: see below |

* Common 42 (Radin's menu) and 44 (Sern's menu): `MoveEvent` with event
  10001 (the hero) changing his graphic, in a shared body. The converter
  leaves both out ("left out, not compiling: 42, 44").
* Common 32 (`AG7CutsceneInTheRain`): a `MoveEvent` too ([2, 8, 0, 0, 13]).
  The converter's list does not name it (it only lists what the automatic
  commons reach), and every page that pastes it compiles
  (`skipped_calls` is empty); whether a page reaches it as a shared body
  was not checked.
* The 137 troop pages are page 1 of troops 1 to 80, 103, 105-107, 187,
  189-190 and 251-300: no condition flag and no commands. In RM2k a page
  without a trigger never runs, and `troops::trigger` gives None on purpose.
  Nothing is lost.

**Map 4's page without code**: not a page of the game. Map 4 is the boot
map, and `release` carries the suite's cases there as test pages; the last
one, which turns `TEST_SWITCH` off, has no code by design. The line says
"automatic" but counts every triggerable page: see the draft
[the converter's per-map line](convert-log-calls-every-page-of-a-map-automatic.md).
`culprits` finds all 5601 map pages compile.

**Map 321's shops** (Talan, Emily and Sern): the pages compile; only the
items fall. `OpenShop` compiles to the item numbers as words, and the
runtime's `op_shop` skips the ones `item_k` does not know (`$FF`). So
Talan sells 406-410 and loses 411; Emily's (413-416) and Sern's (418-421)
shops open with nothing to sell, all four of each being cut. That is the
temporary cut of
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md),
not a new bug; no draft.

To install when merging: `convert` and `events` (the-advocate).
