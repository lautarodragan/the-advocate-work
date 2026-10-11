---
name: "Local tools per worktree"
description: "Each worktree's own bin/, first in just's PATH, instead of ejecutable.py; Rust is compiled only if the agent touches that project"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-29, after step 1 (`el-justfile-no-sabe-que-existe-python.md`):
the problem is the one `npm link` tries to solve, with N sub-agents in
parallel modifying the tools often. What was agreed:

- each worktree has its own `bin/`, ignored by git, which the `justfile`
  puts first in the `PATH` if it exists: what isn't there comes from the global one;
- Python is linked whole (the eight executables), because it costs nothing and
  each script resolves its modules from its real checkout;
- Rust is installed there **only for the project the agent modifies**. From
  taro: "it's important that no subagent runs an unnecessary Rust
  compilation. They're costly";
- `tools/comun/ejecutable.py` goes: it resolved the same thing implicitly;
- on merging, whoever merges reinstalls in the global only the Rust
  the branch touched.

## What was done (Espinillo)

* `just herramientas-locales [proyectos…]` builds `.herramientas-locales/bin/`
  in the worktree: the eight scripts always, and `cargo install --root` only of
  the named projects. Without names it compiles nothing; a name that isn't a
  project stops before compiling. It refuses in the main checkout
  (`git-dir` equal to `git-common-dir`).
* The `justfile` exports `PATH` with that `bin/` first if it exists
  (`path_exists`). In `main` it doesn't exist.
* `just herramientas [proyectos…]`: with names, only those in Rust plus the
  Python symlinks; without names, everything, as before.
* Both use `_instalar`, which joined the list of tool
  recipes in `test_lado_de_abl.py` with what used to be inside
  `herramientas`.
* `just cuales` prints which executable the checkout resolves for each one.
* `tools/comun/ejecutable.py` went away with its calls; `comun/` went back to its
  row in `tools/README.md`.
* AGENTS.md, "Sub-agentes": what the agent does on starting and what the
  merger reinstalls.

**The name, `.herramientas-locales/`**: at the root and not in `tools/`, so
the fingerprint —which looks at `tools/*/*.py`, `rom/src/` and the binaries the
PATH resolves— doesn't walk it, and neither does the grep test —it looks at `parches/`, `data/` and
`pruebas/`—. Hidden, because it isn't part of the tree. Inside is what
`cargo install --root` leaves: `bin/`, `.crates.toml` and `.crates2.json`.

**Without the `bin/`, a worktree refuses.** It would run `main`'s scripts,
which build in `main`'s `rom/build/`: it would stomp on its cartridges without noticing.
The coordinator flagged it before merging, and it was solved with
`_herramientas_del_checkout`, which `cartuchos`, `build`,
`pruebas*`, `espacio`, `parches`, `parches-check`, `techos`, `entregar` and
`video` depend on. It passes in the main checkout (`git-dir` equal to the common one) and in a
worktree with `.herramientas-locales/bin/`. `herramientas-locales` and `cuales`
don't depend on it. Measured: without the `bin/`, `just cartuchos`, `just pruebas`,
`just espacio release` and `just video` exit 1 with the message, and `just
cuales` works; in the main checkout the recipe exits 0; after `just
herramientas-locales` —without Rust— `just cartuchos` builds and `just pruebas` gives
973 green, with `abl.sfc` and `prueba.sfc` the same as before.

**`cargo` outside installing**: it's only called by `herramientas`, `_instalar` and
the Rust `*-pruebas`, which are its tests. No `.py` in `tools/` or in
`pruebas/` calls it (grep).

### Verified

* **ROMs**: `SIN_CACHE=1 just cartuchos` in this worktree, with its `bin/`
  —the eight scripts and `lz2` local—: the 47 files in `release/` and
  `tests/special/` with the same sha256 as before step 1 (`abl.sfc`
  `7a3c6483…6a66552`).
* **`just pruebas`**: 973 pass.
* **Resolution**, with `just cuales`:
  * this worktree without `bin/`: everything in `/usr/local/bin`, no error;
  * after `just herramientas-locales`: the eight local, Rust global;
  * after `just herramientas-locales lz2`: `lz2` local too;
  * a copy of the `justfile` in a directory without `bin/` —what `main` sees—:
    everything global.
* `just herramientas-locales foo` stops without creating the directory;
  `_no_en_el_principal` run in the main checkout exits 1.
* **Rust was compiled only once**: `lz2`, the smallest (one crate, no
  dependencies; `protocol` has 34 and 837 lines against 700).
* The global wasn't touched: the symlinks in `/usr/local/bin` still point to the
  main checkout, with the date when the coordinator installed them.
  `just herramientas lz2` was tried only with `--dry-run`.

**What wasn't tested**: `just herramientas <proyecto>` for real against the
global, and nothing on the host (`CARGO_ROOT=~/.cargo`). Nor a real second
worktree: "from `main`" was tested with the copy of the `justfile`, not running in
the main checkout, which nobody wanted to touch.
