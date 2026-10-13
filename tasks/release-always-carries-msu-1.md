---
name: "The release always carries MSU-1"
description: "The tracks go next to release/abl.sfc, and it is the harness that decides whether the core sees them"
type: feature
status: done
---

taro decided on 2026-09-25 that **the release always carries MSU-1**:
`rom/build/release-msu/` goes away, and `just build release` leaves the
`abl.msu` and the `abl-N.pcm` next to `rom/build/release/abl.sfc`. There
can't be two ways of having the ROM with tracks.

What forced splitting them in `5a22c81` (2026-09-24): the emulator looks for
the `.msu` next to the `.sfc`, so with the tracks in `release/` the suite ran
with the SPC700 silent or not depending on whether someone had run `just msu`.
Now the harness controls it: `retro.Consola` gives the core a directory of
its own with no tracks, unless it is asked for MSU-1.

# Done

- `retro.Consola(msu=False)`: by default the core receives a copy of the `.sfc`
  in its own `tempfile.mkdtemp`, which is also its system and save
  directory; it is deleted with `weakref.finalize`. `msu=True` loads the real
  path. A copy and not a symlink: measured that snes9x and bsnes don't follow
  a symlink to the real directory —mesen-s couldn't be measured, its audio
  doesn't repeat—, but the copy doesn't depend on that and comes for free: the
  bytes are already read.
- `retro.Consola.tasa()`: snes9x delivers 44100 samples per second with MSU-1
  and 32040 without it. `video.py` asks for it instead of the constant it had.
- `video.py` records with MSU-1 by default —it is for hearing the ROM as it is
  played— and `--sin-msu` for the SPC700 alone. `Partida(msu=...)` passes it on.
- `cartridges.py release` always runs `msu.armar`, even if the ROM is up to date.
  The `msu` recipe is gone: a single way of having the ROM with tracks.
- `msu.py` writes each `.pcm` alongside and replaces it, instead of truncating it.
- `tests/abl/test_msu.py`: with the tracks alongside, `tanda.encender` gives
  the same audio as a copy without tracks, and with `msu=True` it gives another.

# Measured

- Before the change, 1200 frames of the title: snes9x and bsnes give different
  audio with the tracks alongside than without them. After it, by default, the
  same as without them, and with `msu=True` the same as before with them.
  mesen-s also changes with `msu=True`, but its audio doesn't repeat between runs.
- `release/abl.sfc` identical byte for byte to before the change, and the 22
  re-rendered tracks identical to those in `release-msu/`.
