---
name: "The Python of tools/, out: common/ to Rust and the harness to tests/"
assignee: Tero
type: refactor
status: done
---

# The Python of `tools/`, out

From taro, on 2026-10-02. In `tools/` two Python packages remain that the
converter no longer uses: they are imported by ABL's test harness —some 24
files— through `rm2k-snes-python-path`.

- `common/` (`project.py`, `settings.py`, `environment.py`): a second
  reader of `rm2k-snes.toml` and of the machine's flags, next to
  `rm2k-project`, which is the Rust one. Two models of the same format is what
  Ditto's guard forbids for the dump.
- `emulator/retro.py`: the one that drives a libretro core frame by frame.
  It belongs to the tests and nothing else.

## What was decided

- **`common/` goes.** The harness asks a Rust binary what today
  it asks `common/` —for example `rm2k-snes-project`, which prints the
  resolved configuration in JSON—, and `rm2k-project` is the only one that reads
  `rm2k-snes.toml`. Its tests go too, `test_project.py` and
  `test_settings.py`, or what they covered moves to the crate's tests.
- **The tests stay in Python.** What belongs only to the tests **is
  moved, not migrated**: it leaves `tools/` for a tests folder, without
  rewriting it. `retro.py` is the case.

## What the harness asked of `common/`

Measured with grep over ABL at `a942b02`, the 24 files:

- **`project`**: the game's paths —`data()` fourteen times, `build()`,
  `patches()`, `manual_patches()`, `auto_patches()`, `project_file()`,
  `directory()`—, the suite's paths —`root()`, `tools()`, `runtime()`, in
  `deliver.py`, `render_map.py` and `test_perillas_repetidas.py`— and
  `use`/`from_command_line`/`add_argument` to choose the project.
- **`settings`**: three knobs —`[rom] name`, `[rom] sram_signature`,
  `[battle] fallback_backdrop`— and the whole file, in
  `test_perillas_repetidas.py`.
- **`environment`**: nothing that comes from the file. The harness used it as a
  box of machine values: `places.py` filled it with `ABL_GAME_DIR`
  and the others, and `converter.py` and `music.py` asked it for the flags to
  pass to a tool; `deliver.py`, its `--shared`.

Everything that is a rule —that `[paths]` is relative to the file, that the
manual patches are in `manual/`, where the runtime is— was already in
`rm2k-project`; the only thing it did not expose was the whole file
(`Project::settings`).

## How it answers now

- **`rm2k-snes-project`**, a `[[bin]]` of the `rm2k-project` crate
  (`src/main.rs`, and what it prints in `src/resolved.rs`): a JSON with
  `project` —the game's paths already resolved—, `suite` —`tools`, `root`,
  `runtime`, of the checkout it was installed from— and `settings` —the whole
  file, in order—. It checks what the library checks for any
  tool and nothing more: that `sram_signature` is four ASCII letters is
  required by the converter when building, not by this one.
- In ABL, **`tests/harness/project.py`** calls it once per process
  (with `lru_cache`) and gives `ruta(...)`, `of_the_suite(...)`, `ajuste(...)` and
  `ajustes()`. `places.py` tells it which the project is, as before to
  `common.project.use`.
- The machine part **did not move to Rust**: it is not a rule of the format but of
  which flag each tool receives, which the harness already knows for all the
  others (`--project`, `--maps`…). `places.py` keeps the values —`GAME`,
  `RTP`, `SOUNDFONT`, `CACHE`— and `lugares.banderas(...)` gives them as flags.
  `deliver.py` has its `--shared` in its own `argparse`, and stopped
  accepting `--project`: it belongs to ABL and the project is ABL.

## Where each thing went, and why

- **`tools/emulator/` —`retro.py` and `bsnes-wram.patch`— to ABL, to
  `tests/harness/emulator/`.** Only ABL's harness imports it, and with that
  the harness stops importing anything from the tools:
  `rm2k-snes-python-path` and `tests/harness/suite.py` go, and ABL goes back to
  knowing only executables in the PATH, which is the rule of
  `decisions/the-tools-split-from-abl.md`. The other option was
  a tests folder in the root of this repo, where the ROM tests come back
  in phase 2; but until then its only user would be
  ABL, and a mechanism would have to be maintained for another repo to import it
  —an executable that says the path— for a single file. When in phase
  2 the harness is split, `retro.py` comes back with the rest of the generic part, and
  how ABL imports it is decided then, with the whole harness and a second
  real user. As a package and not as a loose module, so that
  `from emulator import retro` stays the same in the nine that import it. The
  copy is byte for byte that of `3bddfeb8`, in its own commit; the two
  comments that named `tools/runtime/` were touched in the next one,
  because `test_abl_side.py` does not let a test name `tools/`.
- **`tools/tests/` stays.** They look at the tree of `tools/` —the layers, who
  reads the dump, that nothing names ABL, the index— and need nothing
  from outside: they belong to the suite as a crate's tests belong to the
  crate, and `tools/justfile` runs them. The phase 2 tests folder
  is for ROM tests with a game, which is something else. They stop importing
  `common`: they get `tools/` from `__file__`, two folders up.
- **`test_project.py` and `test_settings.py` go with `common/`.** What
  `test_settings.py` covered —missing key, wrong type, `true` is not `1`,
  `ascii`— was already covered by the crate's `tests/project.rs`. `test_project.py`
  checked that no `.py` in `tools/` built paths by hand or read
  `ABL_*`: without Python in `tools/` it has nothing to look at, and that nothing names
  ABL is still guarded by `test_no_game_names.py`, also in Rust and in the
  `justfile`. Three tests came to the crate: the resolved output, the error without
  `[paths]` and the binary actually running.

- **Incidentally, the fingerprint of `rm2k-snes-cartridges`** stopped reading the `.py`
  of `tools/`: it dated from when the converter was Python, and with `common/` and
  `emulator/` out there were none left. The fingerprint changes, so the
  first `just cartridges` after installing it rebuilds everything, identical byte
  for byte.

## What is left loose

- `test_perillas_repetidas.py`, in ABL, looks for values of the project
  file repeated in the tools' `.py`: today only those
  of `tools/tests/` remain, so it looks at almost nothing. What it protected —a default
  of the game written in a tool— would today live in Rust. It is left
  running; extending it to the `.rs` or deleting it is taro's call.
- The suite's key in the JSON is called `directory` and not `tools`:
  `test_abl_side.py` does not let an ABL test write `"tools"`.

## Done

Tools, on the worktree's branch:

- `9d015fb4` `rm2k-snes-project`, with three new tests in the crate.
- `8b2d796e` `git rm` of `tools/emulator/`, alone.
- the judgement one: `common/` and its two tests out, `tools/tests/` without
  importing anything, the `justfile` without scripts or `install-scripts`, the
  fingerprint, the READMEs and `AGENTS.md`.

ABL, branch `tero-python-afuera` in `/extras/scratch/tero/abl`:

- `bf22a0d` the copy of the emulator, byte for byte.
- `dc3a817` the harness asks `rm2k-snes-project`; `suite.py` out.

Verified:

- `just -f tools/justfile test`: from 52 to 27; the 25 of
  `test_project.py` (20) and `test_settings.py` (5) went.
- `cargo test -p rm2k-project`: 18 (it was 15); `-p rm2k-snes-cartridge`
  green.
- ABL's suite with the worktree's `project` and `cartridge` first in the
  PATH: 993 green, and `abl.sfc` `8c9e670f8c86d7c4…` identical, rebuilt
  because of the new fingerprint.
- With an `rm2k-snes-project` that answers a `data` that does not exist: 124
  fail and 74 error, all reading `/no/existe`.

## On merging

- **The order matters**: ABL's new harness needs `rm2k-snes-project`
  installed, and the `directory` of its JSON. First this merge and install;
  then the `git pull` of ABL's branch.
- Install `project` and `cartridge` in the global: `just -f tools/justfile
  install project cartridge`. Since `project` is everyone's library,
  the tidy thing is `just -f tools/justfile install` whole; for the ROM
  those two are enough, because the other binaries did not change
  behaviour.
- `_install` deletes on its own the old symlink `rm2k-snes-python-path`, which
  would be left pointing at nothing.
