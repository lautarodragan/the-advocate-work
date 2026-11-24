---
name: "The event compiler's requests are built and read by hand"
description: "The converter builds the event compiler's scan and compile requests as a serde_json Map key by key (`compiler.rs`), and the events crate reads them back field by field (`lib.rs`); so `MapInfo` still carries the pictures' table and the big pictures' table as `Value`, the last two between two stages"
type: refactor
status: todo
author: calandria
links:
  found-in: [the-emission-s-request-still-takes-seven-pieces-through-json]
  relates: [the-stages-speak-json-nobody-types]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, typing the emission's seven pieces
([`the-emission-s-request-still-takes-seven-pieces-through-json`](the-emission-s-request-still-takes-seven-pieces-through-json.md)),
in the-advocate `calandria-seven` over `3e71d3a1`.

**What**: the event compiler's answers are typed since B5, but its two
requests are not. `Compiler::request`, `scan` and `compile` in
rm2k-snes-convert's `compiler.rs` build them as a `Map<String, Value>`,
one `r.insert` per key, and `rm2k-snes-events`' `lib.rs` reads them back
with `data.get(..)`, `field`, `int`, `list` and `by_map`, one key at a
time (`pictures_of` for a picture entry: `plane`, `image`, `center`,
`texture`, `slot`). Because of that the converter keeps what goes into
them as JSON too: `MapInfo::big_table` and `ForMap::table` are
`Vec<Value>` —a picture key with its fields inserted by name in
`pictures::number_big`, `common_pictures.rs` and `maps.rs`—, and
`compiler.common_pages`, the copies, is `Option<Value>`
(`CommonPages::to_json`).

**Why not with the seven pieces**: those were one field each of a
request that was already a type. These are not: typing the picture table
means a request type in the events crate for the compile request —or at
least for its picture entry— and its reader in `lib.rs` going with it,
which is the whole compile request's step and not a field's. A renamed
key there compiles on both sides and fails only when a game converts,
the same as the seven did.

**How it would go**: the requests as serde types in the events crate
(`request.rs`, as the screens and the images have), built by the
converter and read by `stage::scan`/`compile` with `serde_json`, and the
reading by hand in `lib.rs` gone; the picture entry as the converter's
`pictures::Key` flattened with its table fields. Checked byte for byte
with the nine games, `events-request.json` included —the file the
converter writes beside the cartridge with the compile request—: the
keys' order is what the cache key reads, so the fields go in the order
the `insert`s put them.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.
