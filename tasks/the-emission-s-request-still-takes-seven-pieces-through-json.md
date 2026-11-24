---
name: "The emission's request still takes seven pieces through JSON"
description: "After MapInfo was typed, `emit::typed` —serde_json::from_value of a Value the converter built or a stage answered— still builds seven fields of the emission's and the battle model's requests, besides the battle's audio: the MSU-1 option, the window's other Systems, the faces, the battle terms, the shared common bodies, the big pictures' layers and the item names' width"
type: refactor
status: todo
author: calandria
links:
  found-in: [mapinfo-carries-wally-s-answer-as-json-between-two-types]
  relates: [the-stages-speak-json-nobody-types, the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, typing `MapInfo`
([`mapinfo-carries-wally-s-answer-as-json-between-two-types`](mapinfo-carries-wally-s-answer-as-json-between-two-types.md)),
in the-advocate `calandria-mapinfo` over `bb961337`.

**What**: `emit::typed` in rm2k-snes-convert's `emit.rs` is
`serde_json::from_value` with the emission's error. After that task it
is called in `convert.rs` eight times —seven fields of `request::Emit`
and one of the battle model's request—. `battle_audio` (the event
compiler's `Compiled::battle_audio`, a `Value`) is in Mulita's
[todo](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md);
these seven are nobody's step:

* `rom.msu`: `json!(msu_data)`, the option's string, read into
  `request::MsuData`.
* `window_systems`: `window_answer.get("systems")`, the screens' window
  answer read by key (`screens::window_colors`).
* `faces`: `screens::faces` answers `Vec<Value>`.
* `battle_terms`: the project's `[battle] terms`, read as a `Value`
  table (`settings.table`).
* `commons`: `json!(compiled.commons)`, B5's typed `Commons`, with the
  copies inserted by key (`common_pages.to_json()`).
* `big_pictures`: the images' background layers as `Value`
  (`pictures::Big::layer`), numbered by a JSON string of their fields
  (`number_big`'s `ident`) and marked by key (`keep_objects` writes
  `keeps_objects`, `say_big` reads it).
* `item_name_width`: `screens::layout()["ITEM_NAME_WIDTH"]`, into the
  battle model's request.

Each is the same round trip the task removed for the maps: typed or
built on one side, `Value` in the middle, typed again by the emission, so
a renamed field compiles and fails only when a game converts.

**How it would go**: each the way `MapInfo` went —the producer's type in
the request where the shape is the same, plain Rust where it differs—;
the big layers are the longest, since `number_big` dedups them by their
JSON. Checked byte for byte with the nine games, as the stages task's
steps are.

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B, checked byte for byte with nothing seen or heard
changing. A step of the stages task, beside Mulita's songs and losses.
