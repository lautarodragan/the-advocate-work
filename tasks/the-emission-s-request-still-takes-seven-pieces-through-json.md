---
name: "The emission's request still takes seven pieces through JSON"
description: "After MapInfo was typed, `emit::typed` —serde_json::from_value of a Value the converter built or a stage answered— still builds seven fields of the emission's and the battle model's requests, besides the battle's audio: the MSU-1 option, the window's other Systems, the faces, the battle terms, the shared common bodies, the big pictures' layers and the item names' width"
type: refactor
game: advocate
status: testing
assignee: taro
author: calandria
agents: [calandria]
links:
  found-in: [mapinfo-carries-wally-s-answer-as-json-between-two-types]
  found: [the-event-compiler-s-requests-are-built-and-read-by-hand, the-emission-s-answer-is-read-by-key]
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

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B, checked byte for byte with nothing seen or heard
changing. A step of the stages task, beside Mulita's songs and losses.

### 2026-11-24, Calandria: the seven from their producers' types

In the-advocate `calandria-seven` over `3e71d3a1`, beside Mulita's songs
and losses (`battle_audio` is hers): `c29ab7a9`, the screens' answers,
and `3be65428`, the converter. `emit::typed` is left with one call,
`battle_audio`: Mulita's, to remove with the function.

#### Each piece

* `rom.msu`: `Settings::msu` answers mapdata's `MsuData`, and the log
  writes it with `MsuData::name`; the music's `msu_samples` compares the
  enum (one line in Mulita's hunk of the music's request).
* `window_systems`: the screens' `window` answers `WindowAnswer`, each
  switched System a `SwitchedWindow` that flattens the `OtherSystem` the
  emission already took; the converter hands those on, reads the
  warnings by field and builds the window's patch decisions from it
  (`window_losses` lost its local struct and its `Result`).
* `faces`: `faces` answers `FacesAnswer`; the converter checks the count,
  reads `missing` and gives the emission `MessageFace`'s two fields.
* `battle_terms`: `Settings::battle_terms` reads `[battle.terms]` into a
  `BTreeMap<String, String>` —a term that is not a text stops the
  conversion there, where the emission's deserialization stopped it
  before—, and `letters.rs` takes the map.
* `commons`: built from B5's `Shared` field by field —the bodies' code as
  hex, as `Hex` serialized it—, with the copies when the cartridge makes
  any, `Copies::default()` when not, as the inserted key did.
* `big_pictures`: `pictures::Big::layer` is a `BigLayer`, the images'
  typed `Layer` (now `Clone` and `Debug`) with the converter's centre,
  half size, panorama under it and `keeps_objects` beside it, which
  `BigLayer::request` turns into mapdata's `BigLayer`. `number_big` tells
  two layers apart by a tuple of the same six things the JSON string
  had; the tables it numbers stay `Value`, below.
* `item_name_width`: the screens' `ITEM_NAME_WIDTH`, which their `layout`
  published. The same for the two other constants the converter read
  through a `layout` answer —the screens' `MESSAGE_WIDTH` and the
  battle's `BA_PAGE_MSG_WIDTH`, in `compiler.rs`—: `screens::layout` and
  `message_width` went. And `Compiler::run` reads the event compiler's
  answer straight into its type, not through a `Value`.

#### The event compiler's request: not typed

`MapInfo::big_table` and `ForMap::table` stay `Vec<Value>`: they are
entries of the event compiler's compile request, which the converter
builds as a `Map` key by key and the events crate reads by hand
(`pictures_of` in `lib.rs`). Typing them means a request type in the
events crate and its reader going, the whole compile request's step:
not small, and not a field of a typed request as the seven were. A
[draft](the-event-compiler-s-requests-are-built-and-read-by-hand.md).

#### What `Value` is left between stages in the converter

* `emit::typed(&compiled.battle_audio)`, `from_value(compiled.songs)` and
  the music's `audio.json` read by key: Mulita's todo.
* The event compiler's two requests, with the pictures' and big pictures'
  tables, the copies (`CommonPages::to_json`) and the screens' `boxes`
  answer they carry: the draft above.
* The emission's own answer, `mapdata.json`, read by key with defaults
  (`emit::emit`), its frames and losses kept as `Value`: a
  [draft](the-emission-s-answer-is-read-by-key.md).
* The screens' `Answer::layout`, the geometry by name, which the
  emission writes out by name: a map of numbers on purpose.
* Not between stages: `game.rs`' two `from_value` read the project's
  forks, and `trim.rs`' build the dump's types in its tests.

#### The binaries, the cache, the key order

The screens' `window` and `faces` write their typed answers through a
`Value`: the binary, built without `preserve_order`, writes the keys
sorted as `json!` did, and the converter, with it, in the fields' order,
which is the macros'. Checked: `rm2k-snes-screens window` (plain, and
with two of Vampires Dawn's Systems switched), `faces` (two faces and a
missing FaceSet) and `layout`, the global binary against this branch's:
the same bytes. So the cached answers' bytes do not move either; their
keys do, as with any new converter.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`) in one ports worktree, the global tools (`3e71d3a1`)
against `convert`, `mapdata`, `screens` and `images` from this branch:
**the 20 `.sfc` and the 19,469 files of the nine `build/` equal**, the
20 `converter.log` included; aside the 20 `stamp.txt` (the inputs'
fingerprint, which counts the binaries) and the 20 `.o` and `.dbg`, which
differ only in the mtimes `ca65` records (checked on every `.dbg` with
them stripped). No log carries a checkout path that differs. The
builds cover the pieces: Vampires Dawn switches five Systems and warns
for one, Zounds has `[battle.terms]`, the MSU-1 screen goes in two
cartridges (`required` and `everything`), a big picture keeps the small
ones over it, and six cartridges carry message faces.

#### Lines

`3e71d3a1..3be65428`, 369 added and 224 removed, **net +145**: the
converter +55 (the commons, the faces and the big layers as struct
literals that rustfmt spreads, `BigLayer` and its conversion, the battle
terms' reader, against the two `layout` readers and `window_losses`'
struct), the screens +79 (the answer types and their paragraphs, and the
`json!`s spread into struct literals), mapdata +11 (`MsuData::name`). The JSON was shorter; the compiler now
sees each of the seven.

#### The suites

On the branch (the-advocate's main had not moved), `convert`, `mapdata`,
`screens` and `images` first in the PATH: `just lint` clean; the-advocate's
`just test` 29 passed; `just rust-test --no-fail-fast` 1,249 passed, 3
ignored, none failed —the screens' and the converter's own tests among
them, `number_big`'s rewritten over `BigLayer`—; the test game
(`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped; the ports' `just
boot` 218 passed; ABL's `just tests` 1,694 passed, 2 skipped. No golden
moved: the ports' worktree is clean. `abl.sfc` `3bf35fd7665c`, as before.
**What no test runs**: the screens binary's `window` and `faces` outside
the converter —checked by hand above, not by a test—, and
`Settings::battle_terms`' refusal of a term that is not a text, which no
game's project has; the rest is covered by the builds above, where every
piece reaches a ROM.

**Install when merging**: `convert`, `mapdata`, `screens` and `images`
(`just install convert mapdata screens images`; `images` only gained two
derives). The shared cache stores every stage's answers once more, as
any new converter does.
