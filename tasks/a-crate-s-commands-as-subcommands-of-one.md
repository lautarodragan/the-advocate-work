---
name: "A crate's commands as subcommands of one"
description: "rm2k-snes-cartridge installs three commands and rm2k-snes-audio three more; each pair of extras becomes a subcommand of the crate's main command, so the PATH has four commands fewer and no boundary moves"
type: refactor
status: testing
assignee: taro
agents: [aguara]
author: taro
---

**Why**: two crates install three binaries each, and every one of them is
a command to know:

* `rm2k-snes/cartridge`: `rm2k-snes-cartridges`, `rm2k-snes-assemble`
  —which only `rm2k-snes-cartridges` runs— and `rm2k-snes-space`;
* `rm2k-snes/rm2k-snes-audio`: `rm2k-snes-audio`, `rm2k-snes-msu` —run
  by the build— and `rm2k-snes-volume-ceilings`, a recipe of ABL's.

They already share a crate, so folding them into subcommands
—`rm2k-snes-cartridges space`, `rm2k-snes-audio msu`— moves no boundary
between responsibilities: it only takes four commands off the PATH. It
follows
[`the-library-crates-carry-binaries-nobody-runs`](the-library-crates-carry-binaries-nobody-runs.md),
and waits for it to be merged, since both touch the justfile's lists.

> Let's go!

(taro, 2026-11-23, approving this and the split, in the book, of the
commands a person runs from those the pipeline runs)

**What is asked**:

* The six binaries become two commands with subcommands; every caller
  follows —the justfiles of the nine games and of the test game, the
  harness, the `Command::new`s in Rust, the fingerprint of
  `rm2k-snes-cartridges`, the release workflow—, and the old names go to
  `RENAMES.md` of the ports for the recipes that change.
* Whatever the caches key by binary —the MSU-1 tracks, `ca65`'s objects—
  keeps meaning what it meant: say what a hit or a miss becomes.
* No ROM changes: every game's ROM byte for byte equal to `main`'s.

## Log

### 2026-11-23, Aguará: the fold, and what the caches key by

From the-advocate 4b36cc8d, the ports d279eb1, the book acd7cd2; branches
`aguara-subcommands` in each.

#### What the caches keyed by binary see

Measured over the history since 2026-10-01, by which files each commit
touched (a proxy: a binary changes when code it links changes):

* **The cartridges' fingerprint** hashed `rm2k-snes-assemble`; now it
  hashes `rm2k-snes-cartridges`, which carries `assemble`. Of the 34
  commits that touched `cartridge/src`, 11 touched only what building or
  `space` use: those now make every cartridge stale. A stale cartridge with
  the stages and `ca65`'s objects in the cache rebuilds in seconds —all
  eleven of ABL's, from an empty `build/`, in 16 s—, so it stays.
* **The converter's stage cache** keys the audio stage by
  `rm2k-snes-audio`, which now carries `msu` and `volume-ceilings`. Of the
  31 commits that touched `rm2k-snes-audio/src`, 7 touched only the tracks'
  or the ceilings' code: those now expire the audio stage's answers too.
  Its miss costs seconds —every game built with it missing took what it
  took with it hitting—, so it stays.
* **The MSU-1 tracks' cache** keyed by the running executable, which was
  `rm2k-snes-msu` and became the whole `rm2k-snes-audio`: 18 of those 31
  commits did not touch what `rm2k-snes-msu` linked and would now render
  every track again. Rendering ABL's 106 costs about 40 s here, but each
  generation stays in `msu-tracks/` of the cache —hard links, and the
  cache has no eviction—: 2.4 GB more, measured (12 GB before the local
  build, 14 GB after). The crate's README said it in so many words: the
  two were separate binaries "so the MSU-1 tracks' key only changes when
  code that goes into that binary changes". So the key takes something
  narrower: see below.
* **`ca65`'s objects** are keyed by the `ca65` binary, its flags and the
  files it reads, not by the assembler that runs it: nothing changes. The
  headers the assembler writes into the generated `.inc` and `memory.cfg`
  name the new command, so every object missed once, in the first build
  with the branch's tools.

#### The fold

* the-advocate `e18f77aa`: `rm2k-snes-cartridges assemble|space` and
  `rm2k-snes-audio msu|volume-ceilings`, moved with `git mv`. The library
  runs `assemble` and `msu` by name from the PATH; the fingerprint hashes
  `rm2k-snes-cartridges`; a cartridge called `assemble` or `space` is
  refused, and a subcommand written after a flag is told to go first.
  `just which` lists the two commands.
* the-advocate `da083a30`: the tracks' key takes the source of the code a
  track comes from —`OWN_SOURCES` in `tracks.rs`: it, `midi.rs`, `num.rs`,
  `game.rs`, `fail.rs` and `commands/msu.rs`, by `include_str!`—, with a
  test that the list is closed over `crate::`, shown red without
  `midi.rs`. After it, a change to compile-only code (a help line) changed
  the binary and made `release` stale, and rendered no track: "0 made and
  106 that were already there".
* the-advocate `98ca9c3b`, the ports' second commit and the book: the
  prose. The ports' first commit: the nine justfiles, the harness
  (`_with_the_project` takes the command as a list), the ceilings test and
  the ceilings table's header. RENAMES.md of the ports has the four.
* Not touched: `AGENTS.md` here names `rm2k-snes-assemble` (lines 333,
  746, 792) and `rm2k-snes-space` (766); it is taro's file, so it is left
  to whoever merges.

#### Verified

Every game's cartridges, from an empty `build/` in a ports worktree: with
the global tools of main 4b36cc8d, and with the branch's installed in
`.local-tools` (cartridge, rm2k-snes-audio, patches, convert) three times
—after the fold, after the generated headers, after the tracks' key—: the
sha256 of every `.sfc`, `.msu`, `musicdata.inc` and ABL's 106 `.pcm`, 166
files, equal every time. The tracks rendered again under each new key, so
they were compared, not taken from the cache.

And the suites, on the branches with those tools: `just test` (29
passed), `just rust-test` (all green, the two known flaky ones too), ABL's
`just tests` (1692 passed, 2 skipped), `SOUNDFONT=…/FluidR3_GM.sf2 just
test-game` (230 passed, 6 skipped), and `just ceilings --measure` in ABL,
which runs `volume-ceilings`, its `--play` processes and
`rm2k-snes-cartridges --list --json`. `abl.sfc` after them is
`014a082d…`, the same as main's. Run by hand: `just space` in ABL —by
name and by a ROM's path— and in `dooms2`. What nothing ran: `just
ceilings` without `--measure`, which writes the table, and the ports'
`just deliver`.

#### On merge

* Install `cartridge`, `rm2k-snes-audio`, `patches` —it links the
  cartridges' library, which changed— and `convert` —a help line—: `just
  install cartridge rm2k-snes-audio patches convert`. Not the whole `just
  install`: no other binary changes; measured, by building every binary of
  the workspace before and after the generated headers changed and
  comparing their sha256.
* Then check that `/usr/local/bin` has no `rm2k-snes-assemble`,
  `rm2k-snes-space`, `rm2k-snes-msu` or `rm2k-snes-volume-ceilings` left;
  if `cargo install` did not remove them, delete them by hand: one left on
  the PATH runs old code without anyone noticing.
* The first build after it misses every `ca65` object once (the generated
  headers) and the audio stage once; the tracks hit, if `tracks.rs` and
  the other files in `OWN_SOURCES` do not change in the merge: this
  branch's build left that generation in the cache. The two generations
  its earlier, executable-keyed builds left there (212 files, about
  4.8 GB) were deleted.
* `AGENTS.md` names `rm2k-snes-assemble` and `rm2k-snes-space` in four
  places (see above).

Found and not fixed:
[`the-workspace-fails-its-own-lint`](the-workspace-fails-its-own-lint.md).
