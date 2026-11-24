---
name: "The screens' requests are built and read by hand"
description: "rm2k-snes-convert's `screens.rs` builds the screens' four requests —`convert`, `boxes`, `window`, `faces`— as `json!` with keys inserted by name after, the custom menus going as their project table and their bodies as `json!`, and rm2k-snes-screens reads them back key by key through its `Json` reader: the screens' answers are types since B3 and the seven pieces, their requests are not"
type: refactor
status: todo
author: calandria
links:
  found-in: [the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key]
  relates: [the-stages-speak-json-nobody-types, wally-s-map-request-is-built-and-read-by-hand]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, counting what JSON is left between the
stages after the last three phase B steps, in the-advocate
`calandria-last` (`e8db6e7d`, over `5fa3d860`).

**What**: in rm2k-snes-convert, `screens::boxes`, `faces`, `window` and
the `convert` request build their requests with `json!`, `convert`'s
then taking `text_rows` and `debug` by name, and the font's part as
`FontChoice::request()`, a `json!` the boxes' request reads one key of
(`font.request()["exfont"]`); `convert.rs` adds the custom menus as
`{"name", "spec"}` —`spec` the project file's table as it is— and their
`before_bodies` as `json!`. rm2k-snes-screens reads them with its `Json`
reader in `stage.rs` and `convert.rs` (`json.files("map_files")`,
`index_or("lines", 0)`, …), defaults included. A key renamed on one side
compiles on both and the stage takes the default.

**Why it was not in phase B**: B3 typed the screens' answer; their
requests were left, and the tests' `rm2k-snes-screens` commands read
them from files written by hand (`tests/harness/screen_stage.py` in ABL),
so the binary has to keep the keys.

**How it would go**: the four requests as serde types in
rm2k-snes-screens' `request.rs`, as the images' are —with `#[serde(default)]`
where the reader defaults today, so the tests' files still read—, built
as structs by the converter; the custom menu's `spec` may stay the
project's table, since its shape is the game's, not a stage's. Checked
byte for byte with the nine games, and the binary's `window`, `layout`,
`refit` and `boxes` against the global ones.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.
