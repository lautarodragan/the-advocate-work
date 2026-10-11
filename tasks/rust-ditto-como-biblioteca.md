---
name: "Rust: Ditto as a library, and RM2k's rules"
description: "A single place in Rust that reads the data/ dump with types (Ditto's library), and an rm2k-rules crate with the rules of rpgmaker/rm2k.py; rm2k-render and rm2k-snes-battle stop reading the JSON by hand"
type: refactor
status: done
assignee: taro
---

A step before the event compiler in Rust, discussed with taro on
2026-09-29. Today `rm2k-render` (`source.rs`) and `rm2k-snes-battle`
(`game.rs`) read the dump's JSON by hand, each with its own types; the
event compiler and the rest of the converter are going to need much more.

Hornero decided it:

- **Ditto's library is the only place in Rust that knows how to read the
  dump**, with types for what is used. Ditto is already a library, but with
  a generic model driven by liblcf's schema.
- **RM2k's rules go to a separate crate, `rm2k-rules`**, in
  `tools/rm2k/`: what `tools/rpgmaker/rm2k.py` does today (passability,
  layers, poses, a page's graphic, translucent ones). Ditto is the format;
  the rules, what the format means.
- `rm2k-render` and `rm2k-snes-battle` switch to using them.

## The types: the ones Ditto already generates, not new ones

The question was whether to write types by hand —only what is used— or generate them
from the schema. **They were already generated**: they are the structs with which Ditto
builds the binary, `src/schema/mod.rs`, from liblcf's schema. What was measured:

- the schema: **61 structs, 994 fields, 69 enums**, with the round trip to
  binary 330 of 330;
- what the two consumers read: `rm2k-render`, 7 fields of 2 structs
  (`Map` and `Chipset`); `rm2k-snes-battle`, some 20 of 5 (`Actor`,
  `Parameters`, `MapInfo`, `Encounter`, `Rect`);
- what `rpgmaker/lcf.py` reads, which is what `events` is going to need:
  **192 distinct field names**, and besides `db.decode()` —the whole
  animations section, field by field— and all the terms. So
  writing them by hand was, to begin with, more than 192 fields, and a second
  copy of the model to keep in step with the schema.

The only thing they lacked to read the resolved view, which is `rom/data/`,
was for an enum to be readable as a number: the derived `Deserialize` only
accepted the name. The generator now writes one that accepts the name,
`{"Other": n}` and the number (`lcf::EnumRepr`). It is +1,300 generated lines
in `schema/mod.rs`, none by hand.

`ditto::dump::Dump` opens a dump of either view: the whole
database, a single section, the tree, a map with its layers; and
`read_map` a map by path, for a fork's. `pack` reads through there
too. On `rom/data/`, in release: the whole database 109 ms, the actors
alone 1.4 ms, the tree 1.8 ms, the 328 maps 82 ms.

**A missing field takes the format's default**, it is not an error: that is
what it means for it to be missing in the exact dump, and the types are the same.
Making the resolved view require all the fields is possible —walking
`schema::description`— and was not done: nobody needed it.

## What ended up in `rm2k-rules`

`tools/rm2k/rules/`, on Ditto's types, without knowing about the console:

- `chipset`: the id blocks, `chip_index`, `terrain_of`, the passability
  table by id, where each piece is in the drawing;
- `passability`: the bits, the wall faces, a cell, a map, and which
  tile goes in front of the hero;
- `animation`: water and animated tiles;
- `charset`: the geometry and the pose;
- `event`: the page a save starts with, what a
  page draws (`Graphic::CharSet` or `Graphic::Tile`), which layer collides, which
  animation is continuous, translucency at 160, what a tile imposes on its
  cell;
- `actor`: `Game_Actor`'s experience curve and `add_exp`;
- `tree`: a map's encounter zones, the steps, and the battle background
  and the song it inherits from the tree.

What in the Python belongs to the port did not come over: `@tile:`, dithering and
baking, the opaque CharSets, the conditions the ROM understands, where
the hero starts, `collect_npcs`.

The two copies are tied together by `rm2k/rules/tests/python.json` —inputs and what
the Python answered—: `tests/python.rs` requires the Rust to answer that, and
`tools/tests/test_rm2k_rules.py` that the Python keeps answering it. Water
and zones have no function in Python and are measured in
`tests/rules.rs` against easyrpg's source; the zones are also enforced by
the hashes of `rm2k-snes-battle`.

## What was deleted from the consumers

- `rm2k-render`: from `source.rs`, the hand reader of the JSON and of the
  `.tiles` grid (`find_resource` and the conversion to its `Map` remain); from
  `layers.rs`, the passability table and the `0x30`/`0x10`; from
  `chipset.rs`, the ids and the positions of the pieces, which now come
  from `rm2k-rules`.
- `rm2k-snes-battle`: all of `game.rs` except `Game`, which is now Ditto's
  `Actor` and an `rm2k_rules::tree::Tree`; from `experience.rs`, the
  curve; from `encounters.rs`, `zones`, `Zone` and `DEFAULT_STEPS`.

## What `events` is going to need and is not there yet

- **Guessing Shift-JIS text**: `lcf.text` rebuilds the database's four
  texts that are not cp1252. It is not a rule of the format nor of
  RM2k; it needs deciding where it lives and a decoder (`encoding_rs`).
- **The forks**: the Python applies `rom/parches/manual/` —maps, new
  maps with their node, ChipSets that get added— when reading. The library reads
  the dump as it is and `read_map` reads a map by path; applying the fork
  is up to the caller, as today with `rm2k-render`'s request.
- **`REFIT_TEXTS`**: the Python rebuilds the text boxes when reading the
  commands; it belongs to the port and will have to be a stage.
- `rm2k-snes-cartridges` still reads `maps.json` by hand, for the type of
  each node (`cartridges.rs`). It was not part of the assignment.
- The rules of `lcf.py` that were not copied: `Item.equippable_by`, the
  `hit` of `Enemy`, `critical_hit_chance or 30`, `targets_enemies`,
  `troop_exp`, `leader`. They are small and the Rust does not use any of them yet.

## Verification

Run on 2026-09-29, on `d1f579a8`+prose, with the branch's `ditto`,
`rm2k-render` and `rm2k-snes-battle` installed in the local
`bin/`:

- `NO_CACHE=1 just cartuchos`: the 999 files of `rom/build/` —`.sfc`,
  `.msu`, `.pcm`, `.inc`, the `.dbg` without mtime— byte-for-byte identical to
  those of the baseline, built before touching anything;
- `rm2k-render --map` over the 328 maps of `rom/data/`: the 827 PNGs
  identical to those of the binary from before (the converter uses `--request`, which
  the above covers);
- `just datos-vuelta`: 330 identical, and the resolved view it writes is
  `rom/data/` without a single difference;
- `just pruebas`: 874; `just -f tools/justfile test`: 84 —the 83 and
  `test_rm2k_rules.py`—;
- `cargo test` of rm2k-rules, rm2k-render and rm2k-snes-battle; Ditto with
  `DITTO_CORPUS` and the long batch: 330 of 330 per file and per tree, and
  both views of the whole game read to the same values.

## On merging

Reinstall in the global the Rust that changed: `just -f tools/justfile
install ditto rm2k-render battle`. `rules` is a library and goes inside
the last two.
