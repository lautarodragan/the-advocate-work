---
name: "The trim guesses which maps go painted"
description: "The RAM's trim ranks a map's still pieces as `Loss::Painted` whenever `[graphics] painted_events` names the map, but Wally may then refuse to paint it; with `painted_events = true` the guess would be wrong on every map that cannot be one picture"
type: bug
status: draft
author: carpintero
agents: [Carpintero]
---

Found by Carpintero on 2026-11-19, reading the code for
[`the-converter-s-stages-and-what-each-spends`](the-converter-s-stages-and-what-each-spends.md),
with the-advocate `4f38ea03`. Not reproduced on a cartridge: it is read
from the code.

**What was seen.** `Game::trim` (`game.rs` in rm2k-snes-convert) asks
`self.painted_events.on(id)` —the project's knob alone— and with it
`trim::left_out_painting` turns every `Looks` and `LooksAndStillWall`
piece into `Loss::Painted`, which is left out before `Looks`. Wally,
later, paints only a map that can be one picture: `painted_pieces` in its
`map.rs` refuses a map with no panorama of its own, one whose panorama
moves against it, one where ChipSet tiles animate, or one whose
substitutions need rows ("the still pieces are not painted into it:
…"). On such a map the pieces the trim left out are not painted and
lose their looks (`event-left-out` still lists them, so nothing is
hidden); and a `LooksAndStillWall` piece went before the `Looks` events,
which is not the order the trim uses without the knob.

**Why it does not show today.** Desert Nightmare's list of 95 maps was
measured map by map, and the maps on it are painted. It would show with
[`painted-events-chooses-its-maps`](painted-events-chooses-its-maps.md),
whose `true` names every map, or with a hand list that names a map Wally
refuses.

**What would fix it**: the trim asking the same question Wally asks
—whether the map can be one picture— instead of the knob, which needs
the map's panorama and ChipSet animation before the trim; or Wally's
refusal reported back so the trim runs again on that map without
`painting`. Either way, the trim keeps running before Wally, which needs
its numbering: see the book's `internals/the-converters-stages.md`.
