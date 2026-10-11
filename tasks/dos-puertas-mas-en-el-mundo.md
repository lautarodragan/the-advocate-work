---
name: "Two more doors on the debug map, in the world"
description: "One that leaves you in the Northern World / Lashe Area past the bridge, with Eisen's story done and the talk with Vago finished, and another to the left of EV0020 on 66, after the burning forest, the agents and the Hover Tram"
type: feature
status: done
assignee: taro
agents: [Hurón]
---

From taro, on 2026-10-10: "Can you add two more doors on ABL's debug
map?

1. One that leaves you right after the bridge, in the Northern World / Lashe
   Area (Map0066, one or two tiles to the left of EV0006, having
   completed Eisen's story and finished the talk with Vago. The
   bridge is maps 2059 and 0255)

2. Another that also leaves you in Northern World / Lashe Area, but to the
   left of EV0020, having finished the sequence of the forest that
   catches fire, fought the agents and the Hover Tram."

It follows `dos-puertas-mas-en-el-mapa-de-debug.md`: same method.

## Where they ended up

**The two new ones fall between door 7 and Paradise's, not after.** The
chapter's path is Sorbe (door 7), the bridge, the Tangle forest with the
tram and the ship, the tunnel, Mountain Path and Paradise: the two taro asked for
are the second and third steps. So the room went from 29 to 35 cells
wide and the doors ended up in the game's order: door 8, after the
bridge, at (25,14) with its sign at (24,11); door 9, after the Hover Tram,
at (28,14) with its sign at (27,11); and Paradise's moved to (31,14),
sign at (30,11), and became door 10. Its event is still 18 and its
page did not change; only its place and its name (`Door10`). The two new ones are
events 20 to 23. If taro prefers Paradise's where it was, it means
changing its x back and shifting the other two.

Both ask for a companion, like door 7: without one the game does not get there, and they
say so without jumping. And both add the companion, because in the game he is there:
the one who stays in Mountain Path only does so in Paradise.

## The moment of each one

**The bridge is 259 and 255**, as taro confirmed: 2059 does not exist.
259 is the Northern Highway Bridge and 255, Under the Bridge.

**Door 8: on the other side of the river, at (73,7) facing left**, one
cell from EV0006 (74,7) —which with 849 no longer lets you go back—. It is where
both ways of crossing leave you: 255 when leaving from below (event 64) and 259
when paying the guard (events 15 and 16). "The talk with Vago" is the expected
one: the one on 81 that closes Eisen's story and that already closed
door 7. On the bridge there is no other; 259 does not name Vago.

**Door 9: (34,56) facing left, one cell from EV0020** (35,56,
which leads to 312). That is where the automatic page of 312 leaves you (event 81, page 2,
with 846) after the fight with the ship, and it ends. Before: Tangle
(310), the clearing (311) with the agents, the tram that sets the forest on fire,
the exit from 312 with the timer and the Hover Tram (313).

## How the state came out

Played, not invented, same as last time: a throwaway test
went into the room, added each companion, crossed the world door (door 6) and
played with the harness the path of the walkthroughs —Sorbe, the chapter, the
bridge (from below with Arden and Saldra, paying with AG7-17), Tangle, the
tram and the ship—, without the walkthroughs' `ir_al_mapa` or `poner_exp`.
No stretch broke. At each point it dumped what
`save_table` keeps, and the pages come from the difference against the room, per
branch, with last time's generator.

What was left out is the same as in door 7 and Paradise's, and
each page's comment says so: switches 298 and 806, which nobody reads, and
variable 134. What is new:

* **Escaping is forbidden after the bridge with Arden and with Saldra.**
  The automatic page of event 10 on 255 forbids it and the game does not
  give it back until the Tangle clearing (311, event 1): door 8
  forbids it too in those two branches. With AG7-17 you do not go underneath.
* **Talan's level depends on the branch** in both: the fight under
  the bridge gives him experience. It goes inside each branch, with the
  companion's.

The levels played: after the bridge, Talan at 4 with Arden and Saldra
and at 3 with AG7-17; Arden at 4, Saldra at 5 and AG7-17 at 6.
After the tram, Talan at 7 with Arden and Saldra and at 6 with AG7-17;
Arden and Saldra at 7 and AG7-17 at 8.

**Verified** like this: the same throwaway test crossed each door with each
companion and dumped the same, and the difference against what was played is only the
usual: the two switches, variable 134, the experience (the exact amount for the
level against the one played) and HP and SP (the played one has the harness's 999;
the door, `FullHeal`). Map, cell, direction, party, gold, items,
skills, equipment, speed, permissions, tint and theme, identical. Door
7 was measured again this way and stays the same.

## The tests

In `pruebas/abl/test_mapa_de_debug.py`, per companion, red before the
new map (there is no path to (28,14) or to (31,14), and the one at (25,14) led
to Paradise):

* `test_la_puerta_despues_del_puente_sigue_al_bosque`: map, cell,
  direction, party, switches, branch, gold, speed, escape, levels; the
  arrival golden; and from there walking to Tangle.
* `test_la_puerta_despues_del_tram_sigue_a_mountain_path`: the same, and from
  there the tunnel up to Mountain Path.

The six new goldens are `mapa-de-debug-puente-*` and
`mapa-de-debug-tram-*`. **The room's, `mapa-de-debug-llegada`, did not
change**: from the arrival you cannot see beyond door 7's terminal, and what
was added is to the right of that. The photos of what follows (the
forest and Mountain Path) stay in `pendientes.txt`, like those of the other
doors.

## For merging

Only ABL: no tools were touched, there is nothing to install. Verified
with the whole suite on the branch (`just pruebas`, with the global
tools): all green. Side by side in
`/shared/capturas/2026-10-10-puertas-de-debug-mundo/`.

What the suite does not cover: experience above the exact amount for the
level, the HP and SP played, and taro playing from both doors beyond
Tangle and Mountain Path.
