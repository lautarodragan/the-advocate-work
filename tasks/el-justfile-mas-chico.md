---
name: "The justfiles, smaller"
description: "Remove from the two justfiles —the tools' one and ABL's— the recipes that are no longer used, and simplify the ones that were left complicated after the migration to Rust and the split into two repos"
type: refactor
status: testing
agents: [Calandria]
assignee: taro
---

From taro, on 2026-10-05: "I think we can remove things from the `justfile`,
right? And simplify others?".

## The inventory (Calandria, 2026-10-04)

On `main` at `c8d5064f` and ABL at `c76157d`.

"Users" is where it is named outside the `justfile` itself, in both
repos and not counting finished tasks; "last" is the last commit that
added or removed an invocation of it outside the `justfile`s —`git log -G
'just… <recipe>'`—, and "in `done/`" is how many finished tasks report
having run it. In ABL the commits of 2026-10-02 are the birth of the
repo, and in this one `d356bfb7` is the deletion of what left: both say
"it moved", not "it was used". And one thing weighs that is not in git:
**taro does not run recipes by hand** (he said so on 2026-09-06), so its only
user is us, and what is weighed is the cost of maintaining them.

The scripts that did the counting, in case they need redoing, are in
`/extras/scratch/calandria/tmp/` (`usos.sh`, `ultimo.sh`, `done.sh`,
`huerfanas.sh`).

### `tools/justfile`

| recipe | what it does | users | last | proposal |
|---|---|---|---|---|
| `test` | `pytest` of `tools/tests/`: layers, dump readers, indices, game names | README, `tools/tests/README.md`, AGENTS.md, the verification of each merge | 2026-10-04 | keep |
| `rust-test` | `cargo test --workspace`, in debug | README, `tools/README.md` | 2026-10-02 | keep |
| `gunter-test`, `rules-test`, `adeleine-test`, `voodoo-test`, `goombario-test`, `project-test`, `cartridge-test`, `patches-test`, `battle-test`, `bytecode-test`, `events-test`, `wally-test`, `screens-test`, `images-test`, `mapdata-test`, `convert-test` | `cd <crate> && cargo test` | none | never | **question 1** |
| `lz2-test`, `render-test`, `audio-test` | the same, in `--release` | `lz2-test` as an example in `tools/README.md`; `audio-test` in AGENTS.md and `docs/port/audio.md`, with `SOUNDFONT` | 2026-10-02 | **question 1** |
| `ditto-test` | Ditto's `cargo test`, with `DITTO_CORPUS` | DITTO.md | 2026-09-29 | **question 1** |
| `ditto-round-trip` | Ditto in release with `--include-ignored`, and it refuses without `DITTO_CORPUS` | DITTO.md | 2026-09-29 | keep: it is not a bare `cargo test` |
| `install` | `cargo install` of the named projects, or of all of them, into `CARGO_ROOT` | AGENTS.md, `tools/README.md`, the converter's `stage.rs` error | 2026-10-04 | keep |
| `install-local` | the same into a `bin/` of a worktree; refuses in the main checkout | AGENTS.md, `.claude/agentes.md`, `tools/README.md` | 2026-10-04 | keep |
| `_not_in_main_checkout`, `_install` | private ones of the two above | `install`, `install-local` | — | keep; the symlink cleanup of `_install`, **question 2** |
| `which` | which binary this checkout resolves for each tool | one task (`los-bytecodes-en-rust`) | 2026-10-02 | keep, and **fix**: it was missing `rm2k-snes-mapdata` and `rm2k-snes-audio` |

### ABL's `justfile`

| recipe | what it does | users | last | proposal |
|---|---|---|---|---|
| `datos` | `ditto unpack` of the game to `data/` and `build/ditto-exacto/` | `rm2k-snes.toml`, `docs/port/pipeline.md`, `parches/manual/README.md`, the harness, DITTO.md | 2026-10-02 (3 in `done/`) | keep |
| `ditto-volcado` | `just datos` to `/extras/volcado-ditto` | **none**: not docs, not tests, not a task, in neither of the two repos | never | **delete**: it is `just datos <dir> <dir>-exacto` |
| `datos-vuelta` | `unpack` + `pack` of the game, byte for byte against the original | DITTO.md | 2026-09-29 (2 in `done/`) | keep |
| `pruebas` | the suite, in parallel, after `cartuchos` | everything | 2026-10-03 | keep |
| `pruebas-rpgmaker`, `pruebas-abl`, `pruebas-herramientas` | the suite of one folder | `pruebas/README.md` | 2026-10-02 (none in `done/`) | **question 3** |
| `_xdist` | refuses if pytest-xdist is missing | the four above | — | keep |
| `cartuchos` | `rm2k-snes-cartridges` with the machine's flags | `pruebas`, AGENTS.md, studies | 2026-10-02 | keep |
| `espacio` | `rm2k-snes-space`, building what is stale first | AGENTS.md, `main.s`, `emit.rs`, studies | 2026-10-04 | keep |
| `parches` | copies the decisions of `release` to `parches/` | `rm2k-snes-patches` (its messages), `parches/README.md` | 2026-10-03 | keep |
| `parches-check` | `rm2k-snes-patches --check` | `test_parches.py`, `parches/README.md` | 2026-10-02 (7 in `done/`) | keep; see **question 5** |
| `techos` | `rm2k-snes-volume-ceilings` | `test_musica_techos.py`, `techos.toml`, `ceilings.rs` | 2026-10-03 | keep |
| `build` | `rm2k-snes-cartridges` with a name: **the same as `cartuchos <name>`** | `parches`, `entregar`, `video`; `test_msu.py`, `docs/port/pipeline.md`, a wishlist task | 2026-10-02 | **question 4** |
| `entregar` | `entregar.py` after building `release` | AGENTS.md of both repos, `docs/snes/emulators.md` | 2026-10-02 | keep |
| `video` | `pruebas/arnes/video.py` | `test_video.py`, `pruebas/README.md` | 2026-10-02 (6 in `done/`) | keep |
| `menu-modo-5`, `fuentes` | test ROM of the menu in mode 5 and of the fonts, and their verification | `experimentos/` | 2026-10-02 (`una-fuente-para-la-alta-resolucion`) | **question 6** |
| `msu-puerto` | test ROM of the MSU-1 data port | the study of maps over the MSU-1 (its phase 0 is measuring the FX Pak) | 2026-10-02 | **question 6** |
| `exhirom` | ExHiROM test ROM | `docs/snes/emulators.md`, `experimentos/` | 2026-10-02 | **question 6** |
| `zoom-modo-7`, `zoom-modo-7-videos` | test ROM of the mode 7 zoom, and its videos next to the original | `experimentos/` | 2026-10-02 (`el-piloto-del-modo-7`) | **question 6** |

What I did **not** find: any Python recipe wrapping a script
that no longer exists, any from `rom/`, and any `just X` invocation in the
docs that names a recipe that does not exist, apart from the historical ones
(`hitos-foto`, in both AGENTS.md, and `diagnostico`, in a dated study
of ABL). The migration to Rust and the split had already cleaned up the
bulk.

## What was applied

* `which` also lists `rm2k-snes-mapdata` and `rm2k-snes-audio`, which are
  installed and it did not list.
* `ditto-volcado` goes, from ABL.
* A summary line at the end of each recipe's comment, in both
  `justfile`s: it is the one `just --list` shows, which until now showed the
  tail of a sentence. In ABL it was already the convention for half the
  recipes.
* The prose of `tools/justfile` that had aged, in its own commit: that
  `rm2k-rules` still has a copy in Python (the converter is already Rust,
  and `tests/test_rm2k_rules.py` does not exist), that the names follow "the repo
  they will live in when the tools split" and the `abl-` ones, and
  that the game's `justfile` "refuses" without its local `bin/` (since
  2026-10-02 it uses the global one).

## Questions for taro

1. **The twenty `<crate>-test`.** Each one is `cd <crate> && cargo
   test` —three in `--release`—, and almost none is named by anyone. They could be
   replaced by a single one, `just crate-test lz2`, that does `cargo test -p`
   with the crate's name (and `--release` for the three that ask for it), plus
   `rust-test` for all of them. What would be lost is the place for the
   comments —"its tests do not need the game"—, which would move to the
   `Cargo.toml` or the `lib.rs` of each one, where whoever touches the
   crate reads them. It changes names that AGENTS.md, DITTO.md and
   `docs/port/audio.md` name (`audio-test`, `ditto-test`, `lz2-test`), and
   that is why I did not apply it. My proposal: do it.
2. **The symlink cleanup of `_install`**: it deletes the `rm2k-snes-*` that
   are symlinks, which were the Python scripts until 2026-10-02. In
   `/usr/local/bin` there are none left; in the host's `~/.cargo/bin` I
   don't know. If there are none there either, it is superfluous.
3. **`pruebas-rpgmaker`, `-abl` and `-herramientas`**: three recipes for one
   folder each, that nobody ran in any finished task. `just
   pruebas` does not work for that because it always passes `pruebas` to pytest;
   if instead it received the folder —`just pruebas pruebas/abl`, and with nothing,
   `pruebas`—, the three would go. My proposal: do it.
4. **`build` is `cartuchos` with an argument**: `just build release` and
   `just cartuchos release` run the same thing. It could go, with `parches`,
   `entregar` and `video` depending on `(cartuchos "release")`, and the
   long comment about the MSU-1 tracks moving to `cartuchos`. It changes
   a name that `test_msu.py` and `docs/port/pipeline.md` name. My
   proposal: do it.
5. **The tools name ABL recipes**: `rm2k-snes-patches` says
   "run `just parches`" and writes in the header of each `parches/auto/`
   "`just parches --check`" —which besides does not exist: it is `just
   parches-check`—, and `rm2k-snes-volume-ceilings` says "`just techos`".
   AGENTS.md says that inside those projects the game is not named.
   Fixing it changes the tool's output and the versioned files
   of ABL's `parches/`, so it is not for this task: does it go in
   a separate one?
6. **The six experiment recipes** (`menu-modo-5`, `fuentes`,
   `msu-puerto`, `exhirom`, `zoom-modo-7`, `zoom-modo-7-videos`): they are
   test ROMs of decisions already taken —mode 5 and the fonts, the
   8 MB, the mode 7 pilot—, except `msu-puerto`, whose phase 0 (measuring the
   FX Pak) is still open. Each script in `experimentos/` already says in its
   header how it is run. They could leave the `justfile` and be run
   directly (`experimentos/exhirom/armar.py build/exhirom/exhirom.sfc && …`),
   which is what the recipes do. They are half a screen of `just --list`.
   My proposal: remove them, leaving in each `experimentos/<x>/` the two
   lines the recipe ran.

Outside the `justfile`, seen in passing: the header of
`tools/rm2k/rules/tests/python.rs` still says that "the rules exist
also in Python, in the converter that still uses them", and names
`tests/test_rm2k_rules.py`, which does not exist. I did not touch it: it belongs to the crate.

## Verified

With the global tools: neither of the two branches touches Rust, so
at merge time there is nothing to install.

* `just -f tools/justfile test`: 27 pass.
* ABL's suite in my clone, with its branch (`calandria-justfile`): 1094
  pass. `abl.sfc` is `924c33ea3b51c958…`, the one from before.
* `just --list` on both sides: twenty-six recipes in the tools and
  twenty in ABL, each one with its summary.
* `just entregar` with `SHARED=/extras/scratch/calandria/shared`: leaves the
  build with `abl.sfc`, `.dbg`, `abl.msu`, `tools/` and `LEEME.txt`. The
  folder has to exist: `entregar.py` refuses otherwise, on purpose.
* `cargo test --workspace --no-fail-fast`: **one red, which is not from this
  branch**: `the_layers_are_the_ones_the_python_made`, in
  `wally/tests/background_python.rs` ("plain: the tiles"). It was born in
  `bfa2e1c4` (the System's arrow): in its parent it passes, in it and in
  `c8d5064f` it fails —`cargo test -p wally --test background_python` on
  each—. Everything else passes.

What I did not run: the experiment recipes, and `datos` and
`datos-vuelta`, which only changed their comment.

# What taro decided

On 2026-10-05: "I like all your proposals for the justfile! And the truth
is I don't install any of this or run it on the host, so don't take it into
account from that side. If I run something by hand, I'll do it inside the container, and
I'll ask you first". That is, the six questions, yes: the `<crate>-test`
into one, without the symlink cleanup of `_install`, a single `pruebas` with the
folder, without `build`, the tools that name ABL recipes (which here
were going as a separate task and go in this one), and without the recipes of the
closed experiments, except `msu-puerto`.

## What was applied afterwards (Calandria, 2026-10-04)

On `main` at `8b7766ad` and ABL at `83e4886`.

In the tools:

* `crate-test <project> [args]` instead of the twenty `<crate>-test`:
  `cargo test` standing in the project, as before, with the name from
  `rust_projects`. The three that ran in `--release` run in debug, like
  `rust-test`: measured, they take one or two seconds. What their
  comments said moved to the README or the `lib.rs` of the seven crates that
  did not already say it. `AGENTS.md`, `DITTO.md`, `docs/port/audio.md`,
  `tools/README.md` and `tools/tests/README.md` name `crate-test`.
* `_install` without the symlink cleanup.
* `rm2k-snes-patches` and `rm2k-snes-volume-ceilings` name the binary and
  its flag instead of `just parches`, `just parches --check` and `just
  techos`; the header of `techos.toml` no longer names
  `test_musica_techos.py` nor the Python functions that do not exist either. The
  patches tests change hashes and sizes: each new patch, with the
  old header put back, gives the Python's hash (all ten).
* `docs/snes/emulators.md` and a wishlist task, which named
  `just exhirom` and `just build`.
* The host prose, in its own commit: `CARGO_ROOT=~/.cargo`, the paragraph about the
  host-container symmetry and "if taro is going to run it from the host".

In ABL (branch `calandria-justfile` of `/extras/scratch/calandria/abl`):

* A single `pruebas`, which passes everything to pytest; with no path it runs `pruebas`
  because `testpaths` in `pytest.ini` says so.
* Without `build`: `parches`, `entregar` and `video` depend on `cartuchos`, which
  kept its comment.
* Without `menu-modo-5`, `fuentes`, `exhirom`, `zoom-modo-7` or
  `zoom-modo-7-videos`; each `experimentos/<x>/` states its lines.
* The 181 patches of `parches/auto/` with the new header, from `just
  parches`, and the one of `techos.toml` by hand, equal to what the
  tool writes.
* The same host prose in its `AGENTS.md`.

**At merge time: reinstall `patches` and `rm2k-snes-audio`.** Everything else that
changed in Rust is comments.

### Verified

With `patches` and `rm2k-snes-audio` from this branch installed locally, and the
rest from the global:

* `just -f tools/justfile test`: 27 pass. `cargo test --workspace
  --no-fail-fast`: 672 pass and none fails (last time's wally red
  is no longer in `main`).
* `just crate-test lz2` and `crate-test ditto` run; `crate-test nope`
  refuses with the list.
* ABL's suite, `just pruebas` in my clone: **1101 pass**. `just
  pruebas pruebas/herramientas`: 81. `abl.sfc` is `5c50524fea3111ba…`,
  the same as before.
* `just --list`: seven recipes in the tools and eleven in ABL.
* `just entregar` with `SHARED` in a folder of mine: leaves `abl.sfc`,
  `.dbg`, `abl.msu`, `tools/` and `LEEME.txt`.

What I did not run: the experiments whose recipes went away (only
the header of their scripts changed), `techos` (four minutes measuring; its
header was changed by hand) and `datos`.
