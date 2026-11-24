---
name: "The emission's answer is read by key"
description: "rm2k-snes-mapdata's `emit` answers `mapdata.json` as a `json!` of notes, report, frames and losses, and the converter reads each by key with a default (`emit.rs`), its frames and losses staying `Value`s it reads by key again: the last stage answer the converter does not take as a type"
type: refactor
status: doing
assignee: calandria
author: calandria
links:
  found-in: [the-emission-s-request-still-takes-seven-pieces-through-json]
  relates: [the-stages-speak-json-nobody-types, the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, typing the emission's seven pieces
([`the-emission-s-request-still-takes-seven-pieces-through-json`](the-emission-s-request-still-takes-seven-pieces-through-json.md)),
in the-advocate `calandria-seven` over `3e71d3a1`.

**What**: the emission's request is a type since B1 and, with the seven
pieces, built from types all the way; its answer is not.
`rm2k-snes-mapdata`'s `stage::emit` (`stage.rs`) writes `mapdata.json`
as `json!({"notes", "report", "frames", "losses"})`, each loss a `json!`
of `map`, `kind` and `text`; rm2k-snes-convert's `emit::emit`
(`emit.rs`) reads them back with `answer["notes"]`, `["report"]`,
`["frames"]` and `["losses"]`, each `unwrap_or_default`, and keeps
`Emitted::frames` and `losses` as `Vec<Value>`, which `convert.rs` reads
by key once more (`loss["map"].as_i64().unwrap_or(-1)`, the boot map's
frames). A renamed key compiles on both sides and the converter takes the
default —no loss listed, no report— without saying anything, the
truthiness the stages task took out of the other answers.

**How it would go**: an answer type in mapdata (`answer.rs`, or beside
`request.rs`) with its loss and its frames typed, written by `stage::emit`
and read by `emit::emit` with `stage::typed`; the defaults go. The
emission is uncached (`call_uncached`), so no cache value moves, and
`mapdata.json` is not kept in `build/`. Checked byte for byte with the
nine games, `converter.log` and the degradations included, which is where
the losses land.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.
