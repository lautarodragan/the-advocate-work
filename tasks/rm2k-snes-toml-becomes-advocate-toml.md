---
name: "rm2k-snes.toml becomes advocate.toml"
description: "Each game's project file is renamed advocate.toml; the tools keep their names"
type: tooling
status: todo
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
(Mulita), which edits ABL's.
