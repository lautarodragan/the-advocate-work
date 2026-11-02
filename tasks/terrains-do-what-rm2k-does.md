---
name: "Terrains do what RM2k does"
description: "A terrain in the database says more than its battle background: damage while walking on it, its encounter rate, a half-hidden character in a bush, which vehicles pass; the console reads only the background and StoreTerrainID"
type: feature
status: done
assignee: taro
agents: [Aguará]
---

taro, on 2026-10-20, in their words, translated:

> For the terrain I think we really have nothing. We are going to have
> to implement everything RM offers for events, including "damage".
> Let's make a task for it.

**What the console reads today**: the terrain of each cell, for the
battle's background (`backdrop_terrain`, `rm2k-snes/mapdata/src/scene.rs`)
and for `StoreTerrainID` (`TERRAIN_OUTSIDE`, `TERRAIN_PLANE`,
`block_terrain`, `rm2k-snes/mapdata/src/record.rs`). Nothing else of the
database's terrains.

**What an RM2k terrain says** (liblcf's `Terrain`, to be checked in
easyrpg's `Game_Player`/`Game_Character`/`Game_Map`):

* **damage**: HP lost on each step onto it, with the screen's flash —the
  same moment poison hurts; see
  [`the-partys-conditions`](the-partys-conditions.md)—;
* **encounter rate**: a multiplier of the map's steps to a battle;
* **bush depth**: the lower part of a character drawn half-transparent
  while standing on it;
* **vehicles**: whether the boat, the ship and the airship pass and the
  airship lands;
* the background's own flags and, in RPG Maker 2003 games, the footstep
  sound and the 2003 battle background options.

**Done** is to be written by whoever defines it, one part at a time,
each with what the nine games use. **First step**: which terrains of the
nine games have damage, a rate other than 100, a bush depth or vehicle
flags, and on which maps they are walked on.

**Where to start** —taro, on 2026-10-20, in their words, translated—:

> The simplest case is Zounds': the first desert has tiles that cause
> damage when you walk over them. And there are also monsters there that
> poison.

So Zounds' first desert is this task's first case, and the same desert
is the first of [`the-partys-conditions`](the-partys-conditions.md).

## What the nine games use

Measured by Aguará on 2026-11-01 over the dumps in `data/` of the ports at
`ab38e40`: each terrain that differs from liblcf's default —damage 0,
rate 100, bush 0, boat and ship no, airship passes and lands—, and the
maps whose **lower layer** has it, which is where `GetTerrainTag` reads
it. "Has it" is cells of the map, not cells walked: it does not look at
the upper layer nor at events. Many games carry RM2k's default database,
so terrains 5 and 8 —"Poison Swamp", "Alcove Damage"— show up everywhere
and are on almost no map. The script is a throwaway one; the numbers are
what it printed.

**Damage** (HP per step):

* ABL: 14 "SwampPoisonFloor", 2, on map 159 *Ill Marshes* (1014 cells).
  Items 78 *Safe Tea Boots* and 291 *TankTreads-!O* have
  `no_terrain_damage`.
* Vampires Dawn: 8 "Alcove Damage", 2, on map 1 *Weltkarte* (1974
  cells); 11 "Giftwasser", 5, on maps 201, 236, 240, 351 and 435. Items
  43 *Gargasch's Armor* and 91 *Sunblock Cloak* protect.
* Zounds: 12 "Piedra Caliente", 1, on maps 28 (the desert's explanation
  cutscene), **34 *Main* of *Desierto de Urbaddûn* —the first desert,
  397 cells—**, 35, 37, 38, 40, 88 and 95; 13 "Piedra Caliente2", 2, on
  59, 75, 93, 96 and 102, where its tiles are not passable below. No item
  protects.
* Book of Three, Dooms 2, El Dorado, Frozen World: only the default 5
  and 8, on no map. Desert Nightmare and Sunset: none.

**The 2003 footstep and the damage sound** (only Zounds is 2003): 12 and
13 play *Flame2* when they hurt (`on_damage_se`); 14 "Sonido Desert 1"
plays *NAU_Item* on every step, on maps 33, 47, 55, 56, 57, 81, 87 and
94.

**Encounter rate**: ABL's 9 and 10 (sea, 20) on 19 and 5 maps, its 2
(forest, 250) on map 5; Dooms 2's 3 (desert, 200) and 9 on four maps;
Book of Three and Frozen World's 9 on one map each; Vampires Dawn's world
map, map 1, has 2 (250), 7 (250), 8 (200), 9 (70), 10 (**0**, 66656
cells) and 12 (60), and 10 also on maps 59, 341, 396; Zounds' 9 on maps
35, 186 and 187. It only counts on maps with encounters: today
`rm2k-snes/battle/src/encounters.rs` fixes the rate at 100 (`RATE`), and
ABL's `tests/tooling/test_encounters.py` guards that assumption.

**Bush depth**: ABL's 2 on map 5 and 320; Book of Three's 11 "Water in
Tylwyth" (depth 2) on maps 56, 57 and 84; Vampires Dawn's 2, 7 and 11 on
map 1 and the five of "Giftwasser". The others only on no map.

**Vehicles**: only Zounds has one. Its boat starts on map 187 *Fishing
Game* (1, 13), and two `EnterExitVehicle` there board it; no game has a
`SetVehicleLocation` nor a `ChangeVehicleGraphic`. The console has no
vehicles —draft
[`vehicles-enterexitvehicle-and-the-boat`](vehicles-enterexitvehicle-and-the-boat.md)—,
so the terrains' vehicle flags wait for it: the boat passes Zounds' 9
"Beach", on maps 35, 186 and 187. Sunset's only terrain forbids the
airship, which nobody has.

## Damage: Done

Defined by Aguará on 2026-11-01, from easyrpg's `Game_Player::Move`
(`game_player.cpp`), `Game_Battler::ChangeHp`, `Game_Actor::
PreventsTerrainDamage` and `Game_Screen::FlashMapStepDamage`:

* **When**: as the hero **begins** a step onto a cell —`Move` after
  `Game_Character::Move` succeeded—, with the terrain of the destination
  cell. Every step of the hero, the pad's and a forced move route's: the
  check is in `Game_Player::Move`, which a route calls too. A blocked
  step hurts nobody. Not in the airship, which the console does not have.
* **How much**: the terrain's `damage` to each actor in the party; a
  negative one heals. `ChangeHp` with `lethal` false: it leaves no one
  below 1 HP, it does not touch a fallen actor and it caps at the
  maximum. **It cannot kill**, so no Game Over; that is EasyRPG's own
  `easyrpg_damage_can_kill`, which no game here sets.
* **Who is spared**: an actor with an armor —shield, armor, helmet or
  accessory, not a weapon— with `no_terrain_damage`, only for positive
  damage.
* **The flash**: `FlashOnce(31, 10, 10, 20, 6)` —red, strength 20, six
  frames— if the damage is positive and someone in the party is not
  spared, fallen or not.
* **Not in this part**: the 2003 sounds —footstep and `on_damage_se`—,
  which need the sample in the map's audio package; it is the next part.
  And poison's step damage, which is
  [`the-partys-conditions`](the-partys-conditions.md).
* **Tested**: a ROM test in Zounds, on map 34: a step onto Piedra
  Caliente takes 1 HP from each actor and flashes, one onto sand takes
  nothing, and at 1 HP it stays at 1.

## Damage: what was done

By Aguará, on 2026-11-01, on branches `aguara-terrains` of the-advocate,
the ports and the book.

* `runtime/terrain_steps.s`, in `FAR3`: `terrain_step`, which `begin_step`
  calls with `jsl` —four bytes of bank 0—; `hero_terrain`, the lookup of
  the hero's cell that `scn_terrain` had for the battle's backdrop, now
  shared by both; `flash_step_damage`; and `spared`, the armors. The HP
  goes through `actor_change_one`, `ChangeHP`'s own, with a `_l` entry.
* The emission writes `terrain_damage`, a signed word per terrain id, and
  bit `$10` of `item_use` for an armor with `no_terrain_damage`. The
  battle stage's `Db` carries the terrains now.
* Tests: the ports' `tests/test_zounds_terrain_damage.py` (map 34, 1 HP,
  never below 1, sand hurts nobody, the flash) and ABL's
  `tests/rpgmaker/test_terrain_damage.py` (map 159, 2 HP, the
  *TankTreads-!O* spare their wearer, nobody spared means no flash). ABL's
  *Safe Tea Boots* also spare, but no cartridge carries them: nothing of
  the game gives them.

**For poison** ([`the-partys-conditions`](the-partys-conditions.md)): it
hurts at the same moment in RM2k —after `IncSteps`, pad steps only— with
the same flash, so it wants `flash_step_damage` and
`actor_change_one_l`, both in place; the hook is `after_step` in
`move_hero`, next to `encounter_step`, not `begin_step`, which also runs
for forced routes.

## What is left

Each its own part, with what the nine games use above:

* **The 2003 sounds**: Zounds' hot stones play *Flame2* when they hurt
  and "Sonido Desert 1" plays *NAU_Item* on every step. The sample has to
  be in the audio package of each map that has the terrain —the event
  compiler and `rm2k-snes-audio` decide those today from `PlaySound`—, and
  a table from terrain to `sound_table` row. In Zounds' "Known issues".
* **Encounter rate**: the ROM's model assumes 100 —`RATE` in
  `rm2k-snes/battle/src/encounters.rs`, guarded by ABL's
  `tests/tooling/test_encounters.py`—; with a rate per terrain the
  thresholds are on the accumulated rate and not on the step count, and
  the chance is multiplied by `rate / 100`, which is no longer a shift.
  Vampires Dawn's world map, with a 0 on most of its sea, is the case.
* **Bush depth**: the lower part of a character half-transparent; Book of
  Three's "Water in Tylwyth" (depth 2) and Vampires Dawn's forests.
* **Vehicles**: wait for the console to have them.

**When merging**: the-advocate's `aguara-terrains` changes the runtime
and two Rust projects, `battle` and `mapdata` —`just install battle
mapdata`—. `convert`, `events` and `screens` compile `battle`'s library
too, but nothing they write changes.

**Verified** on 2026-11-01, with the branch's tools —`battle`, `mapdata`
and `cartridge` installed locally, so the runtime was the branch's—: ABL's
whole suite, 1590 passed, 2 skipped and 3 red —the two new terrain
tests, which used item 78, and the test index, which did not name the new
test—; those three and the jumps test green after the fix; the ports'
`just boot`, 112 passed, with no golden moved; `just crate-test mapdata` and `battle`; `just space` of
ABL's cartridges, bank 0 at 89 bytes in `test-change-system`, the
tightest, and of Zounds'. Not covered by any test: a negative damage
—healing—, which no game has, and a forced route's step onto a damaging
terrain.
