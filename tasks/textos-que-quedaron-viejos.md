---
name: "Three texts that went stale"
description: "internals/events.md says the converter is Python, internals/vram.md says 'four' layouts and lists five, and the header of rm2k-rules' tests names a Python and a test that don't exist"
type: docs
status: draft
---

Two agents saw them and left them noted without touching them, because they
weren't part of their task. They are still like that today (the-advocate
`fc6f7456`, book `f6e8d57`):

* **The book's `internals/events.md`**: "What is left on the Python side is
  the converter, which compiles what the routine later reads". The
  converter is Rust. Tijereta noted it on 2026-10-10 when translating it
  (`el-libro-docs-y-ports.md`: "it was translated as is").
* **The book's `internals/vram.md`**, section "A map that shows its
  panorama uses one of its own": "There are four" and the table lists five
  layouts (`panorama`, `panorama_m1`, `panorama_bg`,
  `panorama_bg_sprite`, `panorama_bg_ceiling`). The same task.
* **`rm2k/rules/tests/python.rs`** in the-advocate: the header says that
  "these rules also exist in Python, in the converter that still uses
  them" and names `tests/test_rm2k_rules.py`, which doesn't exist (in `tests/`
  there are four tests and none is that one). Calandria noted it on 2026-10-04
  (`el-justfile-mas-chico.md`): "I didn't touch it: it belongs to the crate".

A page in `internals/` has to be up to date (AGENTS.md); the test's
comment protects the hashes in `python.json`, so whatever it says has to keep
explaining why they aren't edited.
