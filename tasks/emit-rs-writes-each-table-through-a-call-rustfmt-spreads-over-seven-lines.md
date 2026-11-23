---
name: "emit.rs writes each table through a call rustfmt spreads over seven lines"
description: "mapdata's emission writes some 240 tables with bytes_asm/words_asm(out, label, &decimal(…), true) and line(out, &block(…)), and 21 more by hand with format!: a writer with short methods would take some 300 lines off emit.rs"
type: refactor
status: draft
author: calandria
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/mapdata/src/emit.rs`, all of it; the helpers are
`bytes_asm` and `words_asm` (lines 478-501) and `block` in `asm.rs`.

**What the code does**: every table of the `.inc` goes out through one of
three call shapes, each of which carries `out`, a label, a conversion and a
flag:

* `bytes_asm(out, "item_heal_rate", &per_item(&|i| …)?, true)` and its
  `words_asm` twin: 145 calls, 138 of them with `declare = true`, every one
  with its values already turned into `Vec<String>` by `decimal`, `hex2` or
  `hex4`. 54 of them do not fit a line, and rustfmt spreads each over 7 on
  average: 386 lines.
* `line(out, &block(&format!("big_tiles_{k}"), &data))`: 96 calls, 28 of
  them spread over 5 lines each (142 lines).
* And 21 tables written by hand with `format!(".block {}\nlabel:\n    .word
  {}\n", n, values.join(", "))` (`message_face_ptr`, `menu_exp_finished`,
  `menu_sp_finished`, `menu_arrow_cells`, `slot_glyph_cells`,
  `slot_actor_text`, `timer_mask`, `sand_table`, `map_access`, the three
  `slot_block_*` and `item_txt_*`…), several with their own empty-table
  rule; and seven 24-bit pointer tables written as
  `.word .loword(x)\n.byte ^x` by hand (`message_face_ptr`,
  `window_systems`, `picture_sets`, `big_table`, `screens_table`,
  `compar_table`, `ti_party_ptr`).

**The shorter form**, a sketch: a small writer that owns `out` and takes
anything displayable, so the conversion and the flag leave the call:

```rust
struct Inc { out: String }
impl Inc {
    fn block(&mut self, label: impl AsRef<str>, data: &[u8]);
    fn bytes<T: Display>(&mut self, label: &str, values: impl IntoIterator<Item = T>);
    fn words<T: Display>(&mut self, label: &str, values: impl IntoIterator<Item = T>);
    fn far(&mut self, label: &str, targets: &[String]);   // the pointer tables
    fn segment(&mut self, name: &str);
}

inc.bytes("skill_phys", per_skill(|s| s.physical_rate)?);
inc.words("item_heal_hp", per_item(|i| i.recover_hp.min(0xFFFF))?);
inc.block(format!("big_tiles_{k}"), &big.tiles);
```

`bytes_asm(…, false)`, the three tables in bank 0 without a `.block`, stay
as `bytes_unplaced`/`words_unplaced`. The hand-written tables become
`inc.words("menu_arrow_cells", hex4(…))`. Nothing about which segment a
table goes in changes.

**Estimated saving**: some 300 lines of emit.rs —the 386 + 142 lines of
spread calls down to about 150, and the 21 hand-written tables at 4 to 8
lines each down to one or two—, and `bytes_asm`/`words_asm`/`line` go.
More if the same writer is used by `record.rs`, `scene.rs` and the three
modules under `emit/`, which were not counted.

**What it risks**: little. The text of the `.inc` can keep every byte as
it is —the writer formats the same `.byte`/`.word` lines—, or change only
in whitespace if the hand-written tables' odd indents (`        .word`) are
let go. A table's empty case is the one place to look: `bytes_asm` writes
`$FF` and `.block 1`, the hand-written ones write `0`, and those bytes are
in the ROM.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges` in each game, `cmp` of every `.sfc`), and
the `.inc` diffed: no change, or whitespace only. `just crate-test
rm2k-snes-mapdata` for `made_up.rs`, whose two requests cover the empty
tables no game reaches.
