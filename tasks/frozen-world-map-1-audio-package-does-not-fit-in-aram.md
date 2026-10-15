---
name: "Frozen World's map 1: its audio package does not fit in the ARAM"
description: "With map 1 (\"Battle Screen\") brought back into The Frozen World, the build now gets past the code and stops at the audio: the samples of package 1 do not fit in the ARAM even at the minimum, with the package already 25,987 bytes over"
type: bug
status: draft
agents: [Carpintero]
---

Seen by Carpintero on 2026-10-15, on the branches `carpintero-rom-code`
(the-advocate, on top of `huron-tp` and main `978c0d25`; ports, on top of
`huron-tp` and main `08551c6`).

**How to see it**: in `frozen-world/rm2k-snes.toml` of the ports, take
map 1 out of `excluded` and run `just cartridges release` in that
directory. It stops with:

    rm2k-snes-audio: the samples of 1 (30546 of -25987 B) do not fit in the ARAM even at the minimum

**What changed to get here**: until that branch, map 1 stopped first at the
hero's flash (draft `flashing-hero-shares-a-palette-with-an-npc`, which
Hurón's `huron-tp` turned into a warning after a teleport) and then would
have stopped at its code; now its 347,625 bytes of bytecode go to the
cartridge in six blocks of up to a bank (`map-streams-that-dont-fit-in-wram`),
and the next thing it hits is the audio.

**What is known of the cause**, not looked at further: the free space is
negative before any sample, so what the package carries besides the
samples —its songs, which map 1 picks from a chain of `PlayBGM`, one per
battle, read in the data— is already more than the ARAM. Read in the data,
not measured: which songs and how big.
