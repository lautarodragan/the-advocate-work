---
name: "The shared conversion cache grows without bound"
description: "Nothing ever deletes an entry of the machine's cache: every reinstall of a stage, of ca65 or of the runtime leaves the whole previous set of answers behind, and a full set for the nine games is over a gigabyte"
type: refactor
status: draft
assignee: taro
author: huron
agents: [cardon]
links:
  found-in: [a-conversion-cache-shared-by-the-worktrees]
---

Seen by Hurón on 2026-11-23, in
[`a-conversion-cache-shared-by-the-worktrees`](a-conversion-cache-shared-by-the-worktrees.md),
with the-advocate at `e3c93e76` (branch `huron-shared-cache`) and the
ports at `5745ec0`.

**What happens**: the cache that `CACHE` in the ports' `machine.just`
names —one for every checkout— keys each value by the binaries that made
it, so a new `wally`, a new `ca65` or a new runtime makes new keys, and
the old entries stay. Nothing deletes them. After one cold build of the
nine games, `du -sh` of the cache gave `stages/` 749 MB —every stage's
answers— and `ca65/` 394 MB —one object per cartridge, Vampires Dawn's
alone tens of megabytes—; `msu-tracks/` is hard links to the builds'
`.pcm` and costs nothing while a build keeps them, and all the space once
no build does.

**How to see it**: `du -sh ~/.cache/advocate/*` before and after
reinstalling `wally` and building the games once more.

It can be emptied by hand whenever nothing is building; deleting it while
something builds can take away a game unpacked from its `.zip` under a
converter that is reading it.

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: what evicts the machine's conversion cache (AGENTS.md
says "It has no eviction yet"). It matters more while
`the-stages-speak-json-nobody-types` keys every stage's answer by the
converter's binary: every converter change leaves a full set (~1 GB for
the nine games) behind.

**Options**: (a) nothing automatic, a recipe that empties it when nothing
builds; (b) each build deletes entries not read in N days (by atime or a
touched stamp); (c) a size cap, oldest first; (d) wait for
`a-stage-s-cache-key-once-it-is-a-library`, then decide.

**Recommendation**: (b), with N around 14 days, done in `cache.rs` with a
lock so that nothing reads an entry being deleted; it is toolchain code
with a cost to choose (disk against rebuilding), so it is yours.

### 2026-11-28, taro: an answer: (b)

> (b)

## Log
