---
name: "The emission keeps fallbacks for answers older than its fixtures"
description: "emit.rs has a branch for each screens field an old answer lacked —slot_names, the screens' advances and reach, screen_letters, renamed, menu_tiles, inks—; the stages are always the same build, so only made_up.rs's two hand-kept requests still reach them"
type: refactor
status: testing
assignee: taro
author: calandria
agents: [cardon, calandria]
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
  blocks: [the-emission-reads-the-screens-answer-and-the-battle-model-by-name]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**, all in `rm2k-snes/mapdata/src/emit.rs`:

* 694-710: `slots.slot_names` missing, "an answer from before 2026-10-20";
* 901-904: `slots.menu_tiles` missing, then the bank's tile count;
* 296-317: `font.screen_letters` missing, "an answer from before
  2026-11-22";
* 2543-2565: `text_inks.advances`/`reach` missing, "a request from before
  2026-11-02", rebuilt from the window's first 96 and `TL_FIGURE`;
* 3611-3621: `texts.renamed` missing, "a screens' answer from before
  2026-10-15";
* 1483-1491: `window.inks` missing, every colour drawn as colour 0 ("a
  made-up one of the tests").

**What was seen**: the answers come from `rm2k-snes-screens` of the same
install, and the stages' cache key carries the producing binaries, so no
real request is ever older than the emission reading it. Who still lacks
those fields are the two hand-kept requests of `mapdata/tests/`,
`emit-bare.json` and `emit-whole.json`: checked, neither has `slot_names`,
`menu_tiles`, `screen_letters`, `text_inks.advances`, `texts.renamed` nor
`window.inks`. The fallbacks are those tests' path, and a path no game
takes —the same in reverse: the paths every game takes are not the ones
`made_up.rs` runs—.

**The shorter form**: regenerate the two requests' `screens` from the
screens stage (or add the missing fields by hand), and take the branches
out: a missing field is then a request this stage cannot use, as
`json.rs` already says for every other.

**Estimated saving**: about 40 lines of emit.rs. Small alone; what it
matters for is
[`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md),
which otherwise has to type two shapes of each of these fields.

**What it risks**: `made_up.rs`' asserts were written over the fallbacks'
output —the `made_up` notes and whatever they check of the slot screen—,
so some move with the fixtures; that is the test catching up, and has to
be looked at, not blessed.

**How to verify**: every port's ROM byte for byte equal before and after
(no game reaches the branches), and `just crate-test rm2k-snes-mapdata`
green with the new fixtures.

## Log

### 2026-11-24, Cardón: to todo

It is step **B0** of the plan in
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(`part-of` it, in `doing`): defined and ordered there.

### 2026-11-24, Calandria: done as B0

the-advocate `a63397d4`, on `calandria-b`: the six branches go
(`emit.rs` net -48 lines), and `emit-bare.json` and `emit-whole.json`
carry the six fields, filled with what each fallback gave, so the
made-up cartridges' `.inc` and notes came out byte for byte the same and
no assert of `made_up.rs` moved. The gold window, which this draft did
not list, went in B3 the same way. The nine games' builds with B0-B3, and
the suites, in the log of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md).
