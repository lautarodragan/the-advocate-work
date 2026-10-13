---
name: "Everything in English: the ports' prose"
description: "Step 2 of the ports into English: comments, docstrings, READMEs, messages, and the names local to a file, by directory among five agents"
type: chore
status: doing
assignee: Aguará
agents: [Aguará, Tijereta, Calandria, Mulita, Cardón]
---

Step 2 of [`everything-in-english-the-ports`](everything-in-english-the-ports.md),
whose step 1 (the names that cross files) Chajá merged on 2026-10-12, with
`RENAMES.md` at the root of the ports. Chajá counted 18,268 lines of prose
left and proposed this split, which is the one used:

* **Aguará**: `abl/tests/rpgmaker`, files a–m.
* **Tijereta**: `abl/tests/rpgmaker`, files n–z.
* **Calandria**: `abl/tests/harness`.
* **Mulita**: `abl/tests/abl`, `abl/tests/golden`, and the files at the
  root of `abl/tests`.
* **Cardón**: `abl/tests/tooling`, `abl/experiments`, `abl/patches`,
  `abl/menus`, the root of `abl` (justfile, README, `rm2k-snes.toml`,
  `deliver.py`), the root `tests/`, the root of the ports, and the seven
  games.

What is in scope: comments, docstrings, markdown, justfile and toml
comments, messages the harness and the recipes print, the texts recipes
write (`README.txt`), and names local to one file —locals, parameters,
module constants, dict keys private to a module, shell variables in a
recipe—. Names used from other files were step 1 and stay; if one was
missed, it is renamed in a commit of its own, with its line in
`RENAMES.md`, and the others are told at merge.

Verification for each part: the suite with the same count, every ROM byte
for byte equal, goldens untouched.

## Log

### Calandria: `abl/tests/harness/`

Branch `calandria-harness-english` in the ports, from `4b15e20`, with
main merged (Aguará's and Tijereta's parts). 30 of the 42 files had
Spanish; `emulator/`, `lcf.py`, `rm2k.py`, `engine.py`, `resources.py`,
`snes_format.py`, `stage.py`, `screen_stage.py`, `fork.py`,
`image_stage.py` and `render_map.py` were already English. Translated in
six groups, one commit each: prose, messages, private dict keys
(`scene.py`, `animation.py`'s cache, `events.py`'s timings) and the names
local to each file, including parameters of public functions that no
caller passes by name (grepped across the ports before each one).

**Left in Spanish, on Hornero's word, because other files use them**: the
keyword parameters tests pass by name and the keys a test reads. The
whole list, with the English picked, is in Calandria's report; a script
that renames each keyword at its definition and at every call site,
resolving the callee by name and skipping files that define a function
of the same name, did it once and was reverted before committing. Its
traps, for whoever does that commit: `tests/test_book_of_three.py` calls
`walk_to(hasta=)` and `wait(tope=)` on `tests/play_script.py`'s
`ScriptedPlay`, not on the harness; and the `session` fixture of
`abl/tests/conftest.py` takes `en=` itself and forwards it, so its
callers and its own parameter move together.

One finding, not fixed: [`video-read-slowly-breaks-wait-for-control`](video-read-slowly-breaks-wait-for-control.md).

The first run gave 1284: one of the six groups had renamed
`stretch_sorbe.play_case`'s `tope`, which `test_playthrough_chapter_golden.py`
passes by name; it went back, in its own commit, and a script that diffs
every harness signature against `4b15e20` and looks for keyword calls to
the names that left found no other. Verified on the branch merged with
`main` (`d922a44`), global tools: `just tests` in `abl/`, 1285 passed;
`just boot` at the root, 9 passed; `abl.sfc` sha256 `395367f6…860238`, as
before; no golden touched.

### Tijereta: `abl/tests/rpgmaker`, n–z

"n–z" is read on the name after `test_`, since every file there starts
with it: 48 files, from `test_number.py` to `test_walk_golden.py`, about
6,600 lines. Branch `tijereta-english-prose` in the ports, from `4b15e20`.
Four commits, one per stretch of the alphabet (`94b257c`, `009374d`,
`8713d58`, `c7744ce`). Only names local to each file were renamed; no
file of the part is imported from elsewhere. Docstring tables that listed
the old Spanish case ids now list today's; two parametrize changes move
node ids only (`test_stack`: `parallels`, `slots`; `test_title_golden`:
`held`, `taps`).

Missed by step 1, and **not** renamed here, because they are defined in
the harness (Calandria's part) and called from every part, so renaming
them in one branch would conflict with all five: `Session.run`'s
`cuadros`, `apretar_a`, `sosteniendo`, `toques`, `tocar`;
`run_hardware`'s `cuantos`, `toques_hardware`; `save_in`'s `cancelar`,
`espera`; `go_to_map`'s `cuadros`; `session`'s `en`; and
`Fight.give_command`'s keys `"atacar"`, `"defender"`, `"habilidad"`. The
`"sonidos"` key of `effects.json` is written by the converter in
the-advocate. Best done once, after the five merges, with its lines in
`RENAMES.md`.

Verified on the branch merged with `main` (`4b15e20`, unmoved), global
tools: `just cartridges` and `just tests`, 1285 passed; `abl.sfc`
sha256 `395367f6…860238`, as before; no golden touched.

### Aguará: `abl/tests/rpgmaker`, a–m

"a–m" read as the name after `test_`: 66 files, 12,689 lines, from
`test_action_with_route.py` to `test_music_writes.py`. Branch
`aguara-english-prose` in the ports, from `4b15e20`. Split in five groups
by size, each translated in parallel and committed on its own.

Five commits, `7f9153f`..`b7c65a6`. Golden, case and pytest-id strings
untouched, except two parametrize argument names (`toques` is `taps`)
whose auto ids no golden uses. Verbatim Spanish quotes stay. Ran once at
the end, with the global tools: `just cartridges`, `abl.sfc` byte for
byte (`395367f6…`), and `just tests`, 1285 passed; no golden moved.

Cross-file, left as they are: keyword arguments and keys the harness
declares in Spanish, which step 1 missed and Calandria's part may rename
—`que=`, `cantidad=`, `niveles=`, `eligiendo=`, `toques_hardware=`,
`apretar_a=`, `sosteniendo=`, `tocar=`, `tope=`, `cuadros=`, `salta=`,
`en=`, `espera=`, `paquetes=`, `herencia=`, `aire=`, `fin_de_la_aram=`,
the `"atacar"`/`"defender"`/`"habilidad"` commands of
`Fight.give_command`, and `info["clave"]`/`info["alto_rm"]`—: if they are
renamed, these calls follow at merge. And the keys of the `music.json`
the tools write (`temas`, `nombre`, `largo`, `huella`, `recortes`), which
are the-advocate's output. Renamed here and cited in the harness's
comments: `Grabador` (`Recorder`) and `sonido_muestra` (`sample_sound`).
