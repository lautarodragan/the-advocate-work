---
name: "Dooms 2: three autostart pages are lost to their ChangeSpriteAssociation"
description: "The autostart pages of maps 45, 58 and 59 don't compile: their ChangeSpriteAssociation names a graphic past the eight every map's table reserves"
type: bug
status: draft
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
