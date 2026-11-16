---
name: "The debug screen in the .msu"
description: "Move the debug screen's data (its precomposed font and the rest, ~146 KB in ABL's release) out of the ROM and into the .msu: with MSU-1 the pause menu offers it, without it the option is not there and the game is whole"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, on 2026-11-16, after [`abl-room-for-still-events-in-the-background`](abl-room-for-still-events-in-the-background.md) (Mulita's study):

> The debug screen could go to the .msu whole. I almost always test the
> games with the .msu (both in emulators and on the FxPak). And it isn't
> needed in the final release, to enjoy the game. I suppose it is needed
> if, eventually, we want to use EasyRPG Editor + The Advocate as an
> engine to create SNES games (which wouldn't be bad at all, but isn't in
> my current goals).

The study measured `debug_screen = false` at −146,168 B (release in 122
banks); the screen's font is one of three precomposed fonts.

Done means: with `debug_screen = true` the screen's data goes to the
.msu (read through the data port, as the battle backgrounds), the ROM
keeps only what it needs to ask; with MSU-1 the screen works as today,
without it the pause menu does not offer it; gain measured; ROM tests
with and without MSU-1; the book's `internals/the-msu-file.md` updated.

## Log
