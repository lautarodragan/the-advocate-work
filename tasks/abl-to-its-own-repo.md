---
name: "ABL to its own repo"
description: "Phase 1 of the test game: everything of ABL's —rom/, its justfile, its tests and goldens, its patches, its part of docs/ and workflow/— to a separate repo, born from scratch; this repo keeps the tools and the runtime"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02, with the plan in
[`research/2026-10-02-the-test-game.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-02-the-test-game.html) (Leñatero, phase 1):
"I'd start by making sure all of ABL's things exist in a single
place. In fact, I think I'd take them out of the repo and move them to a repo
of their own, and `git init` there". Without `git filter-repo`: "we still have the git
log here, and what's going to stay on ABL's side should be very little". The new
repo is born from scratch with today's files.

The risk Leñatero pointed out: between this phase and phase 2 the engine is left without
ROM tests of its own. That's why phase 2 comes right after.

# The classification (Ñandú-petiso, 2026-10-02, before moving anything)

The criterion is that of `decisions-and-divergences-by-repo.md`: what goes with
ABL is what belongs to this game —its content, its tests, its recipes, its
experiments, what decides what its cartridge carries—; what stays is what would hold
for any game ported with the tools, even if it was
found or measured on ABL. **Mixed** means it goes to both: it's
copied and each repo keeps its own, or it's copied whole if splitting it is
a judgement call that isn't mine to make.

## The loose files

| what | where to | why |
|---|---|---|
| all of `rom/` | ABL, **to the root** | `rom/` has already been ABL's root since the move of 2026-09-29: in a repo of its own the extra step isn't needed. `rom/X` becomes `X` |
| the root `justfile` | goes, and doesn't pass to ABL | it only imported `rom/justfile`; in the new repo `rom/justfile` is the root one. Here nothing's left to import: see below |
| `tools/assembly/entregar.py` | ABL, to `entregar.py` | it's ABL's (`abl-entregar`), as `tools/README.md` says |
| `DITTO.md` | **stays** | the study took it as ABL's; read, it's why the converter reads the dump and not the binary, and the status of that decision: it belongs to the tools (`tools/justfile` cites it, `decisions/data-is-the-resolved-view.md` is the tools'). ABL's part —what's in its `data/`— is already in `rom/data/README.md` |
| `README.md` | mixed | each repo its own: ABL's, the original game, `just datos`, how it's built; this one's, the runtime's architecture |
| `AGENTS.md` | mixed | each repo its own; the environment is described in both, because it's the only file in each one that can name it |
| `CLAUDE.md` | mixed | the same shape in both |
| `.gitignore` | mixed | each with its own |
| `.git-blame-ignore-revs` | stays | it names commits from this history |
| `.idea/`, `.claude/` | stay | IDE and Claude Code configuration of this checkout |

## docs/

| file | where to | why |
|---|---|---|
| `docs/README.md` | mixed | each repo its own |
| `docs/jetbrains.md` | stays | the annotate across the `main.s` split |
| `docs/port/*` | stays | except `pipeline.md` |
| `docs/port/pipeline.md` | mixed | the diagram is the tools'; the `rom/…` paths, `$ABL_GAME_DIR` and the two recipes, ABL's |
| `docs/rpgmaker/chipsets.md` | stays | |
| `docs/rpgmaker/rtp.md` | mixed | what the RTP is and how it's extracted, the tools'; the chipsets and charsets ABL uses, ABL's |
| `docs/snes/*` | stays | |
| [`research/graphics-and-sound-from-rm2k-to-the-snes.md`](https://lautarodragan.github.io/the-advocate-docs/research/graphics-and-sound-from-rm2k-to-the-snes.html), [`the-map-of-the-python-tools.md`](https://lautarodragan.github.io/the-advocate-docs/research/the-map-of-the-python-tools.html), [`the-tools-today.md`](https://lautarodragan.github.io/the-advocate-docs/research/the-tools-today.html), [`2026-10-01-the-picture-system.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-01-the-picture-system.html), [`2026-10-02-the-test-game.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-02-the-test-game.html) | stay | the tools'; the test game one is this repo's plan |
| [`ports/abl/research/a-full-inspection-of-the-repository.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/a-full-inspection-of-the-repository.html) | ABL | according to Hornero's table |
| [`ports/abl/research/2026-10-01-the-whole-game-without-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-the-whole-game-without-msu-1.html) | ABL | how much the whole of ABL weighs and what cuts its cartridge asks for |
| [`ports/abl/research/2026-10-01-the-maps-through-the-msu-1.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-01-the-maps-through-the-msu-1.html) | ABL | how far ABL's cartridge goes; its test ROM (`experimentos/msu-puerto/`) is already ABL's |

## workflow/decisiones/ and divergencias/

The table in `decisions-and-divergences-by-repo.md` (Hornero) holds as
it is; what was added or changed afterwards:

| file | where to | why |
|---|---|---|
| `decisiones/README.md` | mixed | each repo its own |
| `ports/abl/decisions/the-camera-offset-after-the-gate-is-the-games.md` | ABL | according to the table |
| `ports/abl/decisions/the-thunder-plays-whole-and-pays-for-the-rain.md`, `the-tools-split-from-abl.md`, `a-long-case-at-zero-proves-nothing.md` | mixed, copy | according to the table |
| `decisions/the-cartridge-goes-to-8-mb.md` | mixed, copy | it replaced `el-cartucho-se-queda-en-4-mb.md`, which the table had as mixed: ExHiROM is the runtime's, that ABL needs it is ABL's |
| `decisions/the-game-is-playable-without-msu-1.md` | mixed, copy | new; the rule is for ABL, and the engine follows it while ABL is the only game |
| `decisions/first-the-whole-game-then-the-quality.md` | mixed, copy | new; the same |
| `decisiones/rm2k-plus.md` | mixed, copy | new; for the tools it's what they are, for ABL it's that what it asks for goes to the engine |
| `decisions/call-event-into-a-shared-body.md`, `large-pictures-in-mode-1.md` | stay | new; the converter's and the runtime's |
| `divergencias/*` | stay, all of them | according to the table, and the four new ones (`the-way-into-battle-in-mosaic`, `the-heros-speed-with-l-and-r`, `what-pictures-as-sprites-do-not-model`, `what-large-pictures-do-not-model`) are the runtime's. ABL doesn't carry `divergencias/`: its `AGENTS.md` points here |

The copies go untouched: splitting the prose of a mixed decision is
taro's call.

## workflow/ the rest

| what | where to | why |
|---|---|---|
| `workflow/README.md` | mixed | each repo its own |
| `workflow/ESTADO.md` | mixed, copy | frozen and read-only; it has some of both |
| `workflow/tasks/tasks.nu` | mixed, copy | the tasks script |
| `workflow/tasks/done/` | **stays whole** | it's a record, like the `git log`, and the history stays here (taro, 2026-10-02) |
| the tasks in `todo/`, `testing/` and `wishlist/` | per task, below | |

**To ABL** (the rest stays): the ones that work on its content, its
tests, its recipes or its experiments, or decide what its cartridge carries.
An engine bug found on an ABL map stays here: the fix lives
in the runtime or the converter.

* `todo/`: `msu-1-coverage`, `audio-in-two-lossy-steps`,
  `world-and-what-follows`, `diff-photos-cropped-and-217-montage-as-in-rm2k`,
  `goldens-of-the-neon-vipers-playthrough`, `playthrough-pending-goldens`.
* `testing/`: `cartridge-at-8-mb-exhirom` (the test ROM belongs to
  `experimentos/`), `common-35-and-the-radio-music`,
  `fortitude-counter-is-not-shown`, `enemies-hp-hidden-and-the-takeoff-thunder`,
  `plan-the-whole-game-without-msu-1-the-count`, `mode-7-pilot-for-the-zoom-of-the-diff-photos`,
  `troop-events` (the battle systems of ABL's
  characters), `just-video-with-playthroughs`, `bank-guard`
  (the test lives in ABL), `tests-without-silent-holes`,
  `plan-the-maps-via-the-msu-1`, `mock-up-the-menu-in-high-resolution`,
  `test-rom-the-menu-in-mode-5-on-the-snes`, `font-for-high-resolution-or-a-narrower-one`,
  `world-1-map-66-fits` to `world-7-the-road-to-paradise`.
* `wishlist/`: `elevator-scene`,
  `split-test-comandos-golden`.

`abl-tests-without-opcodes.md` (Cotorra) touches both halves and stays
here, with the Rust half, and so do `plan-an-rm2k-game-for-tests.md` and
`decisions-and-divergences-by-repo.md`: they're this repo's plan.

# What was done

## The new repo

`/shared/abl-snes`, with `git init`, author `taro <taro@taro.codes>` in its
`.git/config`. The commits, in order:

1. `bdd0d83` **A Blurred Line, from abl-snes at 817037ee**: the 2075
   files of the classification, without touching a byte, with `rom/X → X` and
   `tools/assembly/entregar.py → entregar.py`. Checked blob by blob and
   with their mode against `git ls-tree -r 817037ee`: none different.
2. `6f79c2b` the `.gitignore` with the paths over there.
3. `574427f` **the Python packages, asked of the suite**:
   `pruebas/arnes/suite.py` runs `rm2k-snes-python-path` and puts what it
   answers into `sys.path`; it's imported by `lugares` and the scripts that don't go
   through it. `pytest.ini` and `video.py` stop naming `tools/`.
4. `63c57f7` without the `_herramientas_del_checkout` guard, and `entregar`
   calls `./entregar.py`.
5. `e2aef83` `consola.RAIZ` is the game's root and not the
   tools'.
6. `c32b9ba` a comment of mine that named Python: caught by
   `test_el_justfile_no_nombra_python`.
7. `bc55f57` `test_el_dbg_nombra_los_fuentes_relativos_a_la_raiz` accepts the
   cartridge's `.inc` files with an absolute path: see "What was left".
8. `6d2d783` **`entregar.py` with two repos**: the build is called
   `<fecha>-<commit de ABL>-<commit de las herramientas>`, checks for uncommitted
   changes in both, takes `tools/runtime/` from the tools'
   checkout and the LEEME says both commits.
9. `3e4d196` README and AGENTS.md with ABL's half.
10. `d6053f5` `docs/`, `workflow/` and the `justfile`: paths and names from over there.

`CLAUDE.md` came over the same: it has the same shape, and the text holds as is.

## This repo

1. `be6fafa8` **`rm2k-snes-python-path`** (`tools/common/python_path.py`),
   installed as a symlink by `_install`; `abl-entregar` stops being
   installed, and the `find` of `abl-*` cleans the one left in the global.
2. `d356bfb7` **the deletions, only deletions**: 2059 files.
3. `4ffb90b2` **the prose**, guided by the previous one's diff.

## The decisions I made

* **ABL finds `common` and `emulator` by asking an executable**,
  `rm2k-snes-python-path`, from Python (`arnes/suite.py`). The study's other
  two, discarded:
  * a `PYTHONPATH` exported by ABL's `justfile`: a `just` backtick
    **doesn't see the `PATH` that the same `justfile` exports** —tested with
    just 1.58—, so it would take the global one even with a local `bin/`
    in front; it would be evaluated in every recipe; and ABL's `justfile` doesn't name
    Python, which `test_lado_de_abl.py` guards;
  * packages installed with pip or a `.pth`: global state that a worktree
    can't cover with its own, and one more installation step.
  The executable is a symlink to the checkout it was installed from, the same one
  the binaries take the runtime from.
* **`rom/` goes to the new repo's root**, and not into a `rom/` inside: the
  decision of 2026-09-29 already made it ABL's root.
* **The root `justfile` goes, and doesn't become `tools/`'s**:
  `tools/justfile` finds what it installs with `justfile_directory()`, which
  imported from the root would be the root. It's run with `just -f
  tools/justfile`, or with `just` from `tools/`, as until today.
* **`DITTO.md` stays here**: see the classification.
* **The ABL worktrees guard goes**: the tools find
  the project from the directory where they run, and there are no longer Python
  scripts in the global that build in another checkout's `build/`.
* **`tasks/done/` stays whole here**, as a record.

## The verification

* **The ROM, from `/shared/abl-snes`**: `NO_CACHE=1 just cartuchos` on
  a `build/` that didn't exist —62 s— gives `abl.sfc` =
  `35c765009320d43664d4604bc6b456db7f0b4332638dc52d761a573c5ffd7349`, the
  baseline's. **The 1424 files in `build/`** —the three cartridges, the 51
  MSU-1 tracks, `parches-manual/`— come out identical to those in the main
  checkout's `rom/build/`, except the three `.dbg` files, which name the generated
  `.inc` files with an absolute path (below).
* **`just pruebas` over there: 993 green**, 95 s, on the last commit.
* **`just -f tools/justfile test` here: 32 green**, after the
  deletions and after the prose.
* **`just entregar` over there**, with `SHARED=<un directorio del scratchpad>`
  so as not to touch `/shared/builds`: it left
  `builds/2026-10-02-bc55f57-d356bfb7/` with the usual `abl.sfc`, its
  `.dbg`, the `abl.msu`, `tools/runtime/` and the LEEME with both commits.
  **It wasn't run against the real `/shared`**: it deletes the old builds.
* All of that was run with the global tools plus the worktree's
  `rm2k-snes-python-path` in front in the PATH, because the
  global doesn't have it yet.

## On merging

* **`just -f tools/justfile install-scripts`** from the main checkout:
  installs `rm2k-snes-python-path` and deletes the `abl-entregar` symlink.
  Without that, ABL's harness stops saying it's missing. There's no Rust to
  reinstall.
* **The main checkout's `rom/` stays on disk**: `rom/build/` (1.7
  GB), `rom/pruebas/snapshots/` and whatever is untracked. With the
  new `.gitignore`, `git status` will show it. I didn't delete it —it's the
  environment—: it gets deleted when ABL is built from `/shared/abl-snes`.
* With that, `just pruebas` in `/shared/abl-snes` with the global ones is what
  verifies a change in `tools/`.

## What was left, for phase 2

* **The engine without ROM tests**, as Leñatero said: it's written in
  so many words in the README and in `AGENTS.md`.
* **`/shared` is a CIFS**: without symlinks, so the tools'
  `install-local` can't leave its `bin/` in ABL's `.herramientas-locales/`.
  To run ABL with the tools of a worktree from here, its
  `tools/.local-tools/bin` goes in front in the PATH (it's in both
  `AGENTS.md` files). No execute bits of its own: a new script is marked
  with `git update-index --chmod=+x`. And no case distinction.
* **An ABL worktree for a tools agent**, so as not to build
  in the `build/` of the checkout that gets played: `git -C /shared/abl-snes
  worktree add <dir>`. I didn't test it.
* **A game's `.inc` files outside the checkout go absolute in the `.dbg`**
  (`under`, in `assemble.rs`, on purpose). Mesen2 doesn't see them from a delivered
  build, as before; opening the ROM from ABL's `build/` it doesn't either,
  and before it did. It's fixed by running `ca65` with paths relative to the project
  for the generated stuff, if needed.
* **ABL's `test_perillas_repetidas.py` walks the `.py` files of the tools'
  checkout** (`project.tools()`): it still works, but it's a
  test over there that looks at code from here.
* **`convert.rs` also looks for images in `suite::root()`**, the root of
  this repo, and ABL's `render_map.py` copies it: since ABL isn't here,
  there's nothing there to find. I didn't touch it: it changes what the
  converter reads.
* **The runtime's and the crates' comments that cite `rom/…`** —in
  the `.inc` files the converter emits, among others— stay, according to the
  tools' decision.
* **The suite version the game declares**, which the decision asks for: with
  two repos it's what ties ABL's goldens to an engine, and today it doesn't exist.
* **`test_lado_de_abl.py`** remains whole: in the new repo naming `tools/`
  is naming another repo, and it has three files in its list that name it
  in the prose.
