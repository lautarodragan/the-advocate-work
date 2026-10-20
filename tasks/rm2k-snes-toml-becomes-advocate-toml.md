---
name: "rm2k-snes.toml becomes advocate.toml"
description: "Each game's project file is renamed advocate.toml; the tools keep their names"
type: tooling
status: testing
assignee: taro
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

**The rename.** In the-advocate, `FILENAME` is `advocate.toml`, with the
tests, help texts, layering test and `test-game/advocate.toml` in one
commit, and READMEs and `LAYOUT.md` in another. **No fallback to the old
name**: the ten projects are ours and moved together, and two names for
one file are two answers to "which one does it read". But `find` stops at
a directory with an `rm2k-snes.toml`, and `open` refuses it —"has
rm2k-snes.toml, which is called advocate.toml since 2026-10-20: rename
it"—, so an old checkout neither gets "found no advocate.toml" nor walks
past its game to another project further up; a test of its own, shown
red first. In the ports, the nine `git mv`, the root's `deliver` glob,
`tests/games.py`, the two tests that read a setting from the file, and a
dated section in `RENAMES.md`; the prose in its own commit. The book's
living pages and AGENTS.md follow; the research snapshots and the
engine-vs-RM2k data, frozen at their commit, keep the old name.

**Byte for byte.** Every game's cartridges built from scratch with the
local tools of 97ae388d on the ports at f3cff0e, and again with the
renamed tools on the renamed ports: the 34 `.sfc` and `.msu` —ABL's
`release` and its eight test cartridges, and the other eight games'
`release`— come out with the same sha256. `abl.sfc`:
`7ec61010ab940141c9925aa74ce53d52d17c0d39dfed7e5ea05627a5175c252e`.
`just test`, `just rust-test`, `just lint` and `just test-game` green in
the-advocate.

**Suites, on the final branches** (the-advocate 8f290c39, the ports with
the prose commit), with the local tools: ABL's `just tests`, 1576 passed
and 2 skipped; `just boot` from the ports root, 96 passed. To testing.

**When merging**: the three branches go together —tools that look for
`advocate.toml` cannot build a ports tree that still has `rm2k-snes.toml`,
and the other way round—, and `project` is compiled into every binary that
reads the project: `just install project cartridge convert patches
rm2k-snes-audio`, or everything. Nothing in this change moves a ROM byte.
