---
name: "The workspace fails its own lint"
description: "`just lint` in the-advocate is red on main: clippy's wrong_self_convention on `from_the_cache` in rm2k-snes-audio, and rustfmt on two files, all from before the five libraries lost their binaries"
type: bug
status: draft
author: tijereta
agents: [Tijereta]
---

Seen by Tijereta on 2026-11-23, in the-advocate at `ca74a4d4` (main), while
checking the branch that dropped the five library binaries; none of it is
in a file that branch touched.

What was seen, standing in the-advocate:

* `cargo clippy --workspace --all-targets -- -D warnings` stops on
  `rm2k-snes/rm2k-snes-audio/src/tracks.rs:482`: "methods called `from_*`
  usually take no `self`", on `fn from_the_cache(&self, …)`. `git log -S
  from_the_cache` gives `6389bbb0`, "The disk cache can be shared: whole
  values, and the tracks themselves".
* `cargo fmt --all --check` asks to rewrap a line in
  `rm2k-snes/cartridge/src/assemble.rs` (around line 436) and two asserts
  in `rm2k-snes/wally/src/events.rs` (around lines 444 and 460).

`just lint` is what CI runs before building, so CI on main should be red
on that step. Reproduce with `just lint` at `ca74a4d4`.
