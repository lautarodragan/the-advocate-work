---
name: "The Python parity left behind"
description: "Twelve test files pin the tools' output to hashes taken from the Python they replaced, and two copies of pyjson write JSON the way Python did; the Python is gone, so both go, keeping only the tests that guard a path nothing else runs"
type: refactor
status: doing
author: taro
assignee: carpintero
agents: [carpintero]
---

**Why**: when the converter went from Python to Rust, around 2026-10-01,
each stage was proved equal to the Python it replaced: tests that compare
the output against hashes taken from the Python before it was deleted
—`tests/python.rs` in battle, events, mapdata, patches, rm2k-snes-audio,
screens, text, wally (and `background_python.rs`), rm2k-render, rules and
adeleine; some 6,600 lines— and `pyjson.rs`, in `convert` and in
`rm2k-snes-audio`, two near copies of a JSON writer that formats like
Python's `json.dumps`, so that `patches/uses.json` and `music.json` came
out byte for byte as before. The Python is gone: a hash nobody can read is
a golden without its image, and is updated without looking whenever an
intended change moves it.

> Regarding pyjson, I think I'd aim to remove it. It looks like legacy
> that brings unnecessary complexity.
>
> And the parity tests with Python — aren't they all superfluous?

(taro, 2026-11-23; and "Dale!" to doing both in one task.)

**What is asked**:

* `pyjson` goes: both copies, and what they write goes out with
  `serde_json`. What changes in a versioned file —`uses.json` in the
  ports— changes once, in its own commit.
* The parity goes, whole: every hash of the Python's output, every
  "against the Python" framing, the `*-python.json` fixtures only those
  tests read.
* What is **not** dropped blind: a test that drives a path neither ABL's
  suite nor the test game nor the crate's other tests run —the synthetic
  maps of `mapdata/tests/maps.json`, made to go through every path, are
  the clearest case— and that checks a property and not a hash, stays,
  renamed for what it checks, in the crate's tests. Each survivor says
  which path it guards; each file says how much was left of it.
* No ROM changes: every game's ROM byte for byte equal to `main`'s.
