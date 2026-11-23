---
name: "rm2k-snes-mapdata maps has no caller"
description: "The mapdata binary's `maps` subcommand writes offsets.inc, maps.inc and tables.inc for a list of maps, and nothing runs it: the converter calls `emit`, the ports' tests `vram`, `compress`, `pages` and `engine`"
type: refactor
status: draft
author: calandria
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
