---
name: "Zounds: a debug map"
description: "A map of our own with doors to the ship after the intro, the desert on first arrival with Kazar, and the desert with the pickaxe; and someone to level Kazar and Uname up"
type: tooling
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Asked by taro on 2026-10-19, to play the parts of Zounds they are testing
without replaying the way there. Like ABL's (see
[`debug-map`](debug-map.md) and
[`debug-map-2-the-companion-picks-the-branch`](debug-map-2-the-companion-picks-the-branch.md)),
a new map in the port's manual patches. It waits for
[`manual-patches-one-folder-per-kind-of-asset`](manual-patches-one-folder-per-kind-of-asset.md),
which gives new maps their ids from 1000: Zounds' is born there.

**Doors**, each setting the switches, variables and party the game has at
that point:

* the ship, right after the intro;
* the desert, just out of the ship, the first time it is reached, with
  Kazar in the party;
* the same place in the desert, with the pickaxe and the switches of
  having talked to Kazar's friend.

**Levelling up**: an object or NPC that raises Kazar's and Uname's level.
To keep it simple, entering the debug map adds Kazar to the party, and a
door to a place where the game does not have him there yet takes him out.

**How to reach it**: as in ABL, from wherever is cheapest for taro to get to
—to decide, and say in the port's page in the book—.

# Where it starts

From the-advocate `2c350d8f`, the ports `acff443` and the book `7ad39ef`,
in Carpintero's worktrees, branch `carpintero-zounds-debug` in each. Port
side only: the tools are the global ones.

# What the game has at each point

Read from the dump (`zounds/data/`), following the story's pages and
crossing, with throwaway scripts, what is set on the way with who reads it
afterwards. The way:

    intro    map 1 (its "settings" page 2: the constants and common 51),
             106, 107, 1, 4-10, 12, 13, 15, the first dream 18, and the
             jump to Uname's room, 17 (16,5)
    ship     17 wakes (29, 26, 49) -> 19, Kazar shows the ship (31) ->
             20, the boss (33; gold to 0 and +25) -> 19 (34) -> 21, the
             talk at the cafeteria (35, 27, 23) -> 25, Kazar's room, and the
             desert explanation 26-29 (39, 40) -> the bed on 17 (45) -> the
             second dream, 30 (46, 47; Uname's sprite to hero2) -> 17 (23
             off, 48, 25, 49, var 14 = 1) -> 31 -> 32, the download room
             (50, 51) -> Kazar's talk there (var 17 = 65, 49 off, 117) and
             the jump to the desert, 34 (50,52)
    desert   Kazar's autostart on 34: he joins (52, +32 gold, 3 red and 2
             green potions, 23, 25, 27, 49) -> Bandurion's house, 24, and
             his explanation, 37-40 and 45 (60, 61, 62) -> back in 24 (63,
             59) and the pickaxe (item 23, 65)

The game's own debug start (switch 329 on map 1, set by F9 in RPG Maker)
goes to the desert with Kazar but sets nothing else: it is not used.

# How it is reached: "New Game"

As in ABL: `[debug] debug_map = true` in Zounds' `rm2k-snes.toml`, and page
0 of `release` is `cases/debug-map.json` —a `Teleport` to 1000 (10,9),
Uname and Kazar in the party—. It is one menu option for taro, and
"Continue" is untouched. The plumbing was already there (`[cases]
debug_map_entry` in the project file, the new map's id from the folder);
only the case and the map were missing.

The game's map 1 has an autostart of its own (event 2, a ten-frame wait)
that races the case's page: measured, the case's `Teleport` wins, and the
room is reached on the first ticks.

**The tests that play from the title choose `real_game`**, as ABL's: the
ports' root harness, `tests/games.py`, writes the case variable to
`nothing`'s page in `Session.__init__`, after the boot and **before the
title** —page 0 is automatic and runs on the first game frame, which
`pass_the_title` has already let go by—. `Session(..., debug_map=True)`
asks for the room. The boot clears the variables before the title, and
"New Game" does not touch them.

**For a clean delivery, `false`**: measured, the ROM comes out byte for
byte as with the map files absent (see below).

# The room

Map 1000, `zounds/patches/manual/maps/Map1000.{json,tiles}`: Uname's room,
map 17 (chipset 124, already in the cartridge), 20x15, with its furniture
taken out and four gaps in the bottom wall, the one 17 already has at
column 3 and three more at 7, 11 and 15. Each gap is a door, a touch event
that asks "Go/Stay" with its destination —no signs: the question says
it—. The man in the middle (10,6), a ship's crew member
(`Zounds_Tripulation` 6), levels both up. A throwaway script built it;
from here on the JSON is edited by hand. Signs and questions are in
English, as everything in the repos.

# The doors

Each replays, in the game's order, the state commands of the pages on the
way —switches, variables, gold, items, party, Uname's sprite, the menu's
access—, with a `Comment` naming the page each comes from. Then the jump,
with the destination's song, tint and the ship's rumble as the game's jump
leaves them.

    THE GAME     map 1 (8,4), what 107 jumps to. Kazar and Uname leave: the
                 game starts with an empty party, and 1's page 2 puts her
                 in. The intro plays from the credits.
    THE SHIP     17 (16,5) facing down, as 18 leaves it: map 1's settings
                 (variables 81-83, 185, 3, 20, 21, 23, 50, 51, 91; 332,
                 116, 156, 315 off; common 51; +100 gold), the uniform
                 (7: `Zounds_Charas`), the king's permit and 15000 gold
                 (9). Kazar leaves. 17's autostart wakes her and sets 29,
                 26, 49 itself. Tint 80/80/80 and the rumble, as 18.
    THE DESERT   34 (50,52) facing left, as Kazar's talk on 32 leaves it:
                 the intro, plus the ship's way —see "What the game has at
                 each point"—: gold to 0 and +25 (the boss), Yôzar's
                 amulet (item 13, 38), Uname's sprite to `hero2` 3 (the
                 second dream), variable 14 at 1, 17 at 65, 117. Kazar
                 leaves, and his autostart on 34 puts him back with his gold
                 and potions: the game's own scene.
    THE PICKAXE  34 (50,52) facing left: the desert, plus Kazar's join
                 (52, +32 gold, items 2 x3 and 3 x2, 23, 25, 27, 49) and
                 Bandurion's (60, 61, 62, 63, 59, the pickaxe item 23 and
                 65; the party goes through Bandurion and back).

**What is not done on the way**: the chests (17's, 34's), the cafeteria's
shop, the food, Iman's flashback (42 and 43, which only 21 reads; 42 would
also make map 1 run its flashback page instead of the intro, should the
game's door be crossed after it). The exception is **Yôzar's amulet**: its
page 3, on switch 52, takes it away once Kazar joins, so it is the only
thing that cannot be had afterwards. 107's 25 potions, given only when the
count screen is left waiting, are not given either.

**Common event 51**, which the settings page calls to work out the mining
levels, does not compile —it has a `Loop`—, here as in map 1: the call is
skipped in both, so the doors leave the same as the game's port.

# The man: levelling up

`ChangeLevel` on Uname and on Kazar, with its message, "+1 level" or "+5
levels"; compiled since ABL's debug map (`OP_EXP` with `EXP_BY_LEVELS`).
Kazar's level stays with him when a door takes him out. The question and
its three options fit in one box in RM2k; here they are two —see the
draft below—.
