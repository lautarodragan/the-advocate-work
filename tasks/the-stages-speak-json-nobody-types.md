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
