---
name: "Vehicles turn when they shouldn't"
description: "The hover tram, the agency ships and the race car have charsets made not to rotate, and in the ROM they face where they walk"
type: bug
status: done
assignee: taro
---

From taro, on 2026-09-30, playing on the SNES: "the vehicles, when moving,
look broken because the charsets are half edited, designed so that
certain vehicles can't rotate. I think there's an event option
that forces a certain direction on them, and, with it enabled, they don't face where
they walk". It shows in:

- the hover tram at the start;
- the agency ships, when Lunar Pyramid starts playing;
- the race car: "at times, I can change the car's colour, or
  turn it into another vehicle, by pressing the direction keys".

Hornero's hint: `tools/runtime/oam.s` says that for the hero "no
`lock_facing` to look at: `step_route` ignores 26 and 27", that is, the
route commands that lock the direction aren't carried out on the hero.

# What was done (Coipo, 2026-09-30 and 10-01)

**The three cases**, searched for in `rom/data/`:

- **The Lashe City tram** (map 9, EV27 "Hover-Tram"): an event with
  `animation_type` 4 ("fixed graphic") facing left and with no route
  of its own; on boarding, a forced `MoveEvent` moves it down five cells. It's the
  "hover tram at the start": Lashe City is where the game starts.
- **The agency ships** (map 28, EV11 "Hover2" and EV12 "Hover1"): the
  same, fixed graphic facing left, moved down by EV15's `MoveEvent`,
  the same one that sets `Lunar_Pyramid`.
- **The race car** (maps 49, 51, 52 and 54, EV1 "RaceController"):
  it's **the hero**, with actors 19 and 20 on `Future3`, and a forced route
  `13, 26` (or `14, 26`) that locks the direction and **never unlocks it**: the 27
  only comes in map 64. The ROM dropped the 26 in the compiler, so
  each arrow gave it the row for that direction, which in that CharSet is another
  car.

In total, `scan2.py` (throwaway) found 13 events with a fixed-direction
page moved by a forced route —also Dessen, the Bum in
Sector 30, Emily, the Packages, the Canisters—, and 35 hero routes with 26,
all with their 27 in the same route except the race ones.

**What RM2k does** (easyrpg, `game_character.cpp/.h`): `Move` does
`SetDirection` and `UpdateFacing`, which with `IsFacingLocked()` doesn't touch the
`facing`; the hero's pad goes through the same `Move`. `lock_facing` is set by
a route's 26/27 (`SetFacingLocked`) and by `SetAnimationType` with types
2, 3 and 4 (`IsDirectionFixedAnimationType`). The route's stays set
after the route —it's a field of `SaveMapEventBase`, the hero's too,
and nothing clears it except a 27 or an event's page change—, and it's
saved in the game. A route's `face_*` write the `facing`
directly and **do** turn even when locked. `Jump` only turns if it isn't
locked. It wasn't confirmed with RPG_RT under Wine.

**The tests** (`rom/pruebas/rpgmaker/test_direccion_trabada.py`, cases
`traba-heroe`, `traba-heroe-ruta` and `tram-fijo`): the pad doesn't turn the locked
hero, the locked hero still walks, the route doesn't turn him until the 27, and the
tram with a fixed graphic doesn't turn with the forced route. Red before the
fix: the pad one (the down arrow left him facing down), the route one
and the tram one (+8 stayed on down). The "still walks" one passed before.

**The places that turn a character**, searched with a `grep` of
`sta hero_dir` and `sta route_ev + 8, x`:

- the pad (`hero.s`) and the hero route's `move_*` (`hero_route.s`):
  both now go through `try_toward`, which respects `hero_lock`;
- the 26/27 in the hero's route (`hero_route.s`, `lock_hero`), and the
  compiler no longer drops them (`compile.rs`);
- the hero's jump (`oam.s`, `build_hero_jump`): looks at `hero_lock`, with
  Guanaco's criterion for events;
- the new slot of a forced route on an event (`event_routes.s`,
  `route_for_event`): inherits the fixed-direction bit of the active page,
  which the converter now emits also without a route of its own (`map_record.py`,
  `rm2k.FIXED_DIRECTION`);
- the `face_*` turn even when locked, as in RM2k; the turn towards the
  hero when talking to him already looked at the animation type (`turns`) and the lock.

**The save**: RM2k saves `lock_facing`, the ROM doesn't, on purpose —the only
lock the game leaves set outside its route is the race one, and between
maps 49 and 64 there's no save point—. Loading clears it and reset
starts it at zero. It's in the comment on `hero_lock`.

**Declared**: with the lock set, the action key looks where the hero
faces and not towards the last arrow, which is what RM2k's `GetDirection`
would do: there's a single variable for both things, and no case in the game
presses action while locked.

**The goldens**: two change, `tram-320` (`test_escena[tram]`) and `tram-620`
(`test_hablar[tram]`), in `bccba0fb`, only goldens. The tram goes down with its
page's grey ship instead of the blue car. Before and after, and the captures of
the race and of the agency ships before and after, in
`/shared/capturas/2026-09-30-vehiculos/` (with a `LEEME.txt`). **The
original wasn't captured under Wine.** **The merge awaits taro's approval.**

**Commits**: `e90d1d5c` (the fix and the tests), `bccba0fb` (the
goldens), `c1c9305f` (main merged).

**On merging**: reinstall `events` (`just -f tools/justfile install
events`); `cartridge` didn't change. The ROM moves: `test_musica_techos.py`
passed in the branch. No far RAM or new opcodes were used; BSS gains two bytes
(`hero_lock`, `found_flags`).

**After Chingolo's merge** (`b60f32ec`): `python.json` clashed because
both branches changed the same two hashes; the merged tree's were kept,
measured (see the merge message). Nothing was taken from the allotted far RAM
range —neither `$25C6`–`$25DF` nor from `$25C5` down—. On the
merged tree: 923 in `just pruebas`, 46 in the tools, bank 0 of
`release` at 320 B. On merging, reinstall `events`, which now carries both
things.
