---
name: "picture_tables and common_entries write the same entry twice"
description: "mapdata's two writers of picture_data —a map's pictures and the common events' small ones— each carry the same 50 lines: the objects, the palette stored once, the half size and the two offsets of an entry"
type: refactor
status: testing
assignee: taro
agents: [Calandria]
author: calandria
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `rm2k-snes/mapdata/src/emit.rs`, `picture_tables` (1661-1752)
and `common_entries` (1760-1841).

**What the code does**: both write `PICTURE_ENTRY`-byte entries into
`picture_data` for a list of images: per image the objects (`dx`, `dy`, a
tile word, each checked to fit), its palette's sixteen colours once per
`palette_index` through a `colors_of` map, and the entry —half width, half
height, the object count, the palette byte, the objects' and the colours'
offsets—. They differ only in the palette byte's check (`< 8` and
`PICTURE_BEHIND`, or `< set.palettes`), in what the offsets count from
(the map's block or the table) and in the last four bytes (the base tile,
or the set and `$80`). The closures `byte`, `word` and `offset` and the
palette block are the same text.

**The shorter form**, a sketch: one function for an image, the
differences as arguments:

```rust
/// One image's objects and colours into `data`, and its entry.
fn picture_entry(data: &mut Vec<u8>, origin: usize, image: &PictureImage,
                 colors_of: &mut BTreeMap<i64, usize>, palette: u8,
                 tail: [u8; 4], whose: &dyn Fn(String) -> Bad)
                 -> Result<[u8; PICTURE_ENTRY]>
```

with each caller checking its own palette rule and saying its own tail.

**Estimated saving**: about 45 lines.

**What it risks**: little: the bytes are the same and both callers are
covered —the maps' by every game and `tests/pictures.rs`, the common ones
by the games that have them and by `a_common_picture_s_entry_says_its_set`
in emit.rs—.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`), and `just crate-test
rm2k-snes-mapdata`.

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

### 2026-11-23, Calandria: `picture_entry`

the-advocate `fdc508a5`.

* One function writes an image's objects, its palette's colours once per
  `palette_index` and its entry; each caller checks its own palette rule
  and gives the entry's last four bytes. It returns the whole
  `PICTURE_ENTRY` bytes, zeros past the fourteenth, which is what the
  callers' `resize` left there before.
* The maps' offsets were counted from the map's block and had `start`
  added back, so they were already indices of the table, like the common
  ones: the function counts them that way for both. A map's first tile
  goes through its 16-bit check once per map instead of once per picture.
* Covered by every game —sixteen cartridges carry common sets, all of
  them carry maps' pictures— and by `tests/pictures.rs` and
  `a_common_picture_s_entry_says_its_set`. Every port's ROM byte for byte,
  `.inc` equal.
