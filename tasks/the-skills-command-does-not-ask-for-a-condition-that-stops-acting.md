---
name: "The skills command does not ask for a condition that stops acting"
description: "The pause menu's Skills refuses only an actor at 0 HP; RM2k's CanAct also refuses one holding a condition whose restriction is 'does nothing', which the party can hold on the map since 2026-11-01"
type: bug
status: draft
---

Seen by Chajá on 2026-11-01, doing
[`items-that-cast-a-skill-outside-battle`](items-that-cast-a-skill-outside-battle.md),
reading the-advocate at `0ba09da4`; not run.

`menu_choose` in `runtime/menu_list.s` asks, for the Skills command, that
the actor chosen can act —`Scene_Menu`'s `CanAct()`— and reads only its HP,
with the comment "Outside battle this port keeps no states". Since
[`the-partys-conditions`](the-partys-conditions.md) the party holds them on
the map, and easyrpg's `Game_Battler::CanAct` also says no for any held
condition whose `restriction` is `do_nothing`.

The special items cast from the items screen do ask it —`ic_can_act` in
`runtime/item_skills.s`, for who casts them—, so the two answers differ for
the same actor.

To reproduce: an actor with a condition that does nothing and lasts past a
battle, on the map —or given by an event's `ChangeCondition`—, and Skills
on it from the pause menu: RM2k sounds the buzzer, the console opens the
list.
