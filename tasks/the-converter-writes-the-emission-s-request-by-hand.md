---
name: "The converter writes the emission's request by hand"
description: "rm2k-snes-convert links rm2k-snes-mapdata, whose request.rs types the request, and still writes it with json! —a map, a page, the scene—, with workarounds for json!'s recursion limit; deriving Serialize there and building the types would take the mirror away"
type: refactor
status: todo
author: calandria
agents: [cardon]
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
  relates: [the-emission-reads-the-screens-answer-and-the-battle-model-by-name]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/convert` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**:

* `rm2k-snes/convert/src/emit.rs` 12-45 (`page_record`) and 106-151
  (`map_record`): a `json!` per field of mapdata's `request::Page` and
  `request::Map`, by the same names.
* `rm2k-snes/convert/src/convert.rs` 1886-1990: the whole `Emit` request as
  one `json!` and, after it, nine `request["x"] = json!(…)` lines, "apart,
  because the literal above is at `json!`'s recursion limit".
* `rm2k-snes/convert/src/scene.rs` 768-842 (`request`): the scene as
  `json!`, read back by key in `rm2k-snes/mapdata/src/scene.rs`
  (`scenes_asm`, 21 accessor calls).

**What the code does**: convert depends on `rm2k-snes-mapdata` as a library
—for the engine's numbers and the VRAM layouts— and `request.rs` there
already declares the request as `#[derive(Deserialize)]` structs, with hex
fields read by `hex::bytes`. Convert writes the same structure again,
untyped, in its own key strings; a key spelled differently is a request
mapdata refuses at run time, or, for an `#[serde(default)]` field, one it
silently reads as empty. `PageRecord` in convert's `maps.rs` keeps several
of those numbers as `Value` (`switch_a`, `actor`, `layer`, `frequency`…)
because they only travel.

**The shorter form**, a sketch: `#[derive(Serialize, Deserialize)]` on
mapdata's request types, with a `hex::serialize` beside `hex::bytes`, and
convert building them:

```rust
let request = mapdata::request::Emit {
    maps: infos.iter().map(|m| emit::map(m, access_bits(…))).collect(),
    start: start_index as i64,
    switch_top: indices.switch_top,
    phasing: options.phasing,
    …
};
stage::run_uncached("rm2k-snes-mapdata", "mapdata", "emit", &request, …)
```

and `scene::request` returning a `request::Scene` that mapdata's
`scenes_asm` reads by field. The `Value` fields of `Emit` stay `Value`
until
[`the-emission-reads-the-screens-answer-and-the-battle-model-by-name`](the-emission-reads-the-screens-answer-and-the-battle-model-by-name.md)
types them.

**Estimated saving**: 60 to 100 lines: building a struct is about as long
as the `json!` it replaces, so what goes is the nine recursion-limit
patches and their comments, the conversions `json!` forced
(`.iter().collect::<Vec<_>>()`, `json!([a, h, s])`), and the reading side
of the scene in mapdata. The real gain is that convert stops compiling when
the request changes shape, which today only the run notices.

**What it risks**: low to medium. `rm2k-snes-convert` runs `emit` without
the disk cache, so the request's bytes are not a cache key; its keys
only change order in the `request.json` the stage is handed. `serde_json`'s `preserve_order` in convert is
there for requests built in written order; a struct serializes in field
order, which is just as stable.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`), and the emission's request parsed on
both sides to the same `Value` (keys may move, values may not).

## Log

### 2026-11-24, Cardón: to todo

It is step **B1** of the plan in
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(`part-of` it, in `doing`): defined and ordered there.
