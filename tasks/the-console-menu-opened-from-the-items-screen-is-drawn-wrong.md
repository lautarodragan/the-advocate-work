---
name: "The console menu opened from the items screen is drawn wrong"
description: "ABL's Portable Console, opened by using the console from the items screen, sometimes shows window-frame pieces tiled over its background; opened from the main menu's entry it looks right"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-10-18, playing ABL on Mednafen: the console's menu (the
custom menu, `runtime/custom_menu.s` in the-advocate) sometimes looks wrong
when entered from the items screen, using the Portable Console item, and
right when entered from its entry in the main menu. taro's screenshot (page
2/2: Arden's face, "Neon Viper", Skills, Tutorials): the text, the face and
the windows' frames are there, but the background around them is filled
with pieces of window frame, tiled over the whole screen.

Done means: entering the console from the items screen draws it the same
as from the main menu, every time, measured in a ROM test that compares
both ways in.

## Log
