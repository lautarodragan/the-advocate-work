---
name: "The empty party at the start"
description: "RM2k starts with nobody in the party and no visible hero; the converter asks for a leader to draw, and Sunset and Desert need party = [1]"
type: feature
status: done
assignee: taro
agents: [Mulita]
---

From the survey of 2026-10-05 and the re-sweep of 2026-10-10: it is still Sunset Over Imdahl's and Desert Nightmare's crutch.

## What RM2k does with the empty party (easyrpg-player)

Read in `~/ref/easyrpg-player/src`:

* `Game_Player::ResetGraphic`: without `GetActor(0)` the graphic is `""`, and the
  hero isn't drawn. **Nothing else changes**: there is no question about the
  party in movement, in collisions (`WouldCollide` looks at layer and
  `through`, not the graphic), in event triggers or in
  encounters. The invisible hero walks, collides, touches events and can
  enter a battle.
* `Scene_Menu`: the menu opens. Items, Skills, Equipment, Status and Row
  are disabled (greyed out, and A plays the buzzer); Save and Quit don't
  depend on the party.
* `Scene_Save::Save`: with zero members the game is saved without faces or
  leader name.

## What there was

* The converter stopped at `Database::leader` ("the party is empty") and Wally
  at the `first` of the leaders.
* The runtime already drew nothing with `party_n = 0` (`pick_hero_graphic`, the
  `hero_poses + 2` at zero in `oam.s`) and the slot screen already knew
  that an empty party has no leader.
* `party_initial` came out as `.byte ` with nothing, which doesn't assemble.

## Log

* Sunset, small cartridge (maps 11, 22, 21, 23, 10) without the crutch: it builds.
  Map 22, the camping tent scene, stays black **also with
  the crutch** (`party = [1]`, same cartridge): it isn't the empty party's fault.
* Desert Nightmare without the crutch: the `release` builds (about 5 minutes). On
  map 1, the "With Intro / No Intro / Quit" menu, there is no hero
  drawn and `party_n` is 0; on choosing, actor 1 joins and the game continues
  (looked at with snes9x captures, not with a test).
* ABL: `abl.sfc` comes out identical with only the converter's changes
  (`f135f6af…`). With the menu one it moves, on purpose.
* `test_grupo_vacio.py`, in `test-special` (so as not to touch `release`):
  before the menu fix, red were Items and Equipment —A opened the
  list, and Equipment opened the actor choice over zero rows— and the
  menu golden. "isn't drawn", "walks", "joins and is seen" and
  "saves and loads" were already passing: the runtime already knew about `party_n = 0`.
* The first place chosen for the case, map 1 at (66, 40), is the one from
  `parado-tapado`: the hero ends up under a pipe and can't be seen. Map 255
  opens a sign, and map 21 adds Talan alone. Map 5 at (39, 34) remained, the one from
  `pelea-82-grupo-11-12`.

* Sunset without the crutch: the whole `release` builds (2 h 11 min, with other
  runs going). The title leads to map 21 with the empty party.
* With `hornero-integ` (71737293) and the ports' `main` (a95aacb) merged:
  A Blurred Line's suite, 1174 green (the 1167 plus the 7 new ones); `abl.sfc`
  gives `5852b723…`, different from main's `30c38ba8…` only because of the menu
  fix (without it, before the merge, it came out identical).

## When merging

Branches `mulita-grupo-vacio` in the-advocate, the-advocate-ports and
the-advocate-docs. Reinstall in the global: `convert`, `wally`,
`mapdata` and `cartridge` (the latter because of the runtime, `runtime/menu.s`).

## What it doesn't cover

* **A battle with the party empty.** RM2k loses it immediately
  (`Game_Battle::CheckLose` with nobody who can act); the runtime wasn't
  looked at or tested.
* **The converter's empty start** —`party_initial` without bytes, Wally
  without a first leader— isn't run by the suite: ABL starts with actor 10. Sunset
  and Desert ran it, looked at with captures.
* Skills was already always greyed out; Status and Row don't exist in the menu.
