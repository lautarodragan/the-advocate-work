---
name: "The test game, playable by hand"
description: "A playable build of the test game in /shared/builds/test-game/, where every map and every case the tests reach through the harness can be reached in play, from a hub, without the harness"
type: feature
status: doing
author: taro
assignee: Tijereta
agents: [Hornero, Tijereta]
game: test-game
---

> Could you deliver me a playable build of the test game? If it needs
> things in the tests that don't exist at runtime, like starting on map X,
> could you modify it so it is entirely testable by hand?

taro, 2026-11-22.

## Log

### 2026-11-22, Hornero: taken for Tijereta

### 2026-11-22, Tijereta: taro's change of direction, and the plan

taro, through Hornero, the same day, over the assignment's "do not move
any golden" and its separate `play` cartridge: goldens moving is
preferred, the tests should be as close to real play as possible, and
modifying them is the plan, because

> mocking is a code smell

So a single `release`, which starts on the hub; the tests reach their map
and their case the way a player does, through the hub's menus, and keep
the harness's shortcut only where playing it is absurdly slow or
impossible, saying why on its line. Moved goldens go in a commit of their
own, with before and after in `/shared/captures/2026-11-22-test-game-playable/`
for taro to approve before the merge.

What the harness does that a player cannot, read at the-advocate
`1b8825d8`:

* **The cases.** `Session(core, case=…)` writes the case variable, 1000,
  and turns the test pages' switch off before the first frame: the
  converter puts one automatic page per case on event 0 of the map the
  cartridge boots on —page k asks for variable 1000 at least k— and a last
  empty one that asks for the switch, which each page turns on first.
* **Switches turned on from outside**: `test_conditional.py`'s 1220
  before the case, `test_jumps.py`'s dispatcher, 1430, before entering the
  lookout, and `test_erase_event.py`'s statue's other page and pacer.
* **`go_to_map`**, a door's fade asked of the ROM from outside: the
  erasure, the doors, the lookout and the clearing.
* **RAM poked**: `jumps_left` to zero, the hero's facing, and the hero's
  speed.

The hub is **the meadow itself**, map 1, so no new map: the test pages
live on the map the cartridge boots on, and half the cases run against the
meadow's events —the chain of calls, the switch past 1023, the boxes over
its grass—. A new start map would have carried the pages away from them.
The meadow gets a guide, who teleports to every map, and a tester, who
offers every case in `ShowChoice` menus and starts it the way the harness
does: the variable, the switch, and the hero back on the start cell.
