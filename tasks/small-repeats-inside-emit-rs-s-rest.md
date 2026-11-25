---
name: "Small repeats inside emit.rs's Rest"
description: "A handful of local repeats in mapdata's emission: five loops that add a text per skill, two identical 16-bit checks for a troop's experience and gold, two lookups of an item's skill, a palette of sixteen built five ways, and segment switches that switch back on the next line"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [Calandria]
author: calandria
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
  relates: [emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines, picture-tables-and-common-entries-write-the-same-entry-twice, rm2k-snes-mapdata-maps-has-no-caller, the-battle-terms-by-name-are-a-42-arm-match]
  blocks: [the-stages-speak-json-nobody-types]
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

> I agree. In none of these cases is it really about reducing code,
> but improvements. Let's do the four, and then we go for those types /
> typed contracts between stages.

(taro, 2026-11-23, on this one together with
[`emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines`](emit-rs-writes-each-table-through-a-call-rustfmt-spreads-over-seven-lines.md),
[`small-repeats-inside-emit-rs-s-rest`](small-repeats-inside-emit-rs-s-rest.md),
[`picture-tables-and-common-entries-write-the-same-entry-twice`](picture-tables-and-common-entries-write-the-same-entry-twice.md),
[`the-battle-terms-by-name-are-a-42-arm-match`](the-battle-terms-by-name-are-a-42-arm-match.md) and
[`rm2k-snes-mapdata-maps-has-no-caller`](rm2k-snes-mapdata-maps-has-no-caller.md);
the typed contracts are
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md).)

## Log

### 2026-11-23, Hornero: taken by Calandria

With the other four, in one branch, one commit each, every ROM byte for
byte equal.

### 2026-11-23, Calandria: each repeat once

the-advocate `40353005`.

* **The texts per id**: `Texts::add_each(ids, |id| text)`, through
  `db_text`, in the order of `ids`. It took the enemies' names too, the
  same loop over `rom_enemies`; the order of every `add` is the one it
  was, so every text keeps its number.
* **A troop's experience and gold**: one loop over `("exp",
  "experience")` and `("gold", "gold")`, the error texts as they were.
* **An item's skill as its place**: one closure, `place_of(h, where_)`,
  with `""` for the battle's and `" on the map"` for the items screen's.
* **The palette of sixteen**: `palette16`, for the two that cut to
  sixteen (`picture_entry`, which the previous commit had already made
  one, and the shop party's closure). The battle animations' and
  `scene.rs`' battlers' pad to sixteen and never cut, so they stay: with
  more than fifteen colours they write more, and `palette16` would cut.
* **Segments**: the three `.segment "TABLES"` followed at once by
  `.segment "RODATA"` go (`item_switch`/`item_battle`,
  `item_up`/`item_txt_*`, `crit_table`/`equipment_initial`). The two the
  draft listed as the reverse, `slot_face_block` and `item_price`, are
  not empty: each wraps a table that goes in `RODATA` between two
  `TABLES` stretches, so they stay. The emission's text loses those six
  lines and nothing else.
* **The System suffix**: `system_suffix(k)`. **The backdrop**: `Backdrop`,
  with its bytes, a line's size and how many lines, and `is_one_line`.
* Every port's ROM byte for byte. The `.inc` the build leaves is the one
  after the bank packing, which has already taken every `RODATA` stretch
  into its `BANKxx` segment, so there it differs from the baseline by the
  three `.segment "TABLES"` lines and a blank one, in each of the 20
  `mapdata.inc`, and nothing else.
