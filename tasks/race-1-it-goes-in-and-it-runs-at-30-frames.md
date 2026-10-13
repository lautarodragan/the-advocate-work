---
name: "Race 1: it goes in and it runs, at 30 frames"
description: "The car chase (49 to 54) and 64 in release, the end of the demo at the end of 64, the Teleport from a parallel page and the steering wheel with IsPressed"
type: feature
status: done
assignee: taro
---

# What

Milestone 1 of `race-and-what-comes-next.md`, which has everything measured
before starting: the walkthrough, the numbered gaps and the cost. It branches from `main`
at `49f0e2f`.

* 49 to 54 and 64 in `release`; 52 stops being a test map.
* The end of the demo moves to the end of the scene on 64 (fork in
  `patches/manual/forks/Map0064.json`), and 36's fork is deleted.
* Gap 1: the `Teleport` from a parallel page with the foreground still.
* Gap 2: the `KeyInputProc` without wait reads what is pressed (`IsPressed`), and
  `eventos.py` accepts it without the measuring switch.
* The tests: 52 out of `heroe`, 52's goldens reviewed, the
  Lashe walkthroughs with "leaving takes you to the race", and a walkthrough of the
  whole race up to the end of the demo on 64.

## What was decided

The plan's questions were answered by whoever launched the milestone, with the
plan's recommendations; taro can review them:

1. **X = 65**, excluding 15, 22, 46, 55 and 58, plus 164. Making it a rule is
   milestone 4; here the list of `MAPAS_DEL_JUEGO` has to give the same as that
   rule.
2. **The race at 30 frames is acceptable as an intermediate step.**
3. **The end of the demo goes at the end of the scene on 64**, instead of the jump to
   the world. 36's fork is deleted.
4. **52 leaves `heroe` without replacement**, and its goldens are reviewed.
5. The controls card (gap 4) and the bridge's sounds (gap 5) **are not
   part of this milestone**: they go in milestone 3.

Reserved numbers: opcode 0x31 (not needed) and far RAM
$7E7980-$7E799F (not needed).

# How it turned out

## The `Teleport` from a parallel page

`eventos_tick` looks at `salto_hay` only after running a foreground
page. The fix goes in the main loop, after `eventos_tick`: if a
jump was left pending, it is handled with the same half of `eventos_tick`
(`eventos_atender_salto`, a global alias of `eventos_tick::hubo_salto`,
because `arranque.s` comes earlier in the assembly and `ca65` does not resolve a symbol
from another scope forwards). It is what easyrpg does in
`Scene_Map::UpdateStage2`: the pending jump is handled after
`Game_Map::Update`, whatever runs. Seven bytes of bank 0.

## The steering wheel

`tecla_valor` looked at edges in both forms. Now the one that does not wait looks at what is
pressed: `TECLA_ESPERA` is bit 0, an `lsr` moves it to the carry, and the
carry reaches the action key whole because nothing in between touches it.
Seven bytes. An `.assert` in `menu.s` makes sure `TECLA_ESPERA` stays
bit 0.

The order between the hero's route and the steering wheel (what the plan left to
look at) gave no trouble: holding up or down the car changes lane and
keeps being pushed to the right.

## What was seen running

With both fixes, a test pilot that dodges by looking at the cells of
the cars does the whole race: 49, crash (50) and back to 49, 52, 54,
the bridge (51), the prize (53) and 64 up to the end-of-demo card.

Hardware frames per tick while driving, with the steering wheel running (measured with
the test's pilot, counting only the ticks with 170 and without fade or
message):

    49   2,07
    52   2,04
    54   2,04
    51   1,00

So the three laps run at 30 frames, as the plan measured, and the
bridge at 60. It is milestone 2.

**53 without a companion gets stuck**, in the original too: its three branches
ask for 54 (Arden), 56 (Saldra) or 150 (AG7-17), and without any of them the page
ends without jumping to 64. In the game it does not happen, because 36 only lets you leave with
the condition of one of the three branches; it shows only if the
race is started by hand from outside.

## The end of the demo

64's fork changes the `Teleport [66, 71, 29]` and what comes after it —the
messages that run in the world— for a card ("END OF THE DEMO / The world
beyond Lashe City is not in / the cartridge yet. Thanks for playing!") and a
`ReturntoTitleScreen`, just like 36's did. The layers are those of the
original.

## Space

Measured at the end, on the merge with `main` (`9d6c0d3`), with the method of
`AGENTS.md`:

    cartridge     bank 0    bank 1    BSS   ZEROPAGE   ROM
    release       191 B     ~10,2 KB  109   4          72,6 %
    test-special  967 B     ~11,1 KB  109   4          18,7 %

Against the plan (205 with the maps), the two fixes cost 14 bytes of
bank 0.

# Tests

`just tests` green on the merge with `main`: what it prints is the
number.

* **New: `tests/abl/test_playthrough_race_golden.py`**, with two:
  * `test_the_whole_race`: with Arden, 49's intro, the three laps
    driving with a pilot that looks in RAM at each car's cell and
    holds up or down to dodge, the bridge, the prize (the gold, and
    variable 38 equal to the crashes it counted), the farewell on 64, the end-of-demo
    card and the title.
  * `test_five_crashes_and_saldra_drives`: without touching the steering wheel the car always crashes
    into the one at (101, 26); each crash goes through 50 and starts again
    on 49, and on the fifth Saldra offers to drive: "Yes" leads to the bridge with
    173, and from there to 64 and the title.
  The captures go to `tests/snapshots/playthrough/carrera-*/` and are not
  blessed.
* **The Lashe walkthroughs**: "leaving ends the demo" became "leaving takes you to
  the race" (`leaving_leads_to_the_race`): 182, map 49 and cell
  (1, 26). The end-of-demo photo of `lashe-fin` became that of the
  start.
* **`heroe` without 52**: its five goldens and its plan were deleted, and the case
  `grupo-11-en-52`, which only it used. The other 52 ones —`battle-in-52`, which is
  state— pass without touching anything; `ev41` is from map 8.
* **No golden of the suite changed.**
* `Recorrido.foto` accepts an `imagen` taken before: the end card is
  recognised only when the next press goes back to the title.
* `just ceilings`: the mix changed with the two new themes
  (`Fire_Mustang_…` and `prepara`), and the table was measured again.

# What taro has to test by playing

* Leave Lashe City from 36 through any of the three branches and play the
  race: the intro with the black screen (the controls card is not there:
  it is milestone 3; any key starts), the steering wheel with up and down, that it
  feels at half speed and nothing more.
* Crash: 50 and back to the same lap. Crash five times and let
  the companion drive.
* The bridge (the jump goes without its sounds: milestone 3), the prize and the farewell,
  with each companion —the texts on 53 and 64 change with each one—, up to
  the end card and the title.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including the path
of selling the Idol, bribing the guard and taking AG7; the race without lag or
bugs (the companion at the wheel, too). Separate is the black hero after
changing graphic on the same map (Lazer Teeth HQ, Boss Wick).
