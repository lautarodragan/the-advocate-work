---
name: "rm2k-render draws the CharSets"
description: "The first part of rm2k-render drawing everything of RPG Maker: the poses of a CharSet and the ones made with a tile, which today the converter draws in Python"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, in their words, translated:

> let's go for the CharSets in rm2k-render

It is the first part of `rm2k-render-draws-everything-from-rpg-maker.md`, and it comes after
Adeleine in Rust because the CharSets go through Adeleine before reaching
Voodoo.

The criterion for what goes into `rm2k-render` comes from the decision
(`decisions/the-tools-split-from-abl.md`): drawing what
RPG Maker would draw, without knowing about the SNES. What the port decides
because of the console —the pattern or the baking of the translucent ones,
which the SNES does not have, the opaque CharSets— is not `rm2k-render`'s: it
stays on the converter's side, or Adeleine's if it is deciding colours. The
test to know which side something goes on: would an RM2k viewer on a PC do it
the same way?

## What was done (Yaguarundí, 2026-09-30)

Two commits: the change (`c455677e`), with the ROMs byte for byte identical,
and the prose (`a418f6d3`): the crate's README, AGENTS.md, `tools/README.md`,
the justfile and `docs/port/events.md`.

`rm2k-render charset --request <json> --out <dir>`: a request is a list of
CharSet sheets, and sheet `i` comes out as `<i>.png`, RGBA. Each entry is
`{"charset_file": ruta}` or `{"chipset_file": ruta, "tile": n}`, and either of
the two can carry `"translucent": {"behind": png, "x": x, "y": y}`. The paths
are relative to the request. The crate's README tells it, "What an event is
drawn with"; the code is `src/charset.rs`.

### What went to each side, and why

To `rm2k-render`, because an RM2k viewer on a PC would do it the same way:

* **Loading a CharSet with its colour key** —index 0 of an indexed one—.
  `picture::read_rm2k` already did it for the ChipSets.
* **The sheet of an event made with a tile** (`_from_tile` and `upper_tile`):
  RM2k draws tile `n` of the upper layer where the event is, whichever way it
  faces. The sheet with the tile in the twelve poses of character 0, standing
  in its cell, is the way for it to be cropped like any other; the double copy
  for the alpha, which in an indexed one is a copy, comes from when the tile
  came out of the atlas, and it is in the test.
* **The blend of a translucent one at 160/255 over what is behind it** (what
  `_baked` did): it is RM2k's drawing in that cell. The opacity and the poses'
  geometry are `rm2k-rules`'s (`event`, `charset`); they were not duplicated.
  Outside the background it is black, which is what RM2k shows outside the
  map.

It stayed in `render_map.Charsets`, because it is the port's:

* **The pattern** (`~trama`, `DITHERS`): it exists because the SNES does not
  have transparency to spare.
* **Baking** —leaving the blend inside the graphic, opaque— and **against which
  background**: the map's lower layer, because the upper one is drawn
  afterwards and covers. `rm2k-render` receives the background as a picture
  and does not know about layers.
* **The `~aparte` copy**, which is the same drawing with another palette.
* **The names** (`@tile:`, `~horneado:…`): they are how the port calls each
  graphic. `Charsets` translates the name into the request.
* **Cropping the pose and everything that comes after** —the OBJ's 32x32, the
  colours, the 8x8 tiles— is `sprites.py`'s and Adeleine's, as before.

The opaque ones (`[graphics] opaque`) do not even go through here:
`rm2k.decorate_translucent` decides them when reading, and they arrive as a
plain CharSet.

### In batches, and how much it costs

`Charsets.draw(nombres)` asks for a list in a single call; `get` of a name
nobody asked for costs a call of its own. Measured with a wrapper that noted
each call, in `NO_CACHE=1 just cartridges`: **186 calls to `charset`** (and
106 to `layers`), one per CharSet asked for on its own. A call for one CharSet
costs 3.7 ms, against 2.1 ms per CharSet in a batch and 0.3 ms to read it with
Pillow: in total, less than a second in a 46 s build, which took the same
before and after. That is why the whole cartridge is not asked for at once:
building the whole list would force bringing forward decisions of
`drawable_npcs`. I tried one batch per map in `convert_map` and it went down to
163 calls; I did not keep it, because it is not noticeable. The only batch
that stayed is the one in `baking.bakeable_events`, which asks for the alpha of
several tiles per map.

`baking._tile_alphas` now looks at the tile in the event's sheet —pose 0,
where the cell is— instead of cropping it from the ChipSet: it is the same
drawing, and that way `upper_tile` goes away. Its signature changed, and with
it `rom/pruebas/herramientas/test_horneados.py`.

### The comparison

Throwaway, in the scratchpad (`yaguarundi/comparar.py`): the `render_map.py`
of `a369a538` copied aside against the new `Renderer`, RGBA byte for byte,
over **the game's 328 maps** (those of `release` and `test-special` are
included). **None different**:

* 1930 sheets of the CharSets the events draw, with the `~aparte` copy of each
  one;
* the 6 baked translucent ones there are, and their pattern version (5
  different);
* the 144 upper-layer tiles of each of the 36 ChipSets, as an event sheet
  (5184), and their alpha via `_tile_alphas` against the old `upper_tile`
  (5184);
* the CharSets of the 17 actors.

And the ROMs: `NO_CACHE=1 just cartridges` before and after, with the sha256 of
the 1032 files of `rom/build/` (minus cache, `.o`, `stamp.txt` and the log;
the `.dbg` without mtime): **all identical**.

    d098a86fbd7fb9bd41b6ccbea3dba3d0ee2b214e1d7e75a911577b95f6b3be10  release/abl.sfc
    616d8bf8e1e9bebf4293bf39f5ddc4211df26f18fe62e2076470808966b1312b  tests/special/prueba.sfc
    8e85c21b4de4bda9aea90e7061386e7b56a731b245ab039a975eed021f32df6c  tests/encounter-every-step/prueba.sfc

### The crate's test

`tests/charsets.rs` keeps the sha256 of what the Python drew for an indexed
CharSet and an RGBA one with half transparencies, tiles of an indexed ChipSet
and of an RGBA one, and translucent ones in middle cells and on the edges of a
background: all generated inside the test. The hashes came from the old Python
over the same files (`yaguarundi/hashes_python.py`), and all twelve came out
identical to Rust's. `tests/command_line.rs` tests the subcommand: the three
kinds of entry, the relative paths, and the exit codes. The ChipSet generators
that `tests/python.rs` already used moved to `tests/common/`.

### What was deleted

From `render_map.py`: `upper_tile`, `Charsets._from_tile`, the blend of
`Charsets._baked` and `Renderer.chipset_by_name` —with its cache of ChipSet
pictures—, which only `_from_tile` and `baking` used. Its place is taken by
`Renderer.chipset_file`, which gives the path. **`load_image` stays**:
`scene.py`, `window.py`, `menus.py`, `animation.py` and `snes_convert.py` use
it.

**The suites:** `just tests` 882 and `just -f tools/justfile test` 90,
green; `cargo test` of `rm2k-render`, green and without clippy warnings.

**When merging:** `just -f tools/justfile install rm2k-render`. No Python was
renamed or added, so `install-scripts` is not needed.

**For taro:** there is nothing to play, because not a pixel changes.
