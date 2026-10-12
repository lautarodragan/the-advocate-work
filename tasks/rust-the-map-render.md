---
name: "Rust: the map render"
description: "tools/render in Rust: rm2k-render draws a map's layers from the dump and the ChipSet, and the converter calls it through the PATH instead of importing Renderer, with the ROMs byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

Second step of the road to Rust of [`docs/research/las-herramientas-hoy.md`](https://lautarodragan.github.io/the-advocate-docs/research/las-herramientas-hoy.html),
in parallel with Carancho (`rust-the-project-library-and-the-building-of-cartridges.md`). Hornero
decided it: the converter uses the render for two things, `Renderer` (the layers of
each map, which are cached) and `load_image` (loading an image with its key
colour, from several modules). The first goes to Rust, as an executable
the converter calls through the PATH; `load_image` stays in Python while
the converter does.

## What was done (Hurón)

**`tools/rm2k-render/`**, library and executable. The directory is named
like the binary: `render/` is still the Python that stays (CharSets,
`load_image`, the recipe of the fork's ChipSets), and with the binary's
name the `which` recipe of `tools/justfile` finds it like the others.

    rm2k-render layers --map N [--project DIR] --game-dir G --rtp-dir R --out DIR
    rm2k-render layers --request map.json --chipset-file X.png --out DIR
    rm2k-render atlas (--chipset NAME | --chipset-file X.png) -o atlas.png

It writes `lower.png`, `upper.png` and, per family the map uses,
`water-1.png`, `water-2.png`, `animated-1.png` to `animated-3.png`; it deletes
those of a family it does not use. The crate's README says it all.

### The decisions

* **`png` alone, not `image`.** The ChipSets are indexed PNGs and index 0
  is the key colour whatever the file says: the raw
  indices need to be read, which is what `image` hides. None from the game or the
  RTP is BMP, so a BMP is rejected with a message instead of loading a
  decoder with nothing to verify it against. Grey, RGB
  and RGBA at 8 bits with their tRNS are also read, like Pillow.
* **What it writes: RGBA PNG**, with fast compression. They can be opened to
  look at, Pillow reads them as is, and they are lossless. A raw dump would
  save the compression, but it was not needed: see the timings below.
* **How the map reaches it: a `--request`** in JSON with the field names
  of Ditto's dump (`width`, `height`, `lower_layer`, `upper_layer`,
  `chipset` with `chipset_name` and the two passabilities). Not `--map N`
  because the map the converter draws is not the dump's: it carries the fork
  of `rom/parches/manual/` and the events baked into the upper layer, and the
  fork's logic stays in Python. `--map N` exists anyway —it reads the dump
  as is, with `--project`— and the crate's test verifies that it gives the same
  as the equivalent request.
* **The ChipSet through `--chipset-file`**, resolved in Python with
  `find_resource`: it is the same file `chipset_fingerprint` hashes for
  the cache key, so they cannot diverge. `--game-dir`/`--rtp-dir`
  remain for lookup by name, with the same rules (case-insensitive,
  `.png`/`.bmp`, in order).
* **No atlas in Python.** What used it without being a layer —a
  tile's alpha for baking (`_tile_alphas`) and the made-up CharSet of an event
  drawn with a tile (`Charsets._from_tile`)— looks only at tiles of the upper
  layer, which are uncombined copies of the ChipSet: it is done by
  `render_map.upper_tile`, ten lines, copying twice through the alpha as it
  came through the atlas.
* **Alpha blending like Pillow's**, with its rounding: with the
  indexed ChipSets it is a copy, but with partial transparency it is not, and the
  crate's test covers that case with an RGBA ChipSet.
* **The layer cache key** carries `render_map.version()` —the hash of the
  binary— instead of `render/chipset.py`. `render/render_map.py` stays
  in the key, because it is what builds the request; Pillow too, because
  it still reads the PNGs and is what the conversion works on.

### The full comparison

Throwaway, in the scratchpad (`rust-huron/comparar.py`): the Python of
`f19b27ec` copied aside against the new `Renderer`, on the 93 maps of
`release` and `test-special`, RGBA byte for byte. It covers:

* the layers and the animation drawings of each map, with the fork: 142
  images;
* the same with the baked events put into the upper layer: the 4 maps
  that bake;
* the 352 CharSets their events draw, including the translucent ones
  baked against the lower layer and the ones made with a ChipSet tile;
* the 144 upper tiles of each of the 24 ChipSets, and the whole atlas of
  each one, which also covers the combinations no map uses.

**None different.** Drawing the unbaked layers of the 93 maps: 5.3 s
the Python, 3.7 s `rm2k-render` counting the subprocess, writing and reading the
PNGs (serially, outside the converter).

### The crate's test

`just -f tools/justfile render-test`: `tests/python.rs` keeps the sha256 of
what the Python drew for an indexed ChipSet and an RGBA one with partial
transparency, and a 48x32 map that touches all the waters, terrains,
animated tiles, combination ids 47 to 49, tiles past the end of the
page and tiles on both sides of the hero; all generated inside the
test, without game or RTP. `tests/command_line.rs` tests the executable: the
two inputs, the family files that get deleted, and the exit
codes.

### What was deleted and what stayed

`render/chipset.py` was deleted entirely (the atlas) and, from `render_map.py`,
`draw_tiles`, `render_layers`, `atlas`/`atlas_by_name` and the drawing of
`animated_layers`. Staying in `render_map.py`: `load_image`,
`build_passability` (used by the converter and the tests), `DITHERS`,
`Charsets`, `upper_tile` and `Renderer` as context (database, tree,
`load_map`, CharSets, ChipSet fingerprints, `layer_inputs`). Staying whole:
`render/chipset_recipe.py`: it builds the images of the fork's ChipSets, which
belongs to the converter and not to the format.

### For whoever merges

* **From the main checkout: `just -f tools/justfile install
  rm2k-render`.** Without it in the PATH the converter stops with the message.
  No script changed, so `install-scripts` is not needed.
* **`rm2k-render` has to go into the cartridges' fingerprint**:
  `cartridges.fingerprint_files` lists `tiles_bin.binary()` and the other
  binaries; `render_map.binary()` is missing. Without that, recompiling it does not make
  the cartridges stale. I did not touch it: `tools/assembly/` is Carancho's.
* `tools/justfile`: `rm2k-render` at the end of `rust_projects` and the recipe
  `render-test`, next to `lz2-test`.

### Verified

* `NO_CACHE=1 just cartuchos` on `f19b27ec`, after the change and after
  the deletion: the 987 files of `rom/build` (without `.o`, `.sym`, `.inc`,
  `.dbg`) byte-for-byte identical all three times. `abl.sfc`
  `7a3c64834f783ae0fad34eb9f814801916be00aa962d0ca78c1a215ce6a66552`,
  `prueba.sfc` (`test-special`)
  `fb6db844580e74097af5d500be85dbab3f88e888e27743b457167a97ad9e0617`.
* `just pruebas`: 874 pass. `just -f tools/justfile test`: 132 pass, 2
  skipped (the SoundFont ones). `render-test`: 6 pass.
* What was **not** run: ABL's suite after the last commit, which
  only changes comments; and `cargo test` of the other Rust projects,
  which were not touched.

Commits: `7b49ad2a` (the crate), `c7d2fe84` (the converter uses it),
`2ffc6152` (the deletion, mechanical), `a0968a38` (the citations in prose).
