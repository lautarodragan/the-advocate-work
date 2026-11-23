---
name: "The .inc's constants are format strings with their values far below"
description: "mapdata's emission writes ~480 `NAME = value` constants as format strings: 105 header arguments that only repeat a constant's name, ~250 positional `{}` whose value is twenty lines below, 77 geometry numbers passed through under their own name"
type: refactor
status: draft
author: calandria
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/mapdata/src/emit.rs` 701-924, the `format!(header!(),
…)` call, with its text in `emit/header.rs`; and every
`out.push_str(&format!("TI_PARTY_ACTORS   = {}\nTI_PARTY_TILE0    = {}\n…",
a, b, …))` in `Rest` (`MENU_*` at 3260, `TARGET_*` at 3510, `ITEM_*` at
4152, `TI_*` at 4636, `EQ_*` at 4677, `END_*`, `BA_WIN_*` and so on).

**What the code does**: three shapes, the same thing each time —a name and
its value into the `.inc`—:

* The header is a 400-line format string of named arguments, and `emit`
  fills it with 220 lines of `name = VALUE,`. **105 of those are
  `map_stride = MAP_STRIDE,`**: a constant handed under its own name,
  lowercased, because the format string comes from a macro and
  `format_args!` does not capture identifiers from a string a macro made.
* About 250 constants elsewhere go as positional `{}` in a string of
  several per line, with their values in the same order further down: the
  `TI_*` block has 21 names in seven lines and 21 values in the 21 lines
  after them. Telling which value is `TI_ARROW_SAME` means counting.
* 77 of those values are `t.n("MENU_OPTIONS")` for `MENU_OPTIONS = {}`: a
  number of the screens' geometry passed through under the name it already
  has.

**The shorter form**, a sketch:

* The header as a plain string literal in a function instead of a macro,
  so `{MAP_STRIDE}` captures the constant: the 105 pass-through arguments
  go, and what is left are the ones that compute something
  (`slot_hdr_row = …`).
* Elsewhere, a name next to its value, one per line:

  ```rust
  inc.consts(&[
      ("TI_PARTY_ACTORS", n_party_actors),
      ("TI_PARTY_TILE0", party_tile0),
      ("TI_PARTY_VRAM", hex4(t.n("TI_VRAM") + party_tile0 * 16)),
  ]);
  inc.geometry(t, &["TI_PARTY_MEMBERS", "TI_PARTY_X0", "TI_PARTY_Y0", "TI_PARTY_STEP"]);
  ```

  where `geometry` writes each name with `t.n(name)`.

**Estimated saving**: some 250 lines of emit.rs: the header's 105, and
about 150 from the positional blocks, where each constant now takes two
lines (its slot in the string, its value below) and would take one, or a
word in a list of names.

**What it risks**: nothing in the ROM; a constant written with another
value would be, and that is what the check below catches. The `.inc`'s
alignment of `=` changes unless `consts` pads to the same widths, which
does not matter to ca65.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`); and the set of symbols the `.inc`
defines, with their values, equal —the `.dbg` or `ld65`'s map lists
them—, which catches a constant lost or renamed that the ROM does not
read.
