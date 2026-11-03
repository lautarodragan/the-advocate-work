---
name: "Zounds: debug doors to Delmar and Itân"
description: "Two more doors in Zounds' debug room, to Delmar (183) and the town of Itân (157), which the story does not reach: only the developer's Tests map (2) leads there"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

taro asked on 2026-11-02 whether Zounds offers a way to reach Delmar (183)
or Itân (157). Hornero measured from the dump (ports `3e4e95d`): every
`Teleport` of every map and common event, walked from map 1.

* Delmar, 183 under 182: entered from 185 (Casa 1), 186 (Muelle) and 188,
  its own children, and from map 2, "Tests" (event 5, to (4,37)).
* Itân, 157: only from map 2's event 5, to (19,35).
* Map 2, "Tests", under the intro: only map 75, "Super Race", leads there,
  and 75 hangs from map 2 itself. Nothing in the story reaches it.
* The "Teleport" skill (30): map 2 alone sets teleport targets
  (`TeleportTargets`, 11810), and no actor learns it.

Asked whether to add two doors to the debug room, taro, in their words,
translated:

> Go ahead

## Log

**2026-11-02, Mulita.** Read from the dump (ports `3e4e95d`).

* **Map 2, "Tests"**: its autostart (event 1, erased after) is the
  developer's test setup: switch 1 —"Strong Box", which runs common event
  11, a debug menu on a key—, a random 500,000 to 999,999 coins (variable
  95) given as gold, 81 = 150, 82 = 200, 20 = 1, 17 = 100, 21 = 100,
  Uname and Kazar in the party, items 23, 8, 89 (×50), 87 (×2) and 90,
  the Teleport skill (30) for the party and map 2 as its target. Event 5
  sets nothing: it asks "Cave/Delmar/Itan/Other" and jumps, to Delmar
  (183) at (4,37) facing up, to Itân (157) at (19,35) keeping the facing.
* **Delmar, 183** —Zounds_GreenFull, its own song—, and its children 185
  (Casa 1), 186 (Muelle), 187 (the fishing game), 184 (Water) and 188:
  no event reads a switch, a variable or an item the story sets. They
  read only whether Uname is in the party —183's parallel event 74 adds
  her and 500 gold if she is not, the developer's hook for a test play
  started there, with the database's empty starting party— and, the
  fishing game, 15 gold to play (186, event 1) and its own switch 322
  and item 91.
* **Itân, 157** —Zounds_FarAwayCity, its own song—: no exits, no one to
  talk to; its events are tiles drawn as events, and parallel event 9 is
  Delmar's hook again, without the gold.
* Neither map has encounters, and nothing on the way sets a tint or
  weather: entered from 185, 186 and 188 the jumps are a bare fade and
  `Teleport`.

**The state chosen**: the game's settings, as every door but the game's
own (map 1's page 2: the constants, common event 51 and the 100 gold),
and Uname and Kazar as the room has them, which is also what map 2's
autostart leaves. Nothing of the story: no event there reads it. Not map
2's coins, items, Teleport skill or switch 1 either: they are the
developer's test kit, and the port has its own (the room's man, the F9
screen). The 100 gold pays the fishing game; with Uname in the party the
hooks do not fire. **Facing**: Delmar up, as map 2 jumps; Itân up too
—map 2 keeps the facing, and the room's would be down, towards the map's
south edge, while (19,35) is on the path north into the town—.

**The room**: seven doors two apart fill columns 3-13 and 15; the eighth
does not fit. It grows one column, 20 to 21 wide: the floor 3-17, the
doors at 3, 5, …, 17, and the entrance (10) and the man in the middle
again.

**Found: a `Teleport`'s facing is dropped.** The Delmar golden shows
Uname facing down, the way she walked into the door: RPG Maker 2003's
fourth `Teleport` parameter, the facing on arrival, is not compiled
(`TELEPORT` in `rm2k-snes/events/src/compile.rs`; `op_teleport` has no
operand for it), and 104 of Zounds' 757 jumps ask for one —the maze
door's "facing right" onto 113 too—. A tools change that moves every
2003 game's ROM, out of this task: draft
`a-teleport-s-facing-is-not-applied.md`, and a line in Zounds' Known
issues in the book. The doors ask for the facing as RM2k would, with a
comment pointing at the draft, so they turn the day the engine does; no
test checks the facing.

**Done**, ports branch `mulita-delmar-itan` (on `3e4e95d`), docs branch
`mulita-delmar-itan` (on `9e82b10`); neither main moved meanwhile.
Nothing of the tools changes: nothing to install. The doors are the
seventh and eighth, `Door: Delmar` (column 15) and `Door: Itân` (17).

* Tests: `test_zounds_debug_map.py` with both in `DOORS` and
  `test_the_towns_off_the_story_play_their_song_and_the_party_walks`
  (Zounds_GreenFull on 183, Zounds_FarAwayCity on 157, and steps up the
  path). Red on the room without them —Delmar's "door leads to map 1000",
  Itân's column a wall—, 4 failed; green with them.
* The ports' whole `just boot`, with the tools of the-advocate
  `23b413cd`: 145 passed and 1 red, the record player's golden, whose
  bar is drawn over the room; updated in its own commit, and that file
  and the debug map's, 16 passed, after.
* Goldens: the room's (4,234 px, all in the screen's right quarter) and
  the record player's (4,143 px, the same place) move; Delmar's and
  Itân's are new. `/shared/captures/2026-11-02-zounds-debug-delmar-itan/`.
* `just space` in `zounds/`: `release`'s bank 0, 244 B, as on main.
* Not covered: Delmar's houses, pier and fishing game (184 to 188) are
  not walked into; the state they read is checked, the way there is not
  played. The facing, see above.
