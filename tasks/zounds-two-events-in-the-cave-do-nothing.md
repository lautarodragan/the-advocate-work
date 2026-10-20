---
name: "Zounds: two events in the cave do nothing"
description: "EV0011 on map 79 and EV0005 on map 80, in the cave's Arriba, do not seem to work on the console: dropped?"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Seen by taro on 2026-10-19, playing Zounds' delivery of that day (the ports `1182513`, the-advocate `2c350d8f`).

**What is seen**: `EV0011` in `Cueva / Caída / Planta Baja / Derecha /
Arriba / 2` (map 79) does not seem to work; taro thinks the same of
`EV0005` in `Arriba / 3` (map 80). Maybe dropped by the converter.

## Log

**2026-10-19, Calandria — what they are.** Both are the same page: a touch
event (`trigger` 1) with no graphic, `EraseScreen`, `Teleport`,
`ShowScreen`, into each map's little room —map 79's event 11 at (7,3) to
map 84 "Cuartito" at (5,12), map 80's event 5 at (14,31) to map 85
"Cuartito" at (9,15)—. The converter keeps them: `degradations.json` and
`converter.log` say nothing of maps 79 and 80 but their sizes, their
automatic pages (13 and 5, all runnable) and their audio.

**The cause is the game, not the port.** Both events are on the layer
**below** the hero, and each stands on the doorway's lower half, upper
tile 59 of ChipSet 46, whose passability is 0: the cell is closed. A touch
event below the hero runs only when the hero steps on its cell
(EasyRPG's `CheckEventTriggerHere`; bumping only runs the ones on the
hero's layer, `CheckEventTriggerThere`), and a below event with no graphic
does not open the cell (`IsPassableTile` only lets an event's *tile*
rule). So walking up into the doorway turns the hero and nothing else:

* on the console, the new test below, red: "the hero is on map 79 at
  (7, 4)";
* in **EasyRPG Player 0.8.1.1**, starting at map 79 (7,4) and holding up:
  map 84 is never loaded; from map 84 down, back to map 79, it works;
* in **RPG Maker 2003's own runtime**, the game's `RPG_RT.exe` 1.0.8.0
  under Wine —a copy of the game in `~/scratch/calandria/cave-events/game`
  with the tree's start moved to each doorway and actor 1 in the starting
  party, and a copy of the Wine prefix with
  `HKLM\Software\Enterbrain\RPG2003\RuntimePackagePath` on the 2000 RTP,
  which is enough for it to start—: the hero turns up and stays, on both
  maps. Captures in `/shared/captures/2026-10-19-zounds-cave-doorways/`.

The same doorway, tiles 53 over 59, is used in exactly one more place,
map 63's event 2, and that one is on the hero's layer: there bumping
runs it. Those three cells are the only uses of tiles 53 and 59.

**The fix, in the game**: both events on the hero's layer, like map 63's.
The game is taro's repository and the port's README says retouching it is
wanted, so it goes there and RPG Maker 2003 plays it too: commit `e82e5b8`
on branch `calandria-cave-events` of `~/juegos/zounds` (from `master`
`3330c15`), one byte in each `.lmu`, written with `ditto read`/`write`
(the round trip of `Map0079.lmu` alone is byte for byte equal). Under Wine
with the two fixed maps, walking up from map 80 (14,32) lands in map 85.
Then `just dump` in the ports with `GAME_DIR` on that worktree: the
difference in `data/` is those two lines.

**The test**: `test_the_doorways_of_arriba_lead_to_their_rooms` in the
ports' `tests/test_zounds.py`, from the debug map, `go_to_map` below each
doorway and walk up until the room. Red with the old dump, green with the
new one.

**How many others.** It is not a rule of the engine the port gets wrong, so
it hits nothing else by itself. The same data pattern —a touch event below
the hero with a `Teleport`, with no tile of its own, on a cell whose upper
tile closes it— is, in Zounds, these two and map 111's event 118, one of
nine side by side on the map's top edge (the others open). Across the
ports the scan finds about a hundred more, almost all in Vampires Dawn and
on a map's edge row or column, usually in a run of exits side by side.
Whether each can be reached was not looked at one by one; whatever they
do, the console does what RPG Maker does with them.

**Verified**, with no change to the tools —the global ones, from
the-advocate `2c350d8f`—: the new test red with the ports' `1182513` dump
and green with the new one; `just boot` at the ports' root on
`calandria-cave-events` (`33263fb`), with the default `GAME_DIR` —the
unfixed game: the converter takes the events from `data/`—, 91 passed. No
runtime or converter change, so neither ABL's suite nor `just test` was
run. What the suite does not cover: the way back out of each room (map
84's and 85's exits, untouched; map 84's works in EasyRPG), and the
fixed game under RPG Maker 2003 was only tried on map 80.

**When merging**: nothing to install. Three branches, all
`calandria-cave-events`: the game's, in `~/juegos/zounds` (`e82e5b8`,
over `master` `3330c15`), which is what fixes RPG Maker 2003 and has to be
merged and pushed there so the next `just dump` does not undo the ports'
`data/`; the ports' (`33263fb`); and the book's, a section on Zounds'
page, "What the game's branch fixes in the game".

**2026-10-20, Calandria — a second look, before touching the game.**
taro did not believe a slip that simple, nor ~100 of them in Vampires
Dawn; EasyRPG does not prove anything, and moving the tree's start skips
whatever the way there sets. So, looking for another explanation:

1. **Nothing on the way changes that cell.** The game has no
   `ChangeMapTileset` (11710) anywhere; its only `TileSubstitution` (11750)
   are on maps 17 and 59, on the lower layer and for that map. Maps 79 and
   80 have no page with a condition, no autostart and no parallel; map 78's
   conditioned pages are tiles on its own cells. No common event or troop
   touches them. The one state that would open the cell is the hero
   walking through walls: a hero route's 36 sets `move_route_through`,
   which is saved and only a 37 clears. Decoding every hero `SetMoveRoute`
   in the game, four pages end with it on (map 4 ev 2, 6 ev 3, 7 ev 2 and
   **58 ev 1, the fall into the lower cave**); but map 59's autostart, where
   the fall lands, turns it off (`[28, 2, 2, 2, 2, 37, 39, 29]`), and every
   hero route between 59 and 79 turns it on and off again.
2. **The ChipSet, from the game's own `.ldb`** (ditto read of
   `RPG_RT.ldb`): ChipSet 46, "Dungeon 3", upper tiles 53 and 59 have
   passability 0 —no direction, no star, no square—. At (7,3) of map 79
   and (14,31) of map 80 the lower tile is 4000 and the upper 59; the cells
   left and right are walls (lower 4428), so below is the only side. The
   chipset image's upper tiles 53 and 59 are that green-framed doorway.
   With no star the upper tile closes the cell whatever the lower.
3. **A real path in RPG_RT.** taro's own 2017 `Save03.lsd` is on map 177,
   in the mountains; from there, through the real doors —177, 94, 55, 54,
   47, 51, 58 (the fall), 59 (its scene), 60, 78 and 79, and on to 80— with
   an EasyRPG input replay holding Ctrl (test play: through walls, no
   encounters, which RPG_RT's test play does too) and stepping round every
   touch event but each hop's exit, saved below each doorway: the saves say
   map 79 (7,4) and map 80 (14,32), `move_route_through` 0. Loaded in
   RPG_RT 1.0.8.0 in normal play, holding Up, then Enter, Space and Z
   facing the door, then down and up again: the hero turns and stays, on
   both maps; he walks fine elsewhere. Left and right are walls.
4. **Vampires Dawn**, its own `RPG_RT.exe` (RPG Maker 2000): the strict
   pattern —a touch `Teleport` below the hero, no graphic, on a cell whose
   upper tile has passability 0 and no star— is 84 events there, almost all
   on a map's edge row, each in a run of exit cells side by side, standing
   on a tree, a bush or a rock drawn on the upper layer. Tried four, a new
   game one cell inside: map 161 (0,12), 390 (9,29), 353 (35,39) and 346
   (19,29). All four do not move —no step, no encounter—, and in all four
   the neighbour exit, from the same distance, teleports (or steps and
   rolls an encounter). So in Vampires Dawn the pattern is as blocked as
   in Zounds; nobody notices because the cell next door does the job. The
   difference with Zounds' doorways is only that these have no neighbour.

Captures, with a README: `/shared/captures/2026-10-19-zounds-cave-doorways/`.

**Conclusion**: the original cannot go through either, from a real path,
in RPG Maker 2003's own runtime. Whether to fix it in the game is taro's
call; the test and the game branch stay as they are until then.
