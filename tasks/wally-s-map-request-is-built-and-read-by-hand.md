---
name: "Wally's map request is built and read by hand"
description: "The converter builds each map's Wally request as a `json!` of some thirty keys, with more inserted by name after it (`maps.rs`, `variants::request`, `OnMap::to_json`, `ForMap::asked`, `Arrivals::json_of`), and Wally reads it back key by key (`MapRequest::from_json`, `LayersRequest::from_json`, `map_pictures::from_json`): the biggest request still JSON between two stages"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [aguara]
author: calandria
links:
  found-in: [the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key]
  relates: [the-stages-speak-json-nobody-types, the-screens-requests-are-built-and-read-by-hand]
  part-of: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, counting what JSON is left between the
stages after the last three phase B steps, in the-advocate
`calandria-last` (`e8db6e7d`, over `5fa3d860`).

**What**: Wally's answer is a type since B4, its request is not.
`maps.rs` in rm2k-snes-convert builds it as `json!({"map", "map_files",
"dropped_events", "walls", "chipset_files", "names", "test_event",
"leaders", "pages", "route_graphics", "hero_graphics", "also_walk",
"decorative", "posed_stills", "baked_events_nudge", "test_commands",
"timer", "map_pictures", "rain", "sand", "picture", "battle_animation",
"singles", "palette_weight", "dither", "substitutions",
"common_substitutions", "layouts", "panorama", …})` and then inserts more
by name (`request["panorama"]["painted"]`, `painted_events`, `reach`,
`reach_lowers`, `boots_here`, `picture_own`); `variants::request` copies
it and inserts `chipsets`; the map's pictures go as `OnMap::to_json`, the
sprite bank's reservation as `ForMap::asked`, the arrivals as
`Arrivals::json_of`, and `MapInfo::request` keeps the whole as a `Value`.
Wally reads it back with `MapRequest::from_json`,
`LayersRequest::from_json` and `map_pictures::from_json`, some 25 reads
by key in `wally/src/`. A key renamed on one side compiles on both and
fails —or takes a default— only when a game converts: the same as the
event compiler's requests were until
[`the-event-compiler-s-requests-are-built-and-read-by-hand`](the-event-compiler-s-requests-are-built-and-read-by-hand.md).

**Why it was not in phase B**: the table of steps in the stages task
typed Wally's answer (B4) and the emission's and the music's requests,
not Wally's; it is the request the tests' `wally` binary also reads, so
its thin `main` has to keep the keys.

**How it would go**: the request as serde types in Wally
(`request.rs` already holds the readers), built by the converter as a
struct and read with `serde_json` by the stage and the binary, the
`from_json`s going; the fields in the order the `json!` writes them —the
cache's key reads it, and nothing writes this request beside a
cartridge—. Checked byte for byte with the nine games; Wally's cached
answers move once, as with every typed request.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: counted in the merged code, the same rule as the
rest of phase B —taro asked to finish taking the JSON out—, checked byte
for byte with nothing seen or heard changing. A step of the stages task.

### 2026-11-24, Aguará: the request is `wally::request::Asked`

In the-advocate `aguara-wally-request`, `f6208d13` over `633dcde7`, and
`ed7898d3` merging `main` (`6edfe5ff`, Carpintero's screens) with no
conflict. −126 net lines (683 in, 809 out, with a new test).

#### What changed

* **Wally** (`request.rs`): `Asked`, the whole map's request, with serde,
  its fields in the order the `json!` wrote them and the ones it inserted
  only sometimes —`painted_events`, `reach`, `reach_lowers`,
  `boots_here`, `picture_own`, the variants' `chipsets`, the panorama's
  `painted`— left out the same way; `LayersAsked` for `layers`;
  `request::Picture` and `request::Panorama`. `Reach`, `ScannedPage`,
  `MapPicture` and `Way` (by its name, lowercase) derive serde. What the
  conversion reads, `MapRequest` and `LayersRequest`, did not change:
  `Asked::request` and `LayersAsked::request` make them, and `game()` the
  `Game` the request's files patch. `MapRequest::from_json`,
  `LayersRequest::from_json`, `request::patches`, `panorama_budget`,
  `picture_asked`, `map_pictures::from_json` and their dozen helpers went.
  `stage::map` takes an `&Asked`; the binary's four commands deserialize
  their file. `partial` —`bakeable` and `split`, the ports' tests'
  questions— completes the same defaults and deserializes `Asked`.
* **The converter** builds the struct in `maps.rs`; `variants::request`
  copies it with `chipsets`; `OnMap::asked`, `ForMap::asked` and
  `Arrivals::reach` answer Wally's types; `Game::dropped_json_of` and
  `walls_json_of` went. `run_requests` turns the request into a `Value`
  only for the cache's key.

#### What the request says differently

* **`pages`** carry only what Wally reads, as `ScannedPage` —`compiles` and
  `own_route` yes or no— instead of the scan's whole record: Wally does not
  know the event compiler. Two tests of `wally/tests/whole_map.rs` wrote
  `"code": "00"` and `"own_route": null`, and now say it that way.
* **`palette_weight`** goes in name order, a `BTreeMap`, as Wally already
  kept it.
* **`[graphics] palette_weight` and `[maps] panorama_ways`** are checked by
  the converter, naming the setting, and no longer by Wally.

#### Checked

On the merged tree, with `convert`, `wally` and `screens` installed
locally. The nine games `NO_CACHE=1 just cartridges --force` (ABL
`--without-tracks`) against the global tools' builds of `633dcde7`: of
19469 files, every one equal —the 20 `.sfc`, `converter.log` included—
but the 20 `.o` and 20 `.dbg` (ca65's mtimes) and the 20 `stamp.txt`;
`abl.sfc` `8f3fcb518d8cd4ec5dcfe7a94123deef`. Then twice warm with the
shared cache, in the same ports worktree: the first stored 2702 stage
answers —**Wally's cached answers moved**, as did every stage's, since
the converter changed and the request's `pages` did—, the second stored
none; both equal but for the same 60, and the second for Vampires
Dawn's 672 left-out warnings a cached compile does not print, as before
([`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md)).
`just lint`, `just test` (29), `just rust-test --no-fail-fast` (133
binaries, none red), `SOUNDFONT=…/FluidR3_GM.sf2 just test-game` (231
passed, 6 skipped), the ports' `just boot` (218) and ABL's `just tests`
(1694 passed, 2 skipped) green. A new test,
`a_request_reads_back_as_it_was_written`, holds the round trip and what
is left out; the binary's `bakeable` and `split` answers are ABL's tests'
and did not move.

Not covered: the request no longer goes byte for byte as before
(`pages`), so its equality with the old one was not compared; what holds
it is that every build file came out equal.

**Install when merging**: `convert` and `wally` (`just install convert
wally`).
