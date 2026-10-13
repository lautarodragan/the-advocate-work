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
