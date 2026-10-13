---
name: "Lashe 1: the four sectors with a car"
description: "37, 38, 47 and 48 (with 39 and 56) in release, and 36 that does not get stuck: the choice compiles and leaving ends the demo"
type: feature
status: done
assignee: taro
---

# What

Milestone 1 of `lashe-city-with-the-car-up-to-the-race.md`, which is where the whole context
and the measurements are. It blocks the others.

Put into `_DE_RELEASE` the four sectors with a car —**37, 38, 47 and 48**—, which
36's choice asks for together, and the two interiors that ask for nothing:
**39** (Talan's Pad With Car, an exact copy of 7; it turns on 151) and **56**
(the Sector 33 shop). And leave 36 without getting stuck on the second visit.

# Status

2026-09-27, in `testing/`: done on `93af39f`, on the agent's branch. What
is left is taro's: playing it (below, "What taro has to look at while playing") and looking at
the photos without a golden in `tests/snapshots/playthrough/lashe-*/`.

# What was done

**The six maps in `MAPAS_DEL_JUEGO`** (`tools/ensamblado/cartuchos.py`), and
with that in `release`, which is also the suite's cartridge. 38 converts
with `LAYOUT_VENTANA_AMBOS`, as had been tried by hand.

**The converter no longer stops on 37.** `PawnDoorTop` —event 11, at
(67,29)— meets the rule of `eventos_horneables` but the palette allocation
draws it with a borrowed one. Where there was a `sys.exit`, now it is unbaked:
it becomes a sprite again, with the borrowed colours, and the layers are rebuilt with the
remaining baked ones (`_hornear_si_no_mueve_la_cgram`, in
`tools/port/snes_convert.py`). It is what the comment there asked for —"take it out
of the rule"—; it is asked afterwards and not inside `eventos_horneables` because
the borrowed ones come from the allocation, which runs after drawing the layers. No
other map baked a borrowed one: the `patches/auto/maps/` of the ones already there
come out identical, and the suite moved no golden. It is enforced by
`test_the_pawn_shop_door_is_not_baked`.

**The end of the demo** (taro's decision of 2026-09-26): 36 is
forked in `patches/manual/forks/Map0036.json`, with the original's layers, and
its four `Teleport [49, 1, 26]` are now a message —"END OF THE DEMO / The
escape from Lashe City is not in / the cartridge yet. Thanks for playing!", in
English like the rest of the game— and a `ReturntoTitleScreen`. The converter
compiles that command to the same `OP_GAME_OVER` as `GameOver` (`jml reset`):
here the Game Over no longer draws its image, so both are the same, and the
startup of `release` is the title screen. **No new opcode.** 182
("they leave") is still turned on before the card, as in the original; `reset`
clears it on returning to the title. The why of the fork is in
`patches/manual/README.md`.

`test_fork_incoming_teleports_still_land_on_walkable_cells` required
that every cell a `Teleport` arrives at be walkable, and 36 receives
`DummyHero` on cells that were not walkable already in the original (it is a black
screen). Now it requires what it protects: that the fork does not close a cell the
original let you walk on.

`test_door_of_10.py` enforced that the door on 10 with switch 231 did **not**
lead to 8 because 38 was not there; now it enforces that it leads to 38, at (48,54).

# What was measured

All on `release`, `93af39f` against this branch:

**The pages**: with the plan's script (`measure.py`), 183 of 186 triggerable
pages of 36, 37, 38, 39, 47, 48 and 56 compile. The three that do not are the
expected ones, doors to maps of other milestones:

    37  event 13, page 3 (the neighbour's door) ......... Teleport -> 41 (milestone 2)
    48  event 9, pages 1 and 2 (Stash's door) ........... Teleport -> 57 (milestone 3)

And incidentally the two pages of map 10 that lead to 38 compile (the doors
of switch 231).

**Bank 0** (`TABLAS`, the `AGENTS.md` method): 360 B free before, 342
after. **BSS** 109 and **ZEROPAGE** 4, unchanged. **Bank 1**: the last
symbol is still at $01:F874 (~1.9 KB free), unchanged. **Cartridge**: from
2,652,978 B (63.3% of 4 MB) to 2,748,268 B (65.5%), +93 KB.

**VRAM**: 38 fits with 476 background tiles and 347 sprite tiles, as had been
measured. **CGRAM**: 37 draws 5 graphics with a borrowed palette (the two tile
doors, `Chara2:4`, `Crown1:3`, `Future2:5`), 38 three (`BLObjs:2`, `Chara2:2`,
`People4:0`). **Frames lost** walking 1200 frames in steps of 50, there and back,
the method of `map-11-redesigned.md`: 0 on the four cells of 37,
0 or 1 on the five of 38, 0 on 47 and 48 (8, under the same
conditions, gives 0 to 2).

**Audio.** No new theme: the sectors inherit 36's music, and the plan's three
themes (`Kfmus5`, `tsmedit`, `fm2bar_gs`) are from maps of milestones 2 and
3. The MSU-1 tracks are still the same. But **there are new
packages**, and they lower the rate of themes that were already there: 38 and 47 play
`vswar` (the HQ scene, the guards) and `golden_axe-turtlevillage2` (the
exit), and through 10 `cd4` comes into 38 —in RM2k 10's theme keeps playing when
going back to a sector, which inherits—, so `38+cd4` appears (the fullest
package: 1267 B to spare), `8+vswar`, `10+vswar`, `36+vswar`, `56+vswar` and the
`+golden_axe` of each sector. Measured pair by pair (theme, instrument) with the
real `Banco`, against `93af39f`: of 338 pairs **47 go down** and 26 go up; the
median goes from 18.9 to 16.5 kHz. The ones that go down the most:

    vswar         15 pairs: the polysynth 21,1 -> 12,6; cymbals and toms 22 -> 14,1;
                  strings 22,1 -> 14,2 and 16,7; choir 22,3 -> 16,8
    escape_newyork polysynth 21,1 -> 12,6, and four more by 1 to 2 kHz
    golden_axe    hits 41 and 42: 22 -> 14,1; basses and strings 22 -> 16,5
    Deflector1    hit 36 22 -> 14,1
    cd4, T_ProjectJustice, C3classi, Lunar_Pyramid, wb3town: 1,7 to 5,3 kHz

Half of it belongs to the package itself —`38+cd4` has to fit `vswar`,
`golden_axe` and `cd4` together—, but the ones that fall to 14.1 "the battle limits it" do not:
they are copies that the second batch of `snes_music.copias` stopped making (the bank
goes from 221 to 212 samples), because now there is none that does not lower someone.
**It is reported and not touched**: it is the domain of the audio agents, and it
shows in the `vswar` theme without MSU-1. `just ceilings` redone with the new
mix: no theme clips.

# Tests

`tests/abl/test_playthrough_lashe_golden.py`, on `release`, starting from
where the game starts —the car talk on map 4 with 132, the cutscene
on 34— except the HQ and the guards, which jump to their sector:

* `test_the_choice_of_36_leads_to_the_four_sectors`: with Arden, the four
  one after the other —35, 34, 33, 32—, the first through page 1 of 36 and the
  others through page 2. In each one: the map, the `Teleport`'s cell, the party
  (Talan and Arden) and getting into the car (148 off, 149 on, `DummyHero` alone).
* `test_talans_pad_with_car`: 37 -> 39, the computer turns on 151 and
  only then does the door open, 39 -> 37 (10,31).
* `test_the_vipers_hq_through_the_pipe_with_arden`: the pipe (167, Arden goes
  ahead), the empty HQ (168), talking to Arden (back in the party), the whisper
  (169) and the exit to the street.
* `test_the_sector_33_guards_with_saldra`: the shop on 56 and back, and
  the guards scene with Saldra (181, the escape to (5,36)).
* `test_irse_de_la_ciudad_termina_la_demo`: with 161 and 169, "Stay" (and
  238 on), another round, "We've got to get out of here", the card and the
  return to the title.
* `test_the_pawn_shop_door_is_not_baked`.

The photos are in `tests/snapshots/playthrough/lashe-*/` **without a golden**:

    lashe-sectores  36 the first time, and each sector on arrival
    lashe-pad       Talan's pad
    lashe-hq        above the pipe, the empty HQ, back on the street
    lashe-guardias  the shop, after the guards
    lashe-fin       leave or stay, the end card, the title

What they do **not** cover: the blue car (130 off, 131 on: the same
pages with the neighbouring cell), the "alone" branch (without a companion there is nothing
of its own in this milestone) and 38 through 10's door.

# What taro has to look at while playing

The four sectors with the car: that the choice leads to each one, that on returning
to the car another can be chosen, the Vipers' HQ through the pipe with Arden, the
Sector 33 guards, the shop on 56 and Talan's pad. The NPCs with a
borrowed palette on 37 —the two tile doors and the people who appear with
161— look with someone else's colours. The end-of-demo card. And how
`vswar` (the HQ scene and the guards) sounds without MSU-1, which is the one that went down the most.

# Tested

taro, on 2026-09-27, on the SNES with the FX Pak: everything worked, including the path
of selling the Idol, bribing the guard and taking AG7; the race without lag or
bugs (the companion at the wheel, too). Separate is the black hero after
changing graphic on the same map (Lazer Teeth HQ, Boss Wick).
