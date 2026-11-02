---
name: "The menu shows the party's conditions"
description: "Since the party holds conditions, the main menu's status line and the status screen still say Normal for a poisoned actor; RM2k shows the condition of highest priority, in its colour"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

The follow-up [`the-partys-conditions`](the-partys-conditions.md) left on
purpose for after
[`the-main-menu-scrolls-its-party-for-sp`](the-main-menu-scrolls-its-party-for-sp.md):
the condition in the main menu's status line and in the status screen.
Mulita's map half keeps four conditions per actor in far RAM
(`runtime/party_states.s` in the-advocate); Tijereta's menu rows keep
"Normal" in the row's fixed block, on the level's line.

**Done**: in the main menu and the status screen —and the item and skill
target picker, if RM2k shows it there— a conditioned actor shows the name
of their condition of highest priority, in its colour, as RPG_RT
(`Window_Base::DrawActorState` in easyrpg); "Normal" when there is none.
With a ROM test in ABL, red before, over an actor poisoned on the map.
**First step**: how RPG_RT picks the condition shown and its colour, and
which of the menus' cells already hold "Normal".

## First step: what RPG_RT shows, and where

Tijereta, 2026-11-01, from the-advocate `0ba09da4`, the ports `31fb291`
and the book `a9aa2bd`, on branches `tijereta-menu-conditions`.

**Which condition.** `Window_Base::DrawActorState` draws
`Game_Battler::GetSignificantState`: the dead one if held —here, HP at
zero, since the dead one is not a place in `party_states.s`—; otherwise
the held one of highest `priority`, the later LDB number on a tie (`>=`
walking up), even at priority 0; `normal_status` in the default colour
when none. Its colour is the condition's `color`, a System colour, with its
gradient like any text.

**Where RPG_RT draws it, in a 2000 game**: `Window_MenuStatus` (the pause
menu's party), `Window_ActorTarget` (the actor choice of an item or a
skill) and `Window_SkillStatus` (the skills screen's status line). The
status screen, `Scene_Status`, is RPG Maker 2003's: a 2000 game's menu
has no such command, and the port has none.

**Where "Normal" is today**: baked in the party row's fixed block
(`Kind::MenuRow` in `slots.rs`), at `MENU_TEXT_X + MENU_STATUS_DX` = x 194
on the level's line, cells 24 to 31 of the row —the same cells on the menu
and on the actor choice, which share `menu_row_paint`—; and on the skills
screen, `BA_TXT_NORMAL` written by `sk_status` at `SK_STATE_COL`, five
cells.

## The plan

* **The party panel** (menu and actor choice): a conditioned actor's row
  blanks Normal's cells and composes the condition's name there with
  `tl_strip`, then recolours the stage and moves it one pixel right —the
  strip starts one pixel into its cell, Normal two— and uploads it again,
  in palette 1, the disabled commands', which has room in every game. The
  colour: one entry per condition colour in palette 1, the mean of the
  colour's rows as the message window's ink, and each glyph row to that
  entry or to the palette's nearest, whichever is nearer. The converter
  decides; the cartridge reads a table. A strip per distinct condition,
  kept while the screen is up: the converter counts the four longest of
  the ones the party can hold on the map —the dead one and the ones that
  outlive a battle— in the bank's names.
* **The actor choice after a use**: if a row's condition changes —a
  revival, a cure—, the screen is drawn again, as a material already does.
* **The skills screen**: the condition's name in its full gradient, in
  BG2's palette 4, which the text screens leave free.
* **Test** in ABL on the debug map's full party, a poisoned actor and a
  fallen one, against `render` and a golden; red before.
