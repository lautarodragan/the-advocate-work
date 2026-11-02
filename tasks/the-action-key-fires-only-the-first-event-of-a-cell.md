---
name: "The action key fires only the first event of a cell"
description: "RPG_RT's CheckEventTriggerHere and CheckEventTriggerThere walk every event on the cell; the runtime's event_in_cell returns the first row it finds, so a second event on the same cell, with its own page, is never fired by the action key or a touch"
type: bug
status: draft
---

Seen by Calandria on 2026-11-02, reading the code while doing
[`the-action-key-stops-at-the-event-under-the-hero`](the-action-key-stops-at-the-event-under-the-hero.md),
at the-advocate `12e19bb4` (branch `calandria-action-sides`). Not seen
playing: no game is known yet to put two triggerable events on one cell.

`Game_Player::CheckEventTriggerHere` and `CheckEventTriggerThere` in
easyrpg (`src/game_player.cpp`) loop over **all** the map's events and
schedule every one on the cell whose trigger and layer match.
`event_in_cell` in `runtime/action_key.s` returns the first row whose
position matches —then a twin, if none—, so `action_in_cell` looks at one
event per cell. Two events on the cell under the hero, or two in front,
only the lower-numbered one fires.

To see whether it matters: count, per game, the cells that hold two or
more events whose pages have an action or touch trigger on a compatible
layer, from each port's `data/maps/*.json`.
