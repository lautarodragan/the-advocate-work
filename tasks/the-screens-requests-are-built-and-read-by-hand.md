---
name: "The screens' requests are built and read by hand"
description: "rm2k-snes-convert's `screens.rs` builds the screens' four requests —`convert`, `boxes`, `window`, `faces`— as `json!` with keys inserted by name after, the custom menus going as their project table and their bodies as `json!`, and rm2k-snes-screens reads them back key by key through its `Json` reader: the screens' answers are types since B3 and the seven pieces, their requests are not"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [carpintero]
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

### 2026-11-24, Carpintero: the four requests typed

In the-advocate `carpintero-screens-request` (`7c862830`, over
`633dcde7`), one commit, −50 net lines (413 in, 463 out, nine files).

#### What changed

* **rm2k-snes-screens' `request.rs`** has the four requests as serde
  types —`Convert`, `Boxes`, `Faces`, `Window`— and what they are made
  of: `TextFont` (`font`, `letter_spacing`, `exfont`, null when the
  project names none), `Line` (how a window measures a line: a font and
  `width`, or `advances` and `letters`, or `columns`), `OtherSystem` and
  `Menu`, whose `spec` stays the project file's table, as the task said:
  its shape is the game's. `checks::Vram` derives serde and is the
  request's `vram` as it is. `Convert::read` turns the request into
  `convert::Request` —the `text_rows` check, the custom menus'
  `Context`—, which the crate's tests still build directly.
* **The stage functions take the types**: `stage::convert`, `boxes`,
  `faces` and `window` take `&request::X`; the `_of` doors, the `json()`
  wrapper, `faces::requested` and `Json`'s `convert`, `systems`,
  `text_rows`, `files` and `exfont` readers went. `game_with_font` takes a
  `TextFont` and the two letter lists; `measure_of` takes a `Line`.
* **The binary** reads its request file into the command's type with
  `Json::typed`, which names the file in a complaint. `refit`, the tests'
  command, reads `{boxes, ...Line, lines}` with serde too, because it
  shares `measure_of`; `render` reads its font as a `TextFont` and the rest
  key by key, as `equip` does: those two are the tests', not a stage's.
* **The converter** builds them as structs: `FontChoice::request()` is a
  `TextFont` (the `["exfont"]` read out of a `json!` went),
  `systems::window_request` gives `OtherSystem`s, and `convert.rs` hands
  `screens::convert` a `screens::Menus` —menus, variables' slots, the
  bodies before a page, the names, the debug flag— instead of a `json!`.
  The cache key takes their JSON (`screens::in_key`).
* **The request's keys stay**: the fields go in the order of the old
  `json!` and skip what it left out (`text_rows` without switching,
  `debug` when false, `Line`'s unused ways), so the tests' files read
  and the binary's `window`, `layout`, `refit` answer the same —ABL's
  suite below—. Whether the cached requests' bytes are the same was not
  measured: a new converter moves every stage's key anyway, since it is
  in it. `before_bodies` is now a `BTreeMap` and goes by number; it went
  in the commons' order.

#### Checked

* **The nine games, `NO_CACHE=1 just cartridges --force`** (ABL
  `--without-tracks`) in a ports worktree at `4c23c9e`, the global tools'
  (`633dcde7`) against the branch's `convert` and `screens` first in the
  PATH: every file of `build/` equal —the 20 `.sfc`, `converter.log`
  included— but the 20 `.o` and 20 `.dbg`, whose only difference is
  ca65's mtimes (checked on ABL's with them stripped), and the 20
  `stamp.txt`. `abl.sfc` `8f3fcb518d8cd4ec5dcfe7a94123deef`.
* **Warm, twice, with the shared cache**: both equal to the cold build
  but the `.o`/`.dbg` mtimes; the second also Vampires Dawn's
  `converter.log`, the 672 left-out warnings a cached compile does not
  print, as in Calandria's step
  ([`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md)).
* `cargo fmt` and `clippy --all-targets -D warnings` on the two crates
  clean; `just lint` clean; `just test` 29 passed; `just rust-test
  --no-fail-fast` 1,251 passed, 1 failed, 3 ignored —the failure the
  known `a_cached_object_gives_the_dbg_a_fresh_one_gives`: it failed
  again alone while the test game ran beside it, and passed alone after—;
  `just test-game` (FluidR3) 231 passed, 6 skipped; the ports' `just
  boot` 218 passed.
* **ABL's `just tests`** 1,694 passed, 2 skipped: its `window`, `layout`,
  `refit` and `render` requests read the same through the binary. No
  golden moved: the ports worktree stayed clean.

**What no test runs**: the binary's `convert`, `boxes` and `faces`
commands —the tests send none of those three—; their reading is covered
by the stage's own test, which reads a hand-written `convert` request
with serde, and the converter's path by the nine games above.

**Install when merging**: `convert` and `screens` (`just install convert
screens`).
