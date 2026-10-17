---
name: "ABL: the whole game does not fit in 8 MB"
description: "With every map, ABL asks for 8.42 MB of data and the 127 data banks hold 7.70 MB: about 700 KB over, without MSU-1"
type: bug
status: done
assignee: taro
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

## Log

**2026-10-14, Carpintero.** Taken as a research, not an implementation:
measure what each option saves and costs, and the smallest combination
that fits without MSU-1. Worktrees `carpintero-fit-8mb` of the-advocate
(`51b4b1b2`) and the ports (`d91049e`), with Cardón's experiment diffs
applied —never to be merged— and one more print in `pack`: with
`CARPINTERO_DUMP=<file>` it writes every piece the packing receives, whole,
so each family can be compressed and deduplicated off-line.

The measurement, with the cartridge of 8,426,177 bytes asked: every piece
re-read as bytes, LZ2 and xz of each, the poses decoded to pixels, the
song streams parsed, the per-map tables compared by text, and a
first-fit-decreasing pack of each combination over the 127 slots (the real
packer's loss, 86 KB of gaps, taken from the MSU-1-required build of the
same maps, which builds: 4,238,894 B in the ROM, 4,189,665 B to the
`.msu`). Written up in the book:
[`ports/abl/research/2026-10-14-fitting-the-whole-game-in-8-mb.md`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-fitting-the-whole-game-in-8-mb.html).

**The answer**: it fits without MSU-1 and without losing anything. The
three emitter-only deduplications —identical samples (−205 KB), the
per-map actor tables that are 22 tables repeated 307 times (−213), the
NPC pose tables shared whole (−41)— and the poses stored without their
empty tiles (−571: 52% of their tiles are empty; a walking step uploads
240 B on average against 512) leave about 300 KB free by the count, some
210 after the packer's loss. Nested repeats in the songs (−124), the
panorama tiles in LZ2 (−85), the NPC tables per entry (−74 more) and a
sprite tile pool (−133) take it to about 730 KB, all lossless. The quality
cuts are not needed.

**What grew since 2026-10-01**: +783 KB over that day's "as today", from
the panoramas (+518, left out then), the fonts precomposed in eight phases
for three inks (+351), the big pictures (+293), the per-map sprite tables
(+184) and the poses (+129); the lossless plan of that day happened, about
−760 KB.

No code: the experiment's diffs —Cardón's plus the dump in `pack`— were
kept outside the repos and its worktrees removed. Nothing to install when
merging; only the book's commit. One finding left as a draft:
[`identical-samples-are-stored-once-per-key`](identical-samples-are-stored-once-per-key.md).

What taro decides: the lossless combination (two pieces of work, the
emitter's deduplications and the pose format) or the MSU-1 required.
