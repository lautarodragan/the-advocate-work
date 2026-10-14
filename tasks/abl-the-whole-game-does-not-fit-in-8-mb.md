---
name: "ABL: the whole game does not fit in 8 MB"
description: "With every map, ABL asks for 8.42 MB of data and the 127 data banks hold 7.70 MB: about 700 KB over, without MSU-1"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by Cardón on 2026-10-14, with the-advocate `a7f278e6` and the ports
`6a9d53c`, in ABL, building a cartridge with every map of the game: see
[`abl-release-stops-at-the-first-night`](abl-release-stops-at-the-first-night.md).

**What is seen**: `rm2k-snes-assemble` stops with "the data does not fit:
a piece of 65536 bytes needs a new bank, and the 127 banks the cartridge
has for data are taken". With a print in the packing (`pack` in
`rm2k-snes/cartridge/src/banks.rs`): the pieces ask for **8,419,280
bytes** and the slots hold **7,700,480**; `release` asks for 5,583,989.
The largest families of labels: `map_tiles_` 1.45 MB, `song_stream_` 1.12
MB, `pose_` 1.10 MB, `sample_` 1.07 MB, and the panoramas
(`pano_tiles_` and `pano_map_`) 0.53 MB.

The count of 2026-10-01 (`ports/abl/research/2026-10-01-the-whole-game-without-msu-1.md`
in the book) said it fit with about 850 KB to spare, without the
panoramas and before the songs and maps added since. With
`--msu-everything` the ROM asks for 4.24 MB and builds. The book's
decisions "The game is playable without MSU-1" and "The MSU-1 is required
only when the ROM does not reach" are the two sides of what has to be
decided.

**How to see it**: a cartridge with every map of ABL; the research
[`ports/abl/research/2026-10-14-what-still-blocks-the-end.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-what-still-blocks-the-end.html)
says how.
