---
name: "The emission reads the screens' answer and the battle model by name"
description: "rm2k-snes-screens and rm2k-snes-battle build their answers with json! and mapdata reads them back as serde_json::Value, key by key, with some 290 accessor calls and the shape checks that come with them: one set of serde types both ends share would take the reading off emit.rs"
type: refactor
status: testing
assignee: taro
author: calandria
agents: [cardon, calandria]
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
  relates: [the-converter-reads-the-stages-answers-with-python-s-truthiness, the-converter-writes-the-emission-s-request-by-hand, the-inc-s-constants-are-format-strings-with-their-values-far-below]
  blocked-by: [the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**: `request.rs` in mapdata types the maps, the faces and the full
screens, but `Emit::screens`, `Emit::battle_model`, `Emit::scene`,
`Emit::troop_pages`, `Emit::window_systems` and `BattleTables::slots` are
`serde_json::Value`. `emit.rs` reads them with the getters of `json.rs`
—`at`, `int_at`, `ints_at`, `bytes_at`, `list_at`, `text_at`, `tiles`,
`colors`—: 275 calls in `emit.rs`, 21 in `scene.rs`, 25 under `emit/`.
On the other end, `rm2k-snes-screens` builds the answer with `json!`
(`screens/src/convert.rs`, `main.rs`, 285 `json!` among the stages) and
derives no `Serialize` anywhere: the shape lives only in the key strings,
twice.

**What the code does**: each piece is fetched and converted where it is
used —`let bw_tiles = tiles(at(bw, "tiles")?)?;`,
`let (border_map, border_bars) = (&list(&maps[0])?[0], &list(&maps[0])?[1]);`,
`ints(at(of(h)?, "lines")?)?`— and then checked by hand for the shape a type
would have given: "the window's arrow has {} tiles", "a text colour has {}
rows, not twelve", "the battle's items and the screens' are not the same
list", "the slot screen's `slot_names` is not two numbers". The geometry
goes through `Geometry::n("NAME")`, which panics on a missing name.

**The shorter form**, a sketch: the answer's types once, with
`Serialize` and `Deserialize`, in the crate that writes them —or in a small
crate both depend on—, and mapdata's `request::Emit` holding them:

```rust
#[derive(Serialize, Deserialize)]
pub struct Shop { pub tiles: Vec<Tile>, pub colors: Vec<Color>,
                  pub rows: Vec<Vec<u16>>, pub patches: Vec<u16>,
                  pub layers: Vec<Vec<[i64; 3]>>, pub bars: Vec<Vec<[i64; 5]>>,
                  pub top: i64 }

let shop = &r.screens.shop_border;
inc.block("ti_border_tiles", &packed(&shop.tiles, 8));
```

Fixed-size arrays (`[i64; 4]` for a `*_at` rectangle, `[u8; 12]` for an
ink's rows) make the length checks the deserializer's, with its own
message. mapdata depends on `wally` and `rm2k-snes-battle` already, so the
battle model's types are within reach; the screens' would add
`rm2k-snes-screens` —same layer— or move to a shared crate.

**Estimated saving**: in mapdata, 200 to 300 lines —each accessor chain
gives way to a field, a good part of the 250-odd lines rustfmt spends on
them, the hand-made shape checks, and most of `json.rs`'s 99—; on the
producer side the `json!` literals become struct literals, about as long,
plus the type declarations, perhaps 100 lines. Net 100 to 200, and what
it buys besides is that a renamed key stops compiling instead of failing at
run time with "the request has no `x` where it should".

**What it risks**: the most of these drafts. It touches three crates and
the wire format: field order changes the answer's bytes, so the stages'
cache keys and answers change once (not the ROM). A key spelled one way on
one side and another on the other is exactly what it removes, but moving
there is done key by key. `Geometry` should stay a map: the screens'
layout constants are a list by name on purpose —they are re-exported to the
`.inc` by name, see
[`the-inc-s-constants-are-format-strings-with-their-values-far-below`](the-inc-s-constants-are-format-strings-with-their-values-far-below.md)—.
Best done after
[`the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures`](the-emission-keeps-fallbacks-for-answers-older-than-its-fixtures.md),
which leaves one shape per field to type.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`), the `.inc` text equal, and
`just crate-test rm2k-snes-mapdata rm2k-snes-screens` with the made-up
requests regenerated through the new types.

## Log

### 2026-11-24, Cardón: to todo

It is step **B3** —and, with B2, the battle model's half— of the plan in
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(`part-of` it, in `doing`): defined and ordered there.

### 2026-11-24, Calandria: done as B2 and B3

the-advocate `66dfeb92` (the battle's `tables` and `model`) and
`6fa77fe7` (the screens' answer), on `calandria-b`. `Emit::battle_model`
is `rm2k_snes_battle::model::Model`, `BattleTables::slots` the slots'
type, `Emit::screens` `rm2k_snes_screens::answer::Answer` and
`window_systems` a list of `OtherSystem`; mapdata depends on the screens
crate. Of mapdata's accessor calls, some 446 became 113 —what is left is
the geometry lists by name, which stay maps on purpose—; with B5 merged,
the troops' pages are `rm2k_snes_events::answer::TroopPages` too, and
`json.rs` went from 113 lines to 56, the geometry's readers. Net lines +147 and +66, not the -200 to -300 this draft
guessed for the reading alone: the types' declarations (`answer.rs` is
418 lines) are most of it. The details in the log of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md).
