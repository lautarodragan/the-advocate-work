---
name: "Recipes that only wrap a command"
description: "Recipes that add nothing to the command they run go; the eight identical games' justfiles become one shared file; and the dump's round trip stops being a recipe repeated nine times and becomes a test, on the test game and on the nine games"
type: refactor
status: testing
assignee: taro
agents: [huron]
author: taro
---

**Why**: a recipe is worth having when it saves something repeated —the
whole toolchain behind `just cartridges`, the machine's flags, the
environment of `machine.just` the harness reads—. Some only wrap one
command with nothing added, and the eight games other than ABL each carry
the same 62-line justfile, differing only in `GAME_DIR`.

> There's no need for everything to go through the justfile. The idea is
> that it helps with repetitive tasks. Having a `just build` that calls the
> whole toolchain, for example, can make sense. A `just assemble` that is
> not much more than a wrapper of `rm2k-snes-cartridges assemble` adds
> nothing.

> [dump-round-trip] I think it shouldn't be a recipe or a command, but a
> test, right? We could run it on the test game, maybe.

(taro, 2026-11-23, and "dale" to all of what follows)

**What is asked**:

* **Recipes that go**: `dedupe-frames` and `objects-per-line` at the
  ports' root; `hub` in the test game; `patches` in ABL; `which` in
  the-advocate; and ABL's finished experiments' `msu-dma`, `msu-port` and
  `sram-dma` —how each was built stays in its `abl/experiments/<x>/`—.
  Whatever names them —docs, the book, tasks' "how to reproduce"— says
  the command instead. Check each one first: a recipe that does provide
  the environment or flags something needs, stays, and the task says why.
* **One justfile for the games**: what the eight games share goes to one
  file the ports import, the way `machine.just` is; each game keeps only
  its `GAME_DIR` and what is its own. ABL takes from it what it shares.
* **The round trip is a test**: `dump-round-trip` in the nine games and
  `ditto-round-trip` in the-advocate go. In their place, a test that
  unpacks and packs back and compares byte for byte:
  * in the test game's suite, which runs in CI —it proves Ditto reads
    what Ditto writes—;
  * and in the ports' `boot` suite, once per game, over each game's
    original —which is what proves Ditto reads what RPG Maker wrote—.
  Ditto's own `round_trip.rs`, which only runs with `DITTO_CORPUS`, is
  looked at too: kept, folded into those, or gone, with the why.
* No ROM changes.

## Log

### 2026-11-23, Hurón: the recipes go, the games share one file, the round trip is a test

Branches `huron-recipes` in the-advocate (from `25b2418c`), the ports
(from `614687f`) and the book (from `88ef810`).

#### Each recipe, checked before it went

* `dedupe-frames` and `objects-per-line`, at the ports' root: they ran a
  script and passed it nothing. `tests/objects_per_line.py` builds each
  game through that game's own `just cartridges`, so it takes the
  environment from there; run with an empty environment, it starts.
  Both scripts are executable now, as their usage lines call them.
* `hub`, in the test game: `python3 tests/hub.py`.
* `patches`, in ABL: `just cartridges release && rm2k-snes-patches
  build/release`. `patches-check` stays: it passes `{{test_cartridges}}`.
* `which`, in the-advocate: `command -v`.
* `msu-port`, `sram-dma`, `msu-dma`, in ABL: their commands and the
  recipe's comment are each experiment's `README.md` now. One thing the
  recipe did give: `sram-dma/measure.py` read the audit core only from
  `AUDIT_CORE`, which the recipe exported from `machine.just`, and run by
  hand it skipped that core. It takes the harness's `cores.AUDIT` now,
  like `msu-dma/measure.py`; run by hand after the change, the 64 KB ROM
  built and measured with the audit core among the four.
* `dump-round-trip` in the nine games and `ditto-round-trip` in
  the-advocate: tests now, below.

Stay, with their why: `cartridges`, `space`, `ceilings` and `culprits`
pass `{{to_converter}}`/`{{to_build}}` or the request's path; `mesen2`,
`video` and `display-sweep` build first or hand the harness the
environment of `machine.just`; `test`, `rust-test`, `lint`, `test-game`
and `install` are what CI calls.

#### One justfile for the games

`game.just` at the ports' root, importing `machine.just`: `to_converter`,
`dump`, `without_tracks`, `cartridges`, `space`, `culprits`. The eight
games keep their `GAME_DIR` and the comment that is their own (Vampires
Dawn's `.msu`, Zounds's clone). ABL imports it too and keeps its own
`cartridges` and `space` with `set allow-duplicate-recipes`, under which
a recipe of the importing file overrides the imported one (tried on just
1.58 before using it). ABL's `dump` was the eight's with two defaulted
arguments, so the shared one is ABL's.

Verified: `just --dry-run` of `cartridges` (bare, with arguments and with
`TRACKS=1`), `space`, `dump` and `culprits` in the nine games prints the
same commands before and after; every game's cartridges built from
scratch before and after —the shared cache kept— give the same sha256 for
all 40 `.sfc` and `.msu`, ABL's eleven cartridges included; `just
--summary` lists the same recipes minus the removed ones.

#### The round trip, as two tests

* the-advocate, `test-game/tests/test_round_trip.py`: `build/game/`, which
  `just game` packs, unpacked and packed again, each `.lmu`, `.ldb` and
  `.lmt` byte for byte. It runs in CI with the rest of `just test-game`.
* the ports, `tests/test_round_trip.py` in `just boot`, parametrised with
  ABL and the eight: each original as `just dump` reads it —`GAME_DIR`
  from `just --evaluate` in the game's directory, unzipped by
  `rm2k-snes-project`—, compared by name in lowercase. It builds no
  cartridge: `needed()` in `games.py` skips a module that says `BUILDS =
  ()`, or it would have asked for all eight to be built. The nine take
  about four seconds.

Shown red first, with a `ditto` on the PATH whose `pack` changes its
output: one bit of the database flipped, the test game's fails naming
`RPG_RT.ldb` and the nine ports' fail naming `rpg_rt.ldb`; the first map
deleted, Zounds's fails naming `map0001.lmu` as missing.

Ditto's `round_trip.rs` and `directory_dump.rs` stay as they are. Ditto
is a project of its own and measures itself over whatever corpus
`DITTO_CORPUS` names, without knowing the ports; it goes through the
library —`file::read`, JSON, `file::write`— where the new tests go
through the command line. Their whole-corpus batch, `#[ignore]`d, is run
with the `cargo test --release -- --include-ignored` its README already
gives; the recipe only wrapped that.

#### Prose

The games' READMEs, the root's (`game.just`, the two scripts of
`tests/`), ABL's, `patches/README.md`, `test_patches.py`, the frozen-world
`advocate.toml` comment, the debug screen test's comment, RENAMES.md (a
table of what went and what to run instead); in the-advocate, the test
game's README, `hub.toml`, `hub.py` and `test_hub.py`'s message; in the
book, `testing.md` (a section on the round trip), `ports/README.md`, ABL's
README and pipeline, `the-pause-menu.md`, `progress/the-test-game.md`;
here, the open crowded-lines tasks' how-to-reproduce. Researches and
logs, untouched. AGENTS.md names none of the removed recipes; its
"`machine.just` …, which each game's `justfile` imports" is still true,
through `game.just`, and was left as it was.

#### Verified at the end, once

On the branches, with the global tools (no Rust changed, nothing to
install): the-advocate's `just test`, 29 passed; `just rust-test`, green;
the test game's suite, `SOUNDFONT=…/FluidR3_GM.sf2 just test-game`, 231
passed and 6 skipped, the round trip among the passed; the ports' `just
boot`, 218 passed; ABL's `just tests`, 1694 passed and 2 skipped.
`abl.sfc` `3bf35fd7665c2045…`, the same as before the change;
frozen-world's, rebuilt for its `advocate.toml` comment, the same bytes.

To merge: the three `huron-recipes` branches. Nothing to install.
