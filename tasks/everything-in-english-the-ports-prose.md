---
name: "Everything in English: the ports' prose"
description: "Step 2 of the ports into English: comments, docstrings, READMEs, messages, and the names local to a file, by directory among five agents"
type: chore
status: done
assignee: taro
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

### Mulita: `abl/tests/abl`, `abl/tests/golden`, the root of `abl/tests`

Branch `mulita-english-prose` in the ports, from `4b15e20`.

* **A missed step-1 rename that had switched a check off**:
  `conftest._complete_stretches` looked the module up as
  `sys.modules.get("recorrido")`, a string no rename sees, so since step 1
  the check that every golden and pending line of a stretch was a photo
  never ran. Fixed alone, in its own commit; no `RENAMES.md` line, since
  the module's rename is already there.
* `README.md`: translated whole; the index names the same 172 paths.
  Its heading is now "Which test covers what", which
  `tooling/test_index.py`'s message and the abl `justfile` still cite in
  Spanish (Cardón's part).
* `golden/playthrough/pending.txt`: only its `#` lines.
* The harness keywords the tests pass (`tope=`, `a_cada=`, `mirando=`,
  `hasta=`, `cuadros=`, `apretar_a=`, `salta=`, `momentos=`…) stay: they
  belong to the harness (Calandria's part) and cross files. If the harness
  renames them, every caller in `tests/abl` breaks, and only running those
  tests shows it.
* Also left: the `music.json`/`effects.json` keys (`temas`, `nombre`,
  `pista`, `sonidos`), which are `rm2k-snes-audio`'s output; golden and
  photo names (one still Spanish: `lashe-plant-arden/01-cerrado.png`).
* Test ids changed in `test_msu.py` (`msu-a-msu` → `msu-to-msu`, …);
  no golden depends on them.
* For others at merge: `rpgmaker/test_cores.py:387` (Aguará) cites
  `EL_PUEBLO_LLENO` of `test_paradise.py`, now `THE_FULL_VILLAGE`; the
  docstring of `test_save_at_save_point.py` quotes the console's "the ROM
  did not reach tick N" in English, to follow Calandria's wording.
* Verified on the branch with ports `main` (`c5564d0`, Tijereta's part)
  merged in, global tools: `just tests` in `abl/`, **1285 passed** —with
  the stretch check back on—; `abl.sfc` sha256 `395367f6…860238`, the
  same; no golden touched. Nothing to install.

### Cardón: tooling, experiments, patches, menus, the root of `abl`, the root, the seven games

Branch `cardon-english-prose` in the ports, from `4b15e20`. Measured
before touching anything, in that worktree: `abl.sfc` is
`395367f6…0238`, the one given; the seven games' `release` `.sfc` and
`.msu` hashes are kept in `~/scratch/cardon/baseline-hashes.txt`, to
compare at the end.

* The root of the ports and the seven games, then `tests/` at the root,
  then ABL's justfile and `deliver.py`, each in its commit.
* `deliver.py` has no test: its template was checked by running it
  against a scratch `--shared`, and `update_msu` against a copy of
  today's `/shared/msu/README.txt`, which is in Spanish —its patterns
  accept both languages now—.
* Then ABL's README, project file, `pytest.ini`, `linter-exceptions.txt`
  and `data/README.md` (no part named it); then `patches/` and `menus/`;
  then `tests/tooling/`. The TOMLs' data was checked to parse the same
  with tomllib. The debug map's `Comment` commands
  (`patches/manual/new/Map0900.json`) are event data and stay in Spanish.
* Then `experiments/`, with a fork of mine. Step 1 had left three
  experiments broken —`fonts/mockups.py`, `menu-mode-5/build.py`, and a
  docstring of `zoom-mode-7/videos.py`— and they were fixed; none was run.
  `msu-port/port.s`'s labels went into English, checked byte for byte;
  what the assembly or another file reads keeps its Spanish name.
* For others at merge: `just video`'s examples keep `quieto:N`, which is
  what `tests/harness/video.py` parses today; if Calandria renames it,
  the justfile's comment follows. test_index.py quotes Mulita's "Which
  test covers what".
* Verified with ports `main` (`cdb3228`) merged in, global tools: `just
  tests` in `abl/`, **1285 passed**; `just boot` at the root, **9
  passed**; `abl.sfc` sha256 `395367f6…860238`, the same; the seven
  games' `release` `.sfc` and `.msu`, and ABL's `.msu`, byte for byte
  equal to the ones built before touching anything; no golden touched.
  `deliver.py` and the root `deliver` are not run by any test (see
  above), nor are the experiments. Nothing to install.

### Calandria: the names that cross files, last

After the five merges, on ports `c59fc10` and the-advocate `9f95b248`:
branch `calandria-cross-file` in both. Every rename has its line in the
ports' `RENAMES.md`, section "Step 2, the names that cross files".

* The harness's keyword parameters, with every caller (`b291efb`), by a
  script that renames at the definition and at each call resolved to a
  harness function by name; root `tests/` (`ScriptedPlay`) untouched, and
  the conftest's `session` fixture moves with `suite.session`. Calls that
  forward `**how` (`test_cores.py`'s `two_cores`) by hand.
* The values and keys other files read (`a01cbee`): `give_command`'s
  commands, `events.ANIMATIONS`'s and `scene.battler`'s keys,
  `places.flags("game")`, `.expected.png`, `still:N` with
  `abl/justfile`'s example.
* The photo `lashe-plant-arden/01-cerrado.png`, only in `pending.txt`
  (`b88fc13`).
* The keys `rm2k-snes-audio` writes —`music.json`, `effects.json`, the
  `--play` row— in the-advocate (`2393f0bc`), and their readers in ABL's
  tests (`734165d`). `tests/python.rs`'s hash of `music.json` moves: with
  the keys turned back the text gives the Python's hash, which its comment
  keeps.
* `abl/experiments/` (`b9ba6cc`): what each build writes and its assembly
  reads, the labels left, and the ROM titles. exhirom, menu-mode-5 and
  msu-port built before and after: only title and checksum differ; their
  emulator checks green. zoom-mode-7 does not build, before or after:
  draft [`zoom-mode-7-experiment-does-not-build`](zoom-mode-7-experiment-does-not-build.md).
* The sweep (every name token of the ports' Python against a list of
  Spanish words; justfiles; TOML keys) found one more, `test_cinematic`'s
  `en` (`b75902d`). Left on purpose: `videos.py`'s `escena*.mp4`, capture
  files already on disk, and the runner's `--toques` flags `suite.py`
  cites as history.
* taro's two extra items: the debug map's `Comment` commands in English
  (`Map0900.json`, same line count per block; what the player reads was
  already English), and two dead citations (`patches/manual/README.md`'s
  pruning test, now `pruning_keeps_the_slots_only_an_event_names` in
  `convert/src/chipsets.rs`; `test_auditorium_routes.py`'s removed
  divergence). A scan for backticked test names and old doc paths that
  exist nowhere found no other.

Verified with the-advocate's branch `rm2k-snes-audio` in the PATH
(`install-local`): `just tests` in `abl/`, 1285 passed, before and after
the debug map; `NO_CACHE=1 just cartridges --force`, every `.sfc` and
`.msu` of `build/` equal to the cached build; `just boot`, 9 passed; the
seven games' and ABL's `release` `.sfc` and `.msu` equal to the hashes
measured before step 2; `abl.sfc` `395367f6…860238`; `just test` in
the-advocate, 27 passed, and `just crate-test rm2k-snes-audio`, with and
without `SOUNDFONT`, green. No golden touched.

**To install when merging**: `just install rm2k-snes-audio` from
the-advocate, **before** running ABL's suite: the ports' tests read the
new keys.
