---
name: "Frozen World: the cursor keeps the wrong graphic in the menu and the battle"
description: "In Frozen World's plate menu and battle the hero, which plays the cursor, shows a graphic that is not the one RM2k would show: a soldier when picking the attack plate in battle, and the plate's graphic after leaving the placement screen instead of Ludine"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by taro on 2026-10-19, playing The Frozen World with the ports
`1869b99` and the-advocate `52d564ca` (and builds before them: an old
bug, never reported).

**What is seen**, in the systems made of events —the B menu and the
battle—, where the hero is moved around as a cursor and its graphic is
changed to say what is being picked:

* picking the attack plate in battle turns the cursor into a soldier's
  graphic;
* picking the attack plate to put in a slot turns the cursor into that
  plate's graphic —which looks right—, but leaving that screen and going
  back to the menu's first one keeps the plate's graphic, instead of
  Ludine;
* taro thinks they saw the same in other places of those systems.

taro has not compared it with the original yet, but remembers paying
attention to it there and seeing it differ.

**Probably related**:
[`frozen-world-map-2-route-graphic-changes-past-the-table`](frozen-world-map-2-route-graphic-changes-past-the-table.md)
—map 2, Plate Placement, has 20 route graphic changes the ROM's table of 8
drops— and
[`a-route-graphic-on-a-paged-row-is-undone-after-a-battle`](a-route-graphic-on-a-paged-row-is-undone-after-a-battle.md).
