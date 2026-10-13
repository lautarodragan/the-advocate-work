---
name: "The flashing hero shares a palette with an NPC"
description: "If a page makes the hero flash and its graphic is also used by an NPC on the map, the converter stops: on the console they would share a palette and both would flash. It leaves out map 1 of The Frozen World"
type: bug
status: draft
---

Measured by Calandria on 2026-10-11 (`exclusions-left-over-in-the-ports.md`)
and **checked today** (the-advocate `fc6f7456`, ports `a85b7e3`): with map 1
returned to The Frozen World (and map 2 still out), `just cartridges
release` stops at "map 1: a page makes the hero flash, and actor 11 is
drawn with rangedmelee[0], which an NPC of the map also uses. On the
console they share a palette and both would flash".

The stop is on purpose, and doesn't degrade: `crate::stop!` in
`rm2k-snes/convert/src/convert.rs`, which looks at each `OP_FLASH` on the
hero in the pages that run on the map. What is known of the cause
is in the message: the flash is the palette's, and the hero and the NPC
drawn with the same CharSet share one.

**What you see while playing**: Frozen's map 1 is called "Battle Screen", and it
isn't in the cartridge; an event that leads there loses the whole page (a
`Teleport` to a map that isn't there doesn't compile). Which part of the game
is lost with that wasn't looked at.

And it isn't the only thing about map 1: according to Frozen's page in the book,
"map 1 asks for 1.8 MB of code alone" (the re-sweep of 2026-10-10), that is,
behind this one may be the one from `map-streams-that-dont-fit-in-wram`.

**How to see it**: remove 1 from `excluded` in `frozen-world/rm2k-snes.toml` and
`just cartridges release` in `frozen-world/`.
