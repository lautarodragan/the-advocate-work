---
name: "rm2k-snes.toml becomes advocate.toml"
description: "Each game's project file is renamed advocate.toml; the tools keep their names"
type: tooling
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-10-20: rename each game's `rm2k-snes.toml`, in the ports,
to `advocate.toml`. They also thought of renaming the tools without a
name of their own —`rm2k-snes-*`, and maybe `rm2k-*`— and decided
against it for now: "I don't want to associate one category of tools
with the project and not another". Only the file.

**How**: the mechanical rename alone first —`git mv` in every game, the
tools look for the new name (`rm2k-project` finds it), the old name in
the ports' `RENAMES.md`, every ROM byte for byte equal—; then the prose
that names it, in its own commits: comments, READMEs, the book,
AGENTS.md. History is not rewritten. Wait for
[`abl-map-11-back-to-the-original`](abl-map-11-back-to-the-original.md)
(Mulita), which edits ABL's —merged on 2026-10-20, with
[`a-debug-screen-in-the-pause-menu`](a-debug-screen-in-the-pause-menu.md)
(Tijereta), which edited all nine.

## Log

**2026-10-20, Carpintero.** Branches `carpintero-advocate-toml` in
the-advocate (from 97ae388d), the ports (from f3cff0e) and the book (from
568eace). The literal name lives in one place in the tools,
`FILENAME` in `rm2k-snes/project/src/project.rs`; the rest are tests that
write a project to disk, `--project` help texts, the layering test
(`tests/test_layers.py`), the ports' root `justfile` (`deliver` globs
`*/rm2k-snes.toml`), `tests/games.py` (which finds the games by that file)
and two ports tests that read the file to know a setting. Nine games in
the ports plus the-advocate's `test-game/`.

Baseline: every game's cartridges built from scratch with the local
tools of 97ae388d (`project cartridge convert patches rm2k-snes-audio`,
the only crates that compile `rm2k-project`), hashed, to compare against
the same build after the rename.
