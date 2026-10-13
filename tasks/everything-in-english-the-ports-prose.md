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
