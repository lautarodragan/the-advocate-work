---
name: "The event compiler's requests are built and read by hand"
description: "The converter builds the event compiler's scan and compile requests as a serde_json Map key by key (`compiler.rs`), and the events crate reads them back field by field (`lib.rs`); so `MapInfo` still carries the pictures' table and the big pictures' table as `Value`, the last two between two stages"
type: refactor
status: testing
assignee: taro
agents: [calandria]
author: calandria
links:
  found-in: [the-emission-s-request-still-takes-seven-pieces-through-json]
  relates: [the-stages-speak-json-nobody-types]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, typing the emission's seven pieces
([`the-emission-s-request-still-takes-seven-pieces-through-json`](the-emission-s-request-still-takes-seven-pieces-through-json.md)),
in the-advocate `calandria-seven` over `3e71d3a1`.

**What**: the event compiler's answers are typed since B5, but its two
requests are not. `Compiler::request`, `scan` and `compile` in
rm2k-snes-convert's `compiler.rs` build them as a `Map<String, Value>`,
one `r.insert` per key, and `rm2k-snes-events`' `lib.rs` reads them back
with `data.get(..)`, `field`, `int`, `list` and `by_map`, one key at a
time (`pictures_of` for a picture entry: `plane`, `image`, `center`,
`texture`, `slot`). Because of that the converter keeps what goes into
them as JSON too: `MapInfo::big_table` and `ForMap::table` are
`Vec<Value>` —a picture key with its fields inserted by name in
`pictures::number_big`, `common_pictures.rs` and `maps.rs`—, and
`compiler.common_pages`, the copies, is `Option<Value>`
(`CommonPages::to_json`).

**Why not with the seven pieces**: those were one field each of a
request that was already a type. These are not: typing the picture table
means a request type in the events crate for the compile request —or at
least for its picture entry— and its reader in `lib.rs` going with it,
which is the whole compile request's step and not a field's. A renamed
key there compiles on both sides and fails only when a game converts,
the same as the seven did.

**How it would go**: the requests as serde types in the events crate
(`request.rs`, as the screens and the images have), built by the
converter and read by `stage::scan`/`compile` with `serde_json`, and the
reading by hand in `lib.rs` gone; the picture entry as the converter's
`pictures::Key` flattened with its table fields. Checked byte for byte
with the nine games, `events-request.json` included —the file the
converter writes beside the cartridge with the compile request—: the
keys' order is what the cache key reads, so the fields go in the order
the `insert`s put them.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.

### 2026-11-24, Calandria: the requests typed, both ends

In the-advocate `calandria-last`, `e1d44127` over `5fa3d860`.

**What it is**: the request is `rm2k_snes_events::request::Asked`, one
type for both calls —what only one of them reads is optional—, in a new
`request.rs`; the converter's `Compiler` builds it as a struct
(`request`, `scan`, `compile`, `loose`), the stage functions and the
binary take it, `culprits` reads its file with serde, and
`Request::from_asked` makes the compiler's own request of it, with the
window's advances and letters and the picture bytes still checked there.
`field`, `list`, `int`, `text`, `strings`, `command`, `commands`, `pair`,
`by_map` and the JSON `pictures_of` in `lib.rs` went. With it:

* the picture tables are `request::Picture`, a key and its `Place`
  —`Sprite {slot, palette}`, `Background {plane, image, center, texture}`,
  `Common {slot, palette, plane, image, set}`—: `MapInfo::pictures` and
  `big_table`, `ForMap::table`, `number_big`'s tables, the common events'
  entries and sets, `CompileMap`; the converter's `pictures::Key` moved
  into the events crate as `request::Key` (re-exported where it was),
  since the compiler reads its `with_map` and `screen_on_map`;
* `CommonPages::to_json` is `request()`, the menus' hooks a
  `request::MenuHooks`, the windows `request::Window`, `[events]
  counters` `request::Counter` and `[sound_effects]` `request::SoundEffects`;
* the screens' `boxes` answer is `boxes::Reflowed`, read with
  `stage::typed`; `names` are tuples; `Game::dropped_json` went.

**The order of the keys**: the fields go in the order the inserts put
them, and the cache key and `events-request.json` read it. Two things
were not where one would put them: a small picture's entry carries
`palette` after `slot` —the compiler never read it, so the old reader
was silent about it—, and a common entry keeps the slot and palette it
had as a sprite entry before its `plane`. Maps keyed by number are
`ByMap`, in the cartridge's order; **a map given twice is one key, where
it was first, with the last value**, as the `Map` was: the first build
had ABL's `events-request.json` 566 bytes longer, because release lists
maps 121, 133, 261, 269 and 348 twice
([`the-patches-request-of-release-repeats-five-maps`](the-patches-request-of-release-repeats-five-maps.md));
`ByMap::insert` does what the `Map` did, with a test. The scan request's
`counters` now go before its `cases` —one struct, the compile order—:
that request is only the cache's key, so the scan's cached answers move
once.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`), with the commit's `convert` first in the PATH, against
the global tools' builds of `5fa3d860`: 19469 files in `build/`, every
`.sfc` (20) equal, `converter.log`, `degradations.json` and every
`events-request.json` included. What differs is what always does: the 20
`.o` and the 20 `.dbg` by ca65's mtimes alone, and the 20 `stamp.txt`
(the inputs' fingerprint, which names the binaries).

The first build of this step, before `ByMap` collapsed a repeated map,
was equal but for ABL release's `events-request.json`; the one above is
of the fixed commit, built in a second ports worktree, so its
`converter.log`s and `events-request.json`s name that checkout's path:
with the path written as the first's, they are equal too.

The binaries the tests call: `rm2k-snes-events scan`, `compile` and
`culprits` over the crate's `tests/scan.json` and `compile.json`,
`compile` over ABL release's `events-request.json` (3 MB of answer), and
`rm2k-snes-screens boxes` —columns and pixels— and `layout`, equal to the
global ones. `window` and `refit` are untouched code.

**Measured**: +174 net lines (1013 in, 839 out): the reader by hand goes
(some 500 lines), the types with their docs and two tests come in.

**Install when merging**: `convert`, `events` and `screens`.
