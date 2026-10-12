---
name: "Rust: the music compiler"
description: "The audio chain from MIDI to the S-DSP stream and the per-map audio package, in Rust (rm2k-snes-audio), with the ROMs byte for byte the same; msu and ceilings stay in Python for now"
type: refactor
status: done
assignee: taro
---

Third step of the road to Rust in [`research/the-tools-today.md`](https://lautarodragan.github.io/the-advocate-docs/research/the-tools-today.html),
in parallel with Carancho. Hornero decided it: the audio goes in parts, and
this is the first, the music compiler —`midi`, `music`, `sdsp`, `spc700`,
`snes_music`, `snes_samples`, `brr_samples`, `msu_effects`—. `msu.py` and
`ceilings.py` (the PCM tracks and the ceiling measurement, which use
fluidsynth and ffmpeg) stay in Python for a second part. The bridges to
`gunter` (`brr_samples`, `snes_samples`) disappear: the new crate uses
`gunter` as a library.

## How it ended up

**The crate is `tools/rm2k-snes-audio/`**, library and executable, and it
uses `gunter` (the SoundFont and the BRR) and `rm2k-project` (the project
file) as libraries by `path`. For that Gunter got a `lib.rs`, and the
extraction of `sf2 --extract` —selector, zone, contract, PCM— moved out of
its `main.rs` into `gunter::extract`; its binary says the same as before.
And `protocol` learned `--rust`: `rm2k-snes-audio/src/music_opcodes.rs`
comes out of `music.toml` like the other two sides, and the `protocol`
recipe checks it.

**The converter passes it a request and reads what it writes.** It builds
the request —themes, effects, packages with their outputs and standalone
ones, inheritance, the measurement headroom, the `System` songs and what
goes to `musicdata.inc`—, leaves it in `audio-job.json` next to the
cartridge and runs `rm2k-snes-audio compile`, which writes
`musicdata.inc`, `musica.json` and `audio.json`. From there the converter
takes what it is missing: the boot against `BOOT_FRAMES` (which it still
reads itself from `far_ram.s`) and the quality versions of the effects for
the `.msu`, which it still builds itself because it also carries the battle
backgrounds.

**The comparison, first run**: `NO_CACHE=1 just cartuchos` on `release`
and `test-special`, against the snapshot of merged `main` (`fdae002f`): the
991 files of `rom/build/` that existed come out the same byte for byte —the
`.sfc`, the `.msu`, the 43 `.pcm`, `musicdata.inc`, `musica.json`,
`efectos.json`—, and the four new ones appear (`audio-job.json` and
`audio.json` of each). The converter's log has the same lines, in another
order: the theme and bank report is now printed by the executable, before
the converter's lines.

The whole of `release`'s audio takes **2.3 s** in Rust, in one thread and
without disk cache.

**The decisions**:

* **What matching cost.** The Python rounded half to even, divided with
  floor, filtered with numpy —the kernel summed pairwise, in blocks of
  eight— and squared with libc's `pow`; the Rust does the same, on purpose,
  and `src/num.rs` says so. The loop's circular convolution, which numpy did
  via FFT, is direct here: it differs in the last bit and did not change any
  rounding in either cartridge. What in Python depended on the order of a
  `set` —the order of `allocate`'s sums and of the copies, which changes
  with `PYTHONHASHSEED`— goes here by key order.
* **No disk cache.** The `muestras` and `brr` categories go away: 2.3 s for
  the whole of `release` does not call for it. So there is no key that has
  to carry the new binary; what does carry it is the cartridges'
  fingerprint (`tools/cartridge/`), where it replaces `gunter`, which the
  build no longer runs.
* **The effect tables that `events.py` reads** —per map, of routes, of
  troop— `events.py` reads from the project file; the standalone themes and
  the themes of each map of the tree, the converter. They are not asked of
  the executable: they are game knobs, not music.
* **`msu.py` and `ceilings.py` stay in Python**, without importing anything
  deleted: `msu.py` looks up each theme's file with `rm2k-snes-audio
  find-song` and keeps the SoundFont's fingerprint, which belongs to its
  cache; `ceilings.py` asks `rm2k-snes-audio constants` for the headroom and
  the master volume.
* **The `.msu` is still built by the converter** (`write_msu`), because it
  carries the battle backgrounds; which version of each effect goes in each
  package, their rows and their heights are decided by the executable and
  left in `audio.json`.
* **ABL's tests** ask through `rom/pruebas/arnes/musica.py`, shaped like
  `cartuchos.py`. Four leave the list in `test_lado_de_abl.py`.
* **`tools/tests/test_music_stream.py` moves to the crate**, in Rust: its
  twenty tests are in `src/voices/tests.rs`, `src/midi.rs`, `src/sdsp.rs`
  and `tests/soundfont.rs` (the two with the SoundFont, with `SOUNDFONT`).
  And like `rm2k-render`, `tests/python.rs` keeps the SHA-256 of what the
  Python wrote for a small game built in the test.
* **`music_opcodes.py` stays**: `protocol` generates it and
  `test_protocol.py` reads it, which now also checks the Rust module.
* **`musicdata.inc` changed four comment lines**, in a separate commit: it
  said it was generated by `snes_music.py`.

**The full comparison**, with the fingerprint script of `rust-chingolo/`
in the scratchpad: `NO_CACHE=1 just cartuchos`, `release` and
`test-special`, against the snapshot of `fdae002f`, after each step —the
switch to Rust, the deletion of the Python, the prose—: all the same. After
the last commit, the `.sfc`, `.msu` and `.pcm` the same, and
`musicdata.inc` different in those four lines.

## When merging

Install `protocol` (it has `--rust`, and `test_protocol.py` uses it),
`cartridge` (the fingerprint) and `rm2k-snes-audio`: `just -f tools/justfile install
protocol cartridge rm2k-snes-audio`. `gunter` is not needed: its binary does
the same, and what changed is that it is now a library, which goes inside
`rm2k-snes-audio`. Not `install-scripts`: no script changed name.

## What is left

The second part: `msu.py` and `ceilings.py` (fluidsynth and ffmpeg) to Rust.
