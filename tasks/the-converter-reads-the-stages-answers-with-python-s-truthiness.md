---
name: "The converter reads the stages' answers with Python's truthiness"
description: "convert reads Wally's map answer, the compiler's scan and the picture keys as serde_json::Value with silent defaults —int(v) = as_i64().unwrap_or(0) in five files, a truthy() that copies Python's—: typed answers would take most of the reading off maps.rs and pictures.rs"
type: refactor
status: draft
author: calandria
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
