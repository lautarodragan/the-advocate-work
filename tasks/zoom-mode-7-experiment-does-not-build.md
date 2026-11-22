---
name: "The zoom-mode-7 experiment does not build"
description: "abl/experiments/zoom-mode-7/build.py reads a top-level mapping from adeleine reduce's answer, which today's adeleine gives per tile; it fails before assembling"
type: bug
game: abl
status: wishlist
author: calandria
---

Seen by Calandria on 2026-10-13, with the-advocate `9f95b248` and the
ports `c59fc10` (and at step 1's version of the file too), in ABL's
experiments.

**What is seen**: `abl/experiments/zoom-mode-7/build.py` reads
`answer["mapping"]` from `adeleine reduce`, and today's Adeleine answers
the mapping per tile, `"tiles": [{"palette", "mapping"}]`; the build stops
there with a `KeyError`, before writing `data.inc` or assembling.

**How to reproduce it**: run `abl/experiments/zoom-mode-7/build.py` with
its usual arguments (`--help` lists them). The other experiments build.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Still so (`answer["mapping"]` in `build.py`). An experiment nobody runs
today. **Done** is `build.py` reading the per-tile `tiles[].mapping` of
today's Adeleine and the experiment assembling again. If taro would rather
drop the experiment, deleting it is the other way to close this.

## Log

### 2026-11-22, Tijereta: what the experiment was, and a recommendation

Checked against the-advocate `0ae40e0a`, the ports `89f77b4` and the book
at its `main`. `build.py` still reads `answer["mapping"]`; not run.

**What it is**: the pilot of
[`mode-7-pilot-for-the-zoom-of-the-diff-photos`](mode-7-pilot-for-the-zoom-of-the-diff-photos.md)
(Chimango, 2026-10-02, done): a stand-alone test ROM, outside the
converter, that zooms the four Diff photos of maps 212-216 from 100 to 0 %
in mode 7, with four variants switched by the joypad —2x2 average or 255
vq tiles, all mode 7 or a hybrid with the still photo in mode 1—, for taro
to choose on the TV. It lives in `abl/experiments/zoom-mode-7/` of the
ports: `build.py`, `zoom.s`, `memory.cfg`, `verify.py`, `videos.py`.
No recipe or test runs it any more (the `zoom-modo-7` recipes are gone;
only `RENAMES.md` names it).

**What was decided since**: taro chose variant 4, the vq hybrid, on
2026-10-03, and it went into the engine for any game in
[`picture-zoom-in-mode-7`](picture-zoom-in-mode-7.md) (Chajá, done):
`mode7.rs` in `rm2k-snes-images` bakes the texture and
`runtime/big_picture_zoom.s` plays it; the book records it in
`decisions/large-pictures-in-mode-1.md`. The other zoom,
[`the-zoom-baked-at-run-time`](the-zoom-baked-at-run-time.md) —the battle
transition, composing the live mode 3 screen into mode 7—, is a separate
question: research done (`research/2026-10-12-the-zoom-baked-at-run-time.md`
in the book), wishlist by taro's word on 2026-10-13, and its prototype was
its own, in Carpintero's scratch, not this one.

**Recommendation: close it by deleting the experiment**, not by fixing
it. The question it asked is answered and built into the engine, which
the suite now covers (`big-picture-photo-*` goldens); the pilot's own
numbers are in its task, and git keeps the code. Fixing `build.py` would
only keep alive a ROM nobody will build again. `game: abl` added, since the
code is ABL's, whichever way it closes.
