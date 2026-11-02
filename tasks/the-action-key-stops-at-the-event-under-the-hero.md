---
name: "The action key stops at the event under the hero"
description: "RPG_RT fires the action pages of the hero's own cell and of the one in front, both; the runtime stops at the first that queues, so a rock whose top half is an empty event above the hero cannot be mined from above"
type: bug
status: done
assignee: taro
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

**2026-11-02, Calandria.** Worktrees at the-advocate `ac986e8d` and the
ports `bda2103`, branch `calandria-action-sides` in both.

`git blame -C --diff-algorithm=histogram` of the two early returns in
`try_action`: the one after the own cell is from `6176f5d3` (2026-09-07),
which added the own cell to the front one and kept the order of
`CheckActionEvent` but not its OR; nothing in its message asks for the
stop. The one after the touch in front is from `a4fd1514` (2026-10-05),
which wrote the gap down itself ("is not modeled"). Neither protects
anything: both came after the queue became one bit per event, which is
what lets several be marked from one press.

The queue copes, read in the code: since `348cf58c` (2026-09-06) it is
one `FLAG_WAIT` bit per event, not a list, and `mark_waiting` counts an
event once however many times it is marked. `start_waiting` starts them
by event number, which is `Game_Map::Update`'s order too, and the
`running` loop in `events_tick` chains the next one waiting in the same
frame. So on the rock, 15 (the one in front) runs before 18 (the empty
one under the hero) in both. The note in `try_touch` that "an event that
fires twice before running comes in here twice" predates the bits
(`40cc99d6`, 2026-09-04) and is stale.

The fix, in `try_action` (`runtime/action_key.s` in the-advocate): the
three passes run one after the other with no early return, and the
answer is `waiting_n`, which is zero on entry —`events_tick` only calls
it with nobody waiting—, so no RAM is spent keeping three answers. The
counter loop is left as it was: not modeled. What the order of the calls
still decides is whose turn toward the hero survives, since
`turn_toward_hero.s` keeps one at a time and the last marked wins; with
a turning event under the hero and a touch one in front, the one under
wins, and RPG_RT turns both. Not seen in any game; written in the
comment.

`tests/test_zounds_action_from_above.py` in the ports: below the rock
first, as the control that the setup opens messages, then from (37,25)
facing down. **Red** with the global tools (the-advocate `ac986e8d`): "A
from (37, 25) of map 33 ... opened no message in 120 ticks". **Green**
with the local ones.

Measured with a throwaway probe on the fixed ROM: on the tick after the
A, `ev_running` = 14 (event 15) and `waiting_n` = 1 (event 18 waiting);
15's page ends at tick 381 and 18's empty page starts and ends in that
same frame, `waiting_n` back to 0 and control back. Two marks from one
press, run by number, nothing lost.

What was run, with the local tools (`just install-local .local-tools
cartridge project`) first on the PATH: ABL's `just cartridges` and `just
tests`, **1637 passed, 2 skipped**, no golden moved —so no ABL scene
changed with the press now also looking ahead—; the ports' `just boot`,
**137 passed**, with the new test in; `just space` in `abl/` and
`vampires-dawn/`, both at 126 of 126 banks, bank 0 at **227 B** in the
tightest (Vampires Dawn's release; ABL's tightest, `test-change-system`,
243 B). `abl.sfc` sha256 `a85df642…`.

Not covered: a turning event under the hero together with a turning one
in front, where only the last marked keeps its turn; and RPG_RT fires
**every** event on a cell, while `event_in_cell` returns the first one
it finds —left as it was, not asked here—.

Branches `calandria-action-sides`: the-advocate `12e19bb4`, the ports
`946d38f`, the book `0c325ba`. When merging, reinstall nothing of Rust:
only `runtime/` changed, and the cartridges rebuild from it.

**2026-11-02, taro**, playing Zounds' build of the-advocate `3656d606` and the ports `4ba709b` on the console, in their words, translated:

> The levers work fine now!
