---
name: "One advocate command"
description: "Once the stages are libraries, the converter becomes one too, and rm2k-snes-cartridges becomes `advocate`, with subcommands: build, assemble, space, and whatever else is building the game"
type: refactor
status: doing
assignee: calandria
author: taro
links:
  relates: [artistic-decision-patches, battle-tests-without-simulate, the-volume-ceilings-are-measured-without-a-rom, tests-without-the-stages-subcommands, the-cartridges-fingerprint-hashes-the-path-s-builder]
  has-part: [cartridges-runs-itself-to-assemble, the-stage-subcommands-only-the-converter-called-have-no-caller]
  blocked-by: [the-stages-speak-json-nobody-types]
---

**Why**: building a game is today a chain of processes —
`rm2k-snes-cartridges` runs `rm2k-snes-convert`, which runs each stage,
and then runs itself to assemble—. After
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
the stages are libraries inside the converter; this takes the last step:
the converter is a library too, and what a person runs to build a game is
one command, named after the project and its `advocate.toml`.

> Hmm, I like it! And turning the converter into a library too. All the
> stages stay as libs. And advocate with subcommands. It's beautiful.

(taro, 2026-11-23)

> [a file in `build/` instead of `rm2k-snes-project`] I like that idea.

(taro, 2026-11-24)

**What is asked**: `rm2k-snes-cartridges` becomes `advocate`, with the
converter linked in:

    advocate build      what rm2k-snes-cartridges does today: convert,
                        assemble, the MSU-1 tracks
    advocate assemble   only assemble
    advocate space      each cartridge's free space

To decide in its design, each with its why:

* **`rm2k-snes-project` goes, instead of becoming `advocate project`**:
  `advocate build` leaves in `build/` a file with what it prints today,
  and the ports' tests and recipes read that file. The tests then consume
  no binary —the book's decision "One command, and no tool of ours runs
  another"—; `--unpacked` and `--harness`, its other two modes, need a
  place too.

* **The MSU-1 tracks**, `rm2k-snes-audio msu`: their cache keys on the
  sources they include (`OWN_SOURCES` in `tracks.rs`), not on a binary, so
  being a library costs them nothing.
* **What stays its own command**: the domain tools a person runs for
  something other than building the game —`ditto`, `goombario`, `fxpak`,
  `rm2k-sketch`, `rm2k-snes-events culprits`, `rm2k-snes-patches`— and the
  stages' subcommands the ports' tests call, if the stages' task left them.

**The goal at the end: `advocate` as one static musl binary, with nothing
beside it.** taro's, 2026-11-24:

> I would love to have that as a goal for `advocate`, if it can be done.
> We go back to really having a statically linked binary, with no
> dependencies, fully self-contained.

> [musl] Let's ignore this for now. We evaluate it again at the end of
> everything.

(taro, 2026-11-24: the goal stands, but it is looked at again once the
rest is done, not along the way.)

What stands in the way today, measured on the-advocate `90d1041d`:

* **The Linux releases are glibc because of one `dlopen`**: the libretro
  core `rm2k-snes-audio volume-ceilings` plays the songs in (`retro.rs`),
  and `release.yml` says so. It is not in what `advocate` links —the
  audio stage does not use `retro.rs`—, and
  [`the-volume-ceilings-are-measured-without-a-rom`](the-volume-ceilings-are-measured-without-a-rom.md)
  takes it away for good. No crate of the workspace links C today.
* **The runtime is not inside the binary**: `rm2k-project`'s `suite.rs`
  finds `runtime/` through the checkout the binary was compiled from
  (`CARGO_MANIFEST_DIR`), or beside the release's `bin/`. Self-contained
  means the runtime's sources embedded in `advocate` —a couple of MB of
  text—. What it costs: editing a `.s` then needs a rebuild of `advocate`
  before a ROM sees it, so a flag pointing at a `runtime/` on disk is
  probably kept for whoever works on the engine; and `just deliver`, which
  copies the commit's `runtime/` beside the ROM for Mesen2, takes it from
  git as it does now.
* **What it still runs is not ours**: `ca65` and `ld65`, and the MSU-1
  tracks' synthesizer and encoder. Self-contained is about `advocate`
  itself; those stay requirements on the `PATH`, as the book's decision
  says.
* **If `snes_spc` comes in** for the volume ceilings, it is C++: building
  it statically for musl needs the C++ standard library for that target,
  which is to be checked then.

The cartridges' fingerprint, which hashes the binaries the build runs,
shrinks with them; the recipes, the harness, AGENTS.md, the book and
`release.yml` follow the new name.

It goes after
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md),
and [`cartridges-runs-itself-to-assemble`](cartridges-runs-itself-to-assemble.md)
is its first step.

## Log

### 2026-11-23, Hornero: written

Nothing done yet.

### 2026-11-24, Hornero: the project as a file the build leaves

At taro's word; the decision is in the book, `src/decisions/one-command-and-no-tool-runs-another.md`.

### 2026-11-24, Hornero: a static musl binary as the goal

At taro's word; what blocks it, measured, above.
