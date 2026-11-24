---
name: "emit.rs writes each table through a call rustfmt spreads over seven lines"
description: "mapdata's emission writes some 240 tables with bytes_asm/words_asm(out, label, &decimal(…), true) and line(out, &block(…)), and 21 more by hand with format!: a writer with short methods would take some 300 lines off emit.rs"
type: refactor
status: testing
assignee: taro
agents: [Calandria]
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

### 2026-11-23, Calandria: `Inc`, and how the five were verified

the-advocate `5302c03c`, the last of the five commits on `calandria-emit`
from `eb22c280`: `f7601987` (`maps` goes), `5e810d43` (the terms),
`fdc508a5` (`picture_entry`), `40353005` (the small repeats) and this one.

#### The writer

`Inc`, in `asm.rs`, owns the `.inc`'s text: `bytes`, `words`,
`bytes_unplaced`, `words_unplaced`, `block`, `msu_block`,
`msu_only_block`, `far` —the two lines of a 24-bit pointer— and `line`,
`push_str` and `push` for the rest. The values are anything displayable,
so `decimal(…)` left almost every call and the `per_*` helpers answer
numbers. Every function of `emit.rs` and of the three modules under
`emit/` that took `out: &mut String` takes `&mut Inc`; `emit` starts it
with the header and hands back its text.

The 145 `bytes_asm`/`words_asm` and the `line(out, &block(…))` calls were
rewritten by a throwaway script that parsed each call's arguments
(`decimal` dropped, `&hexN` kept, the flag to the method's name); the
hand-written tables, the pointer tables and the submodules by hand.

* **The empty case**, table by table, as it was: `bytes` writes `$FF`
  and `words` `0`; the byte tables that wrote `0` —`comauto_mask`,
  `comauto_body`, `comauto_copied`, `slot_actor_text`, `item_txt_*`,
  `map_access`, `cm_portrait_bk`— go through `or_zero`, which says why.
  The hand-written tables that declared their exact size with no empty
  case (`menu_exp_finished`, `menu_sp_finished`, `menu_arrow_cells`,
  `slot_block_*`, `slot_glyph_cells`, `equipment_initial`, `timer_mask`,
  `sand_table`, `cm_layout_*`) now get the writer's `max(1)`: empty, they
  wrote `.block 0` and a directive with no operand, which ca65 refuses,
  so no cartridge had one.
* **Left as they were**: `ti_party_ptr`, whose pointers are `.byte
  <(x), >(x), ^(x)` lines, one per member; `dbg_pages`, eight words a
  line; the battle animations' frame table, built as lines with the
  rest of its section; the header's format string; and `record.rs`,
  `scene.rs`, `panorama.rs` and `posed.rs`, which the draft did not count
  —now the draft
  [`record-scene-and-panorama-write-their-tables-outside-the-inc-writer`](record-scene-and-panorama-write-their-tables-outside-the-inc-writer.md)—.
* **The `.inc` text**: only whitespace changes. The hand-written
  tables' indents of one, two, five, six, seven and eight spaces are the
  writer's four, and the tables joined with `,` (`fade_ramp`,
  `party_initial`, `route_after_*`) are joined with `, `.

`emit.rs`: 6053 lines at `eb22c280`, 5566 after the five commits (6011
before this one); `asm.rs` 174 to 309 with the writer and its test;
`main.rs` 355 to 317.

#### How it was verified

* **Baseline**: mapdata installed from `eb22c280` into the worktree's
  `.local-tools`, and `NO_CACHE=1 just cartridges --force` in each of the
  nine games of a ports worktree at `4c23c9e` (ABL with
  `--without-tracks`: the MSU-1 tracks do not come from mapdata), every
  `.sfc` and `.inc` of `build/` kept: 20 ROMs, 80 `.inc` files.
* **Each commit**: its mapdata installed from a detached worktree at that
  commit, the same nine builds, every `.sfc` compared with `cmp` and
  every `.inc` compared whole and, when it differed, with spaces, tabs
  and newlines removed.
* **The made-up cartridges**: a temporary test, not committed, wrote the
  `.inc` of `tests/made_up.rs`' bare and whole requests at `40353005` and
  with the writer; they differ only in whitespace, the same lines as the
  games'. The bare one reaches the empty tables no game does.
* `just crate-test mapdata` green at each commit, and `cargo clippy -p
  rm2k-snes-mapdata --all-targets -- -D warnings` clean.

#### The results

* **The ROMs**: each of the five commits leaves all 20 ROMs of the nine
  games byte for byte equal to the baseline. The `.inc` files are equal
  through `fdc508a5`. `40353005` drops three `.segment "TABLES"` lines and
  a blank one from each `mapdata.inc`, which is what is left of the
  removed switches after the bank packing. At `5302c03c` they differ from
  `40353005` only in whitespace (20 of 80 files; the opcodes and music
  `.inc` files are equal).
* **The suites**, on the branch with main merged in (main had not moved),
  with mapdata from `.local-tools` first in the PATH:
  * the-advocate `just test`: 29 passed;
  * `just rust-test --no-fail-fast`: 1237 passed, 0 failed, 3 ignored;
  * the test game, `SOUNDFONT=…/FluidR3_GM.sf2 just test-game`: 231
    passed, 6 skipped;
  * the ports root, `just boot`: 218 passed;
  * ABL, `just cartridges` and `just tests`: 1694 passed, 2 skipped.
    `abl.sfc` sha256 `3bf35fd7…691718`, the baseline's. No golden moved.
* `just lint` is red on main for reasons that do not come from here:
  rustfmt in cartridge and wally, clippy in rm2k-snes-audio. Those are
  the draft
  [`main-of-the-advocate-fails-just-lint`](main-of-the-advocate-fails-just-lint.md).
  mapdata passes fmt and clippy `-D warnings` on its own.

**To install when merging**: only `mapdata` (`just install mapdata`).
