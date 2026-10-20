---
name: "rm2k-render draws the battle"
description: "Another part of rm2k-render drawing everything RPG Maker draws: the battle animations (battle_animations.py, animation.py), the enemies and the battle backgrounds (battle_scenes.py, scene.py)"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, after the CharSets
(`rm2k-render-draws-the-charsets.md`, Yaguarundí), in their words,
translated:

> keep going with all of those

It's another part of
`rm2k-render-draws-everything-from-rpg-maker.md`, in parallel with the other
(`rm2k-render-draws-the-battle.md` and `rm2k-render-draws-the-screens.md`).

Scope: the battle animations (battle_animations.py, animation.py), the enemies and the battle backgrounds (battle_scenes.py, scene.py).

The criterion is the same one Yaguarundí used: what goes to `rm2k-render` is what an
RM2k viewer on a PC would draw the same way; what the port decides because of the
console stays on the converter's side, or in Adeleine if it's deciding
colours.

## What was done (Coatí, 2026-09-30)

Two new subcommands, shaped like `charset`: a JSON request that is
a list, and one output per entry.

* `rm2k-render battle-animation --request <json> --out <dir>`: each
  entry is `{"sheet_file": ruta, "animation": {...}}`, the animation with
  the names from Ditto's dump (`large` and `frames` with their `cells`).
  For animation `i` it writes `<i>.json` —`{"box": [x, y, ancho, alto],
  "frames": [[{"x", "y", "tone"}, …], …]}`, the box relative to the anchor or
  `null` if there are no cells— and each cell RM2k draws of frame `f`
  as `<i>-<f>-<k>.png`, already cropped, with its zoom and its transparency.
* `rm2k-render battle --request <json> --out <dir>`: each entry is
  `{"backdrop_file": ruta}` or `{"monster_file": ruta, "hue": grados}`, and
  out comes `<i>.png`.

The code is `src/battle_animation.rs`, `src/battle.rs` and
`src/resample.rs`; the animations' sheet (five cells per row, of 96
or of 128) went to `rm2k-rules`, `battle_animation.rs`.

### What went to each side, and why

To `rm2k-render`, because an RM2k viewer on a PC would do it the same way:

* **Loading the animation sheet, the Monster and the Backdrop** with what
  RM2k does with each: the sheet and the Monster with the key colour; **the
  background opaque**, because RM2k doesn't apply a key colour to it (easyrpg's
  `Cache`: `Backdrop` isn't `transparent`). The Python achieved it with
  `convert("RGB")`; now it's a stated rule.
* **The cells of each frame**: which ones are drawn (`valid`, and the ones the
  sheet doesn't have aren't), where they're cropped from, the zoom —with Pillow's
  bilinear copied to the bit, premultiplying alpha—, the transparency, and
  **the animation's box**, the union of all the cells of all the
  frames, with the position of each cell inside.
* **The battler's hue** (`battler_hue`, easyrpg's `HueChangeBlit`):
  it's what makes a `BLmouse` three enemies.

What stayed on the converter's side, because it's the port's:

* **Each cell's tone, and therefore the stacking.** The Python tints with
  `color.apply_tint`, which is **the console's** screen tint: at 15
  bits and with the arithmetic the 65816 can do (the truncation of
  oversaturation, for example). A PC viewer would tint at 8 bits. And since
  RM2k tints each cell **before** stacking it, there's no way to leave the
  stacking to `rm2k-render` without putting the console's maths into it: that's why
  **each cell comes out with its tone unapplied**, and the converter tints and stacks
  (`_paint_frame`, which ended up at ten lines). I thought of a colour table
  per tone that the converter would pass to `rm2k-render`: the table would have
  to be indexed by the 15 bits, which is the console inside again.
* **Shrinking**: the animation to OAM's 64 box (`fit_size`, LANCZOS),
  the background and the battlers to 80% of the SNES screen, and the light
  fallback to 128x64.
* **The colours**: the animation's palette of 15 (`palette.reduce`), the
  background's 96, the fallback's 16 and each battler's 15 (Adeleine),
  the alpha cut at half.
* **The ROM anchor** (`rom_anchor`, with `Animation::Position`'s
  offset baked in), the tiles, the bytes, the tables.
* **Which backgrounds and which battlers the cartridge carries** (`battle_scenes.py`), and
  where each enemy stands and who covers whom (`position`,
  `drawing_order`): they're for the ROM's tables, which composes on its own. Nobody
  composes a troop the way RM2k would draw it —`compose` belongs to the tests, in
  console indices—, so `rm2k-render` doesn't compose it: it would be a
  path nobody runs.

### What it costs

Measured with a wrapper that logged each call, in `NO_CACHE=1 just
cartuchos`: **14 calls to `battle-animation`** (150 ms in total; one per
map that shows new animations, and one per batch in `rom_animations`) and
**204 to `battle`** (715 ms; one per background or battler, most of them in
parallel). The build took 47 s, as before (46 s). `by_numbers` requests per
batch; `battle` doesn't, because it isn't noticeable.

### The comparison

Throwaway, in the scratchpad (`coati/comparar.py`): `animation.py` and
`scene.py` from `d4120186` copied aside against the new ones, byte by byte.
**None different**:

* **the LDB's 180 animations** (161 with a sheet, 19 without): the 3623
  frames in RM2k pixels (`_paint_frame`, RGBA) and each one's box,
  and the whole `convert` —indices, palette, anchor, sizes— of the 180;
* **585 battlers**: each Monster in the game with each hue an
  enemy gives it, and also with 0, 17, -45, 181, 359, 360 and 720; the RGBA and the
  whole `battler`;
* **the 70 backgrounds** of the game and the RTP: the RGB, `backdrop` and
  `light_backdrop` whole.

Everything that goes into `release` and `test-special` is inside.

And the ROMs: `NO_CACHE=1 just cartridges` before and after, with the sha256 of
the 1032 files in `rom/build/` (minus cache, `.o`, `stamp.txt` and the log;
the `.dbg` without mtime): **everything identical**.

    905decd20b48411fb509d60ca7a61b3ddbfe1fd5fcf618519972ddba86b83cee  release/abl.msu
    d098a86fbd7fb9bd41b6ccbea3dba3d0ee2b214e1d7e75a911577b95f6b3be10  release/abl.sfc
    616d8bf8e1e9bebf4293bf39f5ddc4211df26f18fe62e2076470808966b1312b  tests/special/prueba.sfc

### The crate's test

`tests/battle.rs` stores the sha256 of what the Python drew over the
two images in `tests/common/` (one indexed and one RGBA with partial
transparencies): the cells of two animations —zoom up, down
and to one pixel, transparencies of 37, 100, -5 and 150, an invalid one, one
the sheet doesn't have, a large one— with their position and the box; the battlers
with six hues; and the RGB of the backgrounds, besides their coming out opaque. The
hashes came from the old Python (`coati/hashes_python.py`), which runs the
same per-cell steps as the old `_paint_frame`, and they all matched.
The executable's tests —requests, relative paths, exit codes—
are in the same file, so as not to touch `command_line.rs`, which Hurra
has.

### What was deleted

From `animation.py`: `sheet_of` (now `sheet_file`, which gives the path),
`_live_cells`, `_side`, `rm_box`, `CELL`, `BIG_CELL`, `COLUMNS` and, from
`_paint_frame`, the cropping, the zoom and the transparency. From `scene.py`:
`rotate_hue`, `_to_hsl`, `_from_hsl` and `_div`, and reading with `load_image`.
`load_image` stayed because `snes_convert.py`, `window.py` and
`menus.py` used it; after the merge with Hurra they no longer did, and it was deleted: see below.

**The commits:** the change (`d8a56790`), with the ROMs identical byte for byte,
and the prose (`a13b4b6a`): the crate's README, AGENTS.md,
`tools/README.md` and the docstrings of `animation.py` and `scene.py`. I didn't touch
`render_map.py`, `command_line.rs`, the `about` in `main.rs` or the
description in `Cargo.toml`, which belong to both sides: the
`MISSING` message in `render_map.py` still says "las capas y los CharSets".

**The suites:** `just tests` 882 and `just -f tools/justfile test` 90,
green; `cargo test` of `rm2k-render` and `rm2k-rules`, green, and
`rm2k-render` with no clippy warnings (the one in `rules/src/tree.rs` was already there).

**On merging:** `just -f tools/justfile install rm2k-render` (it carries
`rules` inside). Nothing in Python was renamed or added, so
`install-scripts` isn't needed.

**After the merge with Hurra** (`d23f52f4`, both sides in each
clash): `battle` and `battle-animation` read the request with its `request.rs`,
`scene._open` calls `render_map.draw`, and **`load_image` was deleted**, because
nobody uses it anymore (`c523d9ff`). On the merged tree, again: the
comparison with no differences, the 1032 sha256 identical to those from before
everything, `just tests` 882 and `just -f tools/justfile test` 90 green.

**For taro:** there's nothing to play, because not a pixel changes.
