---
name: "The stages speak JSON nobody types"
description: "Each stage builds its answer with json! and whoever reads it walks a serde_json::Value key by key; one set of serde types both ends share makes the contract between stages something the compiler checks"
type: refactor
status: todo
author: taro
---

**Why**: the converter's stages —screens, battle, events, images, Wally,
the emission— hand each other JSON. The side that writes builds it with
`json!`, and the side that reads walks a `serde_json::Value` with accessors
and checks the shape by hand: some 320 calls in mapdata alone, an `fn int`
copied in five files, and a `truthy` in the converter that is Python's.
A field renamed on one side compiles on both, and shows up only when a game
converts —if it does—.

> I agree. In none of these cases is it really about reducing code, but
> improvements. Let's do the four, and then we go for those types / typed
> contracts between stages.
>
> serde_json, or whichever library fits, takes care of the JSON. We gain a
> lot.

(taro, 2026-11-23)

**What is asked**: the contract between stages as Rust types that both
ends share, serialized with serde; the reading by hand goes. It starts
with a design —where the types live so that the layers still only depend
downwards (`tests/test_layers.py`), and what it does to the stage cache,
which keys each answer by its binary's hash (`stage.rs` `key`)—, shown to
taro before the code.

**The first question of the design: whether the stages stay processes.**
They are separate programs since the converter was Python, from the idea
of small tools that compose; the stage cache, from `be1f43a5`, keys each
answer by its binary's hash, which invalidates by construction. If the
stages became libraries inside `rm2k-snes-convert`, the contracts would be
plain Rust values passed between functions, and serde would be needed only
to store an answer in the cache: most of this task would come for free.
What decides it is whether a per-stage cache key can be as trustworthy as
the binary's hash —a hash of each crate's sources and its path
dependencies, computed at build time, misses a dependency and hands back a
stale answer silently; the converter's binary for every stage is safe but
throws away what the cache gained—. And the ports' tests call some stages'
subcommands directly (`rm2k-snes-battle simulate`, `rm2k-snes-screens
window`, `rm2k-snes-images animations`, `rm2k-snes-mapdata`…): where those
go. The answer, measured, goes to taro before the types are designed.

> [the processes] I would like to review that. Does rm2k-snes-convert
> exist only for the cache? Is it a more elaborate `make`?

(taro, 2026-11-23. It is not: of its 17,300 lines, running and caching
the stages is `stage.rs`'s 544; the rest are the decisions that join the
domains.)

What Calandria already measured, as drafts that this task takes in:

* [`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md)
* [`the-converter-reads-the-stages-answers-with-python-s-truthiness`](the-converter-reads-the-stages-answers-with-python-s-truthiness.md)
* [`the-converter-writes-the-emission-s-request-by-hand`](the-converter-writes-the-emission-s-request-by-hand.md)
* [`the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures`](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md)

It goes after the emission's writing style —the five tasks Calandria took
the same day, linked from
[`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md)—,
because both rewrite most of `emit.rs`.

## Log

### 2026-11-23, Hornero: written, waiting for the emission's writing style

Nothing done yet.

### 2026-11-23, Hornero: whether the stages stay processes comes first

Added to the design, at taro's request.
