---
name: "cartridges runs itself to assemble"
description: "rm2k-snes-cartridges builds each cartridge by spawning `rm2k-snes-cartridges assemble`, its own subcommand, as a process: a leftover of when the assembler was a binary of its own; it becomes a function call"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [mulita]
author: taro
links:
  part-of: [one-advocate-command]
  found: [the-cartridges-fingerprint-hashes-the-path-s-builder]
  relates: [the-workspace-fails-its-own-lint]
  blocks: [the-volume-ceilings-are-measured-without-a-rom]
---

**Why**: `Cartridges::convert`, in `rm2k-snes/cartridge/src/cartridges.rs`
of the-advocate, runs the converter and then `ASSEMBLE`
—`["rm2k-snes-cartridges", "assemble"]`— with `Command::new`. Until
2026-11-23 the assembler was `rm2k-snes-assemble`, a binary of its own,
and spawning it was the only way; `e18f77aa` made it a subcommand of the
same program and left the call as a process. Now the program runs itself
through the PATH —which, with a `.local-tools` first, may not even be the
same binary— to call code it already links.

> Go ahead, but to `todo` directly, and we take it on as soon as Calandria
> finishes.

(taro, 2026-11-23)

**What is asked**: the cartridge is assembled by calling the subcommand's
code as a function; `ASSEMBLE` goes, and whatever named it —comments, the
book— follows.

What stays a process, and why, so nobody folds it by analogy:

* the converter runs each stage as its own process: the stage cache keys
  each answer by its binary's hash (`stage.rs` `key`);
* `rm2k-snes-cartridges` runs `rm2k-snes-convert` and
  `rm2k-snes-audio msu`, which are other commands, with caches of their
  own;
* `rm2k-snes-audio volume-ceilings` plays each song in a process of its
  own: the snes9x libretro core is a `.so` with global state.

**How to verify**: every game's ROM byte for byte equal with `NO_CACHE=1`,
and the cartridges' fingerprint unchanged in what it covers —it already
hashes `rm2k-snes-cartridges` itself—; then the usual suites.

## Log

### 2026-11-23, Hornero: written, after Calandria's emission work

Nothing done yet. It waits for Calandria's branch so that no tool is
reinstalled while their suites run.

### 2026-11-24, Hornero: taken by Mulita

After Calandria's emission work merged (the-advocate `90d1041d`).

### 2026-11-24, Mulita: the assembler is called, to testing

Branch `mulita-assemble` in the-advocate (`46d5b46a`, the code; `04b37873`,
the prose) and in the book (`3686f9a`); none in the ports, which only
built.

#### What changed

`Cartridges::convert` calls `assemble::assemble` with what the
subcommand's `run` made of its flags: the cache directory absolute and
`None` with `NO_CACHE=1`, `self.root` —which is `suite::root()`, what
the subcommand used—, the `.sym` next to the ROM. `ASSEMBLE` is gone.
The `assemble` subcommand stays, for running by hand and for ABL's
harness, which asks it `--memory-map` and `--sources`. What stays a
process is as this task says above; nothing else was folded.

#### What the process gave implicitly, and how it is kept

* **Output**: the child inherited stdout and stderr; the library prints
  its lines with `println!` into this process's, and `ca65`/`ld65` still
  inherit them. The subcommand's own line, "ca65: the object came from
  the cache", is printed by `convert` now. The sorted build logs of four
  games are equal line for line between the two runs below; the cached
  line shows on a cached rebuild of El Dorado.
* **Failure**: a message of the assembler's own (`Failure::Message`) is
  printed to stderr when it happens, as the child did, then
  `<cartridge>: the assembler failed`, exit 1; a `ca65`/`ld65` failure
  (`Failure::Tool`) leaves their own stderr and the same line. Both run by
  hand on El Dorado: a `mapdata.inc` in `runtime/`, and a bad line in
  `main.s`. The child's exit code was never passed on, so nothing to keep.
* **Environment and current directory**: the child inherited both and set
  none; the call runs in the same ones. `ca65` and `ld65` still run
  standing in the root, which the library sets on their `Command`.
* **`.dbg`**: written by `ld65` as before; equal between the two runs but
  for the sources' `mtime`, which are two checkouts'.
* **What differs**: a panic in the assembler now takes the build thread
  down ("a build thread panicked") instead of being an exit status.
  Builds run in threads, and the disk cache's temporary names already
  carry a per-process counter for that.

#### The fingerprint

It hashed `rm2k-snes-cartridges` by its name on the PATH, and nothing
in it named the spawned assembler separately: unchanged. With the
assembler in-process the binary that packs the banks is the running one,
which is the PATH's one unless it is run by its path from elsewhere: a
note on the line, and the draft
[`the-cartridges-fingerprint-hashes-the-path-s-builder`](the-cartridges-fingerprint-hashes-the-path-s-builder.md).

#### The ROMs

`NO_CACHE=1 just cartridges --force` in the nine games of the ports at
`4c23c9e` (ABL `--without-tracks`), first with the global tools (from
`90d1041d`), then with `.local-tools/bin` first: 20 cartridges —ABL's
`release` and its ten test ones, Zounds' `release` and `exits`, the
other seven games' `release`—, every `.sfc`, `.sym` and `.msu` byte for
byte equal.

#### The suites

On the branch, with `.local-tools/bin` first (main had not moved in
the-advocate, the ports or the book): `just test`, 29 passed;
`just rust-test --no-fail-fast`, 1237 passed, 3 ignored; the test game,
231 passed, 6 skipped; the ports' `just boot`, 218 passed; ABL's
`just tests`, 1694 passed, 2 skipped. No golden moved.

`cargo clippy -p rm2k-snes-cartridge --all-targets -- -D warnings` is
clean and `cartridges.rs` passes rustfmt; the crate's `assemble.rs`
still fails rustfmt, one of the three of
[`the-workspace-fails-its-own-lint`](the-workspace-fails-its-own-lint.md),
left for that task.

To install when merging: `just install cartridge`.
