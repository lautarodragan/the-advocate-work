---
name: "`just lint` is red with this machine's toolchain"
description: "On the-advocate a83c4a12, clippy 1.96 refuses mapdata's layer_text.rs:274 (useless_vec) and rustfmt wants convert's chipsets.rs and game.rs changed: none of it from the change that found it"
type: chore
status: done
author: tijereta
---

Seen by Tijereta on 2026-11-16, on the-advocate a83c4a12, finishing
[`the-debug-screen-in-the-msu`](the-debug-screen-in-the-msu.md), which
touches none of those files.

**What was seen**, standing in the-advocate:

* `cargo clippy --workspace --all-targets -- -D warnings` (what `just
  lint` runs, after `cargo fmt --all --check`) stops at
  `rm2k-snes/mapdata/src/layer_text.rs:274`,
  `let mut moved = vec![0u16; COLORS_PER_PALETTE];`: `clippy::useless_vec`,
  "you can use an array directly". The same line is on main
  (cd3fecb8), last touched by 8a233792. clippy says it is rust-1.96.0.
* `cargo fmt --all --check` lists diffs in
  `rm2k-snes/convert/src/chipsets.rs` (lines 308, 739, 746) and
  `rm2k-snes/convert/src/game.rs` (919).

Not measured: whether the CI's toolchain flags them too —it publishes on
each push that passes, so probably it is older—.

## Log

### 2026-11-22, Hornero: already fixed, done

`just lint` is green on the-advocate `cce50c91` with this machine's
clippy 1.96. The `useless_vec` went with `bee428f8` (2026-11-20, "clippy:
an array for layer_text's moved colours, parentheses in planes"), and
rustfmt's diffs in `chipsets.rs` and `game.rs` with `83e536bd` the same
day, which also closed
[`cargo-fmt-check-flags-three-files-on-main`](cargo-fmt-check-flags-three-files-on-main.md).
taro, translated:

> Go ahead
