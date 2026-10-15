---
name: "Identical pages stored once"
description: "Pages whose compiled bytecode is identical are stored once per map and shared through the page table, which already points with 24 bits: Frozen World's map 1 drops from 90 KB to 69 KB, measured"
type: refactor
status: testing
assignee: taro
agents: [Carpintero]
---

Part of phase 1 of Frozen World's combat, from
`research/2026-10-15-frozen-worlds-battle-system.md` in the book, where
Carpintero prototyped it. taro said go on 2026-10-15.

## Log

## How it is done

Started from the-advocate `99140946` and the ports `94e794c`, on branches
`carpintero-shared-pages`.

The code block is laid out by the converter, not by the emission:
`lay_out_code` in `rm2k-snes/convert/src/convert.rs` (it was inline in the
second round of `convert`) places each page's bytecode and its own route's
commands, and a page or a route whose bytes are already in the block points
at them. `rm2k-snes/mapdata` is not touched: it receives `offset` and
`route_offset` per page as before and adds them to `evcode`, so
`record.rs`, `materials.rs` and the Python-hash test do not move.

Why it is safe, checked in the runtime: a page's jumps are offsets from
where it starts (`op_if` assigns Y; `code_carry_before` already moves a
running page by moving its pointer), nothing writes the block, and what
tells two pages apart —the parallel's saved state, the refresh, the action
key— is `page_ofs`, the page's place in the table; `pg_code` is only ever
tested for zero. No routine compares code pointers.

**Only within a map.** Each map's code is its own LZ2 stream, decompressed
alone behind the grid (and alone again into `CODE_CARRY` when a page goes
on after a teleport), so a page cannot point into another map's block.
Across maps it becomes possible with the code of the big maps in the
cartridge (#3 of the research), not before. Identical whole blocks were
already stored once across maps by `store_compressed`.

## What it saves, measured

With the release cartridges, the tools of `99140946` against those of the
branch (`convert` installed locally), the ports at `94e794c`. The bytecode
is the sum of the lengths in the `map_code` table of `mapdata.inc` (what is
decompressed into WRAM); the ROM, the gaps line of `just space` (the banks
used did not change).

| | bytecode before | after | largest map's | ROM |
|---|--:|--:|--:|--:|
| A Blurred Line | 173,689 | 159,299 (−14,390) | 12,716 → 12,584 | −962 B |
| Frozen World | 112,108 | 91,676 (−20,432) | 17,355 → 15,191 | −762 B |

LZ2 already found most of the repetition, so the ROM saves little: what
this buys is WRAM, where a map's code has 19,968 bytes.

**Frozen World with maps 1 and 2**, in a throwaway build: the prototype
compiler of the research (calls as calls, switches past 1023 and
`ChangeActorFace` as nothing, behind `FW_PROTO`), the flash check off, and
a line that prints each map's block with and without sharing; not
committed. Map 1: **90,339 → 69,227**, the research's number, now from
the real layout. Map 2: 38,185 → 38,062. All 155 maps: 242,932 → 212,093.
It then stops where it has to: "map 1: a stream of map_code is 69227
bytes and 19968 fit in WRAM" —the code in the cartridge, #3 of the
research—. Without calls as calls map 1 does not build at all.

## Verified, and what to install

With `convert` installed locally from `carpintero-shared-pages`: `just
test` (27 passed), `just rust-test` with the SoundFont (no failure; the
new `identical_pages_and_routes_are_stored_once` in `convert`, and
mapdata's Python hashes did not move, since the emission did not change:
no filter needed), ABL's `just tests` (1534 passed, 2 skipped; **no golden
moved**), `NO_CACHE=1 just cartridges release` byte for byte equal to the
cached one (`abl.sfc` `06ef6c56…`), and `just boot` from the root of the
ports, 21 passed. The first `just boot` failed only on Sunset as "just
built and the builder takes it as stale": main's `c3e9c695` touched
comments in `runtime/` while it ran; after merging main it passed whole.

What the suite does not cover: a page that **shares** its code with another
and keeps running after a teleport (`code_carry`), and two parallel pages
of one event with the same code; both go through `page_ofs` and a pointer
moved by offset, which the reasoning above covers, but no case builds them
on purpose. Frozen World's shared pages run in no test: it has no suite.

Branches `carpintero-shared-pages` in the-advocate and the book (the
ports' has no commit). **When merging, install `convert`**: `just install
convert`.
