---
name: "Runtime optimizations, read whole: events, text and screens"
description: "Read the events, the text and the screens of runtime/ file by file for optimizations the book's Optimizations section does not tell"
type: docs
status: doing
assignee: Tijereta
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
