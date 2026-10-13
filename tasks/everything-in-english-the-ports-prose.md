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
* The harness keywords the tests pass (`tope=`, `a_cada=`, `mirando=`…)
  stay: they belong to the harness (Calandria's part) and cross files.
