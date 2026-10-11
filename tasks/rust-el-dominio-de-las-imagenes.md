---
name: "Rust: the image domain"
description: "The scaling and colour reduction of images (palette, picture, title, Game Over, battle backgrounds) and, on top of that, the battle drawings (scene, battle_scenes, animation, battle_animations) to Rust, with the ROMs byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, in the migration of the converter to Rust. It's what
the screens (Tataupá) and battle (Cardón) left out, for the same reason:
Pillow's LANCZOS scaling, `palette.reduce` and `color.apply_tint` are shared
by the maps' images (`picture.py`), the title, the Game Over, the battle
backgrounds that go through MSU-1 (`msu_data.py`), the battle scenes
(`scene.py`, `battle_scenes.py`) and their animations (`animation.py`,
`battle_animations.py`). They move together, starting with the scaling.

It starts from `main` at the commit that launches the task. There: `NO_CACHE=1 just
cartuchos` gives `abl.sfc` `241dc9ad2bf8b43c…`, `special` `63779e111ee18923…`,
`encounter-every-step` `200a0b7355289700…`; `just pruebas` 882,
`just -f tools/justfile test` 49.

## The pilot: Pillow's LANCZOS in Rust

**It came out identical.** `tools/snes/resample/` is Pillow 12.3.0's
`libImaging/Resample.c` —the installed one— copied down to the order of
operations: the weights in `double` with libc's `sin`, normalized, to integers
with 22 fractional bits, two passes (horizontally only over the rows the
vertical pass is going to read) and the `clip8` after each one; and what
`Image.resize` does around it: the same size is a copy, RGBA is premultiplied
(`MULDIV255`) and divided back like `Convert.c`, and an image a hundred times
taller than wide goes in two calls.

Measured on 2026-09-30 against **everything the converter scales**: a
`sitecustomize` wrapping `Image.resize` captured every LANCZOS call of
`NO_CACHE=1 just cartuchos` —Pillow's input, size and output—. That's
**377 distinct scalings** (64 RGB: the title, the Game Over, the
`ShowPicture` image and the battle backgrounds, full and lightweight; 313
RGBA: the battlers and the animation frames), **2,826,049 pixels**, and **not
one differs**. The scripts, in `<scratchpad>/lapacho/` (`hook/`,
`piloto/`).

## The boundary

**What moves to Rust is the pixels**: from the image —the file, or what RM2k
draws— to indices and palette. **What stays in Python** is which images the
cartridge carries and the bytes that carry them: the emission.

Three libraries and a stage:

* **`tools/snes/resample/`** (`resample`, new library): Pillow's LANCZOS,
  RGB and RGBA. It knows nothing about the console or RPG Maker. It goes in
  `snes/` because that's the layer that depends on nothing and the stages can
  use it; not in Adeleine because scaling isn't deciding which colour is lost,
  even if it changes pixels. `rm2k-render` has its own Pillow bilinear
  (`resample.rs`, the cells' zoom) and can't use this one: `rm2k/` doesn't
  depend on `snes/`. Two copies of the same convolution with two filters
  remain; noted in "What's missing".
* **`adeleine`** adds **`keep_most_used`**, which is `palette.reduce`: the
  most used ones are kept and each of the others goes to its nearest
  neighbour. **It goes in Adeleine because it decides which colours are
  lost**, which is AGENTS.md's definition ("if it changes a pixel of what's
  seen"): it's the same question `merge_least_visible` answers another way.
  What Adeleine doesn't know is that black is the PPU's backdrop colour: the
  colour that goes first is passed by the caller.
* **The console's tint** (`color.apply_tint`, RM2k's `ToneBlit` in fifteen
  bits) goes to the stage: it belongs to RM2k and to the console at once, and
  today only the animation cells use it. `color.py` keeps the constants that
  `mapdata` emits —the runtime does the same arithmetic—.
* **`tools/rm2k-snes/images/`** (`rm2k-snes-images`, the stage): reads the
  images with `rm2k-render` as a library —the opaque background, the battler
  with its tone, an animation's cells, the `ShowPicture` image—, and does what
  `palette.convert`, `picture.convert`, `scene.backdrop`,
  `scene.light_backdrop`, `scene.battler` and `animation.convert` do today:
  scale, tint, stack the cells (Pillow's `alpha_composite`, also by hand),
  reduce the colours and return indices and palette. One subcommand per piece
  —`fullscreen`, `picture`, `backdrops`, `battlers`, `animations`—, because
  the converter asks for them at different moments: the image when choosing
  which `ShowPicture` goes in, before compiling; the title and the Game Over,
  the animations and the scene, afterwards.

**What the stage receives**: the images' paths —`resources.find_resource`
looks for them in the game and in the RTP, as today, and the stage has no
second copy of that search—, and **the geometry**: the scene's size, how many
colours and from which CGRAM entry, the animations' box. They're ROM numbers
that Python emits to the `.inc`; they travel in the request so that they stay
written only once.

**What stays in Python**, and why:

* **Which images the cartridge carries**: `rom_scene`, `patch_uses`,
  `rom_animations`, `events.Pictures.choose`, `game_backdrops`. They depend on
  the chosen maps, the encounters, the troops and the emitted bytecode: they
  belong to the orchestrator.
* **The bytes and the `.inc`**: `backdrop_bytes`, `fallback_bytes`,
  `battler_bytes`, `scenes_asm`, `animations_asm`, `fullscreen.compressed`
  (packing and LZ2), `picture.cells`, `animation.cells`, `rom_anchor`. It's
  the emission, which the assignment leaves in Python.
* **What ABL's tests use to know what to expect**:
  `scene.position`, `drawing_order`, `compose`; they're ROM geometry and don't
  touch the game's pixels.
* **`msu_data.py`**: the `.msu` format, which doesn't touch pixels.

## Log

* **The stage, whole at once.** The five pieces came out identical on the
  first run: `NO_CACHE=1 just cartuchos`, 1032 files of `rom/build/`
  identical to the base —with `cartridge` in the local `bin/` for the base
  too, because of the `.dbg` trap Mara noted—; `just pruebas` 882, `just -f
  tools/justfile test` 49. The crate's tests compare against the sha256s of
  the old Python (`<scratchpad>/lapacho/ referencia.py`, which runs the
  `tools/` of `1a827260` taken out with `git archive`) over a small game
  built by `juego_chico.py`; those for `keep_most_used`, in Adeleine, against
  `palette.reduce` likewise.
* **The animations are read from the dump**, by number, and not from the
  request as `rm2k-render battle-animation` received them: that's the shape
  of a stage. It came out identical, so the dump and what
  `events.ANIMATIONS` built say the same thing.
* **What the converter prints** wasn't compared against the base: the base
  ran before the `conversor.log` files were saved. The stage's are in
  `<scratchpad>/lapacho/logs-etapa/`.

## Done

**The images' pixels are in Rust**, in `rm2k-snes-images`, over two new or
grown libraries —`resample` and `adeleine`—, and the Python that did them was
deleted. The three ROMs and all of `rom/build/` come out byte-for-byte
identical to those of `1a827260`; the only difference comes from the prose of
the last commit, in the `.dbg` files: see below.

| commit | what |
|---|---|
| `140c840e` | `resample` —Pillow's LANCZOS— with the measured pilot, and the boundary in this task |
| `32e58392` | the `rm2k-snes-images` stage and `adeleine::keep_most_used`; the converter calls it through `port/image_stage.py` |
| `c938b060` | the test of `cartridge`'s fingerprint, which the previous commit left red (I forgot to run it) |
| `f6877a8b` | the deletion, deletion only; `adeleine` and `rm2k-render` leave the fingerprint, because the converter no longer runs them |
| `0bc9b02c` | `port/adeleine.py` goes: all it had left was `CELL`, which was already in `constants.py` |
| `b1939e75` | the prose that named what was deleted |

**What changed from the planned boundary**: nothing substantial. The stage
reads the animations from the dump by number, instead of receiving them in
the request. The title and the Game Over stopped being opened with Pillow in
`snes_convert`: `fullscreen.compressed` and `palette.convert` receive the
path.

## How it was verified

* **The pilot** —above—: 377 scalings, not one pixel different.
* **The cartridges**: `NO_CACHE=1 just cartuchos` and the sha256 of 1032
  files of `rom/build/` —without cache, `.o`, `sello.txt` or
  `conversor.log`; the `.dbg` without `mtime`; the PNGs decoded—, identical
  to the base after each commit up to the `adeleine.py` one. After the
  prose, identical except the three `.dbg` files, which name the size of
  `registers.s`: with the previous size they give the same sha256.
* **The ROMs' sha256s**, the same as in `1a827260`:
  * `release/abl.sfc` `241dc9ad2bf8b43c205a6abef97fbe84ba25f3986626d5f0d058e27c742b123e`
  * `tests/special/prueba.sfc` `63779e111ee18923fc3335b725c92c55a0587f9ecd6e7a1908ae1a852e5e3710`
  * `tests/encounter-every-step/prueba.sfc` `200a0b73552897001dcc22509e356c421cd88cf771dd894e0f13e3e19e4fb89c`
* **The suites**, after each commit with code: `just pruebas` 882,
  `just -f tools/justfile test` 49; `cargo test -p` of `resample`,
  `adeleine`, `rm2k-snes-images` and `rm2k-snes-cartridge`, green.
* **The crates' tests don't depend on ABL**: `resample` against Pillow over
  noise; `rm2k-snes-images` against the old Python over the small game in
  `tests/game/` —two full screens, two images, a background in its two
  versions, a battler with and without tone, three animations with zoom,
  transparency, tones with and without saturation, an invalid cell and one
  the sheet doesn't have—; `adeleine` adds `keep_most_used` against
  `palette.reduce`.

## On merging

* Install globally `images` —the new binary— and `cartridge` —the
  fingerprint names `rm2k-snes-images` and no longer `adeleine` or
  `rm2k-render`—: `just -f tools/justfile install images cartridge`.
  `resample` is a library, and `adeleine` only changed as a library: its
  binary doesn't need reinstalling. Without `rm2k-snes-images` in the PATH
  the converter stops and says how to install it, and so do the scene and
  animation tests.
* `install-scripts` isn't needed: `port/image_stage.py` was added and
  `port/adeleine.py` deleted, modules and not programs.
* `registers.s` changes a comment, with the same lines: if Yarará touched
  the same area, it's a prose conflict.
* It doesn't move the ROM or goldens.

## What's missing

* **`battle_scenes.py` and `battle_animations.py` are still in Python**:
  which backgrounds, battlers and animations the cartridge carries, and their
  bytes and their `.inc`. It's the emission and the choice, which depend on
  the maps, the troops and the bytecode; the assignment left the emission in
  Python. Likewise `picture.cells`, `animation.cells`, `rom_anchor`, and
  `scene.position`, `drawing_order` and `compose`, which the tests use.
* **Two copies of Pillow's convolution**: `rm2k-render`'s bilinear
  (`resample.rs`, the cells' zoom) and `resample`'s LANCZOS. `rm2k/` can't
  depend on `snes/`; joining them needs a common layer or moving the zoom.
* **A background that goes to the ROM is drawn twice**: `rom_scene` asks for
  the quality ones and the lightweight ones in two calls. It costs little;
  they're joined by asking for both versions per background.
* **What the converter prints** wasn't compared against the base (see the
  log).
* `animation.RM_SCREEN` isn't used by anyone, since before this task.
