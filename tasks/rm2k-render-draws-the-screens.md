---
name: "rm2k-render draws the screens"
description: "Another part of rm2k-render drawing everything of RPG Maker's: the FaceSets (menus.py), the System of the windows (window.py) and the ShowPicture sign (picture.py)"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, after the CharSets
(`rm2k-render-draws-the-charsets.md`, Yaguarundí), in their words,
translated:

> go on with all of those

It is another part of
`rm2k-render-draws-everything-from-rpg-maker.md`, in parallel with the other one
(`rm2k-render-draws-the-battle.md` and `rm2k-render-draws-the-screens.md`).

Scope: the FaceSets (menus.py), the System of the windows (window.py) and the ShowPicture sign (picture.py).

The criterion is the same one Yaguarundí used: what an RM2k viewer on a PC
would draw the same goes to `rm2k-render`; what the port decides because of
the console stays on the converter's side, or in Adeleine if it is deciding
colours.

## What was done (Hurra, 2026-09-30)

Two commits, like the precedent: the change (`0b65a702`), with the ROMs byte for byte
identical, and the prose (`b8c180f2`: the crate's README, `tools/README.md`, AGENTS.md,
`docs/port/events.md`).

Three new subcommands shaped like `charset`: `--request <json>
--out <dir>`, the request is a list, entry `i` comes out as `<i>.png`
RGBA, the paths are relative to the request and a file shared by several
entries is read once. All of them are checked and drawn before writing the
first one: a request with a bad entry leaves nothing half done. The crate's
README tells it, "What the screens are drawn with".

* `face`: `{"faceset_file", "index"}`, the 48x48 face with its key colour
  (`src/face.rs`).
* `system`: `{"system_file", "draw"}` with `draw` = `window` (`width`,
  `height`, `message_stretch` as the database brings it), `cursor`
  (`width`, `height`, `drawing` 0 or 1), `text_color` (`color`), `shadow` and
  `timer` (`src/system.rs`).
* `picture`: `{"picture_file", "use_transparent_color", "top_trans"}`,
  named like liblcf's saved `Picture` (`src/show_picture.rs`:
  `picture.rs` was already the one for reading PNG).

What the three requests have in common is in `src/request.rs`. In `main.rs`,
`lib.rs` and `picture.rs` the minimum: the subcommands, the `mod`s, and in
`picture.rs` a `crop` and a `read_unkeyed` —index 0 opaque, which is how a
sign without its transparent colour is drawn—.

To `rm2k-rules`, in new files: `faceset.rs` (48x48, four per row),
`system.rs` (where each piece of the System is, the twenty colours, the
timer, and `message_stretch` → stretched or tiled; the third value is
EasyRPG's and is refused) and `picture.rs` (the opacity of `top_trans`).

On the Python side, `render_map.draw(command, entries)` is the call the
three use. `window.skin(game_dir, database)` —it used to receive the name—
returns a `Skin` with the path of the System and its `message_stretch`, which
requests whatever is needed and remembers it: windows and cursors by size,
and the twenty colours, the shadow and the timer together in one call. The
functions `window`, `cursor`, `text_color` and `shadow_color` of `window.py`
remain, so the ones that draw menus didn't change. `lcf.Database` reads
`message_stretch`.

### What went to each side, and why

To `rm2k-render`, because an RM2k viewer on a PC would do it the same:

* **Cropping the face** out of its FaceSet, with the key colour.
* **The empty window**: the background stretched or tiled according to
  `message_stretch`, the frame on top; **the cursor**; **the blocks** of the
  text and shadow colours; **the timer glyphs**. The timer wasn't in the
  assignment, but `obj_extras` read the System pixel by pixel to get them,
  and leaving it that way meant still having to read the whole sheet in
  Python with `load_image`.
* **The sign as RM2k puts it on screen**: the file, with index 0
  transparent only if the command asks for it, and at the opacity of its
  transparency.

It stayed on the converter's side, because it belongs to the port:

* **Where each window goes** on a 256-wide screen, the 256x80 message, the
  text cut to what fits, and the windows assembled per layer
  (`menus.py`, `screens.py`, `end_game.py`, `title.py`).
* **Writing the text** with the blocks (`window.draw_line`): the rule of
  `Font::Render` is RM2k's, but the font is the port's 8-pixel one
  (`font.py`), and a PC viewer would use another.
* **From the face onwards**: its fifteen colours (`_face_palette`, with
  Adeleine), the borrowed palettes, the cells.
* **All of `picture.py`** except reading the file: scaling from 320x240 to
  256x224, reducing to fifteen colours, cutting into 32x32 objects, the tone
  applied to the palette. The centring —`ShowPicture` gives the centre, not
  the corner— is RM2k's, but it is stuck to the scaling arithmetic (`box`
  scales the two corners); moving it alone helps nobody.
* **Which `ShowPicture` goes in** (`picture_fits`, `Pictures.choose`): the
  converter still rejects the ones that ask for a transparent colour or
  transparency. Now it passes them to `rm2k-render` all the same, with their
  parameters, so the day the port accepts them the drawing is already there.

### What the comparison with easyrpg found, and was not touched

The Python claimed to follow easyrpg to the letter, and in two things it didn't:

* **The edges of the frame and of the cursor repeat from where they start**,
  next to the corner. easyrpg `TiledBlit`s them from the corner of the
  window, so its drawing is shifted 8 pixels, half an edge. Measured: in the
  game's three Systems (`ablskin`, `BLSys`, `BLHigh`) all the edges repeat
  every 8 pixels, so **in ABL not a pixel changes**.
* **The stretch picks the pixel like Pillow** (`NEAREST`, adding the scale
  column by column in a double), not like pixman. I didn't measure it
  against easyrpg.

They were ported as they were, because fixing them is a change of criterion
and doesn't go in the same commit as a verified move. They are stated in the
header of `src/system.rs` and in the crate's README. If taro wants
easyrpg's, it means changing the origin of `tiled` in `frame` and
regenerating the hashes of the tests that use a System that doesn't repeat
every 8.

### The comparison

Disposable, in the scratchpad (`hurra/comparar.py`): the Python of
`d4120186` against `rm2k-render`, RGBA byte for byte, over **all the
FaceSets, Systems and Pictures of the game and of the RTP**, which is more
than what goes into `release` and `test-special`. **None differs**:

* the 16 faces of the 13 FaceSets (208), and `face_of` of the 17 actors
  with a face; the 8 whose FaceSet isn't in the game (`chara1`, from the RTP)
  make both the old and the new one refuse;
* of the 5 Systems, the stretched window and the cursor in 3959 sizes each
  —all the widths from 16 to 320 with eight heights, and all the heights
  from 16 to 240 with seven widths— (19,795 of each), and the cursor in the
  80 small sizes the old one knew how to draw;
* the tiled window in the same sizes, against the old `_tiled` with the
  frame on top (19,795): the Python never drew it, but it did draw its
  pieces;
* the 20 colours, the shadow and the timer of each System;
* the window and a page of text along the converter's path (`Skin`);
* the 112 Pictures: the RGB against the earlier
  `Image.open(...).convert("RGB")` —all opaque—, with the key colour against
  `load_image`, and 111 through `Pictures._read`.

And the ROMs: `NO_CACHE=1 just cartridges` before and after, with the sha256
of the 1032 files in `rom/build/` (minus the cache, `.o`, `stamp.txt` and
the log; the `.dbg` without mtime): **all identical**.

    d098a86fbd7fb9bd41b6ccbea3dba3d0ee2b214e1d7e75a911577b95f6b3be10  release/abl.sfc
    616d8bf8e1e9bebf4293bf39f5ddc4211df26f18fe62e2076470808966b1312b  tests/special/prueba.sfc
    8e85c21b4de4bda9aea90e7061386e7b56a731b245ab039a975eed021f32df6c  tests/encounter-every-step/prueba.sfc

**What it costs**: measured with a wrapper that logged each call, a
`NO_CACHE=1 just cartridges` makes 19 calls to `face`, 57 to `system` and 1 to
`picture` (and the earlier 185 to `charset` and 104 to `layers`). At about
4 ms each, less than half a second in a build of 46 to 52 s, which is what
varies from one run to another.

### The crate's tests

`tests/screens.rs` keeps the sha256s of what the Python drew for an indexed
System with edges that do **not** repeat every 8 and an RGBA one with
half transparencies —windows in six sizes, cursors in four, three
colours, the shadow and the timer—, a FaceSet and another one smaller than
the faces requested from it, and a sign: all generated inside the test. The
hashes came from the old Python over the same formulas
(`hurra/hashes_python.py`), and all 37 matched Rust's. What the Python never
drew —the tiling, the second cursor, the transparency of a sign— is tested
against the rule. `tests/screens_command_line.rs` tests the three
subcommands: relative paths, each kind of entry, and the exit codes.
`rules/tests/screens.rs`, the positions and the opacity.

### What was deleted

From `window.py`: `_tiled`, `_paste`, the assembly of `window` and of
`cursor`, the crops of `text_color` and `shadow_color` and `SHADOW_ORIGIN`.
From `menus.face_of`, the crop. From `events.Pictures._read`, the
`Image.open`. From `obj_extras`, `TIMER_ORIGIN` and the reading of the
System. The unused import of `load_image` in `snes_convert.py`.

**`load_image` stays**: it is used by `scene.py` and `animation.py`, which
belong to the battle (Coatí, `rm2k-render-draws-the-battle.md`). If that task moves
them to `rm2k-render`, it can be deleted.

**Dead and not mine**: `picture.render` and `picture.report` are called by
nobody. I didn't touch them.

**The suites:** `just tests` 882 and `just -f tools/justfile test` 90, green;
`cargo test` of `rm2k-render` and
`rm2k-rules`, green and with no clippy warnings in the new code.

**On merging:** `just -f tools/justfile install rm2k-render`. Nothing in
Python was renamed or added, so `install-scripts` isn't needed.

**For taro:** there is nothing to play, because not a pixel changes.
