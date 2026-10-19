---
name: "Frozen World: the cursor keeps the wrong graphic in the menu and the battle"
description: "In Frozen World's plate menu and battle the hero, which plays the cursor, shows a graphic that is not the one RM2k would show: a soldier when picking the attack plate in battle, and the plate's graphic after leaving the placement screen instead of Ludine"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

Seen by taro on 2026-10-19, playing The Frozen World with the ports
`1869b99` and the-advocate `52d564ca` (and builds before them: an old
bug, never reported).

**What is seen**, in the systems made of events —the B menu and the
battle—, where the hero is moved around as a cursor and its graphic is
changed to say what is being picked:

* picking the attack plate in battle turns the cursor into a soldier's
  graphic;
* picking the attack plate to put in a slot turns the cursor into that
  plate's graphic —which looks right—, but leaving that screen and going
  back to the menu's first one keeps the plate's graphic, instead of
  Ludine;
* taro thinks they saw the same in other places of those systems.

taro has not compared it with the original yet, but remembers paying
attention to it there and seeing it differ.

**Probably related**:
[`frozen-world-map-2-route-graphic-changes-past-the-table`](frozen-world-map-2-route-graphic-changes-past-the-table.md)
—map 2, Plate Placement, has 20 route graphic changes the ROM's table of 8
drops— and
[`a-route-graphic-on-a-paged-row-is-undone-after-a-battle`](a-route-graphic-on-a-paged-row-is-undone-after-a-battle.md).

## What RM2k does, and the three causes (2026-10-19, Carpintero)

Read in the dump and in easyrpg-player, and reproduced in the ROM built
from the-advocate `52d564ca` and the ports `1869b99`.

Maps 2 ("Plate Placement", the B menu's "Equip Plates") and 3 ("Command
Grid", the battle's) move the hero as a cursor with `Teleport`s, and give
it each plate's graphic with route command 34, always on the hero. RM2k's
`Game_Player::MoveTo` —every `Teleport`, to another map or to the same
one— ends with `ResetGraphic`: the leader's CharSet again. There is no
`ChangeSpriteAssociation` in the game. So:

1. **A `Teleport` to the same map did not reset the hero's graphic.**
   `move_hero_to` only moved it; `pick_hero_graphic` ran only on a map
   load. Map 2's slots and its Exit jump to (3,1) and (2,1) of map 2: the
   cursor kept the plate instead of Lutine. Reproduced: `hero_poses` stays
   on the plate after the Exit. It is taro's second report.
2. **A route graphic after a jump to another map was numbered in the
   origin map's table and read in the destination's.** The page keeps
   running there (`MapEvents::after_jump`), but `ctx.graphics` was still
   the origin map's. Map 3's 208 plate pages, in 15 events, jump to map 1 (10,6) and give
   the hero the plate: Fight, `Plates1 6`, is index 1 of map 3's table,
   and index 1 of map 1's is `rangedmelee 7`, Borto —others land on
   `sforceK 1`, a soldier—. Reproduced: the hero comes out as Borto. The
   other way, map 1's `CombatController` jumps to map 3 and gives the hero
   `rangedmelee 0`, index 3 of map 1, which on map 3 is `Plates1 5`. It is
   taro's first report.
3. **The table of 8 per map**:
   [`frozen-world-map-2-route-graphic-changes-past-the-table`](frozen-world-map-2-route-graphic-changes-past-the-table.md).
   Map 2 asks for 28 graphics, map 3 for 16: the changes past the eighth
   are dropped, and the cursor keeps what it had.

4. **A common event's shared body dropped its graphic**: compiled once,
   without a map's table. The battle's turns are common events 3, 4 and 8
   —called from map 1's pages—, which jump to the grid and give the hero
   whoever picks next; the item screen, map 14, calls common event 18 for
   whoever uses the item. Reproduced: on Borto's turn the cursor is the
   Fight plate picked before. The other reading of taro's "keeps the
   previous hero".

[`a-route-graphic-on-a-paged-row-is-undone-after-a-battle`](a-route-graphic-on-a-paged-row-is-undone-after-a-battle.md)
is not one of them: Frozen World's battle is made of events, and the
cursor is the hero, not a row.

## Fixed (2026-10-19, Carpintero)

In the-advocate, branch `carpintero-cursor-graphic`:

1. `move_hero_to` —a `Teleport` to the same map— runs `pick_hero_graphic`
   and `apply_tint`, as `MoveTo`'s `ResetGraphic`.
2. Command 34's table in far RAM, sized by the cartridge's map that asks
   for most; the cap is 255. See
   [`frozen-world-map-2-route-graphic-changes-past-the-table`](frozen-world-map-2-route-graphic-changes-past-the-table.md).
3. and 4. `rm2k-snes/events/src/landings.rs`: before compiling, the
   cartridge's pages and common events are walked, and each map's table
   starts with the associations, the shared bodies' graphics where those
   bodies may run, and the graphics pages give after jumping there.
   `Ctx::jump` follows the jump through the page, and `compile_route`
   numbers there.

5. Found on the way: with the table sized by the map, Sunset over Imdahl
   stopped building —"the two passes numbered the route graphics
   differently"—: the scan, without pictures, stops a page of map 14 at its
   `ShowPicture`, and the real compilation numbered a graphic after it.
   The compilation now numbers against the scan's table, which the
   converter passes it (`Graphics::frozen`), and drops what is not there
   with the warning, as the table of eight did. Draft:
   [`a-route-graphic-after-a-picture-is-left-out-of-the-scan`](a-route-graphic-after-a-picture-is-left-out-of-the-scan.md).

The Frozen World's release drops no route graphic any more
(`degradations.json`: no `route-graphic-not-changed`, against 123 in the
build of main); ABL's drops none either (3 before: map 207's ninth graphic
and Radin's and Sern's menus, common events 42 and 44, which now change
the hero's graphic as in RM2k).

**Tests**, in the ports' `tests/test_frozen_world_cursor.py`, one per
cause, all four red against main `52d564ca`:
`test_leaving_the_slots_gives_lutine_back` (`hero_poses` back to
Lutine's), `test_a_plate_past_the_eighth_is_shown` (the cursor's cell,
pixel for pixel Focus's plate), `test_the_battle_shows_the_plate_picked`
and `test_the_next_turn_gives_the_cursor_to_borto` (goldens of the hero).
In the-advocate, `a_route_graphic_after_a_jump_is_numbered_in_the_destination`
and `landings.rs`' own.

**Not compared with the original under Wine**:
[`frozen-world-does-not-open-under-wine`](frozen-world-does-not-open-under-wine.md).
What RM2k does is read in easyrpg-player (`Game_Player::MoveTo`,
`ResetGraphic`, `CommandChangeSpriteAssociation`) and in the dump.

**Branches**: `carpintero-cursor-graphic` in the-advocate, the ports and
the book. **To install when merging**: `just install events mapdata
convert` (the runtime goes with the checkout). Verified with this
branch's tools: ABL's suite, 1573 passed and 2 skipped; the ports' `just
boot`, 83 passed; `just test` and the crate tests of events, mapdata and
convert. Bank 0: the tightest, `test-change-system`, from 69 to 56 bytes
left. The other games drop far fewer route graphics too —`degradations.json`
of each release, against the builds of main: Desert Nightmare 453 to 0,
Vampires Dawn 293 to 0, Sunset 84 to 1, El Dorado 13 to 0—, and their
goldens did not move.

**For taro to play**: the plate menu —take a plate, place it or leave by
Exit: the cursor is Lutine again— and a fight: the plate picked shows on
the battle screen, and each turn's cursor is whoever picks. Not covered by
a test: the item screen, map 14, with common event 18.
