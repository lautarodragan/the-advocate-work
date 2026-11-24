---
name: "The lowering takes the boot start on every map"
description: "`layers::below` adds where the ROM would put the hero if it booted on the map to where he can be, on every map; the still events drawn past their cells take it only on the boot map"
type: feature
status: todo
author: cardon
agents: [cardon]
links:
  found-in: [abl-the-hover-tram-s-crowd-is-cut]
---

Seen by Cardón on 2026-11-18, in
[`abl-the-hover-tram-s-crowd-is-cut`](abl-the-hover-tram-s-crowd-is-cut.md),
with the-advocate at `55268148` (branch `cardon-hover-tram`).

**What happens**: Wally's `map.rs` computes `starts` —the game's start, or
the open cell nearest the map's centre— and `layers::below` adds them to
the hero's entries on every map, as if the cartridge could boot there.
Only the map the cartridge boots on can; since `cardon-hover-tram` the
converter says which in `boots_here`, and the still events drawn past
their cells read it (on ABL's map 13 the centre cell, (10,7), let a scene
seat the hero on (16,5)). The lowering, used by the games with
`unreachable_above_below`, does not, so it may keep above tiles that no
character can cover in the playable ROM. Not measured.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `rm2k-snes/wally/src/map.rs` passes
`&starts` to `crate::layers::below` (line 1742) whatever `boots_here`
says, where lines 495 and 626 already empty it when the map is not the
boot one. The fix is that same line; it only moves above tiles that no
character can cover in the playable ROM, so nothing seen changes —the ROMs
byte for byte, or the maps that move named—.
