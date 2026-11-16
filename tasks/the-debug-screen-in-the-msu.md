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
