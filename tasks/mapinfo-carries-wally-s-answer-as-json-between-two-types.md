---
name: "MapInfo carries Wally's answer as JSON between two types"
description: "Since B4 and B1, the converter reads Wally's typed answer, turns its sprite, NPCs, posed table, runs and panorama back into `Value` with json! for `MapInfo`, and `emit::map_record` deserializes them into mapdata's request types: a round trip through JSON between two sets of types the compiler could join"
type: refactor
status: todo
author: calandria
agents: [calandria]
links:
  found-in: [the-stages-speak-json-nobody-types]
  part-of: [the-stages-speak-json-nobody-types]
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
