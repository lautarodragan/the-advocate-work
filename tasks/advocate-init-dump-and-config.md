---
name: "advocate init, import and config"
description: "advocate gets the subcommands of a port's path besides build: init starts a port from a game's .zip, import is Ditto taking the game from RM2k's format to data/, and config shows the machine's settings, kept in ~/.config/advocate/ beneath flags and environment variables"
type: feature
status: todo
author: taro
links:
  blocked-by: [one-advocate-command]
  relates: [tests-without-the-stages-subcommands]
---

**Why**: with [`one-advocate-command`](one-advocate-command.md),
`advocate` builds a game, and that is all it does: `assemble` and `space`
went, and the versioned patches and `culprits` fold into `build`. What a
person does to start and keep a port is still spread over recipes and
knowledge that lives in the ports —`just dump`, an `advocate.toml`
copied from another game, `machine.just` translating this machine's
paths—.

> I think ditto could become a subcommand... it goes against my initial
> rule, but it is better UX. And if someone wants to use advocate for a
> single subcommand, they are free to do so.

> What other subcommands could make sense? An `init`, à la `npm init`?
> `config`, and we keep the path to the RTP and external binaries in
> ~/.config/advocate.toml? hmm...

> Go ahead! Straight to `todo`.

(taro, 2026-11-25)

The rule of the book's decision "One command, and no tool of ours runs
another" is about what the pipeline runs: one binary with several
subcommands runs nothing.

**What is asked**:

* **`advocate init <game.zip>`**: starts a port —the minimal
  `advocate.toml` and the first dump—.
* **`advocate import`** (named `dump` at first): what `just dump` does,
  Ditto taking the game from RM2k's own format to `data/` —the database
  and the maps, `.ldb` and `.lmu`, as JSON; the pictures, the MIDIs and
  the sounds are not imported, the build keeps reading them from the
  game's untouched `.zip`—. The action, not Ditto's own subcommands:
  `ditto` stays a library, and its binary as long as something needs it.
  Its inverse, the round trip back to RM2k's format, would be
  `advocate export`, if something needs it.
* **`advocate config`** and `~/.config/advocate/config.toml`: what belongs
  to the machine and not to the game —the RTP, the SoundFont, the cache,
  where `ca65`, `ld65` and the MSU-1 tracks' synthesizer and encoder are,
  and each project's `game_dir` in a table by project, since it is per
  game and per machine and `advocate.toml` is versioned—. Precedence:
  flag, then environment variable, then the file, so CI and the agents
  keep passing everything explicitly. `advocate config` prints what is
  resolved and where each value came from. What it changes in the ports'
  `machine.just` and in AGENTS.md's "Where this runs" follows.
* **`build`** may become what a bare `advocate` does, as `cargo` with
  `build`; to decide in the design.

Not subcommands: `goombario` folds into `build` like the patches (the
linter checks each ROM, its findings in `advocate.json`, ABL's test reads
them) —that one belongs with `one-advocate-command`'s step 4 or
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)—;
`fxpak` and `rm2k-sketch` are the console's and the test game's, not a
port's path, and stay on their own.

It goes after [`one-advocate-command`](one-advocate-command.md).

## Log

### 2026-11-25, Hornero: written

Nothing done yet.

### 2026-11-25, Hornero: `dump` is `import`

> Could `advocate dump` have another name? Something more explicit, that
> says "my input is an RPG Maker game in its original format, my output
> is a game in advocate's format"? (excluding graphics and audio, I
> suppose)

(taro, 2026-11-25) `import`, the usual verb for bringing something from
another format into one's own; `export` is left for the way back. The
file name stays.
