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

**What map 1 is** (Calandria, 2026-10-14, the-advocate `14e200fc`, ports
`f775b66`; [research](https://lautarodragan.github.io/the-advocate-docs/progress/book-of-three-and-frozen-world.html)):
it is the game's combat. Frozen World has no `EnemyEncounter` at all; its
fights run on this map ("Battle Screen": 48 events, 28,989 commands, one of
them a page of 1,801), and 324 pages on 72 maps that teleport to it are left
out. The stop was run again today with only map 1 brought back, and it is the
same message; what comes after it is not known.

**Hurón, 2026-10-15** (the-advocate `8d6bc064`, branch `huron-tp`): it is not
only map 1. Once a `Teleport` to a map not carried stops dropping its page
(see `a-teleport-to-a-map-not-carried-is-dropped`), The Frozen World's
`just cartridges release` stops at **map 3** with the same message: a page
there makes the hero flash while actor 11 shares `rangedmelee[0]` with an
NPC, and the page used to be left out together with its teleport to map 1 or
2. The Frozen World does not build with that change until this is fixed (or
the stop made not to apply to pages that now only show the box).
