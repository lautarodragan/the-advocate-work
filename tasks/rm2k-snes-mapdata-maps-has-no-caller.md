---
name: "rm2k-snes-mapdata maps has no caller"
description: "The mapdata binary's `maps` subcommand writes offsets.inc, maps.inc and tables.inc for a list of maps, and nothing runs it: the converter calls `emit`, the ports' tests `vram`, `compress`, `pages` and `engine`"
type: refactor
status: testing
assignee: taro
agents: [Calandria]
author: calandria
links:
  relates: [emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines, picture-tables-and-common-entries-write-the-same-entry-twice, small-repeats-inside-emit-rs-s-rest, the-battle-terms-by-name-are-a-42-arm-match, where-mapdata-and-convert-could-be-shorter]
  blocks: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/mapdata/src/main.rs`: the `Maps(MapsArgs)` variant
with its help (55-67), `do_maps` (227-244) and `MapsArgs`, which `EmitArgs`
flattens and so stays.

**What was seen**: who runs the binary, searched in the-advocate and in
every port's tests, justfiles and project files:

* `rm2k-snes-convert` runs `emit` (`convert/src/emit.rs`);
* ABL's tests run `vram` (`tests/harness/screen_stage.py`), `pages`
  (`tests/tooling/test_pages.py`) and `compress`
  (`tests/tooling/test_lz2.py`);
* the harness runs `engine` (`rm2k-snes/harness/rm2k_snes_harness/engine.py`);
* `maps`: nothing. `record::maps`, which it wraps, is still used by
  mapdata's own tests (`tests/animation.rs`, `tests/made_up.rs`) as a
  library call.

**The shorter form**: the subcommand and `do_maps` go; `record::maps`
stays for the tests.

**Estimated saving**: about 30 lines.

**What it risks**: a caller outside the repos —taro running it by hand—,
which is theirs to say.

**How to verify**: `rm2k-snes-mapdata --help` without it, and every port's
`just cartridges` and ABL's `tests/tooling` unchanged.

> I agree. In none of these cases is it really about reducing code,
> but improvements. Let's do the four, and then we go for those types /
> typed contracts between stages.

(taro, 2026-11-23, on this one together with
[`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md),
[`small-repeats-inside-emit-rs-s-rest`](small-repeats-inside-emit-rs-s-rest.md),
[`picture-tables-and-common-entries-write-the-same-entry-twice`](picture-tables-and-common-entries-write-the-same-entry-twice.md),
[`the-battle-terms-by-name-are-a-42-arm-match`](the-battle-terms-by-name-are-a-42-arm-match.md) and
[`rm2k-snes-mapdata-maps-has-no-caller`](rm2k-snes-mapdata-maps-has-no-caller.md);
the typed contracts are
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md).)

## Log

### 2026-11-23, Hornero: taken by Calandria

With the other four, in one branch, one commit each, every ROM byte for
byte equal.

### 2026-11-23, Calandria: the subcommand goes

the-advocate `f7601987`, on `calandria-emit` from `eb22c280`.

* Searched for the subcommand in the four repos and the book —`mapdata
  maps`, `offsets.inc`, `tables.inc`, `do_maps`, `MapsArgs`—: the only
  mention left was the crate's README, which listed it; it goes in the
  same commit. Nothing in the book named it.
* `Maps(MapsArgs)` and `do_maps` go. `MapsArgs` only lived for `EmitArgs`
  to flatten it, so its two fields, `plain` and `--raw`, moved into
  `EmitArgs`: `emit` takes the same flags. `record::maps` stays, for
  mapdata's own tests.
* Verified: every port's ROM byte for byte and every `.inc` equal to the
  baseline (see the log of
  [`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md)
  for how), which covers `emit` parsing its flags as before.
