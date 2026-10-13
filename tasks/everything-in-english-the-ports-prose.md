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
