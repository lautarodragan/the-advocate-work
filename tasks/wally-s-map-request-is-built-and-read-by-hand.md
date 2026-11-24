---
name: "Wally's map request is built and read by hand"
description: "The converter builds each map's Wally request as a `json!` of some thirty keys, with more inserted by name after it (`maps.rs`, `variants::request`, `OnMap::to_json`, `ForMap::asked`, `Arrivals::json_of`), and Wally reads it back key by key (`MapRequest::from_json`, `LayersRequest::from_json`, `map_pictures::from_json`): the biggest request still JSON between two stages"
type: refactor
status: todo
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
