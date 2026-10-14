---
name: "The event's touch from another layer does not fire"
description: "A trigger-2 page on a layer other than the hero's fires when the hero steps onto it, but not when the event steps onto the hero, nor while the hero stands on it: RM2k's CheckEventCollision and the player's per-frame check"
type: bug
status: draft
---

Seen by Aguará on 2026-10-14, reading the code while fixing
[`abl-the-agents-on-the-road-to-paradise-do-not-come`](abl-the-agents-on-the-road-to-paradise-do-not-come.md),
with the-advocate `a7f278e6` plus that task's branch. **Not seen in a
game**: no game's case was looked for.

**What the code does**: since that task the event's touch —trigger 2,
`Trigger_collision`— fires in three ways: like touch from the hero's
side (stopping on the cell, a bump, the action key) and when an event on
the **hero's layer** tries to step onto him and is refused —
`collide_with_hero` in `runtime/event_routes.s`, RM2k's
`Game_Event::CheckCollisonOnMoveFailure`—.

What RM2k also does and the ROM does not:

* `Game_Event::CheckEventCollision`: an event on **another** layer
  (below or above the hero) that ends a step on the hero's cell fires
  its trigger-2 page.
* `Game_Player::UpdateNextMovementAction` asks, on every frame the hero
  stands still without a page running, for the trigger-2 events on
  another layer at his own cell (`CheckEventTriggerHere({collision})`):
  the hero standing on top of one fires it again once the page ends.

**Where it would show**: trigger-2 pages with commands on another layer,
counted over each port's `data/` (the page's `layer`, 1 is the hero's):
none in ABL (64 pages, all on the hero's layer) nor in Frozen World
(92); 1 of 40 in Desert Nightmare; 44 of 152 in Vampires Dawn, 39 of
them below the hero.
