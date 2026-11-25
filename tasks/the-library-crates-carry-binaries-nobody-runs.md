---
name: "The library crates carry binaries nobody runs"
description: "Voodoo, Gunter, LZ2, Adeleine and rm2k-render each install a command line the pipeline never calls: they were born when the converter was Python and could only reach Rust through a process. Drop the binaries, keep the libraries"
type: refactor
game: advocate
status: testing
author: taro
assignee: taro
agents: [tijereta]
links:
  blocks: [a-crate-s-commands-as-subcommands-of-one]
  found: [fxpak-s-pty-tests-fail-under-load, the-workspace-fails-its-own-lint]
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

And, approved the same day through Hornero, the toolchain's commands in
two lists —those a person runs, those the pipeline runs— and the
libraries under them, in the book and in `LAYOUT.md`, without renaming
or merging any binary: folding `cartridge`'s three and the audio's three
into subcommands is a task of its own, after this one (see the log).

## Log

### 2026-11-23, Tijereta: who runs the five, checked

From the-advocate ca74a4d4, the ports aa04dcc and the book cf20dcb, on
branches `tijereta-library-binaries`.

No recipe, stage or harness script runs any of the five: the converter's
`Command::new` are `stage.rs` (the stage binaries), the audio's
`ffmpeg`/`fluidsynth`, and `rm2k-snes-audio`'s own two binaries;
`CONVERTER_TOOLS` in `cartridges.rs` already left `voodoo` and `lz2` out
on purpose and never had the others; the release workflow takes every
`[[bin]]` from `cargo metadata`, so it follows on its own, and CI runs
`just install`, which skips a library. The one process call left is
`abl/experiments/fonts/mockups.py` in the ports, which runs
`rm2k-render system` and `rm2k-render face` to draw the fonts' mockups: a
one-off experiment, run by hand, no recipe. It does not keep the binary;
its README says which commit to install `rm2k-render` from to run it
again.

### 2026-11-23, Tijereta: the five are libraries, and the toolchain is told as commands over them

Branches `tijereta-library-binaries`: the-advocate `22fcfc94` (the
deletion) and `035da681` (the prose), the ports `d9d8d2c`, the book
`1803d3f`.

Hornero brought, mid-way, the two lists of commands, which taro
approved:

> Let's go!

(taro, 2026-11-23)

#### What went

The five `[[bin]]`, their `main.rs` and clap; what only the binary used:
Gunter's `wav` module, `parse_selector`, `extract()` and `Extracted`;
Adeleine's `request` module (its JSON answers moved to `tests/common/`,
since the hashes of `python.rs` are of those bytes); rm2k-render's
`request` module and every request-reading and file-writing function
(`write`, `request`, `source::request`, `source::dump`, `variant_file`,
the `Wanted`/`Sheet`/`Behind` structs). Gunter keeps `Selector::Named`:
it is the reader's way to pick a sample by name, and dropping it would
reshape `Contract` under the audio stage for nothing.

Coverage moved to the libraries where the command line tests checked
something the library did not: Voodoo's round trip draws back in the
test; Adeleine's three small answers are `tests/answers.rs`;
rm2k-render's `tests/layers.rs` draws a map whole, refuses a layer of the
wrong size and finds a resource whatever its case. What only tested
request parsing and exit codes went with the code. One check had no
library twin: rm2k-render's charset request refused a tile past 143;
`tile_sheet` takes any index, and its callers decide.

#### Verified

`just test` (29) and `just rust-test` green. The stage binaries that link
the five installed into `.local-tools`: `battle convert events mapdata
wally images rm2k-snes-audio screens`. Every cartridge of every game in
the ports —the 20 `.sfc` of `just cartridges` in each game's directory—
rebuilt with them, all "built", and byte for byte equal to a build with
the global tools from ca74a4d4 (`abl.sfc`
`014a082d14df926da817eefdc7c46cbd1f0fa8ff469730eb59f6d65e3d49e1ef`). ABL's
suite not run: the ROMs are the same bytes. The book's relative links in
`tools.md` checked.

#### What else names them

`figures/tools/make.py` in the book runs the five as commands to make the
pictures of "The tools"; it stays, and it and the page say to install
them from the-advocate `ca74a4d4` to make those pictures again. The same
for `abl/experiments/fonts/mockups.py` in the ports, which runs
`rm2k-render system` and `face`. The lists of commands in the book and in
`LAYOUT.md` were checked against the justfiles and the converter: besides
the ones Hornero named, the converter also runs `rm2k-snes-audio` and
`rm2k-snes-patches` as stages (`convert.rs`), so they are in the
pipeline's list too.

Found and not fixed: `just lint` is red on main, from before this branch
—a draft, [the workspace fails its own
lint](the-workspace-fails-its-own-lint.md)—.

#### What to install when merging

No binary of the five is left to install. What links them is reinstalled
from the-advocate: `just install battle convert events mapdata wally
images rm2k-snes-audio screens`. The old `voodoo`, `gunter`, `lz2`,
`adeleine` and `rm2k-render` in `/usr/local/bin` are stale leftovers that
nothing runs; they can be deleted by hand.
