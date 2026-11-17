---
name: "The debug screen in the .msu"
description: "Move the debug screen's data (its precomposed font and the rest, ~146 KB in ABL's release) out of the ROM and into the .msu: with MSU-1 the pause menu offers it, without it the option is not there and the game is whole"
type: feature
game: abl
status: done
assignee: taro
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

## Work log (Tijereta)

Taken on 2026-11-16 from the-advocate a83c4a12, the ports ff7ac5b and the
book's main, on branches `tijereta-debug-msu`.

### The plan, and why not the obvious one

The screen's data in ABL's `release`: its font precomposed, `dbg_pre0` to
`dbg_pre7`, eight phases of 97 glyphs of 156 bytes, 121,056 B; the names,
`dbg_data`, about 19.5 KB (29 KB in Vampires Dawn); the windows' tilemap
and the twenty bars, 4,352 B; the windows' tiles and colours, under a KB in
ABL; the advances and reaches, a few hundred bytes.

**The font cannot be loaded whole**: 121 KB is almost all of WRAM. While
the screen is open the free WRAM is `LZ2_BUFFER` up to `ANIM_DRAWINGS_END`,
$7F0000-$7F7FFF —`back_to_map` rebuilds all of it when the pause menu
closes, and the menu does not open over a big picture—, of which the wide
stage already takes 4 KB. So:

* **The spill region, forced**: the packing's `.msu` region —until now
  only for `[rom] msu = "required"`— takes the pieces an emitter marks
  `.msu_only` in any cartridge: they go to the `.msu` always, and the ROM
  keeps their label as bank `MSU_SPILL_BANK` and unit, as for Vampires
  Dawn's spilled streams.
* **The font is read a letter at a time** through the data port, into a
  cache of glyph-phases in that WRAM: a miss is a seek and 156 bytes by DMA.
* **The names go per page** —a hundred switches or variables, its table and
  its strings—, loaded into one of two WRAM buffers when the page changes:
  the text layer keeps a by-reference run as an address, so a page never
  reuses the buffer the screen still shows.
* **The windows' tilemap and bars** are loaded into WRAM when it opens; the
  windows' tiles and colours are read and uploaded then.
* **Without MSU-1** —or with another build's `.msu`— the pause menu does
  not offer the row: `menu_rows_build` asks the port, each time the menu is
  drawn.

### What was done

* **The packing**: `.msu_only`, a mark next to `.msu`. A piece with it goes
  to the region always —in any cartridge, `MSU_REQUIRED` or not—, before
  the halving picks among the `.msu` ones; the region exists then in a
  cartridge that does not need the MSU-1, with only those, and its
  signature goes to the ROM as for Vampires Dawn. Without any, nothing
  changes. Four tests in `rm2k-snes-cartridge`'s `tests/banks.rs`, three
  of them red on the code before.
* **The emitter**: the eight phases of the font, a piece per page of names
  —the format changed: a block per hundred, its table of offsets and its
  strings, the variables' slot plus two so that zeros say "none"—, the
  windows' tilemap and bars as one piece, their tiles and colours as
  another, all `.msu_only`; in the ROM, a table of each page's unit.
* **The runtime**: `dbg_available` for the pause menu's row; `dbg_seek`
  and `dbg_read` —a seek with `msu_data_seek`'s cap and a DMA from the port
  through the WRAM's—; `page_load`, `frame_load`; `dbg_glyph`, the cache
  of glyph-phases that `tl_glyph_hi` calls instead of computing the ROM
  address. Its RAM is in `LZ2_BUFFER` after the wide stage: far RAM has
  12 B free in ABL's `release`, and the first try, with the screen's new
  variables in `dbg_ram`, overflowed it by 4.
* **A page flip waits for the text** to be on screen, `DBG_FLIP`: the
  text layer keeps a by-reference run as an address and compares records
  by it, so the buffer the screen still shows must not be overwritten.

### What it gains, measured

With `just space release` in each game, the tools at a83c4a12 against the
branch's —global `convert` and the rest the same for both—. Data is what
the data banks leave free, whole banks, halves and gaps; the code is 648 B
more in `FAR3` (`$C1`) in every game, and bank 0, bank 1 and far RAM do not
move:

| game | data free before | after | gained |
|---|---|---|---|
| A Blurred Line | 656 | 146,064 | 145,408 (126 banks used, now 122) |
| The Book of Three | 4,570,943 | 4,703,521 | 132,578 |
| Desert Nightmare | 1,232,940 | 1,375,765 | 142,825 |
| Doom's 2 | 5,026,736 | 5,154,912 | 128,176 |
| El Dorado | 6,323,697 | 6,459,130 | 135,433 |
| The Frozen World | 3,279,875 | 3,432,382 | 152,507 |
| Sunset over Imdahl | 2,031,135 | 2,159,275 | 128,140 |
| Vampires Dawn | 414 | 1,997 | see below |
| Zounds | 3,227,597 | 3,372,336 | 144,739 |

**Vampires Dawn** needs the MSU-1 and its ROM is still full: what the
screen frees, the packing fills with the game's own streams, which come back
from the `.msu` —743 pieces read from the port before, 713 after, 30 of them
the screen's—: about sixty fewer of its maps' streams through the port.
Its `.msu` grows by 1 KB.

ABL's packing sends 25 pieces, 145,755 bytes: the eight phases, fifteen
pages of names, the frame and the windows. The font's cache holds 120
letters in ABL.

**Knob off, byte for byte**: El Dorado's `release` with `debug_screen =
false`, built with the tools at a83c4a12 and with the branch's, gives the
same `.sfc` and the same `.msu`.

### Verified

* ABL's `just tests` with the branch's tools, on the ports ff7ac5b: green
  but for the goldens below, after two rounds. New:
  `test_without_the_msu_1_the_menu_does_not_offer_it` —red on the tools at
  a83c4a12: 6 rows with and without the MSU-1—; the walk over every range,
  `test_no_range_runs_out_of_quads`, now compares each page's names and
  every letter in the cache with the `.msu`'s bytes. The debug screen's
  tests run with the MSU-1, and its seven goldens did not move.
* **Fourteen goldens with the pause menu open lose the Debug row**, 154
  pixels each and all in the last row's box: the suite has no MSU-1. The
  menu column is again what it was before the row existed. Side by side in
  `/shared/captures/2026-11-16-debug-screen-msu/`.
* Goombario caught a branch on a `plp`'s flags in `compose`: rewritten
  without the `php`/`plp`.
* `just boot` at the ports' root, the nine games, with
  `test_debug_screen_room.py` now with the MSU-1: 152 passed, one red,
  `test_gatestreet_and_the_statue` (804 pixels on
  `sunset-over-imdahl-gatestreet-the-man`), **red the same on the tools
  at a83c4a12** and the ports ff7ac5b: not this change.
* `just test` in the-advocate; `cargo test` of `rm2k-snes-cartridge`,
  `-mapdata` and `-screens`; clippy of `cartridge` and `screens`. `just
  lint` is red on this machine on files this does not touch: the draft
  [`just-lint-is-red-with-the-local-toolchain`](just-lint-is-red-with-the-local-toolchain.md).

**What no test runs**: a seek that runs out of time —a page with no names,
a blank letter, the windows without tiles—, because no core of the suite
seeks slowly; the FX Pak, where a letter not in the cache is a seek outside
its 16 KB buffer, an SD card read, **not measured**; Mednafen, where each
is one or two frames, and opening the pause menu costs two seeks more with
the MSU-1. A page flip that waits for the text is run only by the tests'
pace —each step settles first—, not by a tap in the middle.

### Where it was left

Branches `tijereta-debug-msu`, each with main merged —the-advocate
a7c8c2d0, with Carpintero's panorama tiles in LZ2: the screen does not use
the `msu_dma0_l` that went—:

* the-advocate: the code (24d84b33), the runtime's prose (8914bb71),
  rustfmt, and the merge.
* the-advocate-ports: the fourteen goldens (34ea562, 790081c), the tests
  (5675551), and the merge.
* the-advocate-docs: `internals/the-msu-file.md` —"The debug screen"—, the
  pause menu, the VRAM, and what the debug screen does not model; and the
  merge. Relative links checked.

On the merged tree, with the merge's tools (project cartridge mapdata
screens convert events wally): ABL's `just tests` 1662 passed, 2 skipped;
`just boot` at the ports' root 153 passed —GateStreet's red is gone with
main—.

**To install when merging**: `just install cartridge mapdata screens`
—`cartridge` for `.msu_only`, `mapdata` and `screens` for the pieces and
the pages; the runtime travels with the checkout—. The `.msu` of every game with
`debug_screen = true` changes: it now carries the screen, so it goes with
its `.sfc`.

**For taro to look at**: the Debug row shows only with the `.msu` next to
the ROM —on the FX Pak and in an emulator with MSU-1—, and in Mednafen
without it the menu ends at End Game. On the FX Pak, how long a page of
the list takes to show the first time, when every letter is a seek.

**2026-11-17, taro**: declared done.
