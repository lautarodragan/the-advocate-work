---
name: "Rust: the MSU-1 tracks and the ceilings"
description: "The second part of the audio: tools/audio/msu.py and ceilings.py to Rust, still with fluidsynth and ffmpeg from the PATH, with the tracks byte for byte identical"
type: refactor
status: done
assignee: taro
---

Second part of the audio on the road to Rust. Hornero decided it: `msu.py`
(`rm2k-snes-msu`, the MSU-1 PCM tracks) and `ceilings.py`
(`rm2k-snes-volume-ceilings`, the measurement of ceilings) move to Rust,
inside the `rm2k-snes-audio` crate or next to it. They still call
`fluidsynth` and `ffmpeg` from the PATH: another synthesizer wouldn't give
byte-for-byte identical tracks, and that's what is verified.

## How it ended up

**Two more binaries of the `rm2k-snes-audio` crate**, with the same names and
the same flags: `rm2k-snes-msu` (`src/bin/msu.rs`, the logic in
`src/tracks.rs`) and `rm2k-snes-volume-ceilings`
(`src/bin/volume_ceilings.rs`, the logic in `src/ceilings.rs` and the
libretro console in `src/retro.rs`). None of the callers changed:
`rm2k-snes-cartridges` runs `rm2k-snes-msu` and `rom/justfile` runs
`rm2k-snes-volume-ceilings` as before.

Why binaries and not subcommands of `rm2k-snes-audio`:

* **The names**: the cartridge builder and the `techos` recipe call the
  executables by name, and a subcommand would require a wrapper or changing
  the callers.
* **The tracks' key**: what in Python was `version_of("audio/msu.py")` —the
  code that normalizes and writes the track— in Rust is the sha256 of the
  executable that runs. With a binary of its own, the key changes when what
  goes into that binary changes, and not with any change to the compiler:
  the tracks take a minute and a half to redo.
* **The same crate** because they share `Game` —where a theme is, the game or
  the RTP— and the engine's numbers: `ceilings` asked `rm2k-snes-audio
  constants` for the `headroom` and the `master`, and now reads them from
  `sdsp` directly; `msu` asked `rm2k-snes-audio find-song` and now calls
  `Game::song_path`.

**The ceilings, entirely in Rust, console included.** The question was
whether loading a libretro core from Rust was worth it or whether that part
was better left in Python. It came out small —`retro.rs`, some two hundred
lines, with `libc`'s `dlopen` and no other dependency— because for measuring,
the audio is enough: no image, no buttons, no memory needed. It answers the
environment the same as `emulator/retro.py` —the order of the calls, the
first value of each option, a directory of its own with no tracks alongside—
and **gives the same samples**: see the comparison below.

What's different about it: **a core is one console per process** —its state
is the library's globals—, so the themes are played in parallel in separate
processes, as Python's `Pool` did: the same binary with `--play ROM --song N
--frames F`, which prints in JSON the clips, the peak and the frame (and the
LUFS with `--lufs`). `PROCESOS` still says how many.

**`test_musica_techos.py` no longer imports `audio.ceilings`**: it plays each
theme near the cap with `rm2k-snes-volume-ceilings --play`, which is the same
console and the same computations the table was measured with. The rest it
took from the module —where the table is, `musica.json`, the `; Songs:`
line— the test reads on its own: three lines each.

`emulator/retro.py` isn't touched: it's the whole suite's harness.

## The comparison

* **The tracks**: `NO_CACHE=1 just cartuchos` with the Rust binaries against
  the same command with the Python ones, in this worktree: the `.pcm`s, the
  `.msu` and the `.sfc`s of `rom/build/` come out byte for byte identical,
  and so do the lines each track prints. That includes the two that come from
  an `ffmpeg` replacement. With the cache, the second run says it did none.
* **The ceilings, `--measure`**: Rust's report is Python's line by line
  —clips, peak, LUFS of each theme—. And a single theme with `--play` gives
  the same samples as Python's `ceilings.play`.
* **The ceilings, the whole path** —the copy at half headroom, the table,
  rebuilding, measuring again—, run in Python and in Rust on **a copy of the
  project**, so as not to touch the repo's table: both tables come out byte
  for byte identical, and the reports too.
* `just pruebas` and `just -f tools/justfile test` green, before and after
  deleting the `.py`s; the crate's `cargo test` green.

What was seen along the way and not touched: the versioned table is no longer
the one measuring today would give. Python and Rust agree that eight themes
moved between 0.1 and 0.4 dB from the written peak —`MML2_MotherZone`, from
-1.0 to -0.6—, and the whole path changes the headroom of seven and the
fingerprint of six. None clips, and the fingerprint test passes because it
looks at `musica.json`, not at a new run, so it's the drift the test already
expects. And the header of the repo's table is still in Spanish, because it
predates the translation: the next `just techos` writes it in English, and it
cites `build_all` and `sdsp.HEADROOM`, which were Python names —they were left
as they were, so the tables would come out identical—.

## When merging

* **Install `rm2k-snes-audio`**: `just -f tools/justfile install
  rm2k-snes-audio`, from the main checkout. It installs the three binaries,
  and `_install` first deletes the `rm2k-snes-*` symlinks, so those of
  `rm2k-snes-msu` and `rm2k-snes-volume-ceilings`, which pointed at the
  `.py`s, aren't left dangling. Without reinstalling, the global is left with
  symlinks to files that no longer exist.
* **`tools/port/snes_convert.py` cites `tools/audio/` twice** —the help of
  `--measure-headroom` and a comment about `musica.json`—: it wasn't touched
  because Ñacurutú is splitting it.
* The first run with the new binary redoes the 43 tracks —the key changed—: a
  minute and a half, once.
