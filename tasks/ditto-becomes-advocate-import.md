---
name: "ditto becomes advocate import"
description: "Ditto's binary goes: what a port's just dump asks it —RM2k's .ldb, .lmt and .lmu to the JSON dump in data/— becomes advocate import, and what the test game's recipe asks it —packing its text back to RM2k's format and the round trip— finds a home in advocate too; ditto stays a library"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [calandria]
author: taro
links:
  relates: [advocate-init-dump-and-config, one-advocate-command, rm2k-sketch-becomes-a-library]
  found: [the-tools-table-names-the-stages-gone-binaries]
---

**Why**: once `rm2k-snes-battle`, `wally` and `rm2k-snes-events` go
(with [`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md))
and `rm2k-snes-audio` with its volume ceilings, `ditto` is the last
binary of ours on a port's path besides `advocate`.

> Confirmed, `advocate import` instead of ditto.
>
> Let's separate ditto into its own task. advocate-init-dump-and-config
> stays for... init and config, precisely, and `ditto -> advocate import`
> goes to a new task, to `todo`, and we leave it in the queue.

(taro, 2026-11-27) The name `import`, and why not `dump`, are in
[`advocate-init-dump-and-config`](advocate-init-dump-and-config.md)'s log
of 2026-11-25.

**Who calls `ditto` today**:

* each port's `just dump`, in the ports' `game.just`: `ditto unpack`
  from the game's `.zip` to `data/` and the exact dump in
  `build/ditto-exacto/` —the database and the maps as JSON; pictures,
  MIDIs and sounds are not imported, the build reads them from the
  untouched `.zip`—, then `ditto pack` of the exact dump, which has to
  give back the original `.ldb`, `.lmt` and `.lmu` byte for byte;
* the test game's `just game`, in the-advocate's `test-game/justfile`:
  `ditto pack` of its text source to RM2k's files, `ditto unpack` of
  those back to the dump the converter reads, and the round trip
  —packed again, byte for byte— that proves Ditto reads what it writes,
  in CI.

**What is asked**:

* **`advocate import`**: what `just dump` does, its round-trip check
  included, the action and not Ditto's own subcommands; the ports'
  `just dump` calls it.
* **The test game's way back**: `pack` and the round trip need a home
  —`advocate export`, a flag of `import`, or the test game's recipe
  calling a Rust test instead of a binary—, decided in the design. It
  goes together with whatever is decided about `rm2k-sketch`, which
  feeds that same recipe.
* **`ditto`'s binary goes**, the library stays; `cargo uninstall` of it
  where it was installed, and the book's and READMEs' mentions follow.
* Every port's `data/` byte for byte the same as `ditto unpack`'s, and
  the ROMs byte for byte.

It goes after [`one-advocate-command`](one-advocate-command.md) and
before [`advocate-init-dump-and-config`](advocate-init-dump-and-config.md),
whose `init` calls it.

## Log

### 2026-11-27, Hornero: written

Nothing done yet.

### 2026-11-27, Hornero: `rm2k-sketch` goes with it

> Two separate tasks for tracking, but they can be implemented together.

(taro, 2026-11-27) [`rm2k-sketch-becomes-a-library`](rm2k-sketch-becomes-a-library.md):
the packing this task gives a home reads the test game's sketches too.

### 2026-11-27, Hornero: taken, to Calandria

taro's go, the same day, with [`rm2k-sketch-becomes-a-library`](rm2k-sketch-becomes-a-library.md),
which goes first: it is small and leaves the recipe with `ditto` alone.

### 2026-11-27, Calandria: the design

From the-advocate's `bf18d71e`, on `calandria-ditto` in the three
repos, after [`rm2k-sketch-becomes-a-library`](rm2k-sketch-becomes-a-library.md),
which left the test game's recipe with `ditto` alone.

#### `advocate import`

    advocate import --game-dir GAME [--cache DIR] [--data DIR] [--exact DIR]

What `just dump` did, in one subcommand: the game's `.ldb`, `.lmt` and
`.lmu` —a directory, or a `.zip` unpacked into the cache's `zip/` the
way `build` unpacks it— to the resolved view in `--data`, by default the
project's `[paths] data`, and the exact dump in `--exact`, by default
`build/exact/`; then the exact dump packed again into `<exact>-again`
and compared, file by file and by name in lowercase, with the game's.
It fails saying which differ, are missing or extra, and keeps what it
packed to compare by hand; when they are equal it removes it. The pack
and the comparison are Ditto's, a new `dump::round_trip`, so whoever
unpacks a game with the library checks it the same way.

A `.zip` is not unpacked through `Environment::unpack`, which also puts
the port's own files in front of the game's: what is imported is the
game as its author left it.

The ports' `rpg_maker_files.py`, which took the RPG Maker files out of
the `.zip` and compared them, goes. The exact dump moves from
`build/ditto-exacto/` to `build/exact/`, the test game's place already
and English; the ports' `RENAMES.md` says so.

#### The test game's way back: `advocate export`

    advocate export EXACT GAME

Ditto's `pack`, nothing else, and it needs no project. The three options
were:

* **`advocate export`**: the pair of `import`, the name Hornero left for
  "the way back" in [`advocate-init-dump-and-config`](advocate-init-dump-and-config.md)
  on 2026-11-25. Thirty lines, and the recipe stays three commands:
  `export src build/game`, the assets copied beside, `import --game-dir
  build/game`.
* **An option of `import`**, `--from-dump` or similar: `import` would
  then go both ways depending on a flag, and its name would lie for one.
* **A Rust test instead of a binary**: the recipe would call `cargo`,
  which no recipe does —the tools come from the PATH—, and the release's
  smoke test, which makes the test game's dump with the archive's
  binaries, would have none to call.

So `export`. And the test game's round trip is no longer the recipe's:
`import` checks it, as for a port, so the recipe lost its `cmp` loop.

#### `ditto`'s binary goes

`src/main.rs` and its `[[bin]]`; `read`, `write`, `unpack`, `pack` and
`schema` with it. Nothing called `read`, `write` or `schema` —grep of the
four repos—; the schema as data stays `describe::to_json()`, which
Ditto's tests check, and the README says so. The workspace's
`[profile.release.package.ditto] opt-level = "z"` goes too: it was there
for the binary's size, and as a library it only made `advocate`'s reads
slower.

### 2026-11-27, Calandria: done

#### The commits

* the-advocate's `calandria-ditto`: `c33dbe49`, `advocate import` and
  `export`, `dump::round_trip`, the recipe and the release's smoke test,
  Ditto's binary gone; `eb3af050`, LAYOUT, Ditto's and the test game's
  READMEs and the justfile.
* the ports' `calandria-ditto`: `87ef3c53`, `just dump` as `advocate
  import`, `rpg_maker_files.py` gone, `build/exact/`, the READMEs and
  `RENAMES.md`; `34f67392`, `data/` dumped again (below).
* the book's `calandria-ditto`: `91d7481`.
* here, AGENTS.md's list of projects: Ditto a library, `advocate` with
  `import` and `export`.

#### What turned up

**Ditto's dump depended on who linked it.** `serde_json`'s map is a
`BTreeMap` unless a crate of the same binary turns on `preserve_order`,
and `advocate` does: the first `advocate import` of the test game wrote
every file in struct order. Ditto now sorts an object's keys itself
when it writes (`in_order` in `dump.rs`); the new
`the_keys_come_out_in_alphabetical_order` was red without it, with
`cargo test -p ditto --test library -F serde_json/preserve_order`, and
`just rust-test` runs it with the feature, since the workspace build
unifies it.

**The eight RPG Maker 2000 ports' `data/` was stale since 2026-10-20.**
The-advocate's `f818d7e9`, "Ditto reads RPG Maker 2003", gave the
resolved view the 2003 fields with their defaults —its message says so—
and nobody dumped again, so main's own `ditto unpack` did not leave an
empty diff either. What `advocate import` writes is byte for byte what
main's `ditto unpack` writes, in both views and for the nine games
(`diff -r` against the global binary, built from Ditto's source as it
is at `bf18d71e`); the ports' `34f67392` commits it, and the release
ROMs built before and after it are the same, and the same as
`/shared/builds/`: the converter reads none of those fields of a 2000
game. Zounds was already current.

#### Verified, on the final trees

With `advocate` installed from the-advocate's `eb3af050` into its
`.local-tools/`, and stand-in `ditto` and `rm2k-sketch` that fail first
in the PATH, so that anything still calling them would be red:

* the-advocate: `SOUNDFONT=FluidR3_GM.sf2 just lint`, `just test` (31),
  `env -u SOUNDFONT just rust-test --no-fail-fast` (1259 passed, 3
  ignored) and `SOUNDFONT=FluidR3_GM.sf2 just test-game` (231 passed, 6
  skipped), all green; the test game's dump and three cartridges byte
  for byte `bf18d71e`'s.
* the ports, SOUNDFONT unset: `just dump` in each of the nine games,
  round trip passed and `data/` with an empty `git diff`; `just boot`
  (209 passed); ABL's `just tests` (1662 passed, 2 skipped).
* every game's release ROM byte for byte the one in
  `/shared/builds/<game>/`; `abl.sfc` is `3bf35fd7665c2045…`.

Not run here: the release's smoke test, which runs only in CI on a
release; its two lines are the recipe's. The round trip's comparison by
name in lowercase is run by Sunset, whose files are `RPG_RT.LDB` and
the like.

#### When merging

`just install advocate`, which Ditto goes into as a library, and `cargo uninstall
ditto rm2k-sketch` from the global root. The ports' `build/ditto-exacto/`
can be deleted in each game; `just dump` now writes `build/exact/`.
