---
name: "The library crates carry binaries nobody runs"
description: "Voodoo, Gunter, LZ2, Adeleine and rm2k-render each install a command line the pipeline never calls: they were born when the converter was Python and could only reach Rust through a process. Drop the binaries, keep the libraries"
type: refactor
status: doing
author: taro
assignee: tijereta
agents: [tijereta]
---

**Why**: `voodoo`, `gunter`, `lz2`, `adeleine` and `rm2k-render` became
binaries between 2026-09-15 and 2026-09-29, when the converter was Python
and the only way for it to use Rust was to run a process with files in and
out (`848ccf79`, `5ef8be36`, `c7d2fe84` in the-advocate), and because of
the idea of small tools that compose. Since the converter went Rust, around
2026-10-02, the five are linked in as libraries —Voodoo and Adeleine into
wally, images and screens; Gunter into the audio; LZ2 into mapdata;
rm2k-render into five crates— and their binaries have no caller: no recipe,
no stage, no harness script in either repo; only their own command line
tests run them. What they still cost is a `main.rs` each with its clap, its
messages and its tests, one more build and install each, and a toolchain
that looks like it has five more commands than it has.

> Let's go! And let's take it on right now. It also simplifies how one
> reasons about the toolchain, which got too complex.

(taro, 2026-11-23)

**What is asked**:

* The five crates stop having a `[[bin]]` and a `main.rs`; what only the
  binary used goes with it, and so do the command line tests. What the
  binary tested that the library does not, moves to the library's tests,
  so no coverage is lost.
* They stay separate projects: what justifies the split is that they know
  nothing of the game (`AGENTS.md`), and that has not changed. Voodoo and
  Adeleine stay two, on purpose (taro, 2026-09-17).
* Everything that names them as commands follows: the justfile's
  `rust_projects` and its list of installed binaries, `LAYOUT.md`, the
  READMEs, CI and the release workflow, whatever cache or fingerprint lists
  their binaries, and `AGENTS.md` here if it says "binary" of any of them.
* The book: `tools.md`, `internals/`, and any page that tells them as
  commands, describe them as libraries. Researches are snapshots and are
  not edited. If the toolchain's description can say more simply what it
  is —a few commands, and libraries under them— that is the point.
* No ROM changes: every game's ROM, built with the branch's tools, byte
  for byte equal to one built from `main`.
