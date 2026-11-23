---
name: "How much of a test is the emulator drawing"
description: "Many ROM tests advance hundreds of frames nobody looks at; measure how much of a suite's CPU goes to the core rendering frames, and whether skipping the render of frames no test captures would save it, without changing what the tests see"
type: research
status: testing
author: taro
assignee: taro
agents: [Hornero, Chajá]
---

> I would measure the emulator itself.

taro, 2026-11-22, on where the CPU goes when several agents run the
suites: of the four ideas —Rust's cache, a conversion cache, running the
suites incrementally, the emulator—, the emulator is the one to measure
first.

**What to find out**: in ABL's suite, the ports' `boot` and the test game,
how the CPU splits between the cores' emulation, their video rendering,
the Python harness (frame reading, PNG and pixel comparisons) and the
rest. Whether the libretro cores can skip the render of frames nobody
captures —snes9x's and bsnes' frame skip, a null video callback, the
harness asking for the screen only when a test reads it— and how much
that saves, measured, without moving any golden. And whether `PROCESSES`
should follow the number of agents running.

## Log

### 2026-11-22, Hornero: taken for Chajá, on a free machine

taro:

> Yes, let's wait. Let's do the measurement first, anyway.

Launched with nothing else running, after merging the six fixes of the
afternoon (the-advocate `1240ecc9`, the ports `0699267`).

### 2026-11-22, Chajá: what the cores let us skip

Worktrees at the-advocate `1240ecc9` and the ports `0699267`, branches
`chaja-emu`. Neither `py-spy` (not in Arch's repos) nor `perf` (it would
upgrade `libelf` against `lib32-libelf`) could be installed, so the split
comes from cProfile —a ctypes call is not a builtin, so the core's time
shows up as `Console.run`'s own time and the callbacks as their own
functions— and from switching each piece off and timing it.

- **snes9x** asks the frontend every frame, with
  `RETRO_ENVIRONMENT_GET_AUDIO_VIDEO_ENABLE` (`47 | EXPERIMENTAL`), whether
  it wants video, and with bit 0 clear it sets `IPPU.RenderThisFrame` to
  false: the frame is emulated but not drawn, and `video_cb` is not called
  at all (`libretro/libretro.cpp` `retro_run`, `gfx.cpp`
  `S9xEndScreenRefresh`, at the installed `890b5d44`). The audio bit is
  ignored on purpose; only bit 3, hard-disable, stops the DSP.
- **bsnes** has no such question: its only skip is `setRunAhead`, which
  libretro uses for run-ahead and which also drops the audio, and its
  `frameSkip` is not exposed. Skipping there would need a core patch.

First numbers, `abl.sfc` (release) on the title screen, CPU time, one
process (`~/scratch/chaja/emu/bench/micro.py`):

| core   | as is | no frame copy in `_on_video` | video off |
|--------|------:|-----------------------------:|----------:|
| snes9x | 3172 fps | 3413 fps | 4299 fps |
| bsnes  |  522 fps |  525 fps | (not supported) |

#### Before: the four suites, alone, one after another

`~/scratch/chaja/emu/bench/baseline.sh`, each command under
`bench/timed.py` (wall, and user + sys of all its children). The cold
runs built everything in fresh worktrees; the warm ones are the numbers to
compare.

| suite (command, where) | wall | CPU (user + sys) | tests |
|---|---:|---:|---|
| `just cartridges`, `abl/`, cold | 117 s | 699 s | |
| `just tests`, `abl/` | 241 s | 1354 s | 1692 passed, 2 skipped |
| `just boot`, ports root, cold | 362 s | 2882 s | 205 passed |
| `just boot`, ports root | 169 s | 1030 s | 205 passed |
| `just test`, the-advocate | 3.9 s | 3.9 s | 29 passed |
| `SOUNDFONT=…FluidR3_GM.sf2 just test-game`, the-advocate | 111 s | 111 s | 222 passed, 6 skipped |

The test game runs **in series**: one process, so its wall time is its
CPU time.

#### Where the CPU goes

The three ROM suites again under cProfile, through a pytest plugin that
profiles every xdist worker (`bench/plugin/profplug.py`, loaded with
`PYTEST_ADDOPTS="-p profplug"`; `bench/split.py` splits it). The wall time
under the profiler was the same within 3%.

| | ABL `just tests` | ports `just boot` | test game |
|---|---:|---:|---:|
| CPU of the pytest processes | 1068 s | 1114 s | 113 s |
| — inside `retro_run` (emulating and drawing) | 627 s | 925 s | 82 s |
| — loading the ROM (`retro_init` + `retro_load_game`) | 129 s | 21 s | 25 s |
| — copying every frame in `_on_video` | 28 s | 20 s | 1 s |
| — PIL, `fifteen_bits`, the pixel comparisons | 49 s | 40 s | 2 s |
| — the rest of the harness and the tests' Python | ~180 s | ~100 s | ~3 s |
| — pytest and xdist | 9 s | 2 s | 0.3 s |
| CPU of the tools the tests run (converter stages…) | 366 s | 5 s | 0 s |
| frames run | 1 177 392 | 993 637 | 69 605 |
| frames looked at (`image()`) | 5 210 | 6 214 | 1 416 |
| consoles opened | 2 029 | 239 | 213 |

- **Fewer than one frame in two hundred is ever looked at.**
- **bsnes, not drawing, is most of the boot's and the test game's
  emulation**: both run every test on snes9x and on bsnes, and bsnes
  runs at ~520 fps against snes9x's ~2800 on the same scenes, so of the
  boot's 925 s some 750 are bsnes. ABL runs bsnes only in `test_cores.py`
  and the display audit.
- **Drawing is 25% to 30% of a snes9x frame**, on every game:
  `bench/scene.py` plays each cartridge past its title and runs the same
  400 frames from a savestate drawing every frame and drawing none
  (abl 30.0%, book-of-three 28.9%, desert-nightmare 27.5%, dooms2 29.0%,
  el-dorado 24.8%, frozen-world 27.4%, sunset 27.3%, vampires-dawn 26.0%,
  zounds 26.4%, test-game 27.1%).
- **Loading a ROM costs 48 ms in snes9x and 183 ms in bsnes**
  (`bench/state.py`), for an 8 MB cartridge; ABL opens 2029 consoles.
- In ABL, a quarter of the CPU is the converter's stages that its stage
  tests run, 1042 calls to `converter.ask` (249 s of the workers' wall
  time) and 38 renders of `test_music_ceilings.py` (65 s): no emulator.

#### What was tried for drawing, and what stayed

- **Drawing later by replaying the frame from a savestate**, so that no
  caller has to say which frame it will look at, was built and dropped:
  **snes9x's savestate round trip is not exact**. Serializing and
  unserializing at once, with no frame in between, leaves four bytes of
  WRAM different a few hundred frames later —the stack where an interrupt
  landed, and `$7ED3`— on `abl.sfc` at frames 5, 40, 300 and 700
  (`bench/exact.py`). A replay would change where the game goes depending
  on when a test looks. (A savestate costs 0.04 ms to take and 0.13 ms to
  restore in snes9x; 0.03 and 7.6 ms in bsnes.)
- **Not drawing does not change the emulation**: drawing every frame
  against drawing only fifteen of 2000, with input, runs of seven frames
  and a WRAM write halfway, gives the same screens where they are looked
  at, the same WRAM and the same audio on all ten cartridges
  (`bench/same.py`). That is `test-game/tests/test_retro.py` now.
- So **the caller says it**: `Console.run(frames, draw=True)` draws only
  the last frame of the call, and not even that one with `draw=False`;
  `image()` after an undrawn frame refuses instead of showing an old one.
  The loops that count ticks pass `draw=False` for the ticks that cannot
  be the last: ABL's `Session.run` (only the last tick's frames), the
  Teleport fade in `Session`'s boot, the generic `session.run`, and the
  ports' `until_control` (only the tick that can be the `FREE_TICKS`th in
  a row) and `walk`. The loops that end on a condition —`until`,
  `attend`, `wait`— draw every frame: they cannot know which is the last.
- **The kept power-on is exact**: a console of the same ROM, core and
  options as the previous one in the process starts from the savestate
  taken right after the previous load, before any frame, instead of
  `retro_init` + `retro_load_game`. Same screens, WRAM and audio on the ten
  cartridges. snes9x only: bsnes's power-on is meant to differ
  (`bsnes_entropy`).
- **The frame is copied when read**, not in the video callback, for
  snes9x: its `GFX.Screen` stays until the next frame drawn.
- **bsnes could skip too, with a patch**: it has `setFrameSkip` but its
  libretro target does not ask. With a six-line patch answering
  `ENV_GET_AUDIO_VIDEO_ENABLE` (built only in `~/scratch`, not installed),
  drawing is **40% of a bsnes frame** (abl 41.1%, zounds 39.3%, test-game
  41.2%), and with `bsnes_entropy=None` not drawing leaves the same
  screens and WRAM (its audio differs from run to run in one process even
  drawing every frame, so it says nothing).
- The first full run with drawing skipped for all but the last frame of
  every `run(n)` had ABL's `test_end_fades_out_and_stops` red: after
  `stp`, snes9x stops emulating (`HALTED_FLAG`) and shows the last frame
  it drew, so sixty frames drawing only the last showed the menu from
  before the fade. That is why drawing stays the default and only the
  tick loops, whose clock advances to the end, skip.

#### Where the saving comes from, ABL

The same profile after the changes (`bench/prof/abl-after`):

| | before | after |
|---|---:|---:|
| CPU of the pytest processes | 1068 s | 928 s |
| inside `retro_run` | 627 s | 601 s |
| loading ROMs | 129 s | 32 s |
| copying frames in `_on_video` | 28 s | 1 s |
| frames drawn, of 1 177 392 run | all | 724 396 |

So most of it is the kept power-on; skipping the drawing saves 26 s of
emulation here, because only `Session.run` and the arrival skip, and
bsnes, which does not, is in `test_cores.py`.

#### `PROCESSES`

`bench/procs.sh`, ABL's `just tests` and the boot, alone and two at once,
with the changes; 16 threads on 8 cores.

| run | PROCESSES | wall | CPU |
|---|---:|---:|---:|
| ABL alone | 4 | 283 s | 1024 s |
| ABL alone | 8 | 234 s | 1155 s |
| ABL alone | 12 | 216 s | 1690 s |
| ABL alone | 16 | 224 s | 2030 s |
| boot alone | 4 | 234 s | 907 s |
| boot alone | 8 | 171 s | 996 s |
| boot alone | 16 | 187 s | 1663 s |
| two ABL at once, each | 8 | 368 s | 2097 s |
| two ABL at once, each | 4 | 340 s | 1255 s |

- Past the 8 cores the same work costs more CPU —the second thread of a
  core runs both slower—: 12 processes win ABL 8% of wall time for 46%
  more CPU, and 16 lose both. **8 is right for one suite alone.**
- **With two suites at once, 4 each is better on both counts**: each
  ends 28 s sooner and spends 40% less CPU than at 8 each. The rule the
  numbers give is *the processes of all the suites running add up to the
  cores*, so it should adapt: e.g. `PROCESSES` by default
  `max(2, 8 - <pytest workers already running>)`, or 8 minus the load
  average rounded down, with 2 as a floor. Not implemented: it is a
  machine knob, in `machine.just`, and how agents count each other is
  Hornero's to decide.

#### After: the four suites, alone, one after another

With the branches merged with `main` (the-advocate `96cec117`, the ports
`0a534f7`), PATH with the worktree's `.local-tools/bin` (only
`rm2k-snes-project`, so that `--harness` names the worktree's harness),
`bench/after.sh final` and `bench/timed.py`:

| suite | wall before | wall after | CPU before | CPU after | tests |
|---|---:|---:|---:|---:|---|
| the-advocate `just test` | 3.9 s | 4.2 s | 3.9 s | 4.3 s | 29 passed |
| `just test-game` | 111 s | 108 s | 111 s | 108 s | 226 passed, 6 skipped (4 new) |
| ABL `just tests` | 241 s | 237 s | 1354 s | 1190 s | 1692 passed, 2 skipped |
| ports `just boot` | 169 s | 169 s | 1030 s | 982 s | 205 passed |

No golden moved, and `test_cores.py` passed in both. ABL's suite spends
**12% less CPU**, the boot 5% and the test game 3%; the wall times hardly
move, because ABL's is set by its slowest tests and the other two by
bsnes. Another run of the same, `after2`, gave 1155, 996 and 107 s.

#### What is left, with its numbers

- **bsnes, in the boot and the test game**: ~80% of their emulation, and
  40% of each of its frames is drawing; it needs a core patch: draft
  [bsnes draws every frame of the suites](bsnes-draws-every-frame-of-the-suites.md).
  Its ROM load is 183 ms, against snes9x's 48: ~20 s of the test game's
  108, and its power-on cannot be kept, on purpose.
- **ABL's stage tests**: 381 s of CPU, a third of the suite's, in the
  converter's stages the tests run (1042 calls to `converter.ask`) and in
  `test_music_ceilings.py`'s renders. No emulator: it is the "conversion
  cache" idea.
- **The test game runs in series**: 108 s of wall for 108 s of CPU. With
  xdist like the others its wall time would drop to the slowest test's;
  its CPU would not.
- **The loops that end on a condition still draw every frame**: `until`,
  `attend`, `wait`, `until` in the generic session, ABL's `_one_tick`.
  They cannot know which frame is the last; a caller that knows —"run
  until X, I will not look"— could say so. In ABL 38% of the frames go
  undrawn now.
- **PIL and the 15-bit comparisons**: ~50 s in ABL, ~40 s in the boot;
  `fifteen_bits` builds a Python list of tuples per screen.
- **A savestate in the middle of a play is not exact in snes9x**: draft
  [A snes9x savestate round trip is not exact](a-snes9x-savestate-round-trip-is-not-exact.md).
  It rules out reusing a boot from a savestate taken after its frames.
- `PROCESSES`: see above.

When merging: both branches together —the ports' tests pass `draw`,
which the-advocate's harness at `96cec117` takes—. Nothing to install:
the harness is read from the checkout of `~/the-advocate`, so it is
enough that that checkout is at the merged `main`.
