---
name: "MSU-1 coverage"
description: "No test runs bsnes or mesen-s with the tracks alongside, nor covers just video"
type: test
status: todo
---

Since 2026-09-25 `release` always carries its MSU-1 tracks and the harness
hides them from the core (`retro.Console(..., msu=False)`, in
`pruebas/arnes/emulator/retro.py`). `pruebas/abl/test_msu.py` catches it, **only
in snes9x**. What was measured by hand and has no test:

* **bsnes and mesen-s with the tracks alongside.** It was measured by hand that
  bsnes gives the same audio as without tracks; mesen-s changes with `msu=True`
  but its audio doesn't come out the same between runs, so it isn't compared
  for equality. A test for bsnes is cheap if `test_cores.py` already starts it;
  mesen-s needs another comparison (SPC700 silence? the MSU-1 registers?).
* **`just video`** (`pruebas/arnes/video.py`). No test runs it. It has an
  already fixed bug that no net would catch if it came back: it used a fixed
  rate of 32,040 and snes9x switches to 44,100 with the MSU-1 on, so the sound
  drifted from the video. A small test that builds a few frames with and
  without `--sin-msu` and compares the length of the audio with that of the
  picture is enough.
