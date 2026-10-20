---
name: "A debug screen in the pause menu"
description: "RPG Maker 2000's F9 screen —switches by groups of ten, with their names, turned on and off— as an option of the pause menu, for any game, behind a debug knob"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

taro, on 2026-10-20: "Could you add a debug screen like the original RPG
Maker 2000's, that lets me change switches? Since we have no F9, I'd add
it as an entry of the pause menu (as we did with the console in ABL)."
The precedent is ABL's console
([`console-custom-menu`](console-custom-menu.md)): one more option of the
pause menu, full screen.

**What RPG_RT's is** (to confirm against EasyRPG's `Scene_Debug` and,
if it helps, the original under Wine): a list of ranges of ten on the
left, the ten switches of the chosen range on the right with their number,
name and ON/OFF; A toggles, B goes back. Variables are on the same screen
in RPG_RT —a value per variable—: here, second, if it is cheap.

**Behind a knob**: on in the builds taro plays while porting, off in a
clean delivery, like `[debug] debug_map`; a game without the knob has no
entry and no cost in its ROM.
