---
name: "Rust is formatted and linted in CI"
description: "cargo fmt was never run on the workspace (it would rewrite 259 of 362 files) and clippy reports 98 warnings; both go into the GitHub workflow as checks, and the build fails on any compiler warning"
type: tooling
status: testing
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-19, after the three compiler warnings the workflow printed
were fixed (the-advocate `54ec3daf`):

> Is `fmt` run on the Rust code? And `clippy`? It would be nice to have
> them as checks in the GitHub workflow.

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

Clippy, `d79d0c43`: of the 98, fixed what says the same in fewer words or
stops doing work (`is_multiple_of`, `div_ceil`, `slice::from_ref` instead
of a clone, struct update syntax, test modules last…); two doc comments
that rustdoc rendered as a list because a line started with "1.";
`from_events`, which took `&mut self`, is `add_compiler_answer`.
Workspace-wide allows in `[workspace.lints.clippy]`, with their why:
`type_complexity`, `too_many_arguments`, `needless_range_loop`. Per item,
with theirs: `int_plus_one` (three: the battle's text record asserts, the
negative rail), `if_same_then_else` (`round0`), `large_enum_variant`
(Ditto's `Document`), `manual_checked_ops` (a centroid). `just rust-test`
988 passed, 3 ignored; `just test` 29. Fmt tools against clippy tools,
every game, `NO_CACHE=1`: equal, the `.dbg` too without the mtimes; and a
second base build showed base against fmt `.dbg` equal the same way.

CI, `9876ae25`: a `lint` job running `just lint` (new recipe: `cargo fmt
--all --check` and `cargo clippy --workspace --all-targets -- -D
warnings`), `RUSTFLAGS=-D warnings` for the whole workflow, the toolchain
pinned. To 1.96.0 and not 1.98.1: the container's rustfmt and clippy say
1.96 (`cargo clippy --version` 0.1.96, though rustc is 1.98.1 and
`clippy-driver` prints 0.1.98) and do not know `chunks_exact_to_as_chunks`,
which rustup's 1.98.1 clippy denies on forty-odd `chunks_exact` lines. A
check that passes here has to pass there. The trail of that, on the `ci`
branch of the remote and in the local branch `mulita-rust-lint-trail`,
with the diagnostic steps (a failed step's output as an annotation, which
the public API returns without a token). Last run,
[39200438050](https://github.com/lautarodragan/the-advocate/actions/runs/39200438050)
at `fc85d875`: the three jobs green, the lint one in a minute. Its tree is
the branch's but for that annotation step and the `ci` trigger. One run
before it went red in the test game's job and not again: a draft,
[the test game's CI job went red once](the-test-games-ci-job-went-red-once.md).

`.git-blame-ignore-revs`: `cab6995d` (the fmt commit; it was `da6a4a40`
until its message was corrected about the `.dbg`, before anything was
merged). **The branch has to be merged, not squashed**, or that line points
at nothing.

The book: nothing in `contributing/` says how to check Rust before
pushing, so no line; the-advocate's README says `just lint`.

Main merged (Calandria's 2003 comparison): the conflict was `pages.rs`'s
imports; the rustfmt of what it brought goes in its own commit after the
merge.

**To install when merging**: everything, `just install` —every crate was
reformatted; no output changes, but every binary does—.
