---
name: "The party's conditions"
description: "The actors never hold a condition: ChangeCondition on them is ignored or refused, skills and items give none, poison does not hurt while walking and the menu never shows one; RM2k keeps them on the map and in battle"
type: feature
status: todo
---

taro, on 2026-10-20, in their words, translated, after correcting
[`optimise-parallel-events-when-compiling`](optimise-parallel-events-when-compiling.md)
—HP does change on the map, by poison or by a terrain that hurts—:

> Don't we have one for the conditions, which we currently ignore?

We did not. What exists is the enemies' side in battle:
[`battle-conditions-for-real`](battle-conditions-for-real.md) gave the
enemies RM2k's conditions —turns, release, restrictions, halved
parameters, their messages—, but only a troop page gives them, and the
book's `divergences/what-battle-conditions-do-not-model.md` lists what
is left: **the actors never have one**, no skill, attack or item gives or
takes one on either side
([`items-that-give-a-condition-in-battle-only-hurt`](items-that-give-a-condition-in-battle-only-hurt.md)
covers skills on their targets), no HP or SP change each turn, no
sealed skills.

**What RM2k does with the party's conditions** (to be read in easyrpg
—`Game_Actor`/`Game_Battler` states, `Game_Party::ApplyStateDamage`,
`Game_Player` steps, `Window_MenuStatus`— and checked against RPG_RT
where it matters):

* `ChangeCondition` on actors, from map and troop pages; `RecoverAll`
  and death clearing them; which survive the battle's end
  (`battle_only`);
* on the map: a condition's HP change every so many steps —poison—, with
  its flash, and whether it can kill or stops at 1;
* in battle: the actors' turns, restrictions and messages as the enemies
  already have, HP/SP each turn, sealed skills, an attack or skill that
  gives one;
* the menus: the status line and the status screen show the condition
  of highest priority; items and skills that cure them;
* a condition's colour and the dead one, as `ConditionalBranch` reads
  them (`IsActorConditioned` may already compile: check).

**Done** is to be written by whoever defines it: probably split into the
map half and the battle half. **First step**: an inventory of how the
nine games use conditions on the party —which commands, items, skills
and states— to order the work by what is seen most.
