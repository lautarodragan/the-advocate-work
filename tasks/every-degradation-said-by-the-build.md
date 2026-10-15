---
name: "Every degradation, said by the build"
description: "The converter writes, per cartridge, every place where it compiles a command undone or loses part of it —map, event, page, command, what is lost—, machine-readable, for any game"
type: feature
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-15: The Book of Three is a game taro has never played
and does not want spoiled, so they cannot tell when something is missing
—an animation not drawn, a fade ignored—. The plan: the build says every
place where it degrades, and an agent checks each one against the original
([`book-of-three-against-the-original`](book-of-three-against-the-original.md)).

Today some of those degradations are converter warnings, some are only in
the book's divergences and "what the compiler ignores silently", and some
are said nowhere. What it asks for: one list, written by the build in
`build/<cart>/`, complete by construction —at the place in the compiler
where each thing is lost, not a list kept by hand—.
