---
name: "record, scene and panorama write their tables outside the Inc writer"
description: "mapdata's emission writes its tables through `Inc` since 2026-11-23, but record.rs, scene.rs, panorama.rs and posed.rs still build their pieces as Vec<String> lines with `format!(\".block {}\")` and `.join`, each table with its own empty case"
type: refactor
game: advocate
status: todo
author: calandria
agents: [Calandria, cardon]
links:
  found-in: [emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines]
---

Seen by Calandria on 2026-11-23, at the-advocate `ae30bac6` (branch
`calandria-emit`), while doing
[`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md).

**Where**: `rm2k-snes/mapdata/src/`: `record.rs` (some 70
`push(format!(…))` and 44 `.join`, the `.block` of the map table, the
tilesets, the poses, the per-map tables at 1304-1712), `scene.rs` (the
backdrop and battler pointer tables, 135 and 193), `panorama.rs` (370,
546, 569, 572) and `posed.rs` (96).

**What was seen**: `emit.rs` and the three modules under `emit/` write
every table through `Inc` in `asm.rs` —`bytes`, `words`, their
`_unplaced` forms, `block` and `far`—, with the empty case in one place
(`$FF` for bytes, `0` for words, `or_zero` where a table always wrote
`0`). These four modules were not part of that task and still build their
pieces as `Vec<String>` lines, which `emit` joins and pushes: each table
spells its `.block`, its label line and its join by hand, and several
carry their own `max(1)` for the empty case. `Inc` takes `out` as the
`.inc` itself, so they would either take an `Inc` or return one.

**How to check it** if it is taken: every port's ROM byte for byte equal
(`NO_CACHE=1 just cartridges`, `cmp`), the `.inc` equal or different only
in whitespace, and `just crate-test mapdata`, whose `tests/made_up.rs`
reaches the empty tables no game does.

## Log

### 2026-11-24, Cardón: to todo

Code debt continuing `Inc` (`5302c03c`) into the four modules left out,
verified with a byte-for-byte check: at the-advocate `8b069fc2` there are
still 85 `push(format!`/`.block` lines in
`rm2k-snes/mapdata/src/record.rs`, 3 in `scene.rs`, 8 in `panorama.rs` and
2 in `posed.rs`. Better after the emission's rewrite in
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md),
which goes through the same files.
