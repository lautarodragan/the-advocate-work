---
name: "An event with no graphic on the hero's layer stops blocking the hero"
description: "On the test game's meadow, a graphic-less event on the hero's layer stops the hero right after the boot, and lets them walk through it once the game has idled thirty ticks"
type: bug
status: draft
author: tijereta
game: test-game
links:
  found-in: [the-test-game-playable-by-hand]
---

Seen by Tijereta on 2026-11-22, doing
[`the-test-game-playable-by-hand`](the-test-game-playable-by-hand.md),
with the-advocate `tijereta-test-game-playable` at `a0e3c1b9`.

In RM2k an event on the hero's layer blocks the hero whether it has a
graphic or not. The meadow's guide, event 11 at (7, 10), is one with no
graphic, `layer: same` and an action page, on a sign tile. With the tile
passable —ChipSet 1's upper tile 10038 at 15, as it was before that commit
made it 0—:

* booted and walked left at once, the hero stops at (8, 10), in front of
  it, and A starts its page;
* booted, thirty ticks with nothing pressed, and walked left, the hero
  walks through (7, 10) to (1, 10), and A in front of it starts nothing.

How to see it: put 10038's entry in `test-game/src/db/chipsets.json`
—row 4, third column of the first table— back to 15, `just cartridges` in
`test-game/`, and in a `Session` of the release: `run(30)`,
`walk_until_blocked("left")` from the start, which answers (1, 10) instead
of (8, 10). Without the `run(30)` it answers (8, 10).

What was not looked at: which tick it changes on, and whether the meadow's
parallel pages —"Every Frame", event 9, is one— or the boot's test page
refreshing the pages are what drops the event from what blocks. The tile
is impassable since that commit, so the hub does not depend on it, and no
test covers it.
