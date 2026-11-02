---
name: "The Rust on main is not formatted"
description: "cargo fmt --all --check fails on the-advocate's main: the terrains' lines in rm2k-snes/battle/src/db.rs and rm2k-snes/mapdata/src/emit.rs, and the conditions' in battle/src/simulate.rs and battle/tests/states.rs, which CI's lint step checks"
type: bug
status: done
---

Seen by Tijereta on 2026-11-01, on the-advocate `422f904d` ("A
terrain's damage hurts the party as the hero steps onto it"), while doing
[`sp-in-the-menu-and-the-item-target-picker`](sp-in-the-menu-and-the-item-target-picker.md).

`cargo fmt --all --check` —the first half of `just lint`, which CI runs
before building— prints four diffs, none in that task's lines: one in
`rm2k-snes/battle/src/db.rs` (the `terrains: by_id(...)` field) and three
in `rm2k-snes/mapdata/src/emit.rs` (`ITEM_USE_NO_TERRAIN_DAMAGE` and the
terrains' damage table). `cargo fmt --all` rewrites them.

At `origin/main` `3071048a` (the party's conditions) there are four
more: two in `rm2k-snes/battle/src/simulate.rs` and two in
`rm2k-snes/battle/tests/states.rs`.

How to see it: `just lint` standing in the-advocate at `3071048a`.

**2026-11-02, Hornero.** Fixed by `453fa7d4` in the-advocate, which ran `cargo fmt --all` and fixed three needless borrows clippy flagged, with byte-for-byte equal ROMs. At `5ef467fe`, `cargo fmt --all --check` is clean and CI's lint step is green.
