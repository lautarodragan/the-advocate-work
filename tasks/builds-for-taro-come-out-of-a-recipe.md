---
name: "The builds for taro come out of a recipe"
description: "just deliver leaves the release in /shared/builds/ with the .dbg and the commit's rom/src/, so that Mesen2 shows the source from there"
type: chore
status: done
---

The builds in `/shared/builds/<fecha>-<commit>/` were put together by hand and
got things wrong. Now `just deliver "<qué mirar>"`
(`tools/ensamblado/entregar.py`) builds them, and they add the commit's
`rom/src/`, taken with `git archive`, which taro approved on 2026-09-25: Mesen2
looks for the source by walking up folders from the `.dbg`, so with that it
shows it from `/shared` too.

# Done

- It refuses with uncommitted changes in `rom/src/`, `tools/`, `patches/` or
  `data/`, and if `/shared` does not exist.
- If the commit's directory already exists, it overwrites only `abl.sfc`,
  `abl.sfc.dbg`, `LEEME.txt` and `rom/`: the save that taro leaves there stays.
- It deletes the `<fecha>-<commit>` directories except the new one and the
  newest of the others; whatever does not have that format it leaves alone.
- It compares the fingerprint of the tracks with the one in
  `/shared/msu/LEEME.txt`, running the same command it says there. If it does
  not match it warns at the end and the build's LEEME says so;
  `--update-msu` copies them, deletes the extra ones and changes the
  commit and the fingerprint in the LEEME there.

# Measured

- Against a fake `/shared` in the scratchpad: the cases above, plus the
  fingerprint that does not match, with and without `--update-msu`.
- Mesen2's search reimplemented (`mesen_busca.py`) over the build's `.dbg`:
  it finds all the `.s` and is missing only `mapdata.inc` and
  `musicdata.inc`, which are not copied on purpose. It was not looked at in
  Mesen2's interface.
