---
name: "Rust is formatted and linted in CI"
description: "cargo fmt was never run on the workspace (it would rewrite 259 of 362 files) and clippy reports 98 warnings; both go into the GitHub workflow as checks, and the build fails on any compiler warning"
type: tooling
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-19, after the three compiler warnings the workflow printed
were fixed (the-advocate `54ec3daf`): "Is `fmt` run on the Rust code? And
`clippy`? It would be nice to have them as checks in the GitHub workflow."

Measured by Hornero on `54ec3daf`, rustfmt 1.9.0 and clippy 0.1.96:

* `cargo fmt --check`: 259 of the 362 `.rs` files differ; a full
  `cargo fmt` is 21,020 insertions and 5,859 deletions with the default
  config. With `max_width = 100` and `use_small_heuristics = "Max"`,
  10,879/8,549; with 120, 7,488/11,705.
* `cargo clippy --workspace --all-targets`: 98 warnings, no errors. The
  most common: very complex type (14), manual implementation of X (13),
  call replaceable (10), field assignment outside of initializer (6), doc
  list item without indentation (5), too many arguments (3).
* `cargo build` / `cargo test --no-run`: no warnings since `54ec3daf`.

## Log

2026-10-19, Mulita. Branch `mulita-rust-lint` in the-advocate, from
`54ec3daf`. The proof that the formatting changes nothing: two sets of
every tool, both installed from the same worktree —before and after
`cargo fmt`—, so the runtime and everything else is the same; every
game's cartridges built with each, `NO_CACHE=1`, from an empty `build/`,
and the `.sfc`, `.msu`, `.inc`, `.dbg` and `.pcm` compared by hash.
