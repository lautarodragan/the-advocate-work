---
name: "`just lint` is red on main again"
description: "At the-advocate 4b36cc8d, rustfmt wants cartridge/src/assemble.rs and wally/src/events.rs rewrapped and clippy 1.96 refuses tracks.rs's from_the_cache (wrong_self_convention); CI's lint job runs both"
type: chore
status: draft
author: aguara
---

Seen by Aguará on 2026-11-23, on the-advocate 4b36cc8d (main), working on
[`a-crate-s-commands-as-subcommands-of-one`](a-crate-s-commands-as-subcommands-of-one.md),
which touches none of these lines. To reproduce, standing in the-advocate:

    cargo fmt --all -- --check
    cargo clippy --workspace --all-targets -- -D warnings

* `cargo fmt --check` wants the `if let Some(rest) = name.strip_prefix(…)`
  at `rm2k-snes/cartridge/src/assemble.rs:436` split over four lines
  —from 59ce9926, "A cached ca65 object gives the .dbg a fresh one
  gives"—, and two places in `rm2k-snes/wally/src/events.rs`, near lines
  444 and 460.
* clippy (`cargo clippy --version`: 0.1.96, CI's `RUST_TOOLCHAIN` is
  1.96.0) refuses `fn from_the_cache(&self, …)` at
  `rm2k-snes/rm2k-snes-audio/src/tracks.rs:482`: `wrong_self_convention`,
  "methods called `from_*` usually take no `self`" —from 6389bbb0, "The
  disk cache can be shared"—. Renaming it (`take_from_the_cache`,
  `link_from_the_cache`) is enough.

Not fixed in that branch so as not to mix it with the fold; the branch
itself is clean with `-A clippy::wrong_self_convention` and formats only
what it touched.
