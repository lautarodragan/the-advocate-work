---
name: "Runtime optimizations, read whole: events, text and screens"
description: "Read the events, the text and the screens of runtime/ file by file for optimizations the book's Optimizations section does not tell"
type: docs
status: testing
assignee: taro
agents: [Tijereta]
---

taro, on 2026-10-18, after Hurón's pass by keywords
([`the-runtime-optimizations-the-book-does-not-tell`](the-runtime-optimizations-the-book-does-not-tell.md)):
read the code whole, so that what saves without saying so is found too.
Split in three by subsystem, one agent each: this is the events, the text and the screens.

## Log

2026-10-18, Tijereta. From the-advocate `df9a0f9c` and the book `a083b3e`,
on the book's branch `tijereta-optimizations`. Read the whole
Optimizations section first; now reading the files, starting with the
interpreter, variables, common_events, text_layer and messages.

Files read, and what came out (book's `13c3cb2` for the first batch):

* `interpreter.s`, `interpreter_variables.s`, `interpreter_conditions.s`,
  `interpreter_cells.s`: every jump resolved by the compiler (told only in
  a decision) → events. `op_done`'s inline depth check and the random's
  hardware divider: small, left out.
* `variables.s`, `switches.s`: variable slots and the switch table sized
  to the game → events, with the skill bits (from `indices.rs`).
* `common_events.s`: the foreground saved only when a parallel common
  event runs → events.
* `interpreter_keys_and_waits.s`, `interpreter_message.s`,
  `interpreter_movement.s`, `interpreter_game_over.s`,
  `interpreter_party.s`: a waiting command rewinds its cursor → events.
* `interpreter_map.s`: a block's terrain, a flat map's one byte → the map.
* `interpreter_camera_and_tint.s`, `interpreter_effects.s`,
  `interpreter_flashes.s`, `interpreter_gold_and_items.s`,
  `interpreter_music.s`, `interpreter_save.s`, `interpreter_teleport.s`,
  `interpreter_timer.s`, `interpreter_shop_and_battle.s`,
  `variable_arithmetic.s`, `items_by_variable.s`, `control.s`,
  `counter.s`: nothing new.
* `items.s`: only the reachable items carried → the cartridge.
* `messages.s`, `message_letter.s`, `message_arrow.s`, `message_face.s`,
  `message_place.s`, `message_waits.s`, `window_system.s`, `text_layer.s`,
  `text_screens.s`, `system_cursors.s`, `number_input.s`: glyphs by
  palette entry, one set per System and per ink; the composer's pace; a
  wait redraws its line → text and windows.
* `menu.s`: the party panel's one block → text and windows.

Second batch, book's `12c7bf8`:

* `actor_names.s`: a rename is one byte, unrenamed names baked (told only
  in a divergence) → text and windows.
* `end_game.s`: the cursor is a palette swap → text and windows.
* `shop_party.s`: frames when the vblank has room, grey by palette →
  text and windows.
* `slots.s`: the leader's name composed, not baked per actor → added to
  the party panel's entry.
* `menu_experience.s`, `actor_stats.s`, `actor_choice.s`,
  `equipment_screen.s`, `equipment_from_events.s`, `skills_screen.s`,
  `shop.s`, `save_game.s`, `title.s`, `game_over.s`: nothing new.
* `custom_menu.s`: nothing to write; a question for taro (below).

Third batch, book's `1963d78`:

* `picture.s`, `picture_far.s`: the per-frame loops stop at the highest
  slot in use → CPU time.
* `big_picture_zoom.s`: the mode 7 texture goes up a piece per vblank
  while the picture is still (told only in `internals/vram.md`) → CPU
  time.
* `level.s`: experience only for the actors who can fight, each curve
  once → battle (the routine is mine, the page Mulita's: no overlap with
  hers).
* `party.s`, `medicine.s`, `remembered_place_and_song.s`,
  `big_picture.s`: nothing new.

The book's main merged in (`46fb20e`): Cardón's and Mulita's entries
conflicted only as neighbours, both kept. Cardón's "far RAM tables as big
as the game asks" overlaps the slot sentence of my variables entry, which
now links it. `mdbook build` and a check of every relative link and anchor
on the pages touched: none broken.

### What went into the book, by page

* Events: every jump lands where the compiler said; a command that waits
  goes back to itself; the parallel common events save the foreground
  only when one runs; only the variables the game names get a slot; a
  skill learned is one bit.
* Text and windows: the glyphs carry palette entries, one set per System
  and per ink; a message a few letters a frame, a line a vblank; a wait
  redraws its line; the party panel is one block; a renamed actor's name
  is one byte, the others baked; End Game's cursor is a palette; the
  shop's party waits for room in the vblank.
* The map: a cell's terrain is its block's, a flat map's one byte.
* The cartridge: only the items the game can give are carried.
* Battle: experience only for the actors who can fight, each curve once.
* CPU time: the pictures' loops walk only the slots in use; a zoom's
  texture goes up while the picture stands still.

### Left out, as questions for taro

* **The custom menus** (`OP_MENU_OPEN`, `runtime/custom_menu.s`): a
  common event of pictures the project declares a menu becomes an engine
  screen. Is it `OP_COUNTER`'s kind, for `lossy/events.md`, or an RM2k
  PLUS feature that is not an optimization?
* **A waiting page is one bit per event, not a queue** (`mark_waiting`):
  told only in `internals/events.md`, but `event_pages.s` is in none of
  the three lists.
* The small ones, left out by taro's rule unless wanted: `op_done`
  checks the call depth inline, not with a `jsl` (the race lost fifty
  frames in a thousand); the random draw uses the hardware divider below
  256; the title is decompressed while boot waits out `BOOT_FRAMES`;
  saving and loading are one DMA through `WMDATA`; the slot screen does
  not check the checksum to paint the list.

No drafts: nothing dead or broken found. Nothing to install: only the
book changed.
