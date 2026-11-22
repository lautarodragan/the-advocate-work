---
name: "Desert Nightmare: the menu loses its burning face after a note or a map"
description: "A note or a map shown on A is a big picture over the menu's face, another big picture; the console carries one at a time, so when the note goes the menu's windows stand over the map until the menu is opened again"
type: bug
status: todo
author: mulita
game: desert-nightmare
agents: [Mulita]
---

Seen by Mulita on 2026-11-20, at the-advocate `810d483c` and the ports
`0fb2535`, for
[`desert-nightmare-the-game-s-menu-draws-nothing`](desert-nightmare-the-game-s-menu-draws-nothing.md).

**What is seen**: B, Notes (or Maps), A on a note: the note covers the
screen, as in RPG_RT. A again: the note goes, and the menu's windows come
back over the room the player stands in, not over the burning face. The
face comes back when the menu is closed and opened again. In RPG_RT the
face stays behind the menu the whole time.

**Why**: the face (`Introauswahl`, picture 6, common event 4) and the
note (`Notiz_Bild*` or `Karte*`, picture 17, commons 12 and 14) are both
big pictures, and the console carries one big picture at a time, in BG1:
showing 17 replaces 6, and `ErasePicture 17` —`OP_PICTURE_ERASE` of the
big one, whichever is up— leaves none. RM2k keeps both and shows 6 again
when 17 goes.

**To reproduce**: `tests/test_desert_nightmare_menu.py` in the ports,
`test_the_keys_the_notes_and_the_maps_are_drawn`, with a capture after
the map is taken down (the test closes and opens the menu there so that
its goldens do not keep it). Captures in
`/shared/captures/2026-11-20-desert-nightmare-menu-keys/`.

**Ways on**: the runtime remembering the big picture under the one shown
—one level, its image and tone— and showing it again when the top one is
erased; the erase would have to say which number it takes down.
