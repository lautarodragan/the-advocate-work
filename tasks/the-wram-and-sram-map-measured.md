---
name: "The WRAM and SRAM map, measured"
description: "How much of the 128 KB of WRAM and the 8 KB of SRAM is really used, by what, in release and in the whole game; and what it costs that the linker places everything instead of the hand-made map of bank $7E"
type: research
status: done
assignee: taro
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

## Progress (Hurón, 2026-10-15)

Read-only on code. Measured with the-advocate `6fa69781`, the ports at
`f015801`, over the eight games' `release` built in a worktree of the
ports, with the global tools. The deliverable is the research page
`research/2026-10-15-the-wram-and-sram-map.md` in the book, branch
`huron-memory-map` of the docs.

How it was measured, so it can be redone: the `.dbg` of each built
cartridge gives the linker's segments (`ZEROPAGE`, `BSS`, `FARBSS`,
`SWITCHES`) with every label's size and file, and every hand-written
constant with its value; `rm2k-snes-space` gives what each has left; the
hand-written map of `$7E2000`–`$7E7FFF` is `far_ram.s` and the `= $7E…`
constants of the other runtime files, with the game's constants
(`VARIABLES_N`, `ACTORS_N`, `EXP_K`…) substituted. The throwaway scripts
stayed in the scratchpad and are described in the page.

First findings:

* **The walls today are bank 0, not far RAM**: `ZEROPAGE` has 3 B left
  and `BSS` 97 B, in every game —they are the runtime's, not the game's—.
  Of the 253 B of zero page, only 55 are used as `[dp],y` pointers.
* **`FARBSS`**: 12 B left in ABL, 64 in Vampires Dawn, 216–312 in the
  rest. It is the 832-byte pool, not the console.
* **The hand-written map** holds ~19–21 KB of the 24 KB of
  `$7E2000`–`$7E7FFF`; 3.2–5.3 KB of that is slack inside fixed-size
  regions (`FAR_VARIABLES` 512 B for 176 variables, `FAR_SKILL` 256 B for
  32…), plus 309 B of holes between regions.
* **Vampires Dawn hits a real wall**: 256 variable slots (`FAR_VARIABLES`
  is 512 B), and 145 more variables have no slot: 224 events are left out
  for it (`degradations.json`). Its switch table is at 206 of 256 B.
* **SRAM is 32 KB, not 8**, since 2026-10-04: a bank per slot. ABL's save
  is 2,293 B of the 8,182 a slot holds; the other games 735–1,585 B.

## Done (Hurón, 2026-10-15)

The page is written, linked from `SUMMARY.md` and the research index,
and the book builds with the link checker at its baseline of 18
problems. Besides the findings above, it measured the upper halves —the
heaviest map takes 15,809 B of the 32 KB behind its grid, Vampires Dawn's
195; 18 maps across the eight games keep their bytecode in the cartridge—
and found one latent bug: nothing caps `ACTORS_N` against the 128 B of
`FAR_HP` and `FAR_SP` (ABL has 61 actors, 122 of 128 B).

The suggestions, ranked in the page: let the linker place the far RAM
map (3.5–5.6 KB back, `just space` says the total); widen the variable
slot to a word (unlocks Vampires Dawn's 224 events); evict the zero page's
non-pointer variables (60–100 B); move the DMA-only buffers out of bank 0
(up to 3,024 B of `BSS`); leave the save as it is. Drafts opened here for
the first four and for the actors bug:
`let-the-linker-place-the-far-ram-map`, `variables-are-capped-at-256-slots`,
`evict-the-zero-page-non-pointer-variables`,
`move-the-dma-only-buffers-out-of-bank-0`,
`nothing-caps-the-actor-count-against-far-hp`.

Nothing to install when merging: no code changed. The eight `release`
cartridges built in the worktree came out byte for byte equal to the ones
in the main checkout, so the numbers are those of `main` at the commits
above. Branch `huron-memory-map` of the book.
