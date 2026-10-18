---
name: "A GitHub workflow for the tools"
description: "the-advocate checked on every push to main by GitHub Actions: the Rust workspace and its tests, the Python tests, and then the test game's cartridge, its ROM tests and Goombario over it"
type: tooling
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-18: a GitHub workflow that validates what can be
validated without A Blurred Line —that all the Rust compiles, the linter
over the runtime, the test game's tests—. The repo is public, so GitHub's
standard runners cost no minutes: it runs on every push to `main`, with a
concurrency group that cancels the older run. taro: the runner is Ubuntu,
so what we compile by hand here (`ca65`/`ld65`, the libretro cores) is
installed with apt where it can be.

Two steps:

1. The Rust workspace builds and its tests pass (`just rust-test`), and
   `just test`.
2. The tools installed, the test game made and built (which assembles the
   whole runtime), its ROM tests in the emulator, and Goombario over its
   cartridge. A free SoundFont (FluidR3_GM, MIT, or similar), never the one
   used here.

Third-party actions pinned by commit hash, not by tag. ABL's suite stays
the real net for the runtime: this does not replace it.

## Log
