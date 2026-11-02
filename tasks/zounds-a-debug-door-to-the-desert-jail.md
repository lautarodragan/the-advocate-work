---
name: "Zounds: a debug door to the desert's jail"
description: "One more door in Zounds' debug room: to the desert's jail —or dungeon—, past the crack, the desert's maze and the flags, with what the game has set by then"
type: feature
status: done
assignee: taro
agents: [Mulita]
---

taro, on 2026-11-02, in their words, translated:

> Could you add another door to the debug map? One that leaves you in the
> desert's jail (or dungeon or whatever, I don't remember), after
> finishing the first dungeon (the crack) and going through the desert's
> maze and the flags (a total rip-off of Ocarina of Time's desert,
> honestly).

## What is known

The debug room is map 1000, `zounds/patches/manual/maps/Map1000.json` in
the ports, a fork; `[debug]` in `zounds/advocate.toml` says what it is,
and each door's page says in its comments what it sets and from where.
The new door follows the same pattern: what the game has set **by the
time the hero first stands in that place**, played the normal way —the
crack done, the maze and the flags crossed—: switches, variables, items,
party, levels if the existing doors set them.

Which map the "jail" is, and what is set on the way, is read from the
game's events, not guessed.

## Log

**2026-11-02, Mulita.** Read from the dump (ports `bda2103`). Which place:

* After the crack (105's exit sets 184 and gives the fossil; 47's
  autostart, 185; 34, event 11, the ship leaves, 186), Bandurion takes
  the fossil and gives the Talisman (24, event 2, page 7: item 66, 198),
  without which the voice at the Death Desert's mouth (50, event 19)
  sends the party back. The Death Desert is 50, 14, 111, 112 and 113: the
  maze, its flashing stones and the "out of the way" that sends one back
  to its start. From 113 the second dungeon, the desert's cave (114 and
  its children, D2), the boy trapped behind its door; out of it, 124,
  whose autostart walks into Misërenia (49), where the boy's autostart
  sets 233.
* North of the town (109, event 37), a soldier arrests Uname —she leaves
  the party, 237— and Kazar goes alone: the soldier blocking the cave to
  the jail's front (134, event 45, 238), the farmer (139, event 9, 239),
  which opens the cave's back way (110, events 12-17) to 140, 141, 142
  and 143, whose autostart —"at least I avoided the guards"— walks him
  into the jail by its secret entrance (137, under 158 "Unamë's Rescue"
  under 138 "Jail", with the jail's song): the Misërenia jail, "Cárcel de
  Misërenia" on its sign.
* So "the desert's jail" is the Misërenia jail, and the first time the
  hero is there is 137 from 143. The desert's cave (D2) is the other
  reading of "dungeon": it is between the flags and the town.

**taro chose map 113** (relayed by Hornero the same day): the Death
Desert's last map, `5` under 50 "Norte - Peligro", the one with the
desert's cave mouth (event 1, into 114). So the door goes there, and the
jail reading above is left as what was read, not built.

* **Entry**: 112's east edge, events 246-253, jump to 113 (2,27) keeping
  the facing; the party walked right, so the door faces right. The other
  jump into 113, (4,28), is its own "out of the way" reset. 113 has no
  autostart: the party lands with control.
* **Song, weather, light**: 34's jump into 50 (events 55, 83, 84) fades
  the song, starts the sandstorm (weather 4, strength 2) and plays
  `Zounds_Desierto_02`; 50, 14, 111, 112 and 113 are "parent" for music
  and nothing in them changes song, weather or light but their exits back
  and the cave mouth. The light is the desert's, (130,120,110), as 73's
  exit from the crack leaves it.
* **State**: the dungeon door's, plus the crack (96's rock, variable 19
  +10 and 22 +1, the Querril and the pickaxe breaking taken as not
  happening; its chests not opened, as the other doors leave the
  optional undone —the first version opened them all and took the 150
  gold Kazar gives for pressing 96's button 150 times, an easter egg—),
  184, 185
  (47's autostart), 186 (34, event 11, the ship gone) and Bandurion's
  page 7 on 24 (fossil out, Talisman in, 198) — without the Talisman the
  voice at 50's mouth (event 19) sends the party back. The crack's own
  switches are read by no event outside it (measured: only 56, 75 and 184
  are, and variable 49, by 140), and 51's hole closes behind the party
  (event 215, page 2), so they stay off. The maze sets nothing that
  lasts: variables 61-63, the flashing stones, are its parallel events'.
* **The room**: six doors do not fit three apart in its bottom wall, so
  they are two apart now, 3, 5, 7, 9, 11 and 13, each post between two a
  wall tile with its four edges (4346). The other doors' columns change,
  and so does the room's golden.

**Done**, ports branch `mulita-debug-jail` (on `a995157`), docs branch
`mulita-debug-jail` (on `046ce58`). Nothing of the tools changes: nothing
to install. The door is the sixth, `Door: the maze`, column 13.

* Tests: `test_zounds_debug_map.py` with the maze in `DOORS` (map, cell,
  party, gold, items, switches, variables, golden, control) and
  `test_the_maze_door_plays_the_desert_and_the_party_walks` (113's song,
  `Zounds_Desierto_02`, and three steps right). Both red on the room
  without the door ("the maze door leads to map 1000"), green with it:
  the file, 11 passed. The other doors' columns moved and their tests
  pass; the room's golden changed (six gaps two apart) and the maze's is
  new: `/shared/captures/2026-11-02-zounds-debug-maze/`.
* The ports' whole `just boot`, with the tools of the-advocate
  `3656d606`: 138 passed and 1 red, the record player's golden, whose bar
  is drawn over the room —the difference only in the bottom wall's rows—;
  updated in its own commit, and that file and the debug map's, 12
  passed, after.
* Found: the sandstorm is not drawn —the console draws only the rain—.
  Draft `zounds-the-death-desert-has-no-sandstorm.md`, and a line in
  Zounds' Known issues in the book.
* Not covered: walking the maze itself from 113 into the cave (114),
  and anything past it; the state is checked, the way on is not played.

**2026-11-02, taro** declares it done.
