---
name: "Dalia's tank turns into Dalia on the bridge"
description: "Playing as Dalia, in the agency vehicle that takes her to the military base, the tank's graphic becomes Dalia's halfway —I think when crossing the bridge— and continues on foot, with a walking animation"
type: bug
status: done
agents: [Hurón]
assignee: taro
---

From taro, on 2026-10-05: "when you play as Dalia, and you take the agency vehicle
that takes you to the military base, the tank's graphic turns into
Dalia's graphic halfway — and it goes the rest of the way on foot, with
walking animation and everything. I think it always happens when crossing the bridge."

## The scene

`OutsideFactory` (map 84, event 1, the "Transport"): removes Dalia (21),
adds DummyHero (10) and jumps to 66 at (59, 20). There the automatic page
`DaliaGoingToTasgarde` (66, event 14, condition: actor 10 in the party)
swaps 10 for `MobilizedCar` (22, `BLVehicles` 5), gives the hero a
58-step route **without waiting for it**, waits 8 seconds (`Wait 80`) and swaps
22 for Dalia. There is no real vehicle, nor `ChangeSpriteAssociation`,
nor a teleport along the way: the tank is actor 22's graphic, and what
removes it is the `ChangePartyMembers` at the end of the page.

The 58 steps cross the world map's bridge in steps 28 to 31
—(73, 7) to (76, 7)—. At speed 4 that is 8 frames per step, 464 against the
480 of the wait: the route ends at (93, 4) just before the swap. At
speed 3 it is 16: at 480 frames the hero is at step 30, **on the
bridge**, and continues on foot with Dalia's graphic. That is what taro saw, and the
ROM does the same with the speed set to 3 by hand.

## What RM2k does: the same, at the same speed

Measured in the original, with a copy built with `ditto` that starts on
66 with 10, lowers the speed to 3 and runs the page of event 14 with an
`OpenSaveMenu` behind the party change. From the `.lsd`:

| runtime        | speed     | cell at the swap | `route_index` |
|----------------|-----------|------------------|---------------|
| 2015 RPG_RT    | 3         | (76, 7)          | 30            |
| 2015 RPG_RT    | 4 (*)     | (93, 4)          | finished      |
| 2000 RPG_RT    | 4 (*)     | (93, 4)          | finished      |

(*) The same copy with Dr. Vago's part before it —see below—: it starts at 3 and
comes out at 4.

So the bug is not the scene: it is that **in the ROM Dalia drives at
speed 3 and in RM2k at 4**.

## The cause: `TintScreen` did not wait

Speed 3 is set by 64 (event 2, the `[29]` of Talan's ankle), and
Dr. Vago returns it to 4 when healing him: map 81, event 6, page 1,
"…able to walk quickly now". There the page does

    MoveEvent hero [28]
    TintScreen black, 0,5 s, wait
    MoveEvent hero [34 Future1 0]     ← replaces the previous route

In RM2k the `[28]` runs during the 30 frames of the fade. In the ROM the
compiler dropped the duration **and the wait** of the `TintScreen`
(`compile.rs` of the event compiler, since `c64e4d96`, the first
interpreter: the comment talks only about the gradient, the wait went along
with it), the page continued on the same frame, and the graphic's route
replaced the `[28]` without reading it. Talan, and later Dalia, stayed at 3 for the
rest of the game.

There are 508 `TintScreen` with a wait in 247 pages of the game: they all ran
faster than in RM2k.

**The fix**, in the tools: with the wait, the `TintScreen` emits
an `OP_DELAY` of tenths × 6 after the `OP_TINT`, as
`FlashSprite` already did. No new opcode nor new RAM. The gradient is still not
done: the tint arrives at once and the page waits as long as it would have lasted.

**Test**: `pruebas/rpgmaker/test_tinte_espera.py`, cases `tinte-espera`
(the route after a one-second tint arrives at 60 frames) and
`tinte-espera-vago` (Vago's part as is: the hero comes out at 4). Both
red with the tools of `main` —the route arrives on frame 1, the
hero stays at 3— and green with the fix.

## What moved with it

* **The cutscenes that tint arrive later**: the opening, 120 ticks
  from the first message; the card, 60; Vago's house, ~150. The
  fixed-tick goldens moved with their tick; the ones that come out identical
  were renamed, and the opening ones with rain are new (only
  the drops change). The A presses of the opening, +120. Side by side in
  `/shared/capturas/2026-10-05-tanque-de-dalia/`.
* **The debug map**: doors 7 and 8 were dumped from the ROM with the
  bug and left the speed at 3. Now 4.
* **The lookout on 109 no longer leaves Talan stuck**: at 4 his route finishes,
  as the tools' lookout task measures in the original. The
  test of Paradise's door requires him unstuck; talking while stuck and
  saving the stuck state are still covered by their cases.

## The other two of the family

* **The missile hatches** (`las-compuertas-de-los-misiles.md`,
  map 92): it is not this. There there is no `TintScreen` between the hatches'
  routes —they are turns (14, 15) separated by `Wait`—, and the graphic
  change lands with the three `ShowBattleAnimation` on the launchers. I did not
  reproduce it.
* **Boss Wick** (`boss-wick-se-vuelve-una-de-sus-chicas.md`): I did not look at it
  beyond the dump. 40 changes who plays Wick per page (event
  1 becomes `BLPeople` 3 and 3 becomes `People7` 2 with 160), which
  smells of pages or sprite slots, not of this. The vidcasts do
  have fades with waits, so the timing changes with this fix;
  it is not bisected.

## For merging

* Tools: Hurón's branch. Reinstall `events` and
  `convert` in the global —the event compiler goes inside the converter—. The other
  commit is only runtime comments and the lookout task.
* ABL: the branch `huron-tanque` of Hurón's clone, with `main` (`c1b4cb9`)
  merged.

**Verified**: ABL's whole suite, with `main` of both repos
merged (`c1b4cb9` and `d0e2e16c`) and the branch's tools installed
locally, three times
in a row green; `crate-test events` and `just -f tools/justfile test`.
What it does **not** cover: the tank itself played from the factory (the test
enforces the cause, Vago; the tank at speed 4 I looked at with a throwaway
test that reaches 66 and finishes the route at (93, 4) before the
swap), and the rest of the 247 pages with fades with waits, which
run slower and no golden looks at.
