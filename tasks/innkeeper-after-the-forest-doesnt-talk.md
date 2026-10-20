---
name: "The innkeeper after the forest doesn't talk"
description: "On the map with a house and an NPC at its door, a few steps after leaving the burning forest and fighting the hover tram, the NPC should offer an inn and a shop, but he can't be interacted with"
type: bug
status: done
agents: [Mulita]
assignee: taro
---

From taro, on 2026-10-05, in their words, translated:

> on the map that has a house and an NPC at its door, which is a few
> steps after leaving the forest on fire and having fought the hover
> tram, that NPC should be interactable and offer me an inn and a shop,
> but I can't interact with him

# What it is

The forest's exit (312 ev81 p2) leaves the hero on map 66 (34,56), and twelve
cells to the west is the door to **348, "Small General Store"**: a house with
the owner standing at the door, event 1 at (9,8).

* **Page 1**, unconditioned: **touch** (trigger 1) and **on the hero's
  layer**. It's the "I'm just closing up shop" talk, which turns on switch
  975.
* **Page 2**, with 975: action button, the choice of shop and inn. That one
  already worked (`test_choose.py` covers it with 975 on).

So what didn't work was page 1, and without it 975 never turns on and page 2
never activates. It wasn't Hurón's locked direction: the hero arrives
unlocked.

**Why**: the compiler's `can_trigger` left without code every touch page on
the hero's layer, with the reason "an event on that layer blocks the way and
is never stepped on". That's true for its own cell
(`CheckEventTriggerHere`), but RM2k triggers it **from the one in front**
(`CheckEventTriggerThere`), in two ways: A —`CheckActionEvent` first looks at
the touch ones in front— and **bumping into it** —after a `Move` that didn't
advance, in `UpdateNextMovementAction`—. The runtime did neither.

# The original

With Wine (`RPG_RT_2015.exe`), with the game starting on 348 (9,10), in its
own prefix and Xvfb: one step up and A, or the arrow held against him, and
**in both cases he says "I'm sorry, I'm just closing up shop."**.

# The fix, in the tools

* `rm2k-snes-events`: `can_trigger` goes away; a touch page compiles on any
  layer. The `maps` hashes in `tests/python.rs` moved because of that (event
  4 of map 1 of the test game), stated in its header.
* Runtime, `action_key.s`: `queue_by_action`'s layer rule applies to both
  triggers (in front, the hero's layer; on its own cell, the others);
  `try_touch` marks its own cell; `try_bump` looks at the touch ones in front;
  `try_action` calls it before the two action cells, in RM2k's order; and
  `front_cell` is the computation of the front cell that used to be inside
  `try_action`. `hero.s`: a pad step that didn't start calls `try_bump`.

No new opcode (`0x47` wasn't used) and no new RAM.

# What changes in the rest of the game

There are 17 touch pages on the hero's layer. In `release`: 8 ev38
(GangMember1, p4), 11 ev14 (LTSentry1, p2 and p3), 69 ev11 p2 and 114 ev1 p3
(empty). Outside `release`: seven empty ones of 131 and 330 ev10, the rock
that gets pushed (`MoveEvent` + `ProceedWithMovement`), which would now be
pushed.

**Declared**: an **empty** action or touch page does nothing in RM2k
—`ScheduleForegroundExecution` returns early, without turning the event—,
and here it compiles to an `OP_DONE` that turns it towards the hero. It was
already like that with action pages; now 69 ev11 and 114 ev1 also turn when
bumped into.

# The test

`tests/rpgmaker/test_touch_head_on.py`: with A from (9,9), the talk, 975
and the shop open; bumping into him from (9,10), the talk and the inn, which
charges the 100. Both red with the global tools (neither opens the talk),
green with these.

No door was added on the debug map: building the "just out of the forest"
state by hand is more risk than what it saves, and the test gets there with
`go_to_map`.

# When merging

The tools are branch `worktree-agent-abd20fdcf9df6b578`, commit `a4fd1514`:
reinstall `events` and `cartridge` in the global (the runtime changed). ABL's
whole suite with them: green, no goldens moved. Screenshots of the original
and of the ROM in `/shared/captures/2026-10-05-posadero/`.

What taro has to play: leave the forest, enter 348 and talk to the owner with
A and by bumping into him; then, the shop and the inn. And along the way the
gang member of map 8 (GangMember1, p4) and the sentry of map 11 (LTSentry1),
which have pages like that and now talk.
