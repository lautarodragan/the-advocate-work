---
name: "Book of Three: the forge, and a walkthrough test"
description: "At the forge's house the NPC asks to forge something, but the fire isn't interactive and the house can't be left; and up to there the game is right, so a played walkthrough test with goldens is worth having"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

taro, on 2026-10-12, playing `/shared/builds/other-games/` (ports
`a8ee168`, the-advocate `25d93f0a`):

* **The forge**: "I get to the forge's house and the NPC wants me to forge
  something, but the fire isn't interactive. I can't leave the house." The
  game is stuck there.
* **Up to there, everything looks perfect** —behaviour, graphics, all—, so
  it is worth an automated test for this game: what works today shouldn't
  break without anyone noticing.

The plan: a walkthrough played from the start up to the forge, with goldens
at its milestones (as ABL's `test_playthrough_golden.py`), which goes red at
the forge today and green with the fix; and the cause of the fire found and
fixed.

## The cause (Calandria, 2026-10-12)

Both symptoms are one. Coll's Forge is map 6. The fire is event 5, a
touch page with no graphic; its page plays the whole scene —the sword,
a practice battle against troop 82, Coll, Dallben— and its last command
turns switch 9 on. The door, event 1, has a page on switch 7 —which the
arrival scene turns on— that says "you need to forge me some horseshoes"
and walks Taran back in, and a page on switch 9 that lets him out.

The fire's page did not compile: its `ChangeEquipment`
`[1, 10, 0, 0, 83]` puts weapon 83 ("Crude Sword-R") on Taran, actor 10,
and the compiler only equipped armor, helmet and accessory. Measured with
`rm2k-snes-events culprits` on the release's compile request: map 6,
event 5, page 1, culprit ChangeEquipment, alone. The converter's log said
it too: map 6, 21 automatic pages, 20 runnable. The project's `just
culpables` cannot run it (draft
`ports-culpables-recipe-is-missing-its-arguments`): the request was taken
with a wrapper in the PATH.

**Not related** to common events 18 and 21
(`book-of-three-reraise-and-eilonwy-dont-compile`): the forge does not
call them.

## The fix

the-advocate, branch `calandria-forja`, `rm2k-snes/events/` only:

* a weapon on a fixed actor without two weapons compiles: OP_ACTOR with
  ACT_EQUIP on slot 0 —the runtime's `actor_equip` already wrote any
  slot—, and if the weapon is two-handed, an OP_EQUIPMENT that takes the
  shield off, which is RM2k's `ChangeEquipment(Shield, 0)`. No new opcode:
  0x4F–0x52, handed out, unused. Shields and actors with two weapons
  still do not compile.
* in its own commit, an actor past the end of an item's `actor_set` can
  use it, as `IsItemUsable` says; it read "no".

With both, The Book of Three's maps leave no `ChangeEquipment` page out:
the forge, and map 78's Dyrnwyn on actor 11 (two-handed), which no test
plays.

## The walkthrough

`tests/test_book_of_three.py` at the root of the ports, with
`tests/play_script.py` —ABL's `playthrough.py` cut down: BFS over the tiles'
collision from the game's `data/`, with ABL's pure `rm2k.py`; waits by
RAM with a cap; A to every page; frame taps in battle—. It runs with `just
arrancan` (`-k book` alone): same harness, same cartridge and same
question as `test_boot.py`. Eight goldens, snes9x and bsnes against
the same one at 15 bits: Caer Dallben, Caer Dallben East, the forge, the
practice battle waiting for the first order, after the fire (and Taran's
weapon slot holding 83), out of the forge, Dallben's cottage, and back
in Caer Dallben after the Book of Three. Red with main's tools at the
fire, green with the branch's.

## What is left

* Hen Wen's second talk (map 4) does not compile: draft
  `book-of-three-hen-wens-second-talk-does-nothing`, and a Known issues
  line in the book.
* The other maps' culprits, from the same report, not looked at in play:
  `ChangeItems` by variable in six pages (maps 31, 42, 46, 52, 86, 87), a
  hero route with diagonal steps in map 22, a `ControlVars` in map 89.
* The goldens after the forge were not compared against RM2k.

## Verified, and what to install

On the branches, with the-advocate `calandria-forja` installed locally
(`events` only): `just test` 27 passed; `just crate-test events`; ABL's
`just tests` 1265 passed, and `abl.sfc` byte for byte the same as
main's; `just boot` 9 passed, the walkthrough included. Red with
main's tools at the fire.

When merging: `just install events`, from `~/the-advocate`. Then a `just
entregar` of the other games, so taro plays the forge.

Branches: the-advocate `calandria-forja`, the-advocate-ports
`calandria-forja` (code, then goldens in their own commit),
the-advocate-docs `calandria-forja`.
