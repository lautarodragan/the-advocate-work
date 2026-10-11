---
name: "A single place that knows where everything is"
description: "Step 2 of the plan: comun/proyecto.py gathers the eleven root computations and the derived paths, without changing any value"
type: refactor
status: done
assignee: taro
---

Step 2 of the plan in `docs/research/el-mapa-de-las-herramientas-de-python.md`
(§4). It goes before the move of `data/`, `parches/`, `pruebas/` and the engine
(see `workflow/decisiones/las-herramientas-se-separan-de-abl.md`): with this
done, moving a folder is changing one line.

Hornero decided it, with taro's authorisation of 2026-09-29 to decide
without waiting for him: a module `tools/comun/proyecto.py` with one function per
place, which today returns exactly the same as the scattered computations. The
engine is already called `runtime()` there, even though it's still in `rom/src/`, so that the
move doesn't have to rename calls.

## How it's going (Tipa, 2026-09-29)

- `tools/comun/proyecto.py`, in its own commit, with no callers. One function per
  place: `herramientas`, `raiz`, `runtime`, `build`, `data`, `parches`,
  `parches_manual`, `parches_auto`, `pruebas`, `casos`, `goldens`,
  `snapshots`; and the environment ones: `juego` (`ABL_GAME_DIR`), `rtp`
  (`ABL_RTP_DIR`), `soundfont` (`ABL_SOUNDFONT`), `reemplazos_msu` (no
  variable, overridden by `--reemplazos`), `cache` (`ABL_CACHE`),
  `cartuchos_de_prueba` (`CARTUCHOS`) and `compartido` (`SHARED`).
- `herramientas()` comes from `__file__` and `raiz()` is its parent: whichever
  moves is the one that changes a line.
- The scripts that get executed still go up **two** folders from
  `__file__`, to `tools/`: it's the bootstrap that puts the packages on the
  `sys.path`, and without it `proyecto` can't be imported. What they stop
  doing is going up three.
- `parches.py` had a single constant for two things: where the
  versioned stuff is in the repo and where each cartridge leaves it in its build. They were
  equal by chance —the build mimics the shape of `parches/`—. Now
  `Clase` has `directorio` (the repo's, comes from `proyecto`) and `en_build`
  (the build's shape, which doesn't move with `parches/`).
- The converter's layer key (`_version_capas`) adds
  `comun/proyecto.py`: the directories where `render_map`
  looks for the ChipSet come from there, just like `recursos.py`.
- The safety net: `tools/pruebas/test_proyecto.py` fails if a `.py` in `tools/`
  goes up three folders from `__file__`, builds with `os.path.join` a path that
  starts with a root folder (or sticks it after the root), or reads
  one of the location variables. One exception: the build's shape in
  `parches.py`.

## What was left out, and why

- `pruebas/arnes/video.py`: computes the root to build its `sys.path` before
  it can import anything. It's a script, and the bootstrap is that.
- `pruebas/herramientas/test_lado_de_abl.py`, `test_indice.py` and
  `pruebas/abl/test_hover_tram.py`: they don't import from the tools and don't
  start doing so. `test_hover_tram` repeats the default value of
  `ABL_GAME_DIR`, same as the `justfile`.
- `consola.NUCLEO`: a libretro core, not a project path.
- `entregar.HUELLA_MSU` comes from `proyecto` and today gives the same text, but
  that text is copied into the `LEEME.txt` of the delivered tracks: when
  `rom/build/` moves, the fingerprint changes and they have to be delivered again.
- The script in appendix D of the research puts `comun` in the
  `rpgmaker` row; `tools/README.md` says how to run it with `comun` below.

## Verified

- `SIN_CACHE=1 just cartuchos` before touching anything and after migrating:
  997 files in `rom/build/` identical (without `.o` or `sello.txt`; the `.dbg` files
  without mtime). After the comment in `registros.s`, the same except for the
  `size` of that file inside the two `.dbg` files.
- `just pruebas`: 866. `just -f tools/justfile pruebas`: 117 (109 + 8).
- `rm2k-snes-space` and `rm2k-snes-patches --check` by name from `/`,
  `just -f …/justfile parches-check` from `/tmp`, and `--help` of the other
  six executables.
- **Not run**: `just entregar` (its values were printed), nor
  `rm2k-snes-msu` nor `rm2k-snes-volume-ceilings` beyond `--help`.

## What to look at

Nothing to play: the ROM is the same. What's left is reading the diff.
