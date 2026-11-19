---
name: "Painted maps carry every cell"
description: "A painted map stores each of its 8x8 cells in the cartridge, repeated or not: Desert Nightmare's 135 maps that could go painted take 86.5 banks of cells, and only 29.5% of those cells are distinct"
type: feature
status: draft
game: desert-nightmare
agents: [Cardón]
---

Seen by Cardón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-can-the-towns-be-baked`](desert-nightmare-can-the-towns-be-baked.md).

**What was seen**: a painted map —`Way::Painted` in Wally, `painted.s`
in the runtime— carries every cell of the map, 32 bytes each, column by
column. With `painted_maps = true` and the throwaway prototype of that
study (branch `cardon-dn-towns` in the-advocate, every map), 135 of
Desert Nightmare's maps go painted: 177,156 cells, 86.5 banks. The
release takes 91 of the cartridge's 126 data banks without them, so the
cartridge does not link ("the 126 banks the cartridge has for data are
taken"). Cut into 8x8 cells by their colour-memory entries, 52,187 of
those cells are distinct within their map (29.5%, 25.5 banks), 49,985
across maps.

With only the 28 towns painted, the release takes 100 banks and links.

Sunset Over Imdahl's 60 painted maps are stored the same way; how many
of their cells repeat was not measured.

**To reproduce**: the prototype's Wally (`just install-local .local-tools
wally` in that branch), `painted_maps = true` in
`desert-nightmare/advocate.toml`, and `TOWN_BAKE=1 TOWN_FOLD=1 just
cartridges --force` with that `bin/` first in the PATH.
