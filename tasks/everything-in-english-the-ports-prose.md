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
