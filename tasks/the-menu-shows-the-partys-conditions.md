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
