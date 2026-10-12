---
name: "ABL's project file"
description: "Steps 3 and 4 of the plan: ABL's knobs move out of the code into rom/rm2k-snes.toml, and cartuchos.py stays as the mechanism that reads it"
type: refactor
status: done
assignee: taro
---

Steps 3 and 4 of the plan in
[`docs/research/el-mapa-de-las-herramientas-de-python.md`](https://lautarodragan.github.io/the-advocate-docs/research/el-mapa-de-las-herramientas-de-python.html) (§4, and §3's table
with the hooks). taro authorized Hornero on 2026-09-29 to decide the open
points without waiting for him. What was decided:

- **The file is `rom/rm2k-snes.toml`**: it's named after the suite of tools
  that reads it, like `Cargo.toml`, and lives at ABL's root.
- **The keys are in English** —they're the tools' interface, which will be in
  English, and renaming them later would break every game's file—; **the
  comments are in Spanish**, because the file is ABL's.
- **One knob per commit, with the same value**, and the ROM byte for byte
  identical on each one.
- **`cartuchos.py` stays as the mechanism** that reads the file and builds
  (`rm2k-snes-cartridges`); ABL's stuff —which maps, which cartridges, which
  cases— moves to the file. The cache key is still the hash of the binaries
  until there are real versions.
- **The engine limits measured on ABL** (the research's class c) do **not**
  go into the file: they stay in the code with a comment saying they were
  measured against A Blurred Line (taro's decision).

## What was done

Each knob's safety net: `SIN_CACHE=1 just cartuchos` before touching anything
and after each one, with the sha256 of all of `rom/build/` except `cache/`,
the `.o`s, `sello.txt` and `conversor.log`, and the `.dbg`s without `mtime`.
**The `.sfc`, `.sym`, `.msu`, `.pcm` and `musicdata.inc` never changed.** The
only thing that moved: the two `mapdata.inc`, because of the identity block
(six lines, two `.define`s), and hence the `.dbg`s, in line numbers and file
sizes; the symbols, with their values, are the same.

1. **The file and its reader.** `rom/rm2k-snes.toml` and
   `tools/comun/perillas.py`: `perillas.valor("maps", "below", tipo=int)`
   fails with the key's name if it's missing, or if the type isn't right;
   `perillas.ascii` measures the texts that go into the ROM. The whole file
   goes into the cartridges' fingerprint and into what `entregar` requires to
   be committed.
2. **The cartridges.** `[maps]`, `[debug]`, `[cases]` and `[cartridges.*]`.
   cartuchos.py reads the file and builds the flags in the usual order, so the
   stamp comes out the same. Map 900 comes from `fork.nuevos()`: the debug one
   is the only new map, and if there were another it refuses. A new cartridge
   is one more table.
3. **The identity.** `[rom]`: `name`, `title`, `sram_signature`,
   `msu_data_signature`. The converter emits `ROM_TITULO` and
   `SRAM_MAGIA_TEXTO` as `.define`s at the start of `mapdata.inc` —outside
   `RODATA`, which the bank layout moves—, and `cabecera.s` and `partida.s`
   use them with `.byte` and `.strat`. The signature is still `ABLS`.
   `entregar.HUELLA_MSU` comes out the same, letter by letter.
4. **Graphics, battle, jumps and `--map-id`.** `[graphics]`, `[battle]` and
   `[music] jumps_that_never_happen`. `--map-id` no longer has a default:
   `main` enforces it and not `required`, because the parser is reused for
   each `--caso`.
5. **The audio tables.** `[sound_effects]` and `[music]`. snes_music exposes
   them as functions —`se_enteros()`, `temas_aparte()`…— and eventos.py and
   snes_convert.py read them too.
6. **The engine limits** (class c): a comment saying they were measured
   against A Blurred Line on each Python constant. The three in the runtime
   already said so and weren't touched, so as not to move the `.dbg`.

**It's read on use, not on import**, except in cartuchos.py, which is the
game's orchestrator: `test_las_herramientas_se_importan_sin_un_juego` imports
the converter with the file pointing at one that doesn't exist. And
`rom/pruebas/herramientas/test_perillas_repetidas.py` fails if a tools `.py`
writes a text from the file again: on the tree from before this, it found the
sound effect tables, `vswar`, `ABLBackdropSJ08`, `savept`, `Future1`,
`nobodyhere`, `test-special` and `mapa-de-debug`.

## What wasn't done: the environment (step 7 of the assignment)

The tools still read `ABL_GAME_DIR`, `ABL_RTP_DIR` and `ABL_SOUNDFONT` through
`comun/proyecto.py`. How I'd do it:

* `recursos.GAME_DIR`, `recursos.RTP_DIR` and `snes_samples.SOUNDFONT` are
  module globals used **inside** functions, not only as defaults: `escena.py`
  and `snes_music.py` read `recursos.RTP_DIR` without it being passed, and
  `snes_music` reads `snes_samples.SOUNDFONT` in three places. Passing the
  value as a parameter touches some forty signatures. The cheapest thing that
  respects the rule is **a single place that gets configured**: `recursos` and
  `snes_samples` with no value until each executable's `main` sets them from
  `--game-dir`, `--rtp-dir` and `--soundfont`, and failing clearly if someone
  reads them unset. Then, if worth it, they become parameters one at a time.
* The executables that need them: `rm2k-snes-convert` (already has
  `--game-dir`), `rm2k-snes-msu` (already has `--soundfont`),
  `rm2k-snes-cartridges`, which passes them to the converter, and
  `rm2k-snes-volume-ceilings`.
* `rom/justfile` translates: `--game-dir "${ABL_GAME_DIR:-…}"` and company,
  in the recipes that call those four. The machine's default stays in ABL's
  justfile, which already repeats it (`datos`, `ditto-*`).
* ABL's tests that read `GAME_DIR` (about twenty) read the variable
  themselves: they're on ABL's side. `tanda` and `conftest.py` are the place.
* The cartridge's `huella` doesn't cover where the game is —it doesn't today
  either—, so changing `--game-dir` doesn't make a cartridge stale: same as
  now.
* `test_proyecto.py` goes on to forbid `os.environ` of those three in all of
  `tools/`, `proyecto.py` included.

## What remains open

* **The version of the suite of tools** that the game declares in the file,
  and the `verificar-herramientas` recipe: they're part of the decision, but
  not of this assignment.
* **`release` is a name the tools require**: it's the cartridge that carries
  the ROM's name, the MSU-1 tracks and all the cases. It could be a key
  (`[rom] played_cartridge`), but today `entregar`, `parches` and the suite
  name it too.
* **cartuchos.py's module names** —`MENOR_A`, `CARTUCHOS`, `FUERA`— stayed
  because of the suite, which reads them. Renaming them or having the suite
  read the file is another change.
