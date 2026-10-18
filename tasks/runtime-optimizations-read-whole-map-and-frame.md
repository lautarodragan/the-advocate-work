---
name: "Runtime optimizations, read whole: the map and the frame"
description: "Read the map, the characters and the frame of runtime/ file by file for optimizations the book's Optimizations section does not tell"
type: docs
status: testing
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-18, after Hurón's pass by keywords
([`the-runtime-optimizations-the-book-does-not-tell`](the-runtime-optimizations-the-book-does-not-tell.md)):
read the code whole, so that what saves without saying so is found too.
Split in three by subsystem, one agent each: this is the map, the characters and the frame.

## Log

2026-10-18, Cardón. From the-advocate `df9a0f9c` and the book `a083b3e`,
on the book's branch `cardon-optimizations`. Each file read whole; what it
had that the section does not tell, or "nothing".

* vblank: nothing new (strips, budget, window HDMA already told).
* oam: the off-screen cull in `build_oam` before `place_npc`.
* event_pages: the refresh's two passes and its one-byte filter on `+13`,
  which the converter sets per event (`record.rs`).
* event_routes: nothing.
* hero: passability worked out by Wally for both layers, four bits per
  block.
* camera: nothing (the panned camera in pixels: taro's "small").
* map_window: the narrow grid, one byte a cell (told only in
  `internals/maps.md`).
* action_key, animated_stills, bank1, cache_slots, cells, chipset_animation,
  far_npcs, hero_route, hero_speed_keys, header: nothing.
* boot: nothing kept (the title decompressed during the boot wait: a
  question, below).
* character_flash: the flash's one division per channel.
* decompress, far_ram: the load buffer lent while the map is played
  (told only in the WRAM research).
* enter_map: closing a screen reloads only the background tile bank.
* far_ram_game: far RAM sized by the game.
* load_graphics: the book said the NPC table goes up "by one DMA"; it is a
  loop. Fixed in the entry; `npc_buf`'s comment in `low_ram.s` says the
  same and is stale.

Book `74e4252`: eight entries, and that fix.

The rest, same day:

* low_ram, main, npcs, painted, registers, screen_bank, screen_flash,
  shared_poses, teleport_transition, timer, tint, turn_toward_hero,
  twins_block, walking_events, zero_page: nothing new.
* pano: the panorama's tilemap is a ring like the map's.
* rain: the drops go straight to OAM, one byte per axis.
* walk_by_type: walkers past the route slots stand still (lossy, told
  only in its divergence).

Book `553ee4c`, on `cardon-optimizations`: eleven entries in all, each
with its line in `lossless.md` or `lossy.md` —the map five, events one,
CPU time three, the cartridge one, the tables of a fixed size one— and the fix to the NPC table's "one DMA".
Relative links and anchors checked against `mdbook build`.

### Left out, as questions for taro

* The title image is decompressed while the boot waits out
  `BOOT_FRAMES` (`boot.s`): nine frames less of black before the title.
  An optimization for the section, or too small?
* The music IRQ multiplies with the PPU's mode 7 multiplier, which is
  instant and nobody else uses (`registers.s`): it is chosen so the
  interrupt does not clash with the CPU's, not for speed. Leave it out?
* `twins_here`, a direct-page byte so a map without twins pays no cycle
  per step (`twins_block.s`): a sentence for "Copies of an event share a
  row"?
* Cold tables and code moved out of bank 0 to keep it for what runs
  every frame (`bank1.s`, the header of `main.s`): does the section want
  the code banks' policy?

No drafts: no dead code or bug found in these files beyond the draft
`routes-moved-is-written-and-never-read` already open. `npc_buf`'s
comment in `low_ram.s` says the table is copied "by one DMA"; it is a
loop —a stale comment, not a bug—.

Nothing to install: only the book changed.
