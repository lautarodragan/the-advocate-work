---
name: "Pipe bug on map 0008"
description: "Edge case when climbing onto the pipe in Lashe City 34,35"
type: bug
status: done
---

If I hold down the emulator's auto-fire (which is faster than
the one we have implemented directly in the rom),
I can climb up and down the pipe without pressing any other button.

EV0042 triggers the climb with Action Button. It leaves you on
EV0043. EV0043 does the same, but to go down.

From what I saw, the climb is irrelevant.
I think what happens is that the auto-fire of `A`
triggers event EV0052, which is on top of the pipe.
That event is supposed to be interactable only from
the left, never _on top of_ it.

I couldn't reproduce it with the game's own auto-fire.
I couldn't reproduce it in the original game either.

# What was done, on 2026-09-27

**The suspicion was the right one: it is `EV0052`, and the cause is that the
action key did not look at the hero's forced route.** The pipe is three
events:

    EV0042 (51,22)  lower layer, action: climbs up and leaves the hero at (55,18)
    EV0043 (55,18)  lower layer, action: goes down and leaves him at (51,22)
    EV0052 (52,21)  hero's layer, action: climbs up, faced from (51,21)

The page of `EV0043` is **a single `MoveEvent`**, without wait: it ends in the
same frame it starts and the hero goes down the pipe with the page already
closed. The ROM only asked for `step_left` at zero to accept A, and between
two steps of a route —and in a `wait`, and in the air— it is at zero. In the
harness, with A every frame, every two, and four on four off from (55,18): on
frame 49 the hero is at (52,20) facing down between two steps, A looks at the
cell in front, (52,21), and triggers `EV0052`, whose route starts from there
and not from (51,21): it ends at (56,19), on top of the building. The ROM's
autofire, four on four off, hits it or not depending on the phase with which X
is pressed.

**RM2k**: `Game_Player::UpdateNextMovementAction` returns before looking at
the button if `IsMoveRouteOverwritten()` (`game_player.cpp:297`), and only
after that comes the `IsStopping()` that `CheckActionEvent` hangs from. The
layer rule —one's own cell asks for another layer, the one in front for the
hero's— was already right.

**The fix**: `probar_accion` returns without looking at anything if the hero
has route left —`ruta_salto`, `ruta_espera`, `ruta_i < ruta_n`, the three
things of the hero in `hay_rutas` without the step one, which the caller
already checks—. `git blame` gives `1410cb87`, which wrote the action key when
the hero had no routes that survived their page, and its comment cites only
the `IsStopping()`.

**What still happens, and it is RM2k's**: with the autofire held, the hero
goes up and down forever, but now through the right events. Going down leaves
him standing **on** `EV0042`, which is of another layer and an action one, and
the next A takes him up (`CheckEventTriggerHere`); going up leaves him on
`EV0043`, and the next A takes him down. RM2k does the same with any autofire.

**Other places**: an approximate script —pages with a `MoveEvent` on the hero
without a `ProceedWithMovement` after it, following the route and checking at
each stop whether there was an action event below or in front— gives some
thirty candidate pages on maps 8, 9, 95, 261, 278, 279, 343 and 344. It is
approximate —the starting cell of the events in the hero's layer is guessed—
and it does not need refining: the fix is general and covers them all.

**The test**: `pruebas/rpgmaker/test_accion_con_ruta.py`, A every one, two and
four frames from `EV0043`: the second thing that starts has to be `EV0042` and
at (51,22). Without the fix it goes red in all three —"disparó el evento de
índice 51 con el héroe en (52, 20)"—; with it, green. The same assertion
enforces that the A after the route is not lost.

## The `wait` that stayed stuck

The fix brought to light another one, which it was hiding: with it in place,
the chapter's walkthrough got stuck at the Tasgarde gate guard (map 74) with
`ruta_espera` at 19 and the route finished. The pages of events 6, 7 and 16 on
that map send the hero `[face, wait]`: a route that **ends** in `wait` —21 in
the game, on 15 maps— left `ruta_espera` loaded forever, because `move_hero`
only called `paso_de_ruta`, the only one that counts it down, with orders left
to read. `git blame`: the gate is from `483c043f` and the `wait` arrived a day
later in `a95ac7f7`, without considering the case. Now `move_hero` also enters
with a pending wait. What changes in the game: after one of those routes the
hero stays still for the twenty frames of the `wait` before the pad moves him,
as in RM2k. No golden moved.

## What taro has to test

With the emulator's autofire held on the pipe: going down he must no longer
climb back up halfway nor appear on top of the building, at (56,19). Going all
the way up and down, end to end, is the expected behaviour.

And in Tasgarde, when talking to the gate guard and the other two who make the
hero turn: that after the turn control comes back normally, a third of a
second later than before.
