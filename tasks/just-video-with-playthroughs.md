---
name: "just video with playthroughs"
description: "just video is broken with playthroughs since 991bf935: video.py's walkthrough factory doesn't accept a case, and without the debug map talan gets stuck on 900"
type: bug
status: done
assignee: taro
---

Irupé found it on 2026-09-29 (`tests-without-silent-holes.md`):
since `991bf935` (2026-09-27), `just video … apertura` gives a `TypeError`
because the `recorrido` factory in `rom/pruebas/arnes/video.py` doesn't
accept `caso`, and `talan` gets stuck on map 900 because it doesn't pick the
page without the debug map. `quieto:120` records fine. taro uses `just video`
to ask for videos of a build.

The regression gets fixed. Taking `video.py` out of the tests —making the
playthroughs functions of a scenarios module called by both the tests and the
video— is another task, a bigger one.

## What was broken

Both things are the same one: `video.py` built the `Partida` by hand, with a
factory that copied the conftest's from before the debug map.

* The signature was `(_nombre, switch=())`. The opening asks for
  `recorrido("apertura", caso=ENTRADA_AL_MAPA_DE_DEBUG)` since `991bf935`:
  `TypeError`.
* It always picked page 0. Since `991bf935`, in `release` page 0 is the entry
  to the debug map, and the conftest asks for `LA_PARTIDA_DE_VERDAD` by its
  number —`tanda.partida(None)` does it—. `talan` turned on the year switch
  before and waited for map 7 standing on 900. `quieto:N` "recorded fine"
  because it doesn't wait for anything, but it recorded the debug map and not
  the opening with the rain that its help text mentions.

## How it was fixed

`video.fabrica(cartucho, msu)` is the factory, at module level, with the
fixture's signature and the save from `tanda.partida(caso, en=cartucho, …)`:
the page is picked by the same code as in the tests. `tanda.partida` passes
`msu` to the `Partida`. `video.py` receives the cartridge's name and not its
directory —`tanda.cartucho` knows where it is and refuses if it's stale—, and
`just video` depends on `build`, like `entregar`, so a changed checkout is
built before recording.

The safety net is `rom/pruebas/abl/test_video.py`: same signature as the
fixture, and that both factories start on the same page, map and cell for
each way of asking that the playthroughs use (nothing, switches, case). It
neither records nor plays. With the old factory pasted inside `fabrica`, all
four go red: the signature, `caso` with `TypeError`, and the other two on
page 0 against 111 —the map and the cell match at tick 0, so looking only at
the map wouldn't have seen it—.

## What taking `video.py` out of the tests would look like

What remains ugly is that a harness script imports a `test_*` and depends on a
reimplemented pytest fixture. The alternative: a `tests/harness/` module of
scenarios —`escenarios.apertura(r)`, `escenarios.talan(r)`— that receive an
already built `Recorrido`, with the snapshots and the `assert`s as hooks that
the test passes and the video doesn't; the test would be "build the walkthrough
with the fixture and call the scenario", and the video "build it with
`fabrica` and call the same one". With that `-O` is no longer needed —the
video wouldn't have the speed `assert`s—, `IMPORTAN_PRUEBAS` in
`test_index.py` becomes empty, and `just video` could also play the stretches
of `tramo_*.py` and the other `test_recorrido_*`, which it can't reach today
because it only looks in `test_playthrough_golden.py`.

And in passing, which isn't part of this task: a `video.py` that gets cut off
leaves its raw `video.mkv` in the temp directory —about 200 MB per minute—,
because the `os.remove`s at the end aren't in the `finally`.
