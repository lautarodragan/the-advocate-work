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

Default rustfmt config, no `rustfmt.toml`. Of what it would rewrite, only
one thing was a loss: the two glyph tables of `rm2k-snes/text`, one glyph
per line with its character beside it, broken into three lines each. That
file and Ditto's schema are generated and committed as their generators
emit them, so `#[rustfmt::skip]` on their `mod` (`a6a91a24`) leaves both
out; formatting Ditto's would make every `cargo xtask generate` a diff of
layout. The rest of `cargo fmt` alone, `da6a4a40`: 258 files.

Base tools (`54ec3daf`) against fmt tools (`da6a4a40`), every game of the
ports, `NO_CACHE=1`: ABL's 159 files (.sfc, .msu, .inc, .pcm, its test
cartridges), 6 of each of the seven survey games and 12 of Zounds, byte for
byte equal. The `.dbg` differ: ld65 writes each source's mtime in it.
