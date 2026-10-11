---
name: "The lookout's route leaves the hero's facing locked"
description: "At speed 3, the dream scene at the lookout (map 109) cuts the hero's route before it unlocks the facing, and Talan is left unable to turn"
type: bug
status: testing
agents: [Hurón]
assignee: taro
---

Hurón found it on 2026-10-04 (`workflow/tasks/*/dos-puertas-mas-en-el-mapa-de-debug.md`,
in ABL). The hero route of 109, event 6, locks the facing and
unlocks it at the end; at speed 3 —the game's speed since the race— the route is
cut before the unlock, the lock stays and the speed ends up at 4. With
the facing locked Talan cannot turn toward Emily in her house. At
speed 4 the route finishes, and that is why the walkthrough of the first day, which
runs at 4, does not see it. The Paradise door test unlocks by hand,
with a comment to remove it when this is fixed. Still to see what
RM2k does: whether the route is cut in the original too, or it is ours.

## What RM2k does: the same

**The lock is RM2k's, measured in the original.** A copy of the game,
built with `ditto`, starts in 109 below event 6 and runs its
page without the messages —the ones before the hero route do not
touch it—; the one in 122 waits for the movement and opens the save screen
as soon as its hero route finishes. From the `.lsd`, the `party_location`:

| runtime            | speed on arrival    | `lock_facing` | speed     | cell   |
|--------------------|---------------------|---------------|-----------|--------|
| RPG_RT of 2015     | 3                   | 1             | 4         | (4, 8) |
| RPG_RT of 2015     | 4                   | 0             | 4         | (4, 6) |
| RPG_RT of 2000     | 3                   | 1             | 4         | (4, 8) |

The same as the ROM: the route of 109 is not cancelled by the teleport,
it carries on in 122, and the hero route of 122 replaces it before its 27.
At speed 3 it is 80 frames until the 26 and the page jumps at 90; the
nine steps at speed 4 do not get there.

**And speed 3 is the game's**: map 64, event 2, sets it with a `[29]`
inside a branch on switch 164, and the author's comment says
"I need to adjust Talan's walking speed based on whether he's been healed".

One more thing that came out while measuring: with the lock on, a `face_left` from a
route **does** turn him in the RPG_RT of 2000 (`facing` 3 with `lock_facing` 1),
as the ROM already did.

## What was ours: talking while locked

RM2k keeps two hero directions, `direction` and `facing`. `Move`
always changes the first one and, when locked, not the second; `CheckActionEvent`
looks at the cell of `GetDirection`. So when locked, pressing against Emily does not
turn him **but A talks to her**. The ROM had only one, `hero_dir`, and
when locked A looked where he is drawn facing: the comment on `try_toward`
declared it, with "no case in the game presses it while locked". This one
presses it.

Fixed with `hero_heading` (BSS, in `low_ram.s` next to
`hero_lock`): RM2k's `direction`, which is read only when locked. It is written by
`try_toward`, the `face_*` and the jump, and the 26 starts it from
`hero_dir`. Test: `test_el_heroe_trabado_habla_hacia_donde_intento_ir`
in ABL's `pruebas/rpgmaker/test_direccion_trabada.py`, case
`traba-heroe-habla` (the gang member on map 9): red with `main`, green with
the fix.

**And the save did not keep the lock**: loading unlocked, on the reckoning
that the only lock that outlived its route was the car's in the race, and
between 49 and 64 there is no save point. The lookout's lasts all of Distant
Paradise, which does have one. Now `hero_lock` and `hero_heading` go in
`save_table` —`SAVE_BYTES` grows by two and old saves stop
loading—. Test: `test_la_direccion_trabada_vuelve` in `test_guardar.py`,
red with the first commit and green with the second. `test_titulo_dibujo.py`
subtracts from the end of the save to find the music, and learned
the two bytes.

The Paradise door test no longer unlocks by hand: it requires the lock
and walks locked to the farm. The harness (`recorrido.mirar_a`) turns
toward an event by looking at what A looks at.

## Other routes that get cut the same way

A throwaway script goes over every page and, for each hero
route that opens something it closes later on (26/27, 28/29), counts at which
frame the closing runs at speed 3 and at 4 against what the page waits
before the next hero route —or the teleport—. It is a model
(easyrpg's steps: 16 frames at speed 3, 8 at 4; the jump by
`jump_speed`; the route wait, 20), not a measurement. The ones that come out:

* **That carry on after a teleport**: only the one in 109, and the one from
  165 to 166, which the author unlocks by hand in 166 (`[27, 39, 14]`).
* **The wait for the Lashe City tram** (9, event 25, "2 minutos" and "5
  minutos"): each pair of routes `[28, 22 steps, 29]` is replaced by the next
  pair after 90 frames. At speed 3 it never reaches the 29: each
  extra pair leaves **one more point of speed**. At speed 4 the model
  gives 88 frames against 90, and that is decided by one frame: it is not measured,
  neither in the original nor in the ROM. I tried it in the original and the copy
  stood still: I did not find out where the hero really stops to talk
  to the officer.
* **At speed 3, three scenes leave him slower forever**: 128
  event 2 (cmd 154, `[29, 23, 23, 4 steps, 13, 28]` against 120 frames),
  132 event 5 (cmd 8, `[29, 4 steps, jump, 28]` against 120) and 142
  event 2 (cmd 250, `[29, 2 steps, 28]` against 48; and the one at cmd 234 if
  the three messages are skipped quickly). They drop to 2 and do not come back. With the same
  mechanism as 109, so RM2k would have to do the same, but
  **I did not measure it** in the original.
* The one in 64 (`[26, 36, 28, 28, 8 steps, …, 29, 29]` against 30 frames) comes out
  at speed 3 and 4, but there the hero goes at 6 —the car— and ends at 16.

None of those is a ROM bug: they do what RM2k does. If they are to be
fixed, it is a game patch, in ABL.

## To merge

* Tools: Hurón's branch, two runtime commits. Reinstall
  `cartridge` in the global —`rm2k-snes-cartridges` builds from the
  `tools/runtime/` of the checkout it was installed from—.
* ABL: the `huron-direccion-trabada` branch of Hurón's clone. No new or
  changed goldens.
* Saves made before stop loading: `SAVE_BYTES` grew by two.

**Verified**: the whole ABL suite, with `main` merged into both
branches and the branch's tools installed locally, green. What it
does not cover: that the locked hero looks right walking through Paradise —that is
RM2k's, and the suite only looks at it up to talking to Emily—, and nothing of
"Other routes", which is a model.

## Speed 3 was not the game's (2026-10-05)

I found it with Dalia's tank (ABL, `dalia-tank-turns-into-dalia-on-the-bridge.md`):
in RM2k Talan does **not** reach Paradise at 3. Dr. Vago heals his ankle
(map 81, event 6, page 1) with a `[28]` that runs during a
`TintScreen` with wait, and the ROM dropped that wait: the next route
replaced the `[28]` without reading it. Fixed in `rm2k-snes-events`; from
then on Talan reaches Paradise at 4, the lookout finishes its route and comes out
unlocked, as the "4" row of the table above measures. What this task is about
—talking while locked and saving the lock— is still RM2k's and still stands,
but the game no longer exercises it at the lookout: the cases in
`test_direccion_trabada.py` and `test_guardar.py` cover it. Door 8 of the
debug map now leaves him at 4, and its test requires the hero unlocked.

And about "Other routes that get cut the same way": the model counted without the
`TintScreen`s, which now wait; the cuts there have to be looked at again
with that in mind.
