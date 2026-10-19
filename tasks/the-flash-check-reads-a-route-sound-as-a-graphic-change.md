---
name: "The flash check reads a route's sound as a graphic change"
description: "The converter's walk over a route on the hero, to know its graphic when a flash comes, steps over command 35 without its two operand bytes"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-10-19, reading `rm2k-snes/convert/src/convert.rs`
at the-advocate `9592b88b`, while writing the scan's `route_graphics`
(`pages.rs` in the events compiler), which walks the same bytecode. Not
seen in any game's build.

The converter's second round walks each `OP_ROUTE` on the hero to know
which graphic the hero has when an `OP_FLASH` comes ("the graphic the hero
has then is the last one a route on the hero gave it"). It skips command
34's operand, but not command 35's two —the sound's index, low byte
first—: a sound whose index's low byte is 34 is read as a graphic change,
with the high byte as the graphic, and a 34 among them as the start of
another command. What it decides is only whether two flashes share a
graphic, so the worst is a refusal or a missed one, not a wrong ROM.

How to see it: a route on the hero with a sound effect whose index in the
map's audio package is 34, followed by a flash of the hero.
