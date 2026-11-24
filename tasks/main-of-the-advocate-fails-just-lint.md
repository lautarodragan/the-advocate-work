---
name: "main of the-advocate fails just lint"
description: "`just lint` is red on the-advocate eb22c280: rustfmt wants three spots of cartridge's assemble.rs and wally's events.rs written otherwise, and clippy refuses `from_the_cache(&self, …)` in rm2k-snes-audio's tracks.rs"
type: bug
status: draft
author: calandria
agents: [Calandria]
---

Seen by Calandria on 2026-11-23, at the-advocate `eb22c280` (main), while
checking the mapdata branch `calandria-emit`, which touches none of these
files. With rustfmt and clippy 0.1.96 (2026-05-25), the ones installed
here.

**What was seen**: both halves of `just lint` —what CI checks before
building, says the recipe— fail:

* `cargo fmt --all --check`, three diffs:
  * `rm2k-snes/cartridge/src/assemble.rs:436`, an `if let Some(rest) =
    name.strip_prefix(…).filter(…)` that rustfmt splits over four lines;
    the file was last touched by `59ce9926` ("A cached ca65 object gives
    the .dbg a fresh one gives", 2026-11-23);
  * `rm2k-snes/wally/src/events.rs:444` and `:460`, two calls in a test
    that rustfmt splits; last touched by `1d5be7dc` ("A page that only
    lifts an event above the hero is followed", 2026-11-22).
* `cargo clippy --workspace --all-targets -- -D warnings` stops at
  `rm2k-snes/rm2k-snes-audio/src/tracks.rs:502`, `fn
  from_the_cache(&self, …)`: `wrong_self_convention`, a `from_*` method
  that takes `self`. Born in `6389bbb0` ("The disk cache can be shared:
  whole values, and the tracks themselves", 2026-11-23). Clippy stops at
  the first crate that fails, so what comes after it in the build was
  not looked at; mapdata alone is clean.

CI should be red on that commit for the same reasons; not looked at on
GitHub.

**How to reproduce**: `just lint`, and `cargo clippy --workspace
--all-targets -- -D warnings` for the second half, standing in a checkout
of the-advocate at `eb22c280`.
