---
name: "Manual patches: one folder per kind of asset"
description: "patches/manual/ as RM2k's own folders —ChipSet/, Picture/…, plus maps/—, the extension telling an image to replace from a database record; new maps by id 1000 and up, instead of forks/ and new/"
type: tooling
status: testing
assignee: taro
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

## Work log (Aguará)

From the-advocate 52d564ca, ports 1869b99, docs e576b44; branches
`aguara-patches-layout` in the three.

**Names chosen.** `maps/` and the RM2k folders as decided. **Common
events stay in `commonevents/`**: RM2k keeps them in its database, not in
a folder, and `commonevents` is the name Ditto's dump gives that section
(`data/db/commonevents.json`) —the same reason `maps/` is `data/maps/`—.
So the lowercase folders are ours, named as Ditto's dump names them, and
the capitalised ones RM2k's, and Mulita's folder does not move.

**Step 1, the move.** `own_files` in `rm2k-project` reads the RM2k folders
of `patches/manual/` itself, skipping `maps/`, `commonevents/` (its
`OURS`), the `README.md` at the root and the `NNNN.json` records inside an
RM2k folder (`is_record`). `fork.rs` reads `maps/` —in this step a new map
is told from a fork by its `tree` field, which is what `new/` meant, so
900 keeps building— and `ChipSet/NNNN.json`. `new_maps` of
`rm2k-snes-cartridges` and the harness's `fork.py`, the same.
Measured: A Blurred Line's `just cartridges` with these tools gives every
`.sfc` and `.msu` —release and the eight test cartridges— byte for byte
main's, and Frozen World's release too.

**Step 2, the debug map to 1000.** Its JSON's `id` and `tree.id`, the
`debug-map` case's `Teleport`, and `patches/auto/maps/1000.toml`. Only
release's `abl.sfc` changes, in 5 bytes; `just space` prints the same as
main's for every cartridge (bank 0 of test-change-system still 69 B);
ABL's suite green, no golden moved.

**Step 3, the rules**, in `fork.rs` (`FIRST_NEW_MAP = 1000`): below 1000 a
map replaces one the game has —one it lacks is an error even with a node,
and a `tree` in a fork too—; from 1000 on it is new, brings its node and
may not cover one of the game's. A `ChipSet/NNNN.json` whose image is
named like a hand-made image in `ChipSet/` is refused, naming both; and a
`NNNN.json` in another RM2k folder (which `own_files` skips and nobody
reads) too. Four new tests, red with step 1's code and green after.
`rm2k-snes-cartridges` and the harness keep telling new maps by `tree`:
the converter guarantees it matches the id, so 1000 is written once. The
ROMs, byte for byte the same as step 2's.

**Step 4, the docs**: a new decision in the book, "The manual patches are
one folder per kind of asset", and the own-files one saying which
paragraph it replaced; the pipeline, Frozen World's page, the index. The
READMEs of both ports' `patches/manual/`, and ABL's "What is forked today",
which still had 108 (gone since 2026-10-14) and lacked 32.

**And a fix of step 1**: `tests/test_dump_readers.py` refuses any
`.join("maps")` outside Ditto, so the patches' `maps/` is named once, as
`MAPS` in `rm2k-project`'s `own_files`, and asked through
`Project::manual_maps`.

## Verified (2026-10-19)

On the final tree (the-advocate 613d7ac5, ports 5619dba): `just lint`,
`just rust-test` and `just test` green in the-advocate; ABL's `just tests`
with these tools, 1573 passed and 2 skipped, no golden moved; `just space`
the same as main's for every cartridge (tightest bank 0, test-change-system,
69 B); `just boot` at the root of the ports, 79 passed. ABL's ROMs: release
differs from main's only in the debug map's id (5 bytes); the test
cartridges and every `.msu`, and Frozen World's release, byte for byte
main's.

What no test covers: the refusals of `own_files` for a loose file at the
root other than a `.md` are covered (`a_file_outside_a_folder_is_an_error`),
but nothing builds a real port with a `ChipSet/` image of its own —ABL has
none, Frozen World none—, so the path where a hand-made ChipSet image
reaches Wally through the merged game directory runs in no suite; it is
the same path as Frozen World's `Picture/`, which does.

**To install when merging**: everything that links `rm2k-project` —`just
install project cartridge patches rm2k-snes-audio convert`—.

**After merging main** (the-advocate 70e925bf, ports e112386, docs
200b42c, with Carpintero's route graphics), on the merged tree with
`events` and `mapdata` installed locally too —Carpintero's change needs
them, and the global ones were older than that merge—: `just lint`, `just
test` and `just rust-test` green; ABL's suite 1573 passed and 2 skipped;
`just boot` 83 passed. `just space`: the tightest bank 0 is now 56 B, in
test-change-system, 13 B less than before the merge; that is main's,
not this branch's: this branch alone printed main's numbers exactly.
