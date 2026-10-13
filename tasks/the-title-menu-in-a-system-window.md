---
name: "The title menu in a System window"
description: "The title's Begin the Story / Resume the Story menu is drawn as bare text with a mark over the picture; RPG_RT draws it in a window of the game's System, with its cursor"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, on 2026-10-13: "Could you make the start menu use the System for the
Begin the Story / Resume the Story menu, like RPG_RT does?"

Today `rm2k-snes/screens/src/title.rs` in the-advocate draws the database's
`new_game` and `load_game` terms with the message font over the title
picture, on BG2 at 4 bpp, one tilemap per option chosen, with a text mark
as the cursor and no window.

RPG_RT draws a window with the System's background and frame, centred
under the picture, with the System's cursor on the chosen option. It also
has a third option, the database's `exit_game` term, and greys
`load_game` when there is no save.

## Log
