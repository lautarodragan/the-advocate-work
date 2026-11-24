---
name: "The compiler's songs and the music's losses cross the converter as JSON"
description: "After B7 the music stage's request is typed, but its songs arrive as the event compiler's `Compiled::songs: Value` and are read into `rm2k_snes_audio::cartridge::Songs` with one `from_value`; and the losses the music decides come back in `audio.json`, which the converter reads by key with `unwrap_or` defaults"
type: refactor
status: doing
assignee: mulita
author: mulita
links:
  found-in: [the-stages-speak-json-nobody-types]
  part-of: [the-stages-speak-json-nobody-types]
  relates: [the-emission-s-request-still-takes-seven-pieces-through-json]
---

Seen by Mulita on 2026-11-24, doing B7 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(the-advocate `mulita-b7`, over `bb961337`).

**What**: two ends of the music stage still cross the converter as JSON.

* **The songs, going in**: the event compiler answers `songs` as a
  `serde_json::Value` (`rm2k-snes/events/src/answer.rs`, `Compiled::songs`,
  built by `Songs::to_json` in `registry.rs`). B7 typed the music's request,
  `rm2k_snes_audio::stage::Request`, whose `songs` is
  `cartridge::Songs`; the converter reads one into the other with
  `serde_json::from_value` (`rm2k-snes/convert/src/convert.rs`, where it
  builds the request). Both ends are typed and the middle is JSON: a key
  renamed in `to_json` compiles and fails only when a game converts. Same
  for `Compiled::battle_audio`.
* **The losses, coming out**: the music stage leaves what it lost in
  `audio.json`'s `losses`, and the converter reads them by key —
  `loss["kind"].as_str().unwrap_or("")`, `loss["map"].as_i64()`— to put
  them in `degradations.json`. The audio crate builds `audio.json` with
  `json!` in `stage::compile`.

**The shorter form**: the event compiler answers its songs as a type both
crates see —the events crate's own, read into the music's with plain Rust,
or one type in a crate both depend on, as taro chose producer-owned types
for the contracts—, so `to_json` and the `from_value` go; and the music's
`cartridge` returns its losses typed beside its files, as A7 already
returns the files themselves.

**What it risks**: low. The songs' JSON is in the event compiler's cached
answer, so changing its shape moves that cache value once; `audio.json` is
written to the build, and ABL's tests read it too
(`tests/harness/music.py`, from the test cartridges' compile), so its shape stays and
only the converter's reading of it changes. Verified as B7 was: the
nine games' builds byte for byte.

**How to reproduce**: `rg 'from_value\(compiled.songs' rm2k-snes/convert`
and `rg '"losses"' rm2k-snes/convert` in the-advocate.

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: verified in the merged code, it finishes the stages
task along the producer's-crate rule taro chose, checked byte for byte
with nothing seen or heard changing. A step of phase B, after the MapInfo
one.
