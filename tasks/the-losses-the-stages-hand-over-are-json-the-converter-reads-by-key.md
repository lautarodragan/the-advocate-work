---
name: "The losses the stages hand over are JSON the converter reads by key"
description: "`degradations.json`'s entries reach the converter as `serde_json::Value` —the event compiler's `Degradations::losses: Vec<Value>`, the emission's `Vec<Value>`— and the converter keeps them so in `degradations.rs` and filters them by key (`l[\"kind\"] == \"event-left-out\"`, `l[\"map\"].as_i64()`) in four `forget`s of `convert.rs`: one loss type both ends see would make a renamed key fail to compile"
type: refactor
status: doing
assignee: calandria
author: mulita
links:
  found-in: [the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json]
  relates: [the-stages-speak-json-nobody-types, the-emission-s-answer-is-read-by-key]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Mulita on 2026-11-24, typing the music's losses
([`the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json`](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md)),
in the-advocate `mulita-songs` over `2695bd89`.

**What**: the music's losses now reach the converter as
`rm2k_snes_audio::relief::Loss`, but every loss still ends up a
`serde_json::Value` in `rm2k-snes/convert/src/degradations.rs`
(`losses: Vec<Value>`), and the converter reads them by key:

* the event compiler answers them as `Vec<Value>`
  (`rm2k-snes/events/src/answer.rs`, `Degradations::losses`, built by
  `Loss::to_json` in `losses.rs`), which `answer.rs`' header keeps on
  purpose as "what the caller only passes on";
* but the caller does not only pass them on: `convert.rs` drops some with
  four `degradations.forget(|l| …)` filters that read `l["kind"]`,
  `l["map"].as_i64()`, `l["event"].as_i64()` and `l["subject"].as_str()`
  —the events painted into the map, the pictures drawn into it, the
  panoramas never seen, the copies of automatic common events—; and
  `degradations.rs` sorts and counts by `["kind"]` and `["text"]` with
  `unwrap_or("")`.

A `kind` renamed in the compiler (`"event-left-out"`,
`"picture-not-shown"`, `"panorama-not-changed"`) compiles and the filter
stops matching without a word: the loss stays listed in
`degradations.json`.

**How it would go**: one loss type in a crate the stages and the
converter see —the place fields (`map`, `event`, `page`, `command`,
`common`, `troop`, `x`, `y`…) as `Option`s, `kind`, `text` and what
else an entry carries (`subject`, `name`, `code`, `via`)—, the
compiler's `Loss::to_json` becoming its conversion, and `degradations.rs`
holding it; the `kind`s the converter filters on as constants beside it.
`degradations.json`'s shape stays: checked byte for byte with the nine
games.

**How to reproduce**: `rg 'l\["kind"\]|l\["map"\]' rm2k-snes/convert/src`
in the-advocate.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.
