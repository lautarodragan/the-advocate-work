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
