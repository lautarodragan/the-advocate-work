---
name: "Make building the cartridges take less time"
description: "Optimize the time of `just cartuchos` without refactors: memoizing, parallelizing and numpy, with the ROMs byte for byte identical"
type: refactor
status: done
---

Request from taro, on 2026-09-26: optimize the time of `snes_convert.py` and
of what calls it, **without refactors** and without changing what it
produces; Python, parallelizing where possible and numpy if it helps. The
file's refactor is another task: `responsibilities-of-snes-convert-py.md`.

The measured numbers, before and after each step, are in each commit's
message, which is where they don't go stale. What can't be deduced from them:

## Where the time went

Measured with `cProfile` on the `release` conversion and timing each
subprocess of `cartuchos.py`:

* `lideres_posibles` ran once per test case that touches the party and each
  time loaded and compiled all the maps: half of the converter, warm.
* `getpixel` in `sprite_colors` and `pose_tiles`, by the millions.
* Cold, or warm after touching `snes_convert.py` —which is part of the key of
  the saved layers—, the map layers, serially.
* The MSU-1 tracks normalized sample by sample in Python.
* The cartridges and the tracks, one after the other.
* The subprocesses (`gunter`, `voodoo`, `lz2`, `ca65`, `ld65`) weigh little:
  almost everything is pure Python.

## What was done, one commit per thing

1. `lideres_posibles`: the party changes per map, once per conversion.
2. The CharSets' pixels through `load()`.
3. The layers of all the maps in parallel (`precalcular_capas`), with forked
   processes that return what they computed with the cache key.
4. `cartuchos.py` builds the cartridges and the tracks at the same time, in
   threads.
5. `msu.pista` with numpy.
6. `textos.reajustar` and `asignador.merge_least_visible` memoized.

Each one verified the same way: `cartuchos.py` cold (`SIN_CACHE=1`), with the
cache deleted, in the run that fills it and warm, and all of
`rom/build/release` and `rom/build/tests` compared by sha256 against what
8ffc2ce built, except the `.o` and the `.dbg`'s `mtime`s, which change with
each checkout. `just pruebas` green at the end.

## What's left, and why it wasn't done

* **The floor of the cold layers is the most expensive map** (map 2 today),
  which can't be split. Lowering it means changing `_convert_layers`'s data
  model —`quantize`, `cut_tiles`, `build_palette` work with Python tuples per
  pixel— to numpy end to end: a big change, which this one wasn't.
* **Parallelizing `convertir` per map**, no: it carries state between maps
  (`args.imagenes`, the sign of the first map that shows it, the indices the
  passes fill in) and the order matters. The layers were the pure part.
* **Overlapping the converter's stages** —the music, the scene, the layers—
  requires knowing what depends on what in a thousand-line `main`: it's the
  inventory of the responsibilities task, not something to do blindly.
* **Each zone's `gunter sf2 --extract --json`** (more than a thousand calls
  per conversion) could be kept in the on-disk cache; it's little time and
  another category of cache to maintain.
* **`fork.mapas()` validates the whole fork on each `lcf.Map`**, on purpose
  according to its docstring; memoizing it per process would save little.
* **Caching `lcf.Map`**, no: the maps are modified after loading them (the
  test page, the baking, the decorated translucent ones).
* **Tracks in parallel inside `msu.armar`**: with numpy they take less than
  the `release` converter, alongside which they already run. It would only
  help when redoing the tracks alone.
