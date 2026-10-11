---
name: "Warm cartridges in ten seconds"
description: "Second round of optimising `just cartuchos`: taro's goal was under 10 s warm, with no refactors and all of rom/build identical byte for byte"
type: refactor
status: done
---

Request from taro, on 2026-09-26, after `make-building-the-cartridges-take-less-time.md`:
`just cartuchos` warm under 10 s, and also bring down the cold
path. Same rules as the previous round: no unnecessary refactors,
without changing what the converter produces, and all of `rom/build/release` and
`rom/build/tests` identical byte for byte and deterministic.

**10 s wasn't reached.** The numbers for each step, before and after, are in
each commit's message, which is where they don't go stale; `just cartuchos`
prints them.

## Where the time went, after the previous round

Warm, nearly all of it is `release`'s converter, and inside there was no
stage that dominated: the music (`build_varios`), each map's `convertir`, the
battle scene, the sweeps that load every map in the game to
index variables and skills, and a trickle of small stages. Behind the
converter comes `release`'s `ca65`, which can't be sped up without changing
what the converter emits.

Cold, map 2's layers were the floor: layers go one process per
map, so the build doesn't finish before the most expensive map. With that floor
lowered, the critical path became the MSU-1 tracks, one after the
other.

## What was done, one commit per thing

1. The colours and tiles of the CharSets' poses with numpy.
2. `merge_least_visible` with numpy.
3. `fork.mapas` remembers what it validated as long as the directory doesn't change.
4. The SoundFont zones, requested from `gunter` in threads.
5. The themes of `build_varios`, in parallel.
6. The variable and skill sweeps, in parallel.
7. `comun/paralelo.en_paralelo`, a single one for all of the above, and with it
   the MIDIs and the sound effects.
8. The layers are quantised and cut into cells with numpy (the cold floor).
9. The MSU-1 tracks, at the same time.
10. The `indexar_*` and the sweeps read a single LDB.
11. The item screen counts colours with numpy.
12. Each theme's samples, decoding in parallel.
13. `en_paralelo` runs serially if the process already has threads: in a pytest
    worker with a loaded core, forking can hang the child.

Each one verified the same way: `cartuchos.py` cold (`SIN_CACHE=1`), with the
cache deleted —the run that fills it— and warm, comparing the sha256
of all of `rom/build/release` and `rom/build/tests`, except the `.o` and the
`.dbg`'s `mtime`s, against what the starting `main` built; and the same
after merging `main`, against what that `main` builds. `just pruebas`
green at the end.

## What's left

* **A stamp split in two: the converter's and the assembly's.** It's what
  would take the most common case, which is touching `rom/src/`, under 10 s.
  Today `cartuchos.py`'s fingerprint puts all of `rom/src/` in the same stamp as
  the `.py` files of `tools/`, so touching one line of assembler converts
  everything again. The converter reads a single file from `rom/src/`,
  `ram_lejana.s` —I checked it with an audit hook over `release`'s
  conversion—, so with one stamp for the converter (flags, cases, `tools/`,
  converter binaries, `parches/manual/`, ceilings and `ram_lejana.s`) and another
  for the assembly (`rom/src/`, `ca65`, `ld65`), touching assembler would be
  just `ca65` and `ld65`. It's a structural change in `cartuchos.py` and wasn't
  done.
* **The warm converter is still a trickle**: `convertir` (the
  ChipSet atlases to decide what gets baked, `build_blocks`, the
  poses), what's left serial in the music, the two `emit`, the scene,
  the compression, the bank packing. None goes over a couple of tenths
  alone; lowering them all together requires parallelising `convertir` per map or
  overlapping stages of `main`, which is the responsibilities task
  (`responsibilities-of-snes-convert-py.md`).
* **`release`'s `ca65` is a floor**: it assembles the whole `mapdata.inc`, which
  is megabytes of `.byte` in text. Lowering it means emitting the big blocks as
  binary (`.incbin`), which changes what the converter produces.
* **Cold**, with map 2's layers lowered, what's left of it is mostly
  the drawing with Pillow (`render_layers`, one paste per tile) and
  `imagen()` in `convert`, which builds the pixels of each drawing in Python;
  this second one could be done with the shared cells of
  `tiles_cuantizados`, like `_colores_de`.
