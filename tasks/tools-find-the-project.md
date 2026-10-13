---
name: "The tools find the project"
description: "The tools stop knowing that ABL lives in rom/ and stop reading ABL_*: they look for rm2k-snes.toml upwards, their paths come from the file, and the environment arrives through flags"
type: refactor
status: done
assignee: taro
---

What's left so that `tools/` knows nothing about where or how ABL is, after
`abl-project-file.md` (Molle). Hornero decided it, with taro's
authorisation of 2026-09-29 to decide without waiting for him:

- **The tools find the project the way cargo finds its own**:
  they look for `rm2k-snes.toml` upwards from the current directory, or
  receive it through `--proyecto <dir>`. `proyecto.abl()` disappears.
- **The project's paths** (`data/`, `patches/`, `build/`, whatever is
  needed) **are declared by the file**, relative to it. The runtime isn't: it belongs to
  the tools.
- **The environment arrives through flags** (`--game-dir`, `--rtp-dir`,
  `--soundfont`…), as Molle left written in his task; `rom/justfile`
  translates `$ABL_GAME_DIR` and the rest. The tools don't read any
  `ABL_*`.

## How it's going (Timbó, 2026-09-29)

Each commit's safety net: `SIN_CACHE=1 just cartridges` before touching anything and
after each one, with the sha256 of all of `rom/build/` —Molle's script,
with the same criterion: without `cache/`, `.o`, `stamp.txt` or `converter.log`, and
the `.dbg` files without `mtime`—.

1. **Finding the project.** `proyecto.directorio()` looks for `rm2k-snes.toml`
   from the current directory upwards the first time someone asks for
   it, and `proyecto.fijar()` sets it without searching. `--proyecto` is read by each
   executable with `desde_la_linea_de_comandos`, which takes only that flag
   before its `main`'s `parse_args`: `cartuchos` and `entregar` read the
   file on import, so in those it goes before anything else. If it doesn't
   find it, `NoHayProyecto` —a `SystemExit`, so the executable stops with
   the message and no traceback— says where it searched from.
   - **Nothing is computed on import.** The constants that came from the project
     —`lcf.DATOS`, `fork.MAPS`/`NUEVOS`/`CHIPSETS`/`DEL_JUEGO`,
     `chipset_del_fork.GENERADO`, `snes_music.TECHOS`, `cache_disco.DONDE`,
     `techos.MEDIDA`— became functions or are computed inside the one
     that uses them. Otherwise, importing the converter from `tools/` —which the
     tools' tests do— would look for a game. The
     `test_perillas.py` test that guarded it now runs from an empty
     directory, and at the end asks for the project to check there wasn't one.
   - **`parches.py` received the repo root** and added
     `rom/parches/auto/` to it: now its functions receive the automatic
     directory (`proyecto.parches_auto()`), and the messages name the
     paths relative to the current directory.
   - **The converter runs from the repo root** —that's where the relative
     paths that end up in the `.dbg` are—, so `cartuchos` passes it
     `--proyecto`.
   - **ABL's tests set the project by their location**:
     `tests/harness/places.py`, which `conftest.py`,
     `console.py` and `video.py` import first.
   - `render_map` still also looks for resources in `proyecto.raiz()`: it's
     from 2026-08-31 (`00d96428`, when the RTP could live in the repo) and today
     it finds nothing there, because the root has no RM2k folders. It isn't
     reaching ABL, so it wasn't touched.
2. **`[paths]` in the file**, with keys in English and relative to it:

       [paths]
       data = "data"
       patches = "parches"
       build = "build"
       cases = "tests/cases"

   `proyecto.build()`, `data()`, `parches()` and `casos()` read them from there.
   What's inside `patches/` (`manual/`, `auto/`) and `build/`
   (`release/`, `tests/`, `cache/`, `techos/`) still belongs to the
   tools: it's the shape they give it, not a decision of the game.
   - **What goes in and what doesn't, with the brief's criterion: it belongs in the file if
     a tool reads it.** `cases` goes in even though it lives in `tests/`, because
     `rm2k-snes-cartridges` reads it. The goldens and snapshots don't: only
     ABL's tests read them, which know them by their own location, in
     `tests/harness/places.py` (`GOLDENS`, `SNAPSHOTS`).
     `proyecto.pruebas()`, `goldens()` and `snapshots()` disappear.
   - `test_perillas_repetidas.py` doesn't look at `[paths]`: its values are folder
     names, and the tools use `patches/auto/` as the shape of each
     cartridge's directory. Building a game path by hand with those
     words is caught by `test_proyecto.py`, which looks at paths.
3. **The environment through flags**, with Molle's plan: `comun/ambiente.py` is
   **a single place that gets configured**. Each executable adds the flags of what
   it uses (`ambiente.argumentos`) and sets them (`desde_argumentos`); the rest
   of the tools read from there. `recursos.GAME_DIR`, `recursos.RTP_DIR` and
   `snes_samples.SOUNDFONT` still exist, but they're resolved on reading
   with a module `__getattr__`, and when unset they fail with
   `FaltaElAmbiente`, which says which flag is missing. This was chosen over passing the
   value as a parameter because they're read inside some forty functions
   —what Molle counted—: with this the twelve signatures that had them as
   default changed (`game_dir=GAME_DIR` becomes `None`, which is resolved inside),
   and no others.
   - The flags: `--game-dir`, `--rtp-dir`, `--soundfont`, `--reemplazos`
     (`rm2k-snes-msu`'s, which already existed), `--cache` and
     `--test-cartridges` in the suite; `--compartido` in `abl-entregar`.
     The values are stored absolute, because the converter runs from
     a different directory from the one that called it.
   - **No default value**, except the cache and the test cartridges,
     which have their place inside the project's `build` and the flag only
     moves them. The MSU-1 replacements are optional: without `--reemplazos`,
     each track comes from its MIDI.
   - `rm2k-snes-cartridges` passes the converter its own with
     `ambiente.como_flags` (`AL_CONVERSOR`), and `rm2k-snes-volume-ceilings`
     takes those same ones.
   - **`rom/justfile` translates.** It exports `ABL_GAME_DIR`, `ABL_RTP_DIR`,
     `ABL_SOUNDFONT` and `SHARED` with the same default values as
     before, and `ABL_CACHE` and `CARTRIDGES` empty if they're not set; it builds
     `al_conversor` and `al_armar` and passes them to each recipe that runs a
     tool. The replacements, which had no variable, are left as the
     `justfile`'s `reemplazos_msu`. `datos` and `datos-vuelta` use the
     exported one instead of repeating the value.
   - **ABL's tests read the variables themselves**, in
     `tests/harness/places.py`, and set `ambiente` with that: they're the ones the
     `justfile` exports. Without them —a standalone `pytest` without the
     variables— they stop saying which is missing, instead of having a second
     copy of the machine's values. `test_hover_tram.py` stopped
     repeating its own.
   - **Two of the tools' tests read a real SoundFont**
     (`test_musica_stream.py`, the envelopes): before, they fell back on
     `ABL_SOUNDFONT`'s by default. Now they receive it in `SOUNDFONT`, as
     Ditto its corpus in `DITTO_CORPUS`, and without the variable they're skipped with a
     message. `just -f tools/justfile pruebas` gives 120 and 2 skipped; with
     `SOUNDFONT=…`, 122.
   - `snes_convert.args_game_dir` starts as `None` and `_juego()` falls back on
     the environment's: the tests call `lideres_posibles` without going through
     `main`.
4. **The safety net: `test_ninguna_herramienta_sabe_de_abl`**, in
   `tools/pruebas/test_proyecto.py`, next to Tipa's because it shares
   how an environment variable is read. It fails if a `.py` in `tools/` reads
   any `ABL_*` variable, or writes `rom/` as a piece of a path: a
   string without blanks that starts with `rom/` or has `/rom/`. It doesn't look at the
   prose —docstrings, `help=`, the messages, which carry blanks— nor the
   `[rom]` section of the project file, which is a key name. And
   `project.py` stops being the exception in Tipa's: it no longer has the
   machine's values.
   - Shown to fail: with `os.environ.get("ABL_GAME_DIR")` added to
     `comun/ambiente.py` and `"rom/data/maps"` to `rpgmaker/fork.py`, both
     tests go red and name file and line; removed, green.
5. **The prose**, in its own commit: `tools/README.md` ("Cómo encuentran el
   juego"), `AGENTS.md` (the machine's values are set by `rom/justfile`,
   and how to run the two `SOUNDFONT` ones here), `README.md` and the indices of
   the two test folders.

## What changes for taro on the host

**Nothing in the recipes or in the variables**: `just cartridges`, `just build
release`, `just tests`, `just space`, `just patches`, `just ceilings`,
`just deliver` and `just video` are called the same way, and `ABL_GAME_DIR`,
`ABL_RTP_DIR`, `ABL_SOUNDFONT`, `ABL_CACHE`, `CARTRIDGES` and `SHARED` point
to the same things, with the same default values —now in `rom/justfile`—.
What changes:

* **A suite script run by hand**, outside `just`, no longer falls back on
  this machine's values: it has to be passed `--game-dir` and the rest, and
  run from inside `rom/` or with `--proyecto`. It stops saying what's
  missing.
* **A standalone `pytest`** of ABL's tests needs the variables
  set; through `just` the `justfile` sets them.
* **`just -f tools/justfile pruebas`** skips two if not given
  `SOUNDFONT`.

## Verified

* `SIN_CACHE=1 just cartridges` and the sha256 of `rom/build/` before touching
  anything and after each commit that touches what it builds (1, 2 and 3) and at the end:
  **995 files identical**, with the `.sfc`, `.msu`, `.pcm`, `.sym` and the
  `.inc` files inside. The two tracks that come from a replacement came from it
  both times.

      7a3c6483…a6552  build/release/abl.sfc
      905decd2…6cee   build/release/abl.msu
      fb6db844…0617   build/tests/special/prueba.sfc
      d9e96eab…1578   build/tests/special/prueba.msu

* `just tests`: 867, at each commit and at the end.
  `just -f tools/justfile pruebas`: 132 and 2 skipped, and 134 with
  `SOUNDFONT`. It was 122: the ten new ones are the step 4 safety net's.
* Without ABL: `rm2k-snes-cartridges --lista` from `/tmp` stops with "no
  encontré un rm2k-snes.toml en /tmp ni en ninguna carpeta de más
  arriba…"; from `rom/data/maps/` it finds the project; with `--proyecto`
  from `/tmp`, `rm2k-snes-cartridges --lista`, `rm2k-snes-patches
  --check` and `rm2k-snes-space release` work. The converter without `--game-dir` stops
  with "falta --game-dir…".
* By hand: `just space release`, `just patches-check`, `just ceilings
  --medir`, `rm2k-snes-msu` on `release`, and `video.py --help` with and without
  the variables.
* `test_abl_side.py` wasn't touched.
* `main` hasn't moved since `9e276429`: there was nothing to merge.

## What wasn't done

* **`just deliver` wasn't run**: its line was looked at with `--dry-run`.
  Nor the whole of `just ceilings` —it writes the table—, only `--medir`.
* **`raiz()` remains in two places that aren't for reaching ABL**: the
  directory where the converter and `ca65` run —the relative paths of the
  `.dbg` and of the `.inc` files come from there, and changing it changes the `.dbg`—, and
  `render_map`'s resource search, which finds nothing there. When
  the tools are another repo, both have to be thought through.
* **The pre-parsing of `--proyecto`** exists because `cartuchos` and `entregar`
  read the file on import. If they stop doing that, each `main`'s
  `parse_args` is enough.
* **The internal shape of `build/` and `patches/`** —`release/`,
  `tests/`, `manual/`, `auto/`— still belongs to the tools. If another
  game wanted a different one, it would mean more `[paths]` keys.
