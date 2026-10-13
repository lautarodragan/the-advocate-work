---
name: "The other games' boot test once found Sunset stale right after building it"
description: "`just boot` failed once on sunset-over-imdahl with 'recién armado y el que arma lo da por viejo: was built with other sources, other flags or other cases'; the same tools passed it twice after"
type: bug
status: draft
---

Seen by Chajá on 2026-10-12, with the-advocate `7e3049cd` (branch
`chaja-condiciones`, before merging main) and the ports `742e127`, from the
root of a worktree of the ports, `just boot` with the branch's tools in
the PATH (`battle-conditions-for-real.md`).

**What was seen**: `test_boot.py::test_builds_and_reaches_the_first_map[sunset-over-imdahl]`
red, the other seven green: `rm2k-snes-cartridges` built Sunset's release
and right after reported it stale, "was built with other sources, other
flags or other cases". `just boot -k sunset` with the same tools was
green, and so was the whole `just boot` after that.

**What may explain it, not checked**: while that run was going I edited
`rm2k-snes/mapdata/src/emit.rs` in the same checkout of the-advocate
—Rust source, which the fingerprint should not cover, since it looks at the
installed binaries and `runtime/`—; or something else of the checkout was
touched in the middle of the build. If the fingerprint does read Rust
sources, AGENTS.md's "no source is touched while the tests run" covers
them too, and that is worth saying there.

**How to reproduce it**: not reproduced. Running `just boot` while
touching a `.rs` of the tools' checkout would say whether that is it.
