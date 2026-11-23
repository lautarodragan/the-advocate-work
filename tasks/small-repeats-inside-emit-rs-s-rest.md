---
name: "Small repeats inside emit.rs's Rest"
description: "A handful of local repeats in mapdata's emission: five loops that add a text per skill, two identical 16-bit checks for a troop's experience and gold, two lookups of an item's skill, a palette of sixteen built five ways, and segment switches that switch back on the next line"
type: refactor
status: draft
author: calandria
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

Each is small; together they are worth one change. All in
`rm2k-snes/mapdata/src/emit.rs`:

* **The texts per skill** (3015-3077): five loops of the same shape,
  `for &h in &rom_skills { map.insert(h, texts.add(&db_text(&shown, X))) }`,
  for the name, the description, the two using messages and the taught
  names. A closure `per_skill_text(|s| &s.using_message1)` keeps the order
  the texts are numbered in —which is what matters, the text indices are
  in the ROM— and takes about 20 lines.
* **A troop's experience and gold** (5145-5168): the same "read the
  model's field, refuse past 16 bits, write the words" twice; one loop over
  `["exp", "gold"]`, about 10 lines.
* **An item's skill as its place** (4314-4349): the loop for `item_skill`
  and the closure `place_of` for `item_map_skill` do the same lookup with
  two error texts; one function, about 12 lines.
* **A palette of sixteen with the transparent colour first**: built five
  times (1700-1707, 1790-1797, 2325-2330 —this one never cut to sixteen—,
  the `palette16` closure at 2758), and padded without the transparent one
  at 3426 (`arrow_colors`); one `fn palette16(&[Color]) -> Vec<u8>` at the
  top for the first four, about 15 lines.
* **Segments that switch back at once**: `.segment "TABLES"` followed by
  `.segment "RODATA"` (4448-4450, 4586-4587) and the reverse (3241-3243,
  4621-4623). They change nothing in what lands where; about 8 lines, and
  the next reader stops wondering.
* **The System suffix** `if k == 0 { "" } else { "_{k}" }` computed in
  `window_section` and again in `window_systems_table`; and
  `line_bytes`/`text_lines` of the backdrop computed in `window_pieces` and
  in `backdrop_is_one_line`. About 10 lines.

**Estimated saving**: about 75 lines.

**What it risks**: the text indices: `texts.add` numbers in call order, so
the first item must keep the order of the adds exactly —name, description
of every skill, then the messages—. The rest is local.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`); the `.inc` text equal.
