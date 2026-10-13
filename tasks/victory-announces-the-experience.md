---
name: "Victory announces the experience"
description: "Make the battle say N EXP received and Level up"
type: feature
status: done
assignee: taro
---

**Make victory say the experience gained and who levelled up.**

Experience and levelling up already work (`experience-and-levelling-up.md`),
but the battle does not tell them: neither "N EXP received" nor "Level up!". The state changes
anyway; it only shows in the menu.

The texts come from the LDB's `terms`, as in RM2k (`Scene_Battle_Rpg2k`).
It moves the end-of-battle goldens of the suite.

## How it turned out, on 2026-09-26

On winning, the message window covers the party —the four rows of
`BA_PAG_MSG_FILA0`, the same ones as a troop page's message— and tells
what `ProcessSceneActionVictory` tells, page by page, each one
waiting for A:

* the victory and the experience: " The combat has resulted in" / "victory!" /
  "90 EXP". ABL's term did not fit in one row and spilled into the one
  below cut in half; now the converter splits it at a space
  (`pantallas.renglones_de_la_victoria`);
* one for each actor that levelled up, in party order: "Arden LEVEL 6
  achieved!" and a row per skill learned ("Pickpocket acquired!").
  If there are more than three, they continue on another page without repeating the level.

The texts are `victory`, `exp_received`, `level`, `level_up` and
`skill_learned` from the LDB, put together like `game_message_terms.cpp` does for RM2k in
English. The converter stops if any of them does not fit in the 31 characters
(`pantallas.cobrar_la_victoria`).

Experience is now handed out **on winning**, before showing anything, as in
RM2k; before, it was handed out when closing the screen.

What stays out, on purpose:

* **Gold and items**: RM2k tells them on the same page, but the port
  does not give them on winning yet.
* **A skill already known is announced anyway**: RM2k only announces the
  new ones. They differ only if a `ChangeSkills` first teaches one that a level
  later teaches, and in ABL none does (checked in `data/`).

It is covered by `tests/rpgmaker/test_victory.py`, which reads the text from the tilemap.
It uses far RAM `$7E7810-$7E781F` (`BA_VIC*` in `ram_lejana.s`); no
new opcode.

taro still has to play it: that the pace of the pages with A feels right and
that the battle closes on the last one. The before and after captures are
in `/shared/goldens/2026-09-26-victoria/`. No golden of the suite
moved: no capture takes the victory screen. `test_cores.py` does not
go through it either, so the comparison between snes9x and bsnes does not enforce the new
RAM; `ba_vic_empezar` writes the eight positions before anyone
reads them.

**taro looked at the captures on 2026-09-26 and finds them fine.** It still has to be played.
