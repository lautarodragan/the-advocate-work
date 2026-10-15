---
name: "The item index in 16 bits"
description: "The cartridge's item tables are indexed with a byte, so ABL's whole release leaves out the items past 255 (a TEMPORARY hack in the converter): index them with a word and remove the hack"
type: feature
status: doing
assignee: Chajá
agents: [Chajá]
---

ABL's whole `release` carries 264 items; the item tables index with one
byte, so the converter leaves out the ones past 255 (411, 413–416,
418–421) and an enemy dropping one drops nothing —both marked TEMPORARY,
in `items_all` of `rm2k-snes/convert/src/convert.rs` and the enemy drop
table of `rm2k-snes/mapdata/src/emit.rs`—. Emily's and Sern's shops on map
321 open empty because of it. See
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).
taro, on 2026-10-14: "the right fix is 2 bytes"; on 2026-10-15, after the
identical pages, go.

## Log
