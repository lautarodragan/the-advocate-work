---
name: "Zounds: a debug door to the first dungeon"
description: "One more door in Zounds' debug map, to the start of the first dungeon —the cave inside the crack—, with the switches, variables, items and party the game has there"
type: tooling
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-11-01, in their words, translated:

> Another little thing, smaller: could you add a new door to Zounds'
> debug map, that leaves you at the start of the first dungeon?

The first dungeon is the cave inside the crack, the one that plays
`Zounds_Dungeon_01` (see
[`zounds-desert-flower-plays-in-the-cave`](zounds-desert-flower-plays-in-the-cave.md)
and [`zounds-no-way-back-from-map-81`](zounds-no-way-back-from-map-81.md)).
The debug map and how its doors are made: [`zounds-a-debug-map`](zounds-a-debug-map.md).

**Done**: a door on Zounds' debug map (map 1000) to where the game first
enters the dungeon, setting the switches, variables, items, gold and party
the game has at that point —read from the dump, following the story—;
a test that walks through it and lands there; the port's page in the book
says it.

# Where it starts

From the-advocate `422f904d` (the global tools), the ports `cd41913` and
the book `9407191`, in Carpintero's worktrees, branch
`carpintero-zounds-dungeon-door` in each. Port side only.

# How the story gets there

Read from the dump (`zounds/data/`) with throwaway scripts, from where the
pickaxe door of [`zounds-a-debug-map`](zounds-a-debug-map.md) leaves off:

    33  Mountains, from 34's east edge. Event 15/16, "Roca 1" (37-38,
        25-26), closes the only way down into the crack, (37,27); with the
        pickaxe Kazar breaks it: 67, a Querril (item 24), variable 22 + 1,
        and the mining experience, variable 19 += variable 1, a random 8
        to 12. Its common event 22 levels the mining up only from 350.
    47  West of the crack, from 33 (37,27). Kazar's autostart, event 29:
        the notebook (item 35), 76 (and 75 on and off, for the scene).
    notes  Eight notes, one switch each and variable 30 + 1: on 47 the
        plants (77), the rocks (81), the mountains (82), the rise (83), the
        hole (84), the depth (85); on 51, the cave's entrance, the crack
        going on (88) and the stairs (87, event 57: "let's tell Bandurion
        first"). Those are all there are, so all eight are needed; at 8,
        47's or 51's autostart says "enough" (89).
    24  Bandurion's page 5, on 89: "be careful" (98).
    51  Event 57's page 3, on 98, lets the party onto the stairs; event
        215 under them, (32,14), fades the song and jumps to 58 (10,0).
    58  "Caida": the stairs go on down; their fourth step, (10,3), is the
        fall (ff3boss, the cave's tint 60/70/80, 111) to 59 (17,0).
    59  "Centro (START)": its autostart lands the party ("we are trapped"),
        96, and plays Zounds_Dungeon_01.

**Where the door goes**: 58 (10,0), facing down, as 51's hole leaves it:
the first cell of the dungeon the player stands on with control. From
there taro walks the fall and the landing scene as the game plays them.

**What is not done on the way**, as in the other doors: the optional
talks (the hard rock at 33 (26-27,17): 68, 69), 33's chest (58, bombs),
47's second rock (more mining). **The random**: variable 1 is 10, the
middle of 8 to 12, and so 19 is 10.

**The tint**: nothing between 34 and 51 changes it, so the desert's
130/120/110, as Kazar's jump leaves it; 58's song is the parent's,
Mountains', as the game's own jump.

# The room

Five doors do not fit four cells apart in the bottom wall (the floor is
columns 3 to 16), so they are three apart now: the game 3, the ship 6, the
desert 9, the pickaxe 12, the dungeon 15. The wall between two gaps is two
cells, its two ends. The room's golden moves with it.

# The door

Event 6 of map 1000, "Door: the dungeon", at (15,12): the pickaxe door's
page, then, each with its `Comment`, the rock (67, item 24, variables 1 and
19 at 10, 22 at 1), the notebook (item 35, 76), the eight notes and 30 at
8, 89, 98; and 51's hole's jump —EraseScreen, FadeOutBGM 2000, the
desert's tint, Teleport 58 (10,0) facing down, ShowScreen—. The question
says "The first dungeon: the stairs / down the crack, before the fall."
The JSON was written with a throwaway script that keeps the file's own
format (number lists on one line).

# Tests

In `tests/test_zounds_debug_map.py` of the ports:

* the door, as the other four: map 58, cell (10,0), Uname and Kazar, 57
  gold, the items, every game switch on, the constants and 1, 14, 17, 19,
  22, 30; golden `zounds-debug-dungeon`, and the hero walks;
* `test_down_the_dungeon_doors_stairs_the_fall_lands_in_the_cave`: down
  from there, the fall lands on 59, its scene plays and gives control,
  111 and 96 on, the party whole, `Zounds_Dungeon_01` playing.

The other doors' columns moved with the gaps. Shown red on the room
without the door (both fail: column 15 was the pickaxe's, map 34). The
room's golden moved —five gaps— and the dungeon's is new: side by side,
with the difference, in `/shared/captures/2026-11-01-zounds-dungeon-door/`.

`zounds-record-player`, the record player's bar over the same room, moved
the same way: the same 1275 pixels, only the bottom wall's box. With the
ports `just boot` (all the games, the global tools 422f904d): the first
round 113 passed and that one red; blessed, `test_zounds_common_pictures.py`
and `test_zounds_debug_map.py` again, 10 passed.

**Not covered**: playing on into the dungeon past 59; the door's "Stay";
bsnes.

# To install when merging

Nothing: no Rust, no runtime.

# What taro has to test

* "New Game": the five doors, where each was and where it is now.
* The dungeon door: down the stairs, the fall and the landing scene; the
  save point on 59; the notebook (item 35) with its eight notes; going on
  into the cave.
