---
name: "Lashe City with the car, up to the race"
description: "Plan: from the director and Kersh cutscene up to the Teleport to 49, exclusive"
type: feature
status: done
---

# What

Take `release` from where it ends today —the director and Kersh cutscene,
map 34, which teleports to 36— up to the `Teleport [49, 1, 26]` of event 3
of map 36, **without entering the race**. taro asked for it on 2026-09-25: "the
Lashe City maps in their version with the car, the mafia boss stuff, the optional
path of getting the droid as part of the party if you went by the hover
tram… and eventually the race to escape. I'd like to tackle everything up to the
race, exclusive."

This is the plan; what gets executed are each milestone's tasks:

    0. playthrough-picks-option-n.md   the harness chooses option N
    1. lashe-1-the-four-sectors-with-a-car.md  37, 38, 47, 48 (+39, 56) and 36
    2. lashe-2-boss-wick-and-the-vidcasts.md     40 to 45: the favour and the ankle
    3. lashe-3-the-recycling-plant-and-the-droid.md        57, 59 to 63, 164: AG7 joins the party
    4. lashe-4-ag7-in-battle.md              his skills, and the enemies'
    5. lashe-5-the-car-tail-end.md             36's closing through the three branches

Everything measured here is from 2026-09-25 on `d118bc8`, with cartridges built
separately in the scratchpad —`release` wasn't touched—. The scripts that measured it
were left in `/extras/scratch/lashe-plan/`: `medir.py` is the count of which
command blocks each page (it compiles with the same scaffolding as the converter's
`main()`, and replaces the culprit with an ignorable command until it has gathered
them all), `conv.py` is the converter with an in-memory patch to keep going
past the error in map 37, `testmain.py` builds a `test-main` with extra maps,
`segs.py` and `banco1.py` read the `.dbg` and the `.sym`, and `copias.py` measures how much
of a map is a copy of another.

# The Lashe City subtree

**"Lashe City with the car" is distinct maps**, each with its own id —not pages
of the same maps depending on switches—, and almost all copy the drawing of a map
that's already in `release`. What the tree says (`data/maps.json`), with what
was measured of each copy (`copias.py`: the best offset of the new map's tile grid
over the old one, and how many cells of the bottom layer come out
identical):

    id   name                          parent release  what it is
    15   Lashe City                     0      -       folder: nobody teleports there
     9   Lashe City 33,36               15     yes
    13     Hover-Tram                   9      yes
    11     Lazer Teeth HQ               9      yes     forked
     8   Lashe City - 34,35             15     yes
    12     Trash Dump 004               8      yes     the Neon Vipers' HQ
     7   Talan's Pad                    15     yes
    10   Lashe City Interiors           15     yes     2 pages jump to 38
    14   NV Get Talan to Work           15     yes
    16   Running To Work Scene          15     yes
    17   Delcentric Factory             15     yes
    18     Auditorium                   17     yes     forked
    19     Talan and the Director       17     yes
    96       Backup                     19     -       unreachable
    20   Sector 30 Back Alleys          15     yes
    24     Sector30 Monsters            20     -       encounter area
    22   The Rat Tracks                 15     -       folder
    21     Rat Tracks B1                22     yes     (25: area)
    23       Beggar's Hideout           21     yes
    26     Rat Tracks B2                22     yes     (27: area)
    28   Sector 27 Back Alleys          15     yes     (31: area)
    29     Sector 27 Item Shop          28     yes
    30     Sector 27 Workshop           28     yes
    32   Sector 27 Warehouse            15     yes     forked (35: area)
    33     Escape From 27 Scene         32     yes
    34   AfterGettingCarCutscene        15     yes     director and Kersh
    36     LasheCityVehicle             34     yes     the car "menu"
    97     Backup                       34     -       unreachable
    37   Sector 35 With Car             15     NEW     copy of 8: its rows 25-74, 67%
    39     Talan's Pad With Car         37     NEW     exact copy of 7, events included
    40     Boss Wick's Den              37     NEW     the mafia boss
    41     ScreenToneAdjuster           37     NEW     black, like 36
    42     The Vidcasts (Factory)       37     NEW
    43       Vidcasts (Office)          42     NEW     34's tiles, identical
    44       Talan Stats                42     NEW     black, like 36
    45       Security Footage           42     NEW     all of 19: tiles and events
    46         Security Footage 2       45     -       unreachable
    98         Backup                   45     -       unreachable
    38   Sector 34 With Car             15     NEW     rows 33-74 = rows 0-41 of 8 (100%);
                                                        above, the Vipers' HQ (53% of 12)
    47   Sector 33 With Car             15     NEW     copy of 9: its rows 21-74, 53%
    56     Sector 33 Discount Items     47     NEW     65% of 29, the other shop
    48   Sector 32 With Car             15     NEW     new: 25% of 9 at most
    57     Stash's Emporium             48     NEW
    59     Outside Recycling Plant      48     NEW     (180: area)
    60       Floor 1                    59     NEW     (181: area)
    61       Floor 0                    59     NEW     (182: area)
    62       Floor 2                    59     NEW     (183: area)
    63     Tunnel Into Lashe City       48     NEW
    55   Escape From Lashe City         15     -       the race's folder: out
    49..54 the race                     55     -       out
    64   Leaving Lashe City Scene       15     -       out: reached from 53, after the race
    83   Dalia at the Factory           15     -       out: another chapter, reached from 82
    84     OutsideFactory               83     -       same

And one that doesn't hang from Lashe City but goes in: **164, `AG7-17 Tutorial`**
(under `Tutorials`), because the page that puts the droid in the party jumps there and
comes back with `RecallToLocation`. It's black like 36.

The sectors with the car inherit the music (`music_type` 0, and the parent is 15,
which doesn't change it): what 36 set plays, `golden_axe-turtlevillage2`, which is already
in `release`.

# The player's path

Today what's playable ends **at map 36**: page 1 of event 3 —the
first-time one, switch 148, which 34 turns on— has the choice of the four
sectors and doesn't compile because the four destinations (37, 38, 47, 48) aren't in
the cartridge. It compiles with all four or with none. The player is left in black with
the car.

## The axis: 36's choice

`LasheCityVehicle` is a black screen with the car. Page 1 (switch 148)
sets the car theme, says what to do depending on the companion and opens
`Sector 32 / 33 / 34 / 35`; each option jumps to the sector —the cell depends on the
car, switch 130 red or 131 blue— and **keeps running there**: it removes
`DummyHero` (10) and adds Talan (14), the companion —Saldra (17) if 56, Arden
(15) if 54— and AG7-17 (18) if 150.

In each sector, getting into the car (events 1 and 2 of 37, 38, 47 and 48) turns off
148, turns on **149**, removes everyone, leaves `DummyHero` and goes back to 36. From
there **page 2** (switch 149) is in charge: the same choice, plus the car's
tail end, which is the end of this plan (see "The closing").

## What has to happen before the race, per branch

The player decided the companion much earlier: 54 (`NVAlly`, Arden, in the
Neon Vipers scene in map 12), 56 (`LTAlly`, Saldra, in 9) or
none. 36's page 2 only offers leaving when this is met:

    Arden   161 DoneWithVidcast  +  169 Arden's Whisper   (the Vipers' HQ, in 38)
    Saldra  161                  +  181 SawAgencyIn33      (Sector 33, 47)
    alone   161                  +  150 AG7-17 In Party    (the droid, from 48)

**Without a companion the droid isn't optional**: without 150 the "alone" branch never
reaches the car's tail end. With Saldra it's optional, and with Arden it can't be done: the
door of Stash says "Looks like they're closed" (page 5 of event 9 of 48,
switch 54).

## Stretch by stretch

**Sector 35 (37) — the main stretch, mandatory in the three branches.**

    37  Talan's door (event 1) .......................... -> 39
    39  the computer (event 5) turns on 151 ............. -> 37
    37  the neighbour's door (event 13, requires 151): knocks, turns on 155;
        page 3 (155, autorun) fades to black ............ -> 41
    41  ScreenToneAdjuster: tint and pass-through ........ -> 40
    40  Boss Wick, scene 1 (event 7, page 1, autorun):
        the "fat man" and his girls; ChangeScreenTransitions to zoom;
        turns on 156 ..................................... -> 42
    42  The Vidcasts (event 2, page 1): transition to mosaic -> 43
    43  the office (34's tiles) .......................... -> 44
    44  Talan Stats: Zed's voice ......................... -> 45
    45  Security Footage: the director's scene (19)
        again, with "REC" blinking (ShowPicture 'ABLrec');
        turns on 160 ..................................... -> 40
    40  page 3 (160): Boss Wick on the video ............... -> 43
    43  page 2 (160) ........................................ -> 42
    42  page 2 (160): turns on 161 DoneWithVidcast ......... -> 40
    40  page 4 (161): **the favour**. "Accept, and owe him a Favor" /
        "Refuse to be healed" (and a second confirmation)
          accepts: 164 WicksSurgeonDoesOper -> page 5: the surgeon,
                   ChangeHeroTitle of Talan to 'Fugitive', 267 AnkleAllBetter -> 41
          refuses: 162 RefusedWicksOffer ........................... -> 41
    41  pages 2/3 (162/164): turns on 163 ................... -> 37
    37  event 17 (163 + companion): the companion's comment on leaving

**The mafia boss isn't a battle**: it's Boss Wick, an NPC with an event. He heals
your ankle if you agree to owe him a favour. What it leaves, and where it's used outside
this scope:

    162 RefusedWicksOffer     66 (Lashe Area, world)
    164 WicksSurgeonDoesOper  64 (after the race), 69 (Sorbe Village),
                              81 (Dr. Vago's house)
    165 BumTalkKnowsFavor     the Bum in 37 (page 4, requires 164)
    267 AnkleAllBetter        69; if Wick didn't operate, Dr. Vago turns it on in 81
    Talan's title             'Fugitive', with ChangeHeroTitle (today accepted without being done)

All of those are switches and travel in the save. The title the ROM accepts without
doing, and nothing visible is lost: there's no screen that shows it.

**Sector 34 (38) — Arden's branch.** 38 is 8's street plus, at the top, a
car version of the Vipers' HQ, reached through the pipe: events 20 and
21 (switch 54, touch) turn on 167 and jump to (2,10) of 38 itself; 25
turns on 168 and then 169; 26 returns to (73,65). Events 17 and 18 lead to
Lashe City Interiors (10), which is already there.

**Sector 33 (47) — Saldra's branch.** Event 15 (touch at (32,28))
has a branch per companion: Agency guards in the Lazer
Teeth's sector, a `PanScreen`, and turns on 181. It works in all three branches; only Saldra
needs it. 56 is a shop (`OpenShop`).

**Sector 32 (48) — the droid.** What taro calls "if you went by the hover
tram":

    48  Stash's sign (event 7): with the Business Card (item 91, the one
        Stash gives on the Hover-Tram, map 13) turns on 183
    48  the door (event 9): with no condition knocks and enters; with Arden, closed -> 57
    57  Stash (event 2): the scene of the "bald man" who robbed you on the tram.
        Page 1 if he stole the creds (72), 2 the idol (71), 3 nothing (186) —all
        three set by the Hover-Tram—, 4 if **you bribed the guard** (29, map
        8). He sends you to the recycling plant ....... -> 59
    59  Outside Recycling Plant (encounters, shop, inn) -> 60
    60  Floor 1: floors that break. Each tile (events 5 to 18, touch)
        loads map 61 into a variable and the hero's cell plus five rows
        into two others, and does RecallToLocation: **you fall to the floor below** -> 61
    62  Floor 2: the same (events 2 to 14)
    61  Floor 0: the Motivator Chip (item 126); event 13 (requires the item)
        turns on 205 ...................................... -> 63
    63  Tunnel Into Lashe City ........................... -> 48
    48  the door, now through page 2 (item 126) ............. -> 57
    57  page 5 (205 + item 126): turns on 150, ChangePartyMembers +18, removes the
        chip, returns to (3,39) of 48, MemorizeLocation, and jumps to the tutorial -> 164
    164 the droid's tutorial (MemorizeBGM, texts, PlayMemorizedBGM,
        RecallToLocation) ................................... -> 48

The data answers a doubt in taro's phrasing: **Stash's scene also
opens through the bribe** (page 4, switch 29), not only through the tram. See the
questions.

## The closing

36's page 2, with 238 off and the branch's condition met: the
companion notices the Agency car, turns on **238**, and "Should we stay in Lashe
City or get out?". "Stay" stays in the city (and the next time you go back to the
car it asks again, the upper branch of the page). "We've got to get
out of here" turns on **182** and does the `Teleport [49, 1, 26]`: the limit.

# What's missing for it to run

## Pages that don't compile

With a `release` cartridge + the 19 maps above (38 included to count
pages, even though it doesn't convert) and without 49: **336 of 397 triggerable pages
compile**. Per map: 37, 38, 39, 41, 43, 44, 47, 48, 56, 59, 61 and 63 compile
whole. What blocks the rest, counted the way `eventos.py` counts —pages
where it appears / pages it unblocks on its own—:

    RecallToLocation          55 / 54   the floors of 60 (28) and 62 (26), and 164
    ChangeScreenTransitions    4 /  4   40 pages 1 and 4 (Wick's two scenes),
                                        42 page 1, 45 page 1
    Teleport -> 49             1 /  1   36 page 2: the limit
    MemorizeLocation           1 /  1   57 page 5: the one that adds the droid
    MemorizeBGM                1 /  0   164 (together with the other two)
    PlayMemorizedBGM           1 /  0   164

Over **the whole game** (5324 of 5472 compile) `RecallToLocation` is what
blocks the most —60 pages, 55 on its own— and `ChangeScreenTransitions` comes third —15,
14 on its own—, so both go in the direction priorities have been going.

**Compiling isn't working**, and what compiles but doesn't do what the original does:

- **`ChangeHeroTitle`** (40, the surgeon): accepted without being done, and not visible
  because the port doesn't show the title on any screen.
- **`ShowPicture 'ABLrec'`** (45, a parallel that makes "REC" blink over the
  video): the ROM carries a single sign and it's already the "One year previously" one, so
  this one stays accepted without being done.
- **Common event 37, `UpdateAG7 Skills`**: it's **parallel with switch 150**
  and it's what gives AG7 his skills according to the parts he has equipped
  (`ChangeSkills` for each weapon from 268 on). The ROM doesn't run parallel or
  autorun common events —`COMUNES` only serves `CallEvent`—, so
  AG7 would join without any skill.
- **The plant's enemies use a skill**: `ShortCircuit` (188), in 5
  of the 7 troops (108 to 114: Scrapped Droid, Trash Hauler, Tangle Wire,
  Junkbot). The battle only does the basic attack action
  (`acciones_de_los_enemigos`, `CreateEnemyActions` with `kind` 0).

## Resource limits

**VRAM: 38 doesn't fit, and it's the only one.** It uses 476 background tiles and 347
sprite ones (18 slots, 8 palettes). The three layouts with a window give 448/448,
480/256 and 384/512: it's **28 background tiles** short in the first or **91
sprite** ones in the second. In bytes it would fit —476×64 + 347×32 is 41.5 KB of the
42 left—; what prevents it is the alignment: BG1's tilemap is nailed
at `$5800` (`VRAM_MAP`) in the four layouts and cuts the background at 448. The
other 18 convert. (Solved on 2026-09-25 with option (d) of question 2:
see there.)

**The converter stops at 37** before reaching VRAM: "el evento 11 se
hornea en el mapa y además se dibujaba con una paleta ajena". It's `PawnDoorTop`,
a ChipSet tile, and `eventos_horneables`' rule doesn't look at the palette. The
comment there says "ninguno de los mapas del juego lo pide hoy; si aparece,
hay que sacarlo de la regla". It appeared.

**CGRAM**: 37 draws 5 graphics with a foreign palette —the two tile doors and
three of the people who appear with 161— and 38, 3. It's the same as already happens in
`release` (8 has 6); it doesn't block.

**ROM: the cartridge crosses the threshold of the 4 MB decision.** From the `.dbg`, banks
2 onwards:

    release today                      2.82 MB, last bank $61
    release + the 18 that convert      3.34 MB (+538 KB), last $74; the ceiling is $7D
    test-main today                    3.45 MB, last $77
    test-main + 37 39 47 48 56         last $7B
    test-main + the 18                 DOESN'T FIT: the allocator asks for $7E

`decisiones/el-cartucho-se-queda-en-4-mb.md` says "se revisa al llegar al 85-90%
del cartucho": with the 18 (without 38) `release` is around 86% counting what's used,
and the race comes after. And **`test-main` doesn't fit**, which clashes with the rule
in `cartuchos.py` that "cada mapa que se suma al proyecto se suma a todos los
cartuchos". See the questions.

What the copies could make cheaper: the allocator doesn't share data between maps
—39 is 7 cell by cell and its tiles come out at another address in the
cartridge, with other bytes—. Candidates: 39≡7, 43≡34 and 45≡19 in tiles; 41, 44 and
164 are 36's black; 37, 38 and 47 share with 8 and 9 between 88 and 216 of
their distinct cells. In VRAM nothing is gained —each map uploads its own—; in
ROM it is, and it has to be measured.

**Bank 0**: with the 18, `TABLAS` grows 72 bytes (4 per map); some 2.2
KB are left in `release` and 1.9 in `test-main`. **Bank 1**: the last symbol leaves ~8.7 KB
in `release` with the 18 (~11 today) and ~5.5 in `test-main`; the troop pages
grow (108 to 114). **BSS**: 7700 of 7808, unchanged; any new state goes to
far RAM.

**ARAM**: the shared bank doesn't change (57,309 of 64,512 bytes). The three new
themes **don't contribute samples** and play with others': `Kfmus5` (Wick's
den) with 8% of its notes, `tsmedit` (the surgeon) with 53%, and
`fm2bar_gs` (Stash) with 83%. None had an MSU-1 track; since
2026-09-26 every theme in the cartridge has its own (`pista_msu` in
`tools/audio/snes_music.py`).
*Since 2026-09-26 this changed*: with the per-package budget all the
themes contribute all their samples, so the three would go in whole; what
a new map costs is the rate of the samples it shares with the fullest
packages, and the converter's report says so ("la limita …"). It has to be
measured again when adding the 18.

**Parallel pages**: one per map at most (37, 45, 47, 48, 59); far from
`PARALELO_MAX`.

## 36's choice

It compiles with its four destinations, so the milestone that adds the sectors adds
all four: **37, 38, 47 and 48 go together**, and 38 has to be solved
first. The doors inside (39, 40…, 56, 57) can stay dead until their
milestone: a page with a `Teleport` to an absent map doesn't compile and the event doesn't
do anything, which is the usual.

And page 2 has the same problem with 49: **without solving the limit, the
second visit to 36 leaves the player stuck**. That goes in milestone 1, not at the
end.

## New battles

Only random encounters, in the plant (areas 180 to 183, troops 108 to 114). No
`EnemyEncounter` in these maps and no boss. What's missing: the enemies'
skill (above), and AG7's stuff.

## The droid in the party

Actor 18, `AG7-17`: CharSet `AG717` 4 (already in the cartridge: he's a possible
leader and his face already shows in the menu), level 6, weapon 269 (`ArmCannon-!R`) and
armour 282. What it asks for:

- **the pages** of the plant and of 57: `RecallToLocation`, `MemorizeLocation`,
  `MemorizeBGM`/`PlayMemorizedBGM`, and 164 in the cartridge;
- **his skills**: common event 37 (above). There are 17 (236 to 253); with
  today's filter (`habilidad_usable_en_batalla`) five are left out for being
  multi-target (236, 240, 244, 245, 251) and `RemoveStatus` (253) for being for the whole
  party; three touch states, which don't exist;
- **the weapons' SP cost**: the tutorial says so ("attacking with a
  weapon drains a small amount of the droid's SP") and in RM2k2000 it's the
  item's `sp_cost` (ArmCannon 1, ArmLauncher 2, PortableNuke 5). The battle doesn't
  charge it.

# Milestones

Each one is playable and is verified separately. The order is the list's.

**1 is done** (2026-09-27, `lashe-1-the-four-sectors-with-a-car.md`):
the six maps in `release`, 37 without stopping the converter and 36 forked
with the end of the demo. What it leaves for the next ones: the dead doors
from 37 to 41 and from 48 to 57, and the audio packages 38 brought —see there—.

**2 is done** (2026-09-27, `lashe-2-boss-wick-and-the-vidcasts.md`):
from 40 to 45 in `release`, `ChangeScreenTransitions` with the mosaic, and the cap
of chained teleports raised from 8 to 32, which Wick's scene exceeded.

**3 is done** (2026-09-27, `lashe-3-the-recycling-plant-and-the-droid.md`):
57, 59 to 63 and 164 in `release`, `RecallToLocation`/`MemorizeLocation` and the
remembered theme, and AG7-17 joins the party. Along the way the variable slot became
eight bits (the game's no longer fit in seven). What it leaves for 4: AG7
joins **without skills** (common event 37 doesn't run) and the plant's
enemies fight only with the attack.

    0  the harness chooses option N        small, in parallel with 1
    1  the four sectors with the car       blocks all the others
    2  Boss Wick and the vidcasts          in parallel with 3, after 1
    3  the plant and the droid             in parallel with 2, after 1
    4  AG7 in battle                       the enemies part, any time;
                                           AG7's part, after 3
    5  the car's tail end                  at the end: brings the three paths together

**What has to be handed out when launching them in parallel** (see "Sub-agentes" in
`AGENTS.md`): the opcode numbers in `tools/protocol/events.toml` —2 asks for
one (transition), 3 between one and four (remembered place, remembered theme)—;
the far RAM addresses —the remembered theme (3),
the chosen transition (2), the common events interpreter (4)—; and the
`_DE_RELEASE` list in `cartuchos.py`, which all of them touch and is best merged while looking.

The concrete numbers aren't written here: they're chosen when launching, looking at
the declaration at that moment.

# Risks and questions for taro

**After the milestones (taro, 2026-09-27)**: when this plan's milestones are
finished, if it fits, **add the race** (49–54, and 55 if needed) **and
64**. If there's still space after that, **83 and 84** too, so that the
rule for which maps go in stops being a list: if the ids are ordered,
it becomes "the maps with id less than X" plus an `--exclude-maps` that's
always kept small (the inverted list). Move forward without waiting for his
confirmation between milestones.

**What taro already answered (2026-09-25):**

* **(2026-09-26)** 36's closing ("get out"): **an "end of demo" with a
  text message**, very simple, instead of the `Teleport` to 49.
* **(2026-09-26)** The zoom transitions: **they go as a fade**.
* **(2026-09-26)** AG7 **can't lose skills**, and the weapons charge SP
  if they do in the original: **faithful to the original**.
* **(2026-09-26)** The droid's tutorial (164): **it's kept**.
* **(2026-09-26)** 38 now fits in VRAM (`layout-picks-the-background-tilemap.md`): there's no need to split it.
* **(2026-09-26)** The "REC" sign in 45: **stays as debt** for now.
* **(2026-09-26)** Bribing the guard (switch 29) **can be played**: the
  `DetourOfficer` (event 19 of map 8, (62,32)) offers the bribe on his
  page 2 (switches 24 and 28: 24 is turned on by event 4 of map 7 at the
  start, 28 by the first talk with the officer) and asks for **500
  credits** (`ConditionalBranch` of gold >= 500). They're gathered by selling the
  Idol to the Pawn Guy (event 24 of map 10): 600, 700 or 1000 depending on how much
  you haggle (if you haggle once more, he doesn't buy), plus the 100 that
  event 4 of map 7 gives. It's the alternative path to the Hover Tram (where the thief
  steals everything: `ChangeGold -9999` in map 13). Careful: the Idol also opens
  map 14 (page 2 of the HQ door, with switch 53).
* **(2026-09-26)** Maps 64, 83 and 84 **stay out** (confirmed by taro). They were left out because 64 (`Leaving
  Lashe City Scene`) is reached from 53, **after the race**, and 83
  and 84 (`Dalia at the Factory`, `OutsideFactory`) are **from another chapter**,
  reached from 82.

* **Space first, then the maps.** The order: the tint (if it makes
  sense to fix it), merging `release` and `test-main`, and in parallel looking at
  why the music weighs 789 KB and a pilot of battle backgrounds read from the MSU-1.
  This plan is tackled when those improvements are finished, not before.
* **Splitting maps, better not** (question 2): it has advantages, but it forces
  static analysis of the map's events and all their locations and changes, and the
  failures wouldn't be obvious. For 38 first look for another way out (fewer tiles,
  loading tiles while walking) and split only if there's no other.

1. **The limit at 49.** What does the ROM do when the player chooses "We've got to
   get out of here"? The ways out: (a) a fork of 36 that replaces that `Teleport`
   with an end-of-demo sign or with returning to the title, and that gets deleted the day
   the race goes in; (b) put 49 in as it is —the car walks freely, which is
   what taro already saw with the old recipe—; (c) have the converter compile every
   `Teleport` to an absent map as an end of demo, which changes what many
   pages of the game do. **Recommended: (a).**
2. **38 doesn't fit in VRAM.** (a) **split it**: the Vipers' HQ at the
   top is a separate island, reached only through the `Teleport`s of
   events 20, 21 and 26, so it goes to a map of its own and the street keeps the
   id 38. Estimated by distinct cells: the street ~71% of the total and the HQ ~44%,
   both far from the cap. But **`fork.py` doesn't allow adding ids** ("un fork
   reemplaza un mapa del juego, no agrega uno"): either that rule changes, or an
   id that exists and nobody reaches is used (46, 96, 97, 98), which is cheating. (b)
   prune 28 background tiles from 38 in a fork, which is artistic. (c) cut 91
   sprite ones. (d) move BG1's tilemap per layout, which is touching the engine.
   **Recommended: (a) with `fork.py`'s rule changed on purpose.**
   **(d) is done (2026-09-25)**: a fourth layout moves BG1's tilemap down to
   $1800 and gives 480 background with 384 sprite; 38 converts with 4
   background tiles and 37 sprite ones to spare, without changing any map's layout. See
   `layout-picks-the-background-tilemap.md`.
3. **The cartridge.** `release` with this is around 86% —the threshold for revisiting the
   4 MB decision— and the race comes after. And `test-main` doesn't fit with the
   18 maps. Does `test-main` stop carrying all maps (and the tests of the
   new area run on `release`, like the walkthroughs), is a third test
   cartridge built, or is the allocator first made to share the data of
   the copies (39≡7, 43≡34, 45≡19) and how much it yields measured?
4. **The transitions.** 40 asks for **zoom** (type 16) and 42 for **mosaic** (17).
   The console has mosaic (`MOSAIC`); zoom in mode 3 it doesn't. Zoom as a
   fade, declared as debt, and real mosaic?
5. **The "REC" in 45.** A second sign in ROM, or debt? It blinks with a
   parallel, so baking it like the Hover Tram doesn't work as is.
6. **AG7 in battle.** With today's filter, 6 of his 17 skills are left
   out (the multi-target ones and the whole-party one) and states don't exist.
   Is declaring it enough, or does this milestone do the multi-target scope? And the weapons'
   SP cost: is it charged?
7. **"If you went by the hover tram"**: the data says Stash's scene
   also opens through bribing the guard (switch 29), that with Arden the
   door is closed, and that without a companion the droid is mandatory to reach
   the race. Is that what he expected?
8. **83 and 84** (Dalia at the Factory) hang from Lashe City but are reached
   from 82, which is from another chapter. **64** is after the race.
   Both out?
9. **The droid's tutorial** (164). It can be kept —it requires `MemorizeLocation`
   and `RecallToLocation`, which the plant requires anyway— or skipped with a fork of
   57. Recommended to keep it.

# What wasn't measured

- **The lost frames** walking through 37 (23 events) and 38 (47): 8,
  which is the same size, was among the busiest; it's best to measure them like 11
  (`map-11-redesigned.md`) before approving milestone 1.
- **How much 38 weighs** in ROM: it doesn't convert.

The hero's title isn't a risk: the comment on `CHANGE_HERO_TITLE` in
`eventos.py` says the port doesn't show it anywhere, so the surgeon's
'Fugitive' isn't lost from the screen.
