---
name: "The WRAM and SRAM map, measured"
description: "How much of the 128 KB of WRAM and the 8 KB of SRAM is really used, by what, in release and in the whole game; and what it costs that the linker places everything instead of the hand-made map of bank $7E"
type: research
status: doing
assignee: Hurón
agents: [Hurón]
---

taro, on 2026-10-14, worried by the far RAM pool being nearly full (79 B
left in release, ~20 B in the whole game, after Tijereta and Hurón): "are
we going to reach an insurmountable limit?"

What Hornero answered, unmeasured: the 79 B are of `FARBSS`, an 832-byte
stretch chosen by hand (`FAR_POOL_START`/`FAR_POOL_SIZE` in
`rm2k-snes/cartridge/src/banks.rs`), not the console's limit. Most of bank
`$7E` is a map placed address by address in `runtime/far_ram.s` before the
linker placed anything, with gaps nobody uses (Tijereta saw
`$7E7D00`–`$7DFF` free); bank `$7F` holds the large maps' grid and the
battle. The real ceilings are the 128 KB and, probably first, the 8 KB of
the save.

To measure, without touching code: the real map of the 128 KB by owner in
release and in the whole game, what is free, a whole-game save's size
against the SRAM, and the cost of a plan where the linker places
everything, so `just space` says what is left in total.

taro, on 2026-10-15: launched, with suggestions for improvements on top
of the measurement. It came up asking whether map-only switches could
save RAM: they cannot matter —one bit per switch, 256 B at most—, so the
question is what does weigh.
