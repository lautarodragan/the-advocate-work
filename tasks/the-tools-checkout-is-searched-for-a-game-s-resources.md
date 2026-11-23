---
name: "The tools' checkout is searched for a game's resources"
description: "The converter puts the root of the-advocate's checkout among the folders a resource is looked up in, before the game and the RTP; it has no RM2k folder, so it finds nothing, and nobody says why it is there"
type: refactor
status: draft
author: huron
---

Seen by Hurón on 2026-11-23, in
[`a-conversion-cache-shared-by-the-worktrees`](a-conversion-cache-shared-by-the-worktrees.md),
with the-advocate at `75d46e3c`.

**What happens**: `search_dirs` in `rm2k-snes/convert/src/convert.rs`
puts `rm2k_project::suite::root()` —the checkout the tools were installed
from— among the folders every lookup goes through, after the patches'
built images and before the game and the RTP; `wally` and the images
receive it as a `--search-dir`. A lookup opens `<dir>/<RM2k folder>/<file>`
(`find_resource` in `rm2k-render`, `resources::find` in the converter),
and the checkout's root has no folder named as one of RM2k's, so it finds
nothing there. A folder called `Picture/` or `System/` at the root of the
tools would cover the game's without a word.

`git log -S` takes it back to `97827508`, the converter's port to Rust;
no comment or commit says why it is there.

The shared cache had to work around it: a `--search-dir` goes into a
stage's key by its RM2k folders alone (see `Reads::Resources` in
`rm2k-snes/convert/src/stage.rs`), or any change to the runtime would have
expired every Wally answer.
