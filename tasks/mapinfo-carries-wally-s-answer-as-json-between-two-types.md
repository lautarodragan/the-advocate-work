---
name: "MapInfo carries Wally's answer as JSON between two types"
description: "Since B4 and B1, the converter reads Wally's typed answer, turns its sprite, NPCs, posed table, runs and panorama back into `Value` with json! for `MapInfo`, and `emit::map_record` deserializes them into mapdata's request types: a round trip through JSON between two sets of types the compiler could join"
type: refactor
game: advocate
status: testing
assignee: taro
author: calandria
agents: [calandria]
links:
  found-in: [the-stages-speak-json-nobody-types]
  part-of: [the-stages-speak-json-nobody-types]
  found: [the-emission-s-request-still-takes-seven-pieces-through-json]
---

Seen by Calandria on 2026-11-24, merging main —Aguará's B4— into her
B0-B3 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(the-advocate `calandria-b`, over `1f33793d`).

**What**: B4 made `wally::map` answer types; the converter reads them,
and for the fields that go on to the emission —`objects`, `npcs`,
`movable`, `animates_still`, `animates_with`, `posed_table`, `panorama`,
`runs`— builds `Value`s with `json!` and keeps them in `MapInfo`
(`maps.rs`). B1 made the converter build the emission's request as
mapdata's types, so `emit::map_record` turns those `Value`s back into
`request::Sprite`, `Vec<Npc>`, `Vec<Posed>`, `Vec<Run>`, `Panorama` with
`emit::typed`, `serde_json::from_value`. Both ends are typed and the
middle is JSON: a field renamed on Wally's side still compiles and fails
only when a game converts, which is what the stages task set out to end.
`page_record`'s `PageRecord` fields are the same story for the event
compiler (B5), and `pictures`' images for the images (B6).

**The shorter form**: one type per shape. Either mapdata's request
holds Wally's types (`pub sprite: Option<wally::…>`, the producer's
crate, as taro chose for the contracts), or the converter converts
Wally's types into mapdata's with plain Rust where they differ; `MapInfo`
keeps the typed value and `map_record` moves it. The `typed` bridges and
their `from_value` go.

**What it risks**: low; it is checked as B0-B3 were —the nine games'
builds byte for byte— and changes no cache value (the emission is
uncached). Where Wally's and mapdata's shapes differ (mapdata's `Bank`,
`Slot`, `RouteGfx` read tuples Wally may write as structs), the
difference has to be looked at, not papered over.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: verified in the merged code, it finishes what the
stages task set out to do along the producer's-crate rule taro already
chose, and it is checked byte for byte with nothing seen or heard
changing. It goes as a step of phase B, after B7.

### 2026-11-24, Calandria: one type per shape between Wally and the emission

In the-advocate `calandria-mapinfo` over `bb961337`: `3c96090d`, the
change, and `59d851e3`, the paragraph at the top of Wally's `answer.rs`
on key order, which said the converter passed parts of the answer on as
JSON; then `688342ac`, main's B7 (`967d252c`) merged in.

#### What went where

**Where the shape is the same, the emission's request holds Wally's
type** —the producer's crate—: `Slot`, `RouteGraphic` (mapdata's
`RouteGfx`, whose `entry`, `palette` and `colors` are Wally's now),
`answer::Cache`, `map::SharedObjects` (mapdata's `Shared`),
`answer::Animation` and `posed::Placed` (mapdata's `Posed`). mapdata's
six copies go, and its uses take Wally's widths (`usize`, `i32`, `u16`
colours) with casts where its tables count in `i64`/`u32`.

**Where they differ, the converter converts with plain Rust**, in
`emit.rs`: `sprite`, `panorama` and `npc`. The differences, looked at:

* **Files against bytes**: Wally's answer names files —the bank's tiles,
  each character's poses (`Bank`'s third), the panorama's tiles and each
  other image's, the runs' drawings— where the emission takes their
  bytes. The bytes are read in `map_info`, where the files are.
* **`Bank`**: Wally's is a tuple `(charset, index, file, shows)`;
  mapdata's an untagged enum `Shows`/`All` whose third was hex text, which
  the converter encoded and mapdata decoded inside the same process. It
  holds the bytes now (`#[serde(with = "hex")]`, hex only in a request
  file), and `Bank::hex` is `Bank::poses`. `All` —without the fourth— is
  only what an old request file says; the converter always writes
  `Shows`.
* **What the emission does not read**: Wally's sprite has `characters`;
  its rows carry `blocks`, `animates`, `graphics`, `layers`, `outside`,
  `appears`, `changes`; its panorama `distinct`, `colors`, `kept`,
  `merges` and the tile count. mapdata's `Sprite`, `Npc` and `Panorama`
  are the emission's view, and the request fixtures in `tests/maps.json`
  have no more than that, so mapdata cannot hold Wally's `Row` or
  `Panorama` without the fixtures growing every field.
* **Widths and tuples**: `(usize, usize)` against `[i64; 2]` (size,
  stretch, `animates_with`), `BTreeSet<usize>` against `Vec<i64>`
  (`movable`, `animates_still`), the timer `(usize, usize)` against
  `(i64, Option<i64>)` —the palette always there from Wally—. The JSON was
  the same; the conversion is a cast each.

`MapInfo` keeps typed values: the request's `Sprite` and runs, Wally's
rows, panorama (with `panorama_tiles`, its bytes), posed table and way, the blocks and palettes of `where_`, `cached` and `shared` as
numbers, and `variants::Events` for what its events came out as —a
struct, printed as the JSON it was when a variant is refused—.
`map_record` clones them (the infos are read after the emission:
`write_adeleine`, the patches' request).

**`PageRecord::draws` is `request::Draws`** (B5's story), built in
`convert.rs` from one base and `..drawn`.

**The pictures (B6's story)**: `ForMap` carries the pictures' name,
objects, tiles, cells (`(tile, [u8; 64])`) and palettes typed, and
`asked()` writes Wally's request `picture` from them in the same key
order; its images are `request::PictureImage`. So the common sets are
`request::CommonSet` too, and two more bridges go: `map_record`'s
`pictures` and the emission's `common_pictures`.

**Merged with B7** (`688342ac`): B7 folded `MapInfo`'s colours, budget
and both layers' merges into `patches: MapDecision` —which this step had
typed as numbers and Wally's `Merge`s, so they went— and typed
`substitution_table` as Wally's tuples. Kept both: this step's runs and
cached poses, B7's `patches` and table; the flashes check reads Wally's
rows by field over B7's interim `as_i64`; the pictures' image casts B7's
`usize` palette index. The other uses of what B7 changed, looked for by
hand: none outside B7's own lines.

#### What is left

`emit::typed` stays for eight calls in `convert.rs`: `battle_audio`, in
Mulita's
[todo](the-compiler-s-songs-and-the-music-s-losses-cross-the-converter-as-json.md)
with the songs' `from_value`, and seven nobody's, in
[a draft](the-emission-s-request-still-takes-seven-pieces-through-json.md)
—`rom.msu`, `window_systems`, `faces`, `battle_terms`, `commons`,
`big_pictures` and the battle model's `item_name_width`—. `MapInfo` keeps
two `Value` fields, both for the event compiler's request, which is still
built as JSON: the pictures' table (`ForMap::table`, each picture with its
slot, read by key in `common_pictures.rs` and `maps.rs`) and `big_table`;
`Prepared::request` is Wally's request, built with `json!`, and
`pictures::Big::layer` the images' layer (the draft's `big_pictures`).
`serde_json::from_value` between stages is left in `emit::typed`, the
songs' (Mulita's todo) and `compiler.rs`'s reading of the event
compiler's cached file into its type; `game.rs`' two read the dump.

#### Lines

`bb961337..59d851e3`, 455 added and 357 removed, **net +98**: the
converter +162 (the three conversions in `emit.rs`, `ForMap::asked` and
the struct literals rustfmt spreads, against the `json!`s and `typed`s),
mapdata −92 (its six copies of Wally's types), Wally +28 (`RouteGraphic`'s
accessors, the paragraph). On main after B7 (`967d252c..688342ac`), net
+96. The JSON was shorter to write; the conversions are what the compiler
now checks.

#### The builds, byte for byte

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`) on the merged tree `688342ac`, with `convert`,
`mapdata`, `wally`, `rm2k-snes-audio`, `patches` and `events` of it first
in the PATH, against the global tools' builds of `bb961337` (B7 changed no
output): **the 20 `.sfc` equal**, and every one of the 19,469 files of the
nine `build/` equal but `stamp.txt` and the `.o`; 54 differ only in the
checkout's own path or a source's mtime —the 20 `converter.log` (the
paths it prints), the 20 `.sfc.dbg` and the 14 `events-request.json`
(`map_files`)—, and are equal with those masked. An earlier build of
the branch, before the common sets and the lint's edits, compared equal
too.

#### The suites

On `688342ac`, the same tools first in the PATH: `just lint` clean; `just
test` 29 passed; `just rust-test --no-fail-fast` 1,249 passed, 0 failed,
3 ignored (the fxpak pty and cached-`.dbg` flakes did not show); the test
game (`SOUNDFONT=FluidR3_GM.sf2`) 231 passed, 6 skipped; the ports' `just
boot` 218 passed; ABL's `just tests` 1,694 passed, 2 skipped. No golden
moved: the ports' worktree is clean. `abl.sfc` `3bf35fd7665c`.

**Not covered by a build or a suite**: `Bank::All` (a bank without its
fourth, which only an old request file says) is read only by mapdata's
`tests/maps.json`; `variants::Events`' JSON, printed only when a ChipSet
is refused for drawing its events otherwise, was not printed by any game
(no `converter.log` changed).

**Install when merging**: `convert`, `mapdata` and `wally` (`just install
convert mapdata wally`), besides B7's. The shared cache stores every
stage's answers once more (the converter's binary changed); no value
changes.
