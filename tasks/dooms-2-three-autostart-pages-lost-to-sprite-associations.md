---
name: "Dooms 2: three autostart pages are lost to their ChangeSpriteAssociation"
description: "The autostart pages of maps 45, 58 and 59 don't compile: their ChangeSpriteAssociation names a graphic past the eight every map's table reserves"
type: bug
status: done
---

Seen by Calandria on 2026-10-16, with the-advocate `759aa0ba` and the
ports `4b2d41e`, while measuring
[`dooms-2-the-hero-is-not-drawn-on-some-maps`](dooms-2-the-hero-is-not-drawn-on-some-maps.md).
Not played: measured with the converter's queries.

**What it is**: Dooms 2's map pages name ten `ChangeSpriteAssociation`
pairs, and the graphics table of every map reserves eight
(`ROUTE_GFX_MAX`; `associations` in the event compiler's `indices.rs`).
The last two in file order, `x-files_lh` 1 —Will (5) on maps 45 and 58—
and `chara6gold` 2 —Bryan (3) on map 59—, come out in `graphics_dropped`,
and `compile.rs` answers `cannot()` for their command, so the **whole
page** is left out: event 1's autostart page on map 45, on map 58, and
the second one (switch 87) on map 59. Whether the association is the only
command of those pages that does not compile was not checked —the
converter's `culprits` recipe says it—. Both pairs are the actor's own LDB
graphic, so the association itself is a "put him back as he was" and
would cost nothing to drop; what is lost is the rest of each page.

It is the same ceiling as
[`vampires-dawn-transformations-dont-compile`](vampires-dawn-transformations-dont-compile.md).
Two cheap ways out to measure: an association to the actor's own LDB
graphic compiles as "clear the association" (no slot needed), or the
slots are handed out by how many maps use each pair and not by file order.

**How to see it**: `rm2k-snes-convert compile --maps $(seq 1 93)` in
`dooms2/` (with `--game-dir` and `--rtp-dir`): `graphics_dropped` on every
map, and `code: null` on those three pages.

## Closed (2026-10-20, Tijereta)

Fixed by the-advocate `0baaa0a0`, "Route graphics: the table as big as
the cartridge's map that asks for most" (Carpintero, 2026-10-19): the
table of graphics a map reserves went from eight to `ROUTE_GFX_MAX` =
255, and the associations take its first slots in every map, so Dooms
2's ten fit. The release build of the ports `68bf55b` (the-advocate
`8f290c39`) shows it: its `converter.log` says "map 45: 1 automatic event
page(s), 1 runnable", and the same for 58 and 59 (6 of 6), where the
build of 2026-10-12 said "0 runnable" and "the ROM's table of 8 is full"
for `x-files_lh` 1 and `chara6gold` 2; that warning no longer shows up.
Not played.
