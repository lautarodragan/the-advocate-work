---
name: "Runtime optimizations, read whole: the map and the frame"
description: "Read the map, the characters and the frame of runtime/ file by file for optimizations the book's Optimizations section does not tell"
type: docs
status: doing
assignee: Cardón
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

Book `74e4252`: nine entries, and that fix.
