---
name: "A conversion cache shared by the worktrees"
description: "Every worktree of the ports rebuilds every game's cartridges from nothing, with the same inputs; a cache outside the checkouts —~/.cache/advocate?— keyed by the inputs and the binaries' hashes, extended to Wally, rm2k-snes-audio and whatever else is worth it, would build only what a branch changes"
type: refactor
status: todo
author: taro
---

> Add a task to `todo` for the converter cache across worktrees
> (~/.cache/advocate?), and add wally, rm2k-snes-audio and anything else
> we think is worth it to the cache.

taro, 2026-11-22, after Hornero counted where the CPU went with five agents
at once: each one builds every game's cartridges in its own worktree of
the ports, from inputs that are the same for all but what its branch
changes. At that moment the converter, Wally and rm2k-snes-audio added up
to some two and a half cores.

**What exists**: `build/cache/` in each game's project —see `cache.rs` in
`rm2k-project` and "Environment traps" in `AGENTS.md`—, keyed by the hash
of the sources and of the binaries that produce what is stored, and only
for the MSU-1 tracks. It lives inside each checkout, so no worktree sees
another's.

**What is asked**: the same kind of key, in a cache outside the
checkouts, shared by all of them; and more stages behind it —Wally's maps,
rm2k-snes-audio's music and samples, whatever a measurement shows is
worth it—. The rule that already holds goes on holding: a change to what
is cached is verified with `NO_CACHE=1`, both ROMs byte for byte equal. And
two worktrees writing the same entry at once must not corrupt it.
