---
name: "The zoom-mode-7 experiment does not build"
description: "abl/experiments/zoom-mode-7/build.py reads a top-level mapping from adeleine reduce's answer, which today's adeleine gives per tile; it fails before assembling"
type: bug
status: wishlist
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
