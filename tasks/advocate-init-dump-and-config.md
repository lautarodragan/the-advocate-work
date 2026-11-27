---
name: "advocate init and config"
description: "advocate gets the subcommands of a port's path besides build: init starts a port from a game's .zip, and config shows the machine's settings, kept in ~/.config/advocate/ beneath flags and environment variables"
type: feature
game: advocate
status: todo
author: taro
links:
  blocked-by: [one-advocate-command]
  relates: [tests-without-the-stages-subcommands, ditto-becomes-advocate-import]
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
* **`advocate import`** went to its own task,
  [`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md);
  `init` calls it for the first dump.
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

Not subcommands: `goombario` is a lint, the-advocate's `just lint`
(taro's, 2026-11-26); `fxpak` and `rm2k-sketch` are the console's and the
test game's, not a port's path, and stay on their own.

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

### 2026-11-27, Hornero: `import` split out

> Let's separate ditto into its own task. advocate-init-dump-and-config
> stays for... init and config, precisely, and `ditto -> advocate import`
> goes to a new task, to `todo`, and we leave it in the queue.

(taro, 2026-11-27) `import` is now
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md); the
name drops it, the file name stays. And the line on `goombario` folding
into `build` was stale: it became a lint.
