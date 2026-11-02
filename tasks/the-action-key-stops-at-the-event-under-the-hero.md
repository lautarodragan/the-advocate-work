---
name: "The action key stops at the event under the hero"
description: "RPG_RT fires the action pages of the hero's own cell and of the one in front, both; the runtime stops at the first that queues, so a rock whose top half is an empty event above the hero cannot be mined from above"
type: bug
status: doing
assignee: Calandria
agents: [Calandria]
---

taro, on 2026-11-02, in their words, translated:

> There are events in Zounds I can only interact with from one direction.
> It happens with some rocks that get mined (the first one that shows up
> in the story, which blocks the way to the crack) and levers in the
> crack's dungeon. I don't know whether that is a bug of our
> implementation or I did it that way in Zounds and The Advocate's
> implementation is right.

## What Hornero measured

On the delivered build (the-advocate `ac986e8d`, ports `bda2103`), with
a throwaway probe in snes9x: teleport beside the event, walk into it,
press A, look for its message or its switch.

* **Map 33, *Mountains*, the first rock of the story.** It is four
  events: 15 and 16 at (37,26) and (38,26), the bottom half, on the
  hero's layer with the mining page; 17 and 18 at (38,25) and (37,25),
  the top half, **above the hero, action-triggered, with an empty
  page**. From the left, the right and below, A gives the message. From
  above —the hero walks onto 18, which does not block, and faces down—
  **nothing**.

  `try_action` in `runtime/action_key.s` checks the hero's own cell
  first and **returns as soon as it queues something**; 18's empty page
  is queued, so the cell in front is never looked at. RPG_RT, as
  `Game_Player::CheckActionEvent` in easyrpg has it, ORs them all: the
  touch ones in front, the action ones of the own cell, **and** the
  action ones in front. The comment in `try_action` already says it is
  not modeled ("Each cell here stops at the first one it queues, and
  RM2k queues all three").
* **Map 47**: its rock's top half, events 3 and 4, is on the hero's
  layer and says "this rock is very hard": that is the game, not us.
* **Levers, maps 117 and 121** (the crack's dungeon, under *Subsuelo*):
  every lever fired from all four sides. Not reproduced; taro is asked
  which one.

## The fix asked

Queue all three, as RPG_RT does, one behind the other: the touch pages
in front, the action ones under the hero, the action ones in front. A
page that queues nothing still lets the others fire. Keep the order.

## Log
