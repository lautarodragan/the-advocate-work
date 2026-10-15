---
name: "The flashing hero shares a palette with an NPC"
description: "If a page makes the hero flash and its graphic is also used by an NPC on the map, the converter stops: on the console they would share a palette and both would flash. It leaves out map 1 of The Frozen World"
type: bug
status: testing
assignee: taro
agents: [Hurón]
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

### Carpintero, 2026-10-15: on map 1 the refusal is a false positive

Read with the-advocate `497be031` and the ports `0ddf815`
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-15-frozen-worlds-battle-system.html)).
No page of map 1 flashes the hero (no `FlashSprite` on 10001 in its data).
The flash comes from common events 3, 4 and 8 (`Hero1ChoosesAnAction`,
`Hero2ChoosesAnAction`, `RecalcDone!`), which the `CommandDataHero` pages
call and the compiler pastes into map 1's bytecode; in common 3 the
`FlashSprite 10001` comes **after `Teleport 3,7,6`**, so in RM2k it runs on
map 3, where the hero has just been given `rangedmelee` 7 by a route, not
index 0. The check in `rm2k-snes/convert/src/convert.rs` walks the page's
bytecode as if all of it ran on the map that owns the page. Besides, on
map 1 the setup's first route gives the hero the CharSet `nobodyhere`.

**How to see it**: `python` over `data/db/commonevents.json` in
`frozen-world/`, common 3, commands 8 to 12 (`Teleport`, the route, the
flash). What would fix it: the check stops at a `Teleport` to another map
(the rest is that map's), or the call is not pasted (see the research,
"A call is a call").

**Hurón, 2026-10-15** (the-advocate `8d6bc064`, branch `huron-tp`): it is not
only map 1. Once a `Teleport` to a map not carried stops dropping its page
(see `a-teleport-to-a-map-not-carried-is-dropped`), The Frozen World's
`just cartridges release` stops at **map 3** with the same message: a page
there makes the hero flash while actor 11 shares `rangedmelee[0]` with an
NPC, and the page used to be left out together with its teleport to map 1 or
2. The Frozen World does not build with that change until this is fixed (or
the stop made not to apply to pages that now only show the box).

### Hurón, 2026-10-15: the check follows the page (the-advocate `ca228059`, branch `huron-tp`)

* The check now walks each page's bytecode tracking where the hero is: a
  `Teleport` moves it to the destination, and a route on the hero with
  command 34 gives it that graphic (the actor's own is only the default).
  A flash is checked against the NPCs of the map it lands on.
* **Only a flash before any teleport stops the build** (as always). One after
  a teleport is a WARNING per map: checking it as a stop broke ABL (map 32's
  pages flash the hero on 33 with actors 15, 17 and 19) and left Frozen
  World's map 3 refused. Calling that a stop again is a one-word change if
  taro wants it.
* **Map 1 gets past this check**: with 1 brought back (throwaway), no hit is
  on map 1. All the hits are on map 3, after the teleport: the hero as
  `EEEEVIL[5]`, `rangedmelee[0]` and `rangedmelee[7]` against NPCs of map 3.
* **Frozen World still does not build**, for another reason this exposed: map
  3 now carries its 198 pages that were dropped, and its `map_code` stream is
  29,912 bytes against the 19,968 that fit in WRAM
  (`map-streams-that-dont-fit-in-wram`, which was map 2's). `just boot`
  fails only on frozen-world because of it (20 of 21 pass).
* Pages that compile in the converter (sum of "runnable"): 2962 before, 3286
  of 3303 now, +324 = the 324 pages on 72 maps.
