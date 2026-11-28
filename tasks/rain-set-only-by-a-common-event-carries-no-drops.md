---
name: "Rain set only by a common event carries no drops"
description: "scan::has_rain looks at the maps' pages and the test pages but not at the common events, unlike has_sandstorm, so a game whose only rain comes from a common event would build without the drops and its rain would not be drawn"
type: bug
status: todo
author: hornero
links:
  found-in: [abl-forem-left-out-at-the-factory]
---

**What was seen**: noted by Tijereta while doing
[`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md),
and checked by Hornero on the-advocate `5f6d5d48`.
`rm2k-snes/convert/src/scan.rs:71`, `has_rain`, takes the maps and
`extra` —the test pages, `file_commands` in `convert.rs:462`— and looks for
a `WeatherEffects` with rain in them; the common events are not passed.
`has_sandstorm`, right below, takes `common_events` too, and so does the
new `rain_reach`. So in a game where only a common event makes it rain,
`with_rain` is false, no map carries the drops, and the rain RM2k draws is
not drawn.

No port is known to be hit: ABL and Vampires Dawn set rain on map pages
too, so they carry the drops anyway. Not reproduced on a game.

**What to do**: `has_rain` takes the common events as `has_sandstorm`
does, with a unit test in `scan.rs` (rain only in a common event), and
the nine games' ROMs checked byte for byte: any that moves was hit.

## Log

### 2026-11-28, Hornero: written, to todo

Promoted by Hornero: verified by reading the call and its signature
against `has_sandstorm`'s; the fix is not in doubt (what RM2k draws), and
the task says what to do.
