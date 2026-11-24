---
name: "One advocate command"
description: "Once the stages are libraries, the converter becomes one too, and rm2k-snes-cartridges becomes `advocate`, with subcommands: build, assemble, space, and whatever else is building the game"
type: refactor
status: todo
author: taro
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

**What is asked**: `rm2k-snes-cartridges` becomes `advocate`, with the
converter linked in:

    advocate build      what rm2k-snes-cartridges does today: convert,
                        assemble, the MSU-1 tracks
    advocate assemble   only assemble
    advocate space      each cartridge's free space

To decide in its design, each with its why:

* **`rm2k-snes-project`**, which tells the ports' tests what the tools
  know about the project, as `advocate project`: it is about the project,
  not a domain.
* **The MSU-1 tracks**, `rm2k-snes-audio msu`: their cache keys on the
  sources they include (`OWN_SOURCES` in `tracks.rs`), not on a binary, so
  being a library costs them nothing.
* **What stays its own command**: the domain tools a person runs for
  something other than building the game —`ditto`, `goombario`, `fxpak`,
  `rm2k-sketch`, `rm2k-snes-events culprits`, `rm2k-snes-patches`— and the
  stages' subcommands the ports' tests call, if the stages' task left them.

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
