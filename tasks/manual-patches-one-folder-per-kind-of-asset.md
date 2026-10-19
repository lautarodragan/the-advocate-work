---
name: "Manual patches: one folder per kind of asset"
description: "patches/manual/ as RM2k's own folders —ChipSet/, Picture/…, plus maps/—, the extension telling an image to replace from a database record; new maps by id 1000 and up, instead of forks/ and new/"
type: tooling
status: doing
assignee: Aguará
agents: [Aguará]
---

Decided with taro on 2026-10-19, to do once
[`frozen-world-a-legible-menu-from-our-own-pictures`](frozen-world-a-legible-menu-from-our-own-pictures.md)
(Aguará) lands: it brings the first file of a port that replaces one of
the game's, and the lookup for it.

**The layout**, flat, one folder per kind of asset, so a person browsing
the patches finds everything about a ChipSet in one place:

* `patches/manual/<RM2k folder>/` —`ChipSet/`, `Picture/`, `CharSet/`…—:
  an image replaces the game's of the same name; a `NNNN.json` replaces or
  adds the database record of that id (today's `chipsets/NNNN.json`, with
  its image's recipe). A recipe that builds an image with the name of one
  lying there by hand is an error.
* `patches/manual/maps/MapNNNN.json` and `.tiles`, as in Ditto's `data/`:
  **an id of 1000 or more is a new map**; below that it replaces the game's
  map, and replacing one that does not exist is an error. That keeps what
  `forks/` and `new/` guarded —a mistyped number does not pass in
  silence— without the two folders. ABL's debug map moves from 900 to 1000.
* `patches/auto/` stays as it is: the converter's decisions, not the
  game's files.

**How the pipeline reads it**: images through `search_dirs`
(`rm2k-snes/convert/src/convert.rs`), the folder in front of the game, so
Adeleine, Wally and the rest keep looking for "an image called X" and know
nothing of patches. Every stage has to take its files from that list; one
that reads `GAME_DIR` on its own would skip the patches. The `.json`
records are merged into the dump, as `chipsets/` is today.

**How**: first the mechanical move —`git mv`, with each old name in the
ports' `RENAMES.md`, ABL's ROM byte for byte equal—; the debug map's new id, which
changes the ROM, apart; then the rules and
the docs, in their own commit.

**What landed since it was written** (Hornero, 2026-10-19): Aguará's
`frozen-world/patches/manual/files/` —a port's file replaces the game's of
the same name— merges them in `Environment::unpack` (`own_files.rs` in
`rm2k-project`), into `build/cache/own-files/`, not through `search_dirs`;
and Mulita's `frozen-world/patches/manual/commonevents/NNNN.json` replaces
common events, through `Dump::with_section` (Ditto) and
`fork::with_common_events` (convert). Both fold into this layout: `files/`
into each RM2k folder, and the common events with the other database
records.
