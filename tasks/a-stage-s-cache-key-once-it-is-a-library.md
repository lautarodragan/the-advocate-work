---
name: "A stage's cache key, once it is a library"
description: "When the stages live inside rm2k-snes-convert, the cache can no longer key a stage's answer by its own binary's hash; until a per-stage key as trustworthy exists, every answer is keyed by the converter's binary and any change throws them all away"
type: refactor
status: todo
author: taro
---

**Why**: since `be1f43a5` the stage cache keys each answer by the hash of
the stage's binary (`stage.rs` `key` in the-advocate), which invalidates by
construction and per stage: touching Wally keeps the event compiler's
answers. [`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
folds the stages into the converter as libraries, and keys every answer by
the converter's binary meanwhile: still safe, but any change to any stage
rebuilds everything —some ten minutes instead of one for a new worktree—.

> I think I prefer simplifying the architecture first, and solving the
> cache later.

(taro, 2026-11-23)

**What is asked**: a per-stage key that cannot go stale silently. The
candidates, none measured yet: a hash of each stage crate's sources and of
its path dependencies, computed at build time —the risk is a dependency
left out, which hands back an old answer and a wrong ROM without a
word—; or something Cargo already knows about each crate. Whatever it is,
it is verified the way the cache always was: `NO_CACHE=1`, and every ROM
byte for byte equal.

It goes after the stages are libraries.

## Log

### 2026-11-23, Hornero: written

Nothing done yet.
