---
name: "A GitHub workflow for the tools"
description: "the-advocate checked on every push to main by GitHub Actions: the Rust workspace and its tests, the Python tests, and then the test game's cartridge, its ROM tests and Goombario over it"
type: tooling
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-18: a GitHub workflow that validates what can be
validated without A Blurred Line —that all the Rust compiles, the linter
over the runtime, the test game's tests—. The repo is public, so GitHub's
standard runners cost no minutes: it runs on every push to `main`, with a
concurrency group that cancels the older run. taro: the runner is Ubuntu,
so what we compile by hand here (`ca65`/`ld65`, the libretro cores) is
installed with apt where it can be.

Two steps:

1. The Rust workspace builds and its tests pass (`just rust-test`), and
   `just test`.
2. The tools installed, the test game made and built (which assembles the
   whole runtime), its ROM tests in the emulator, and Goombario over its
   cartridge. A free SoundFont (FluidR3_GM, MIT, or similar), never the one
   used here.

Third-party actions pinned by commit hash, not by tag. ABL's suite stays
the real net for the runtime: this does not replace it.

## Log

**2026-10-18, Mulita.** From the-advocate `b066b885`, branch `mulita-ci`.
What the runner's Ubuntu (24.04, noble) has and what it does not:

* `cc65` is there, 2.19-1 —its `ca65` calls itself V2.18—, and **it does
  not assemble the runtime**: twelve "Illegal addressing mode" in
  `runtime/pano.s` (`rol`/`asl`/`inc` on `P_T + n`), measured with the
  noble `.deb`'s binaries over the test game. Ours is cc65's master at
  `e11fb5c`, so the workflow builds that commit, cached by it.
* **No snes9x core**: it is not in Debian or Ubuntu (its licence is not
  free). The only bsnes is `libretro-bsnes-mercury-*` —bsnes v094—, and
  ours is bsnes-libretro with taro's WRAM patch, which the harness needs to
  read `ticks`. So both are built from the commits installed here
  —snes9x `890b5d44`, bsnes-libretro `260f5234` plus the patch—, cached:
  with 4 jobs, 29 s and 20 s of wall time here. The test game's suite
  passes with those two, 44 and one skip, the same as with the installed
  ones.
* `just` is there, 1.21.0: both justfiles parse with it and the test
  game's recipes run with it.
* `fluid-soundfont-gm` gives `/usr/share/sounds/sf2/FluidR3_GM.sf2`; the
  test game's goldens do not move with it (it has no music yet). The two
  Rust tests that read `SOUNDFONT` assert the Microsoft font's envelopes,
  so the Rust job does not set it and they skip.
* `just install` of everything took 12m42s here, with 15m49s of CPU: the
  release profile's LTO links each binary alone, so the runner's four
  cores barely help.
* Goombario over the test game's cartridge with ABL's
  `linter-exceptions.txt` is clean, and every exception matches —the
  runtime is assembled whole—; without them, 32 lines of findings.

Hornero, with taro's approval: pushing to a `ci` branch of the-advocate
is allowed, and the workflow triggers on it while it is brought up; then
it goes to `main`. Commits on `mulita-ci`: `5027e1e` (Goombario over the
test game's cartridge, with a copy of ABL's exceptions —`#` lines count as
comments for `test_no_game_names.py`—) and `fc89611` (the workflow,
`requirements.txt` with pytest and Pillow, the bsnes patch copied next to
the test game's `retro.py`, README and LAYOUT lines). actionlint 1.7.12
with shellcheck 0.11.0: clean.

The disk of the container filled up while measuring (`~/scratch` holds
hundreds of GB of old worktrees): `just rust-test` could not finish
here, and the repeat of the test game's suite gave eight green runs in a
row, not ten —the last eight of the ten died for the disk—. One earlier
run, with an exception deliberately removed, showed two reds where one
was expected; the other was not recorded and did not show again.

First run, `fc89611`: the Rust and Python job green.
The test game's job too: the whole run green at the first try, 12
minutes cold —cc65 and the cores built in about two, the tools' install
9.5—.

With the disk freed: `just rust-test` and `just test` green here with
apt's `just` and the pinned requirements, from a clean environment; the
test game's suite with the built cores, ten runs in a row green (45 and
the one bsnes skip).

`eba877c`: the cores step listed the directory, which never fails; it
names both files now, so a missing core is a red and not a skipped half.
Second run on `ci`, with cc65 and the cores from the cache: green, 9.5
minutes. `20ddb95`: the trigger goes to `main`, pushed to `ci` too —it
no longer runs there—. Left in `doing` until Hornero confirms the run on
`main`.
