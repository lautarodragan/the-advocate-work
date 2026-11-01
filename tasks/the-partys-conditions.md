---
name: "The party's conditions"
description: "The actors never hold a condition: ChangeCondition on them is ignored or refused, skills and items give none, poison does not hurt while walking and the menu never shows one; RM2k keeps them on the map and in battle"
type: feature
status: doing
assignee: Mulita
agents: [Mulita]
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

**Where to start** —taro, on 2026-10-20, in their words, translated—:

> The simplest case is Zounds': the first desert has tiles that cause
> damage when you walk over them. And there are also monsters there that
> poison.

So the first case is Zounds' first desert: its monsters that poison the
party, and the poison hurting while walking, next to the damaging
terrain of [`terrains-do-what-rm2k-does`](terrains-do-what-rm2k-does.md).

# Status

2026-11-01, Mulita, from the-advocate `422f904d`, the ports `cd41913` and
the book `9407191`, on the branches `mulita-conditions` of the three.

## The inventory: how the nine games use conditions on the party

Measured on each game's dump with a throwaway script over `states.json`,
`skills.json`, `items.json`, `enemies.json`, `actors.json` and every
command of the maps, common events and troop pages. "Persists" is a
condition whose `type` is 1, which outlives the battle; the rest are
`battle_only`.

| | conditions that persist | hurt on the map | enemy actions that give one to the party | weapons that give one | cures: medicines / ally skills | map commands |
|---|---|---|---|---|---|---|
| ABL | Poison (2) | 2, 13, 18: 1 HP per 4 steps | 38, over 22 skills | 3 | 10 / 19 | `ChangeCondition` removes the dead one (revive), already compiled |
| Book of Three | Poison | 1 HP / 4 steps | 23, over 15 skills | — | 5 / 8 | — |
| Desert Nightmare | — | — | — | — | — | — |
| Dooms 2 | Bleeding | 1 HP / 4 steps | 2 (Wounding) | — | 0 / 1 | — |
| El Dorado | Poison | 1 HP / 4 steps | 23, over 15 skills | — | 4 / 6 | — |
| Frozen World | Poison | 1 HP / 4 steps | 23, over 15 skills | — | 4 / 6 | — |
| Sunset over Imdahl | — | — | — | — | — | — |
| Vampires Dawn | Curse, Rage, Sick | Sick: 1 HP and 1 SP / 5 steps | 138, over 39 skills | 20 | 5 / 8 | adds Rage (5) in common event 30; removes 2–12 on maps (healers); `IsActorConditioned` Curse ×9 |
| Zounds | Env. (2, its poison) | 1 HP / 9 steps | 7, over 6 skills | — | 7 / 1 | removes 1–13 in common events (the food items); `IsActorConditioned` ×4 |

Book of Three, El Dorado and Frozen World carry RM2k's default database
(Poison, Blind, Silence, Berserk, Chaos, Sleep, Numb, Shock, MindBlow);
ABL extends it to 23 and Zounds to 15. Every condition that hurts on the
map persists and is `lose`: none heals walking. Per turn in battle, ABL
has seven that take HP (and MindBlow SP), Vampires Dawn five, Zounds five.
Sealing: Silence in the default database and ABL's Stone; Vampires Dawn's
Silence seals from level 0.

**What is seen most, in order**: (1) an enemy's skill gives a condition to
an actor —seven of the nine games, every battle that has those
enemies—, and with it the actor holding it in battle: its restriction,
its messages, its turns; (2) poison's HP each turn and on the map, which is
the only thing that outlives the battle in six games; (3) the cures,
medicines and skills, in battle and on the map; (4) Silence's seal; (5)
weapons that give one —Vampires Dawn and ABL—; (6) `ChangeCondition` that
adds, and `IsActorConditioned`: Vampires Dawn and Zounds only.

## Done

**The map half** is done when: an actor holds conditions across maps and
in the save; `ChangeCondition` adds and removes them on actors and the
party; `FullHeal` (and the inn) and a fall to 0 HP clear them as RM2k's
priority purge does; the battle's end drops the `battle_only` ones and
the persistent ones with `auto_release_prob`; each pad step hurts as
`Game_Party::ApplyStateDamage` says —every `hp_change_map_steps` of the
party's steps, never below 1, with `FlashMapStepDamage`— and SP the same;
`IsActorConditioned` reads it. Test: Zounds' desert, an actor with Env.
loses 1 HP on the ninth step and the screen flashes, red before.

**The battle half** is done when: the actors' conditions enter the battle
and come out of it; an actor holding one has its turns, restriction and
messages as the enemies' already do; an attack with a weapon's
`state_set`, a skill's `state_effects` and an item casting a skill give or
take them with RM2k's chance, on both sides, in the model and the
console; HP and SP change each turn; sealed skills cannot be chosen.
Test: Zounds, Gwen's Látigo de Seda poisons and Kazar's Veneno poisons an
enemy, red before.

**Not here, on purpose**: the condition in the main menu's status line and
the status screen —after Tijereta's menu boxes, a follow-up—.
