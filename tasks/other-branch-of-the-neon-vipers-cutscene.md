---
name: "The other branch of the Neon Vipers cutscene"
description: "What the map 12 walkthrough left unexecuted: the `no` branch, the fence and map 14"
type: test
status: done
---

`pruebas/abl/test_recorrido_vipers_golden.py` plays the whole stretch through the
**"Yes, I'll do it!"** branch, which is the one that comes out of pressing A without moving the cursor of the
`ShowChoice`. Three things were left unexecuted, and all three are on the same side:

* the **"No, it's a waste of time!"** branch, which instead of teleporting goes down
  walking and leaves through the fence, with **the two 5-cell jumps** of map 12
  —7.3 px per frame, among the fastest movements in the game—;
* **event 1 at (1,47)**, the fence, with its "Climb the Fence" `ShowChoice` and
  its jump after the `Teleport`;
* **map 14**, which with these switches neither branch enters.

To take it the `ShowChoice` cursor has to be moved, which the harness does not do today;
see `Recorrido.activar` and `mirar_a`. The rest is already there: the path up to the
cutscene is the same, and the detail of each event is written in
`tasks/neon-vipers-walkthrough.md`.

Why it is worth it: the long jumps are the extreme case of `salto_avanzar_heroe`, and
this week's stuck-jump bug lived right there.

## And they are the two candidates to reproduce the shifted map

On 2026-09-23 it was measured that the covered stretch **cannot** reproduce it, not
even walking after coming back: the camera's worst jump per loop is
2 px and more than 8 are needed. The two things in this area that could get there
are precisely the ones left out:

* the `PanScreen` of the scene with the kids and the shop owner —events 51 and
  53 of map 8, at (59,23) and (59,24), which ask for switch 33— **added to the hero
  walking**, which is the recipe that `pruebas/rpgmaker/test_camara.py` puts together by
  hand;
* the fence's five-cell jump, which is 7.3 px per frame.

And what showed up measuring the fence —the camera that stays three cells shifted on
leaving— **is already answered and is not ours**: it is done by the Bum's `PanScreen`,
which nobody returns, and the original RPG_RT stays just as shifted. See
`ports/abl/decisions/the-camera-offset-after-the-gate-is-the-games.md`.

---

## As of 2026-09-26: covered

`pruebas/abl/test_recorrido_vipers_otras_ramas_golden.py`, with
`Recorrido.elegir` —see `playthrough-picks-option-n.md`—. Three
cases, which start with `ir_al_mapa` on the HQ's roof and go in through the door:
the pipe path is already played by the "Yes" stretch.

What was learned reading the events, which the description above had wrong:

- **The two five-cell jumps are not from map 12**: they are the routes of the
  "No" and of the fence, which are written in 12 but run **after** the
  `Teleport` to 8, at (40,51) → (40,56). What does run in 12 is a
  two-cell jump over the fence, and that one **does not happen**, neither here nor in RM2k: the
  `through` is inside the `begin_jump`/`end_jump` pair, where RM2k
  ignores it, and (1,49) is not walkable.
- **Neither branch leads to 14**: what leads there is page 2 of the HQ's
  door, with the Idol —item 90— and switch 53, which leaves the hero on the
  hotplate, whose page 2 is automatic and ends in `Teleport [14, 44, 13]`.
  The cutscene in 14 runs on its own, with five `PanScreen`, and ends in 16.
- **The fence is reached without the cutscene**: the short path from the door to
  (1,47) goes down column 3 and the hotplate is in column 5.
- **Landing in 8 triggers the Bum**: both exits turn on switch 36, and
  the automatic page of event 10 turns it off when it finishes. The test waits for that
  —36 seen on and then off— before looking at the cell.

**The shifted map, measured**: the five-cell jump, at speed 4,
is eleven loops of 7 or 8 px, with the camera behind at the same rate. It does not reach the
more than 8 that are needed, so this candidate is ruled out; the one left is the `PanScreen`
of the kids on map 8.

**A warning for the photos of the "Yes" stretch**: the save that starts through
"Begin the Story" has DummyHero as leader, actor 10, which has no graphic.
In `test_recorrido_vipers_golden.py` the photos of 8 and 12 come out **without
Talan**. This one sets the party —Talan is 14— before going in.
