---
name: "Three texts that went stale"
description: "internals/events.md says the converter is Python, internals/vram.md says 'four' layouts and lists five, and the header of rm2k-rules' tests names a Python and a test that don't exist"
type: docs
status: done
assignee: taro
agents: [Hurón]
---

Two agents saw them and left them noted without touching them, because they
weren't part of their task. They are still like that today (the-advocate
`fc6f7456`, book `f6e8d57`):

* **The book's `internals/events.md`**: "What is left on the Python side is
  the converter, which compiles what the routine later reads". The
  converter is Rust. Tijereta noted it on 2026-10-10 when translating it
  (`book-the-tools-and-abl-docs-and-the-ports-section.md`: "it was translated as is").
* **The book's `internals/vram.md`**, section "A map that shows its
  panorama uses one of its own": "There are four" and the table lists five
  layouts (`panorama`, `panorama_m1`, `panorama_bg`,
  `panorama_bg_sprite`, `panorama_bg_ceiling`). The same task.
* **`rm2k/rules/tests/python.rs`** in the-advocate: the header says that
  "these rules also exist in Python, in the converter that still uses
  them" and names `tests/test_rm2k_rules.py`, which doesn't exist (in `tests/`
  there are four tests and none is that one). Calandria noted it on 2026-10-04
  (`justfiles-smaller.md`): "I didn't touch it: it belongs to the crate".

A page in `internals/` has to be up to date (AGENTS.md); the test's
comment protects the hashes in `python.json`, so whatever it says has to keep
explaining why they aren't edited.

## Done (Hurón, 2026-10-12)

From the-advocate `25d93f0a` and the book `381001b`. Each text was checked
against the code before writing it.

* **`rm2k/rules/tests/python.rs`** (the-advocate, branch
  `huron-stale-texts`, `d08cfd82`): the pickaxe on `test_rm2k_rules`
  shows the Python copy and its test left on 2026-10-02 (`97827508`,
  `f64f7aba`). The header now says that, and keeps why the answers are
  not edited: they are still the only independent answer, and nothing
  regenerates them. `just crate-test rules`: green. A comment only.
* **`internals/events.md`** (book, branch `huron-stale-texts`, `8d336f6`):
  the converter is Rust, `rm2k-snes-convert` and the stages it asks;
  `bakeable_events` is `baking::bakeable` in Wally; "the twenty reasons"
  went (a count of our work, and the compiler no longer enumerates
  reasons: `Stop::Cannot`); the table says which crate each Rust name is
  in. Every other name on the page was looked up and exists.
* **`internals/vram.md`** (same commit): six layouts `vram_layout` never
  returns, not two; five panorama ones, not four; '+both' is not the only
  one that moves the background tilemap; under a big picture the window
  tilemap moves in four layouts, not one; BG2's tiles are not above
  `$5000` in "panorama"; and the window is at index 128 in the last
  panorama layout. The tables were checked against `vram.rs` and are
  right.

The relative links of both pages resolve.

Found and not fixed, as drafts:
[`big-picture-over-a-mode-3-panorama-may-show-its-tilemap-in-bg2`](big-picture-over-a-mode-3-panorama-may-show-its-tilemap-in-bg2.md)
(suspected by reading, not reproduced) and
[`stale-comments-on-the-vram-layouts`](stale-comments-on-the-vram-layouts.md).

Nothing to install when merging.
