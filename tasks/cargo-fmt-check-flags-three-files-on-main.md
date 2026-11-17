---
name: "cargo fmt --check flags three files on main"
description: "At the-advocate 3f3eede3, rustfmt wants to rewrap lines in convert/src/chipsets.rs, mapdata/src/layer_text.rs and mapdata/tests/python.rs; CI's lint job runs it"
type: bug
status: draft
agents: [Chajá]
---

Seen by Chajá on 2026-11-16, at the-advocate 3f3eede3 (and on main
a83c4a12 merged into `chaja-lb-screen`): `cargo fmt --check` from the root
prints diffs in three files nobody in that branch touched —
`rm2k-snes/convert/src/chipsets.rs` (3 hunks, last touched in a9ace784),
`rm2k-snes/mapdata/src/layer_text.rs` (9) and
`rm2k-snes/mapdata/tests/python.rs` (5)—. They are long `json!` and
iterator lines rustfmt wraps. `just lint` is what CI runs, so its job is
likely red; not checked against the rustfmt CI uses, which may be another
version.

To reproduce: `cargo fmt --check 2>&1 | grep '^Diff in'` in a checkout of
main. Fixing it is `cargo fmt` and a commit of its own, after checking the
toolchain CI pins.

Carpintero saw the same on 2026-11-16 at cd3fecb8 (`just lint`), with a
fourth file: `rm2k-snes/convert/src/game.rs`, one hunk, which came with
Chajá's merge that day.
