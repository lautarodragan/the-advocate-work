---
name: "The System's cursor in the main menu and the save slots"
description: "The main menu's command list and the Save/Load screen mark the selection with a two-cell mark of their own instead of the System's cursor, the rectangle the items, equipment, shop, targets and choices already use"
type: feature
status: doing
assignee: Chajá
agents: [Chajá]
---

taro, on 2026-10-16, playing ABL and The Book of Three: the selector in the
Save/Load screen and in the main menu's list of options on the left does
not use the System graphic; it was always like that.

At the-advocate `30ab0ca6`: `menu_cursor_write` in `runtime/menu.s` writes
a two-cell mark —`menu_cursor_cells`, `menu_cursor_vram` from
`rm2k-snes/mapdata/src/emit.rs`—, and `slot_paint` in `runtime/slots.s`
paints a slot's row in one of four variants, the cursor one of them
(`slot_<n>_<full><cursor>`). The items, equipment, shop, target windows and
the message window's choice bar already draw the System's cursor
(`Game::cursor` in `rm2k-snes/screens/src/game.rs`, `borders.rs`).
