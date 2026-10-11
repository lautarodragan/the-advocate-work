---
name: "Full inspection of the repo"
description: "Evaluate the project's architecture, quality, tests, documentation, risks and maintainability"
type: docs
status: done
assignee: Sol
---

Request of 2026-09-28: do a complete inspection and evaluation of the repo.

The evaluation rests on the tree's own sources, the commands of the
`justfile`, the state of the tasks and checks run against the code.
The result will go in `docs/research/`, with verifiable findings, risks and
concrete priorities, without fixing status metrics that go stale: each one is
expressed through the command that reproduces it.

Finished on 2026-09-28. The result is in
`docs/research/inspeccion-integral-del-repo.md`: the repo has a strong architecture
and testing strategy; the priorities are making the environment reproducible,
reducing the blast radius of the converter and clarifying licence and
provenance. The ROM suite could not be run: this environment lacked `just`,
Pillow, cc65 and the libretro cores; the Python syntax checks, the
tests of the five Rust projects and `git diff --check` did pass. `cargo fmt --check`
flags differences in the five projects with this environment's formatter;
that mechanical change was not mixed with the study.

Reopened on 2026-09-28 at taro's request to dig deeper specifically into the
analysis of the current tests: errors, architectural flaws, duplication
and abstractions that are superfluous or missing.

Expanded the same day. The detailed inspection found as main risks
the walkthrough captures without a golden that do not fail, the skips that depend on
artefacts, the helpers imported from `test_*` modules, the concentration of
domains in `Partida`, the repetition of waits without telling clocks apart and the lack
of an executable selection by requirement. It also separates the duplication that
is worth removing from the deliberate redundancy that protects the port.
