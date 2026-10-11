---
name: "The converter does not clean up old patches"
description: "rom/build/<cartucho>/parches/ keeps the tomls of maps that no longer go in, and test_parches fails because of it"
type: bug
status: done
---

Found on 2026-09-25 while measuring whether `release` and `test-main` can be
merged: after rebuilding `release` without the test maps,
`rom/build/release/parches/0052.toml` was still there, from an earlier run
that did include them, and that alone makes `test_parches` fail. The converter
writes one patch per map and does not delete those of the maps that stopped
going in. It should clean the directory (or write into a new one and move it)
before writing.
