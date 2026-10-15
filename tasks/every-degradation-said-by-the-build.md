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

## Hurón, 2026-10-15

Starting from the-advocate `fa9d1a14` and the ports `0ca371b`, branches
`huron-degradations` in both.

The plan: the event compiler carries a collector of losses in its `Ctx`,
with a stack of where it is —the map's page, or the common event or troop
page, and the bodies a `CallEvent` pastes inside—; each arm that compiles
a command with less than RM2k records there, with a `kind` slug. A page
that does not compile takes its losses back with it, as it takes its
texts back, so only what reaches the cartridge is listed. The answer
carries them, and the converter adds its own and those of its stages
(Wally's notes, the ChipSet animation that does not fit) and writes
`build/<cart>/degradations.json`, sorted.
