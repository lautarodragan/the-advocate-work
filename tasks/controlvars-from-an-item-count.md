---
name: "ControlVars: from an item count"
description: "A variable set from the number of an item held (operand kind 4) does not compile: Book of Three 5, Frozen World 13 (the use-item menu), Vampires Dawn 47"
type: feature
status: draft
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three and The Frozen World leave out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).

**What is seen** (not played):

* Book of Three: map 89, event 2, page 1 (sets a variable from the number of
  Denner's Tails, item 126), and common event 21, `Eilonwy's Upgrades`
  (parallel; it counts the Essences of Fire, Water, Thunder and Life, items
  128 to 130 and 237). The second is already in
  [`book-of-three-reraise-and-eilonwy-dont-compile`](book-of-three-reraise-and-eilonwy-dont-compile.md).
* Frozen World: map 14, "Use Menu", events 3 to 7: five pages that count the
  consumables ("have \V[0103]"). The map is part of the combat, which is not
  in the cartridge for other reasons.

**Where it stops**: `CONTROL_VARS` in `compile.rs` takes the operand kinds
constant, variable, random, "other" (gold and timer), an actor's HP and SP,
and a character's cell. Kind 4, "item count", falls to the last `else` and
does not compile. The inventory is `FAR_ITEMS`, one byte per item, so the
data is already there.

**Uses in the eight dumps**: Book of Three 5, Frozen World 13, Vampires Dawn
47 (its summons, see
[`vampires-dawn-summons-dont-compile`](vampires-dawn-summons-dont-compile.md)).
