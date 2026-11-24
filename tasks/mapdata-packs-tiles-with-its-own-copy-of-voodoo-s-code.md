---
name: "mapdata packs tiles with its own copy of Voodoo's code"
description: "mapdata's snes.rs repeats Voodoo's pack_tile and cgram_word, and emit.rs has a third tile packer, pack4, for a flat cell: one tile packer for the workspace would do"
type: refactor
status: draft
author: calandria
links:
  found-in: [where-mapdata-and-convert-could-be-shorter]
---

Seen by Calandria on 2026-11-23, reading `rm2k-snes/mapdata` at the-advocate
`25b2418c` for
[`where-mapdata-and-convert-could-be-shorter`](where-mapdata-and-convert-could-be-shorter.md).

**Where**:

* `rm2k-snes/mapdata/src/snes.rs` 18-37: `pack_tile(&[Vec<u8>], planes)`
  and `cgram_word`, with the same doc and the same loop as
  `snes/voodoo/src/pack.rs` 41 (`pack_tile(&Indices, planes)`) and
  `snes/voodoo/src/color.rs` 34;
* `rm2k-snes/mapdata/src/emit.rs` 1959-1971: `pack4(&[u8])`, the same
  packing again for a flat 64-pixel cell at four planes;
* and `cgram_word` once more in `rm2k-snes/screens/src/message_window.rs`
  972 (outside this task's two crates).

**What the code does**: three writers of the PPU's planar format, which
differ only in how the 8x8 cell arrives —rows as `Vec<u8>`, a `[[u8; 8];
8]`, or 64 bytes—.

**The shorter form**: mapdata depends on `voodoo` (a layer below, allowed)
and uses its `pack_tile` and `cgram_word`; Voodoo's `pack_tile` takes rows
as `impl AsRef<[u8]>` or gets a `from_flat` for the common pictures' cells,
and `pack4` and mapdata's copies go, with `snes.rs` keeping `entry`,
`words_le` and `cgram_bytes`.

**Estimated saving**: about 50 lines.

**What it risks**: little: the bytes are the same and `snes.rs`' test
(`a_tile_goes_in_planes_by_pairs`) and Voodoo's (`packing_and_unpacking_are_inverses`)
cover them. It adds a dependency to mapdata, which costs a crate's compile.

**How to verify**: every port's ROM byte for byte equal before and after
(`NO_CACHE=1 just cartridges`, `cmp`); `just crate-test rm2k-snes-mapdata
voodoo`.
