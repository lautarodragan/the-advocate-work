---
name: "The test game's CI job went red once"
description: "on the ci branch, run 39199346132, the test game's suite failed and the same tree passed on the next run; which test is unknown"
type: bug
status: draft
---

Seen by Mulita on 2026-10-19, bringing up rustfmt and clippy in the-advocate's
workflow, branch `mulita-rust-lint`.

Run [39199346132](https://github.com/lautarodragan/the-advocate/actions/runs/39199346132)
on the `ci` branch, at `b234122f`: the "Test game" step of the test game's
job failed with exit 1 after eleven minutes —the Rust and the lint jobs
green—. The next run, [39200438050](https://github.com/lautarodragan/the-advocate/actions/runs/39200438050)
at `fc85d875`, whose only change is that step printing its failures as an
annotation, was green. Locally, the same tools ran `just test-game -rs`
green (45 passed, 1 skipped).

Which test went red is not known: a job's log needs a GitHub token, and
that run had no annotation yet. Both runs built the tools with Rust 1.96.0
and `RUSTFLAGS=-D warnings`; the earlier runs that passed it used 1.98.1.
`test_cores.py`'s kind of red —bsnes's WRAM garbage— is the one that shows
up once and not again, as in
[ABL's](abl-test-cores-event-red-once-in-a-full-run.md).

**How to reproduce it**: run the workflow several times on the same commit,
or `just test-game -rs` in a loop; the captures that differ are uploaded
as the `test-game-snapshots` artifact.
