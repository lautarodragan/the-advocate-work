---
name: "The debug map, 2: the companion picks the branch"
description: "The Back Alleys let you move, the party does not get scrambled nor left without a hero when crossing, and the NPC picks the branch the doors apply"
type: bug
status: done
assignee: taro
---

# What taro reported

Playing `tasks/debug-map.md` (it starts from `main` at `455f9fc1`,
brought to `8308033b` with the world's milestone 4):

> - Choosing the Back Alleys (AFTER THE DIRECTOR IS SHOT) leaves you where the
>   director's cutscene would leave you, but there is no cutscene triggered, so
>   I stay there, and I can't move. [...] that Talan appears directly where the
>   cutscene normally ends, right before the bridge that takes you to the
>   savepoint and bum/inn.
> - Choosing Arden and going to Talan's Pad (initial) leaves Arden in the first
>   place of the party, and the hero on the map, invisible. The same happens if
>   I choose Saldra and go to LASHE CITY WITH THE CAR [...]
> - [...] that the sets of switches turn on/off as appropriate for each party
>   member. And [...] that it doesn't let you add more than one party member:
>   if you have Arden and add Saldra, Arden leaves.

The whole fix is in `parches/manual/nuevos/Map0900.json`: **the ROM was not
touched.**

# The Back Alleys: the cell at (93,0) is not walkable

The door jumped to `[20, 93, 0]`, the `Teleport` of event 15 on map 19. But the
cutscene **continues after the `Teleport`**: a route of the hero that, passing
through, goes down five, three to the left, jumps five, goes down three, jumps
three, and —no longer passing through— takes one step down. Without the route,
Talan stays at (93,0), which is not walkable, and there is no way out of a
blocked cell.

Counted over the route and confirmed with the collision of 20 (the harness's
`Mundo`): it ends at **(90,17)**, on top of the vertical bridge that goes down
to the save point (88,27) and to the inn's Bum (91,27), facing down. The route
raises the speed by one: 5, which the door already set. No switch is set by the
end of the cutscene: the scene's (89 to 92) are turned on by the page of 19
before.

# The scrambled party and the invisible hero: the map, not the ROM

**The order.** The pad's and the car's doors built the party as the game leaves
it at that point: removing Talan and adding DummyHero. With a companion inside,
removing Talan leaves the companion first, DummyHero goes in behind, and the
destination's page —page 3 of 4, the one of 36— swaps DummyHero for Talan
**behind** the companion: `[Arden, Talan]`, or `[Saldra, Talan, Arden]` on 36,
which adds Arden because of the 54 the door set. It is exactly what RM2k does:
adding goes at the end, removing shifts the ones behind. The ROM does the same.

**The invisible hero.** The leader that remains is a companion, and the
converter provides no graphic for them: `lideres_posibles` (snes_convert.py)
adds to the cartridge's actor table only those that some page leaves **first**,
because each candidate's poses are VRAM tiles loaded with the map. Arden and
Saldra never lead in the game, so they are not there, and
`elegir_grafico_heroe` (grupo.s) exits through `sin_lider` with `hero_poses` at
zero: nothing is drawn.

**Does the real game reach that case?** All the `ChangePartyMembers` batches of
the cartridge's maps were looked at (throwaway script): every batch that
removes Talan with a possible companion in the party also removes the
companions (26, 33, 37, 38, 40, 41, 47, 48, 49, 52, 54, 64, 81), and the ones
that remove only Talan (12, 18, 45) run with Talan alone —45 comes from 40,
which already removed them all—. So in today's cartridge, no: only the debug
map built that party, and it is fixed there. No `git blame` of the ROM was done
because it is not touched.

**Later on, yes, and it is noted for when it goes in**: event 2 of map 111 does
`+17 +18 -14` —Saldra and AG7 come in and Talan leaves—, so Saldra leads.
`lideres_posibles` simulates each map from the LDB's party, where that batch
leaves DummyHero first, and would not see it: the day 111 goes into the
cartridge, Saldra would be drawn without a graphic just like here. There are
others that remove only Talan (113, 145, 168, 171, 173, 175, 232) and one would
have to see with which party each one is reached. It is the approximation its
docstring already warns about.

**The fix**: no door removes Talan with a companion inside. The ones that leave
DummyHero first remove the three companions (15, 17, 18); the Back Alleys one
removes them and leaves Talan alone. That way Talan is always first, and what
the game's pages add afterwards goes behind in its order.

# The companion picks the branch

Talking to an NPC adds them, **removes the other** if there was one, turns on
their branch's switch and turns off those of the others; talking to them again
removes them and turns off theirs. The branches are the game's:

    Arden    54 NVAlly            the Neon Vipers
    Saldra   56 LTAlly            the Lazer Teeth
    AG7-17   150 AG7-17 In Party  no gang, with the droid
    none     —                    no gang, without the droid

Each NPC's sign says which branch the doors take; the doors' signs say "on
your companion's path". AG7 still runs common 37 when turning on 150 (see
`divergences/pure-parallel-common-events-run-only-when-what-they-read-changes.md`).

Each door reads 54, 56 and 150 and sets what belongs to that branch **at that
stretch**, turning off the switches of the others. Where each one comes from is
said by the page's `Comment`; it was looked up the same way as the first time,
crossing what is set before each point with what someone looks at afterwards
(throwaway scripts).

**What each branch sets at each door:**

    NORMAL START   all: turns off 54, 56 and 150 and removes the companions.

    TALAN'S PAD    all: nothing. In the game the branch does not exist yet
                   —it is chosen on 12 or on 9—, so the companion leaves and
                   54, 56 and 150 are turned off. The sign says so.

    BACK ALLEYS    Arden:  48 (the spy, overheard in the cell of 11), 54, 58
                           (the hotplate of 12 catches him), 73 (the scene
                           of 14). Gold 400.
                   Saldra: 38 (turns down the mission), 55, 56 (9: tells
                           the Lazer Teeth about the spy), 58. Gold 400.
                   AG7 and none: the Hover-Tram, 69 and 72 —Stash takes
                           the alarm clock's 100—, and his card (item 91).
                           Gold 300. The droid does not exist yet.
                   The companion leaves in all four: in the game they join
                   at the Rat Tracks (26) and in the scene of 27 on 20.

    WITH THE CAR   What the Back Alleys set, plus:
                   Arden and Saldra: nothing more. Gold 845.
                   AG7: the droid already in the party —183 (Stash's sign),
                        203 (the chip, which Stash keeps), 205 (the tunnel)
                        and 150; Stash's door closed (185 off)—. It does not
                        open the plant's chests. Gold 745.
                   None: without the droid, which can be fetched. Gold 745.
                   The party is left on DummyHero; 36 adds Talan, the
                   companion and AG7 if 150 is on.

    THE RACE       What the car sets, plus the common closing ones (151,
                   156, 160-162, 166, 182, 238; 148 and 90-92 off: 44 turns
                   them off) and the condition of page 2 of 36:
                   Arden:  159 (the Vipers' vidcast), 167-169 (the pipe, the
                           empty HQ, the whisper) and the HQ's three chests,
                           which are only reached through the pipe (544-546,
                           items 124 and 157, +250). Gold 1095.
                   Saldra: 158 (the Lazer Teeth's vidcast), 181 (the guards
                           of 47). Gold 845.
                   AG7:    the droid, as with the car. Gold 745.
                   None:   **there is no branch**: without the droid page 2 of
                           36 does not offer leaving. The door says "Talk to
                           Arden, Saldra or AG7-17 first" and neither jumps
                           nor sets anything.

    THE WORLD      What the race sets per branch, plus the three laps; 53
                   and 64 do the rest according to the branch. None: like
                   the race.

**Two things the first version set wrong and were corrected in passing**: the
race door turned on 158 and 159 together (44 turns on one per branch) and left
90 to 92 on (44 turns them off).

**To know whether there is a companion with a single condition** the race and
world doors use switch **709**, which the game does not use: unnamed, and no
page, common or troop sets it or looks at it. The ROM does not compile
`EndEventProcessing` nor the labels, and the door without a companion cannot
set anything before saying no; the other way out was repeating the whole state
three times. It is turned on and off in the same page.

# Tests

`pruebas/abl/test_mapa_de_debug.py`, on `release`:

* the Back Alleys with each companion and without: the cell (90,17), Talan
  alone and visible, the branch's switches and none of the others', the gold,
  and Talan **walking** along the bridge to (90,22);
* the pad with Arden added —taro's case—: Talan first and visible, 54 off;
* the car with each companion and without: the switches and the gold on
  arrival, and in Sector 35 the party `[Talan, compañero]` —with Saldra,
  taro's case— with Talan visible;
* the race with each companion: the switches and the gold; and without a
  companion, that it does not jump and sets nothing;
* the world with Arden;
* each NPC adds, turns on their branch, and removes; and adding Saldra with
  Arden removes Arden, and AG7 with Saldra removes Saldra.

"Visible" is Talan as leader and `hero_poses` other than zero: without an entry
in the actor table, `elegir_grafico_heroe` leaves it at zero.

**Against the map from before** (the `Map0900.json` of `8308033b`, with
`release` built separately): 16 of the 21 fail —the pad expects Talan in the
party and he never arrives, the Back Alleys stay at (93,0), the car with Saldra
does not have her branch, the NPCs do not remove the other—.

The golden `mapa-de-debug-llegada` did not change: the signs and the NPCs are
text.

With `main` merged at `43dc5303`: `just cartuchos` and `just pruebas`, all
green.

# What taro has to test

* Each NPC: the sign states the branch, and adding one removes the other.
* The Back Alleys with each one: that Talan moves, and playing up to the Rat
  Tracks —there the companion joins, or nobody without a gang—.
* The pad with a companion added: Talan visible, without a companion.
* The car with Saldra, with Arden, with AG7 and with nobody: the party in the
  sector, and with AG7 that Stash does not open again.
* The race and the world with each one, and with nobody: the sign that does
  not let you.
