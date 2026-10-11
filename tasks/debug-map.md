---
name: "The debug map"
description: "A room where Begin the Story starts, with a door to each key point of the game —with the state of someone who played up to there— and an NPC per companion"
type: feature
status: done
assignee: taro
---

# What taro asked for

> could you create a new map, for debug, that has doors leading to
> different key maps, each with a sign saying its destination? the idea
> would be for begin game to start there. one door would take you to the
> normal start, another to talans pad after the intro, another to the back alleys
> after the director is murdered, another to talans pad but with the car… and
> maybe an npc for each of the 3 companions, that when you talk to them do a
> change party. the door should teleport and also turn on the
> switches needed, as if you had played the game normally up to
> there

And afterwards, about the tests: **a single ROM** for the suite and for what he
plays; the flag that turns it off is for a clean delivery, not for the suite.

It comes from `2ca861a5`, with `main` merged at `3c16a178` (the new bank
packing and the four-byte texts).

# How a map the game doesn't have is born

`parches/manual/nuevos/Map0900.{json,tiles}`, and not `mapas/`: a fork
replaces a map that exists and a new map **can't** override one that
exists, so they're the same rule turned around and each one needs its own safety net.
`fork.nuevos()` validates: the two pieces, the id in the name equal to the one inside,
and that `data/` doesn't have that map. The tree node (`data/maps.json`) that a
new map doesn't have is brought by the JSON itself, in the `arbol` field, and
`lcf.TreeMap` adds it. `lcf.Map` reads it like a fork.

* **The id, 900**: outside the game tree's 0 to 351, round so that
  it's obvious it isn't the game's.
* **The chipset, 10** (`LasheINT`, Lashe City Interiors', which is already
  in the cartridge): the drawing is that of the top right room of map
  10 —walls, plain floor, the exit at the bottom— stretched to 26x15, with six
  exits and the back wall's console standing on the floor as a sign.
* **The music**: `music_type` 1, "an event sets it", that is, none, like
  map 4.

A throwaway script built it; from then on the JSON is edited by hand.

# How "Begin the Story" starts there

Page 0 of `release` —the one that runs on starting, in map 4, before
its router— is a case, `PRIMERO` in `cartuchos.py`. Until today it was `nada`. With
`CON_MAPA_DE_DEBUG = True` it's `mapa-de-debug`: a `Teleport` to 900 and Talan
in the party, because DummyHero is an empty sprite and the hero wouldn't be visible.
`nada` becomes just another page.

**For a clean delivery, `CON_MAPA_DE_DEBUG = False`**: the map leaves the
cartridge and page 0 goes back to being `nada`. Measured: that ROM comes out **byte for
byte identical** to `main`'s at `2ca861a5` (`.sfc` and `.msu`), both built
with `cartuchos.convertir` in separate directories.

"Resume the Story" doesn't go through page 0: the saved game already has
on the switch that turns it off.

## The tests that play from the title

Two paths, and it ended up a mix:

* **The ones that play from the title** —`tanda.partida(None)`, the
  cutscenes, the music, Talan's walkthrough— choose the page of
  `LA_PARTIDA_DE_VERDAD` (`nada`) by its number, like any case: it's
  page 0 of the clean delivery, in the same ROM. Going through the door didn't give
  the same: the `cinematica` goldens count ticks from the title and two
  fall on the ramp of the first fade, and reaching 4 with a `Teleport` shifts
  the ramp and the tint (`CINEMATICAS` in `test_escenas_golden.py` says so).
  Goldens that today test exactly the start delivered without the map would
  have to be redone.
* **The opening walkthrough** does what taro suggested: it enters through "Begin
  the Story" into the debug map, walks to the normal start door and
  crosses it. With that the door is covered end to end. Its photo of
  "Kersh takes control" comes out with the rain in another phase (344 pixels,
  0.6%), within those photos' tolerance.

# The doors

*Since `debug-map-2-the-companion-picks-the-branch.md` the branch isn't fixed: it's chosen by the companion
who joins via an NPC, one at a time, and the Back Alleys leave Talan where
the cutscene ends. What's below is how Arden's branch was built, which
still holds for that branch.*

Branch chosen for everything that branches: **Arden's** (Neon Vipers),
arriving at work on time, **refusing Wick** —the same one
`test_recorrido_sorbe_golden.py` uses—. The player is tidy: opens the chests along the
way and talks to the people who leave a switch someone looks at later. He doesn't
take the detours that change branches: not the Hover-Tram (71/72/186), nor the
bribe (29), nor shaving (25).

How it was built: each stretch was read from the events in `data/`, and so as not to
get lost in each map's local switches, it was cross-checked which switches **set
before** each point **someone looks at afterwards** (a throwaway script). Those
all go in, with this branch's value; the others, the story's. Each
door page says where each thing comes from in its `Comment`s, which the
converter skips.

The hero's speed also travels: the game's routes change it (28 and
29) and the ROM saves it. Each door sets it with five decreases and as many increases
as needed.

    1  NORMAL START    map 4 (10,12), the LDB's start. Undoes what the
                       map changes: the party and 150.
    2  TALAN'S PAD     through 4's router (11,9) with the prologue done: 3,
                       5, 7-15, 21, 22 and 806. Runs page 3 of 4 —the
                       sign, the console (81), Talan— and jumps to 7.
                       Speed 5 (page 2 of event 5 of 3); the
                       alarm clock leaves it at 4.
    3  BACK ALLEYS     20 (93,0), the Teleport of 19's exit, with
                       '3D-Galax'. + Lashe City up to the director: 24, 27, 30,
                       31, 32, 48, 54, 58, 73, 77, 78, 79-89, 90, 92, 129,
                       206. Gold 400 (alarm clock and cheque), 81, 97, 88.
                       Party Talan. Speed 5.
    4  WITH THE CAR    36 (10,8), where 34 leaves you (133, 148): the sector
                       choice, and 35 is Talan's pad with car. + the
                       alleys, the Rat Tracks, Sector 27 and the warehouse:
                       93, 95-97, the chests 98-112, 116-118, 123-128, 113,
                       120, 121, 130, 132, 133, 137. Gold 845, the items from
                       all those chests, Detect Aura (133) for Talan. Party
                       DummyHero, as 33 leaves it. Speed 4.
    5  THE RACE        49 (1,26), the Teleport of 36's page 2, with 182.
                       + Arden's branch closed: 149, 151, 154, 156,
                       158-162, 166-169, 238, the three chests in 38
                       (544-546, 124, 157, +250). Speed 3 (41 lowers it
                       when refusing Wick).
    6  THE WORLD       through 53's prize (11,10) with the three laps
                       (171, 174-179, variable 38 at 0): gives the gold and the
                       items, turns on 180 and goes through 64's farewell,
                       which sets up the party and leaves you in the world. Speed 6 (the
                       race raises three); the farewell leaves it at 3.

I proposed the race and the world in addition to the four requested, and **not** Sorbe: the
entrance to Sorbe is twenty steps from where the world door leaves you,
so one more door would be one more state to maintain for twenty steps. The
race yes: without it, reaching the start line means the four sectors with the car.

# The companions

*Changed in `debug-map-2-the-companion-picks-the-branch.md`: the NPCs turn on their branch and remove the other
companion.*

One NPC for each —Arden (15), Saldra (17), AG7-17 (18)— with the
game's graphic. Talking to one adds them to the party if they're not in it and removes them if they are
(`ConditionalBranch` of actor in the party). AG7 also turns 150 on and off:
turning it on runs common event 37 right after —see
`divergencias/los-comunes-del-equipo-corren-al-cerrar-el-menu.md`— and he joins
knowing the skill of his ArmCannon, which he has equipped from the base. There's no need
to give him the weapon. Without 150, 36's page and 64's farewell wouldn't
put him in the party.

**The NPCs don't touch the branch switches** (54, 56): adding Saldra doesn't make
the game believe the Lazer Teeth were chosen. The doors don't remove the
companions who joined, except the normal start one.

# What it doesn't reproduce

* **The level.** Talan reaches each point at the starting level: the battles along the
  way aren't played, and there's no compiled command to change the
  experience or the level (`ChangeExp`, `ChangeLevel`). If needed, it's a
  new opcode: give notice first.
* **The equipped gear**: the items reach the inventory, unequipped.
* **Absorb Aura** and the heals absorbing auras gives: they depend on what was
  detected in which battle.
* The shops, the workshop's repairs and the gambling game: neither the gold they
  cost nor what they give.

# Tests

`pruebas/abl/test_mapa_de_debug.py`, on `release`:

* the arrival through "Begin the Story", with golden (`mapa-de-debug-llegada`) and
  `celdas_mal_dibujadas` at zero;
* each door crossed walking, with the map, the cell, the switches, the
  party, the gold, items and the speed on arrival;
* each NPC adds and removes their companion (AG7, with 150 and his skill);
* the clean delivery, without building it: `release`'s cases with the flag off.

And `test_recorrido_golden.py`, the opening, enters through door 1.

# Space

`just espacio`, against the clean delivery built separately (= `main` at
`3c16a178`, byte for byte): bank 0, bank 1, `BSS` and `ZEROPAGE` don't
move; the map adds **one data bank** (some 8 KB, but it crosses the edge and
leaves a big gap in the last one) and 592 B of texts, the signs.

# `dcbest`'s ceiling

With the map, `test_el_tema_no_recorta_en_su_pico[dcbest]` clipped 2
samples: its streams and samples are the same (the `musicdata.inc` comes out
the same except `PAQUETES_N`), but the peak moves with when each
write lands in the frame, which changes with any ROM change —the
test says so—. On `main` it passes. `just techos` was run, and the table goes in its
own commit.

# What taro has to test

* That "Begin the Story" lands in the room and the six signs can be read.
* Each door, and play a while from each: that what follows works
  as if it had been played —especially the car one (Sector 35 and the pad) and
  the world one—.
* The three NPCs.
* "Resume the Story" with an old save.
