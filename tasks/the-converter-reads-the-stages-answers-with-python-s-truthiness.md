---
name: "The converter reads the stages' answers with Python's truthiness"
description: "convert reads Wally's map answer, the compiler's scan and the picture keys as serde_json::Value with silent defaults —int(v) = as_i64().unwrap_or(0) in five files, a truthy() that copies Python's—: typed answers would take most of the reading off maps.rs and pictures.rs"
type: refactor
status: testing
assignee: taro
author: calandria
agents: [cardon, aguara, mulita]
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
  relates: [the-emission-reads-the-screens-answer-and-the-battle-model-by-name]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/convert` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).
**Sampled, not read whole**: `maps.rs` 906-1100 (`map_info`) and
`pictures.rs` 170-330; the rest of the counts are greps.

**Where**: `rm2k-snes/convert/src/maps.rs` (`map_info`, 906-1460, a
550-line function over Wally's `map.json` and `layers.json`; 79 `as_i64`/
`as_bool`/`as_array`/`as_str`), `convert.rs` (85), `pictures.rs` (22,
and a picture's "key" passed everywhere as `&Value`), `chipsets.rs` (15),
`scene.rs` (14), `compiler.rs` (12). Five files define their own `fn int(v:
&Value) -> i64 { v.as_i64().unwrap_or(0) }` (`convert.rs`, `maps.rs`,
`pictures.rs`, `chipsets.rs`, `variants.rs`), and `pictures.rs` 283 has a
`truthy` that is Python's truthiness —an empty list, `0` and `""` false—,
with a second one in `maps.rs` 877.

**What the code does**: it is the shape the converter kept from when it was
Python and the stages' answers were dicts. Each field is read with a
default —`note["text"].as_str().unwrap_or("")`,
`bg["runs"].as_array().cloned().unwrap_or_default()`,
`int(&s["animation"]["count"])`—, so a key the stage renamed reads as
empty or zero and the conversion goes on. The stages build those answers
with `json!` (`wally/src/map.rs`, `layers.rs`; `events/src/pages.rs`), and
no stage derives `Serialize`.

**The shorter form**: what
[`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md)
proposes for mapdata, here for Wally's answer first —convert would depend
on `wally`, which mapdata already does—: its `map.json` as a struct with
`notes: Vec<Note>`, `sprite: Sprite`, `npcs`, `start: [i64; 2]`…, read
once, and `map_info` working on fields. Then the compiler's `scan`
answer and the picture key. The `int`/`truthy` helpers go with the last
reader.

**Estimated saving**: 100 to 200 lines in convert, mostly in `map_info` and
`pictures.rs` —an estimate from the sample, not a count—, less what the
types cost on Wally's side.

**What it risks**: medium. Typing an answer finds the places where a
default was carrying a real absence (a map without `sprite`, a note
without `loss`): each becomes an `Option` or a `#[serde(default)]`, and
those have to be the ones that were meant. Done stage by stage, each its
own change.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`), and the converter's printed log
equal: a default that used to hide a missing key would show there first.

## Log

### 2026-11-24, Cardón: to todo

It is step **B4** of the plan in
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(`part-of` it, in `doing`): defined and ordered there. `todo` so that the
page shows it as a step to take, not as a finding.

### 2026-11-24, Aguará: Wally's part, in B4

Done on the-advocate `aguara-b4` (`94f3312c`), told in
[the stages task's B4 entry](the-stages-speak-json-nobody-types.md):
Wally's `map.json` and `layers.json` are `wally::answer::Map` and
`Layers`, `map_info` and `variants::drawn` read their fields, and these
went with what read them: **`maps.rs`' `truthy`** (and `slot_key`, the
only other user) and **`variants.rs`' `fn int`**. Nothing defaulted an
absence that was real: the nine games convert byte for byte the same.

**What remains, for B7 (with the last reader):**

* **`fn int`** in four files: `convert.rs` (160), `pictures.rs` (170),
  `chipsets.rs` (286), and `maps.rs` (853), which keeps it for `pages`,
  the compiler's records (B5).
* **`truthy`** in `pictures.rs` (283), over the picture keys (B6).
* **`MapInfo`'s `Value`s that carry Wally's answer on** to the emission
  —`objects`, `npcs`, `movable`, `animates_*`, `posed_table`, `panorama`,
  `runs`, the merges—: built from the types now, and left `Value`
  because B1 reads them into mapdata's typed request; they become
  Wally's types when the emission's request takes them. One reader by
  hand of them is left: `convert.rs`' flashes, `m.npcs.as_array()`
  (about 1383).
* `maps::panorama_names` reads `MapInfo.panorama` by key, for the event
  compiler's request: the same `Value`.

It stays `doing`, for B5-B7.

### 2026-11-24, Mulita: the last readers, in B7

Done on the-advocate `mulita-b7` (`9d4446b7`), told in
[the stages task's B7 entry](the-stages-speak-json-nobody-types.md). Of
the list above:

* **`fn int`**: gone from the four files. `maps.rs`' went in B5 with
  `pages`; `convert.rs`', `pictures.rs`' and `chipsets.rs`' in B7, with
  the substitution table typed as Wally's tuples, `[events] counters` as a
  `Counter`, the scan's zooms as pairs, a shown picture's number and
  palette kept beside its entry, and a ChipSet's patch read into a typed
  recipe.
* **`truthy`**: `pictures.rs`' went in B6 with the picture key;
  `convert.rs`' closure over the substitution table in B7.
* **`MapInfo`'s `Value`s that carry Wally's answer on**, the flashes'
  `m.npcs.as_array()` reader and `panorama_names`: what
  [`mapinfo-carries-wally-s-answer-as-json-between-two-types`](mapinfo-carries-wally-s-answer-as-json-between-two-types.md)
  types, not this. The flashes' reader is inlined there until then. The
  four of them that only the patches read —`colors`, `budget`, the two
  merges— became one typed `MapDecision` in B7.

The nine games' builds byte for byte with the readers gone, `converter.log`
included: no default was carrying a real absence. `degradations.rs` keeps
a local `int` closure that answers an `Option`, over the converter's own
loss records, which this task did not count.
