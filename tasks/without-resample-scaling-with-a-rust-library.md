---
name: "Without resample: scaling with a Rust library"
description: "resample (Pillow's LANCZOS bit for bit) and rm2k-render's bilinear imitated Pillow so that the migration did not move the ROM; with the Python gone, both move to a standard Rust library, even if that moves pixels"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02: "I'd like to remove resample. There's no need to
keep compatibility with Python. It was fine for the migration, but I'd rather
simplify the pipeline and have the binaries that need to apply image
transformations use some standard or popular Rust library".

It is used by `rm2k-snes-images` (`pixels.rs`: title, Game Over, large
pictures, backgrounds and battlers, animations, `ShowPicture` with zoom) and,
with its own bilinear scaler, `rm2k-render` (`src/resample.rs`,
`battle_animation.rs`). Changing the scaler moves ABL goldens, which as of
today live in their own repo.

## The library: `image`, only `imageops`

Measured on 2026-10-02 with three toy binaries identical except for the scaler
—they read a PNG with `png 0.17`, scale and write—, compiled with the
workspace's `release` profile (`lto`, one unit, `strip`):

| scaler | binary | crates |
|---|---|---|
| `resample` (today's) | 524,056 B | 13 |
| `image 0.25`, `default-features = false` | 529,392 B (+5 KB) | 18 |
| `fast_image_resize 6`, only `std` | 3,528,416 B (+3 MB) | 24 |

`fast_image_resize` brings a SIMD variant for each pixel type and each CPU
extension, and `lto` does not remove them because they are chosen at run
time: three megabytes to scale a few pictures. It also adds `thiserror`, `syn`
and `document-features` to compile. `image` without features compiles `moxcms`
and `pxfm` —the colour management that `imageops` does not use— and `lto`
throws them out entirely.

How they look, against Pillow —which is what `resample` gave bit for bit—, as
difference per channel over 8 bits and as pixels that change once converted to
the console's 15 bits:

| case | `image` | `fast_image_resize` |
|---|---|---|
| title 320x240 → 256x224, LANCZOS | max 37, 1.5% of pixels | max 35, 1.9% |
| Game Over, same | max 18, 0.4% | max 23, 0.6% |
| background 320x160 → 256x128, LANCZOS with alpha | max 6, 3.9% | max 8, 5.4% |
| animation sheet 480x192 → 320x128, LANCZOS with alpha | max 18, 0.7% | max 18, 1.0% |
| animation sheet, bilinear shrinking and enlarging | max 1, 0.3% | max 1, 0.2–0.3% |

Neither flips the transparency mask. Both look the same to the eye, and both
differ from Pillow in the same thing: the hard edges, where LANCZOS's negative
lobes go past 0 or 255. Pillow clamps to a byte after **each** pass; `image`
does both in `f32` and clamps at the end, and that is why the maxima of 37 and
18 fall on a handful of outline pixels. **`image` is chosen**: the same result
for five kilobytes instead of three megabytes.

What `image` does not do and `fast_image_resize` does: **premultiply the
alpha**. `imageops::resize` says it assumes it done, so it is done on both
sides of the call, in `f32` —without the rounding to a byte that Pillow did
with `RGBa`—, so that a transparent pixel does not tint its neighbours.

Both uses keep the filter they had: `Lanczos3` where there was LANCZOS and
`Triangle` —`image`'s bilinear— where there was BILINEAR.

## What was done

Three commits, in the order "the verifiable and the debatable" asks for:

* **the change**: `Picture::resized` in `rm2k-render` —`imageops::resize` with
  the alpha premultiplied in `f32`—, used by the cells' zoom (`Triangle`) and
  by `pixels.rs` of `rm2k-snes-images` (`Lanczos3`); and the tests that
  compared against the Python, changed on purpose: in `rm2k-render` the zoomed
  cells are compared by where they land and their size, and the zoom by
  properties in `picture.rs`; in `rm2k-snes-images`, `python.rs` becomes
  `answers.rs`, pinned with what it answers today, and it says it is a
  regression net and not an independent answer;
* **the deletions**: `tools/snes/resample/`, `rm2k-render/src/resample.rs`,
  the workspace member, `rust_projects` and `resample-test`. `test_layers.py`
  did not name it;
* **the prose**: `AGENTS.md`, `tools/README.md`, the READMEs of
  `rm2k-snes-images` and `rm2k-render`, and the header of `rm2k-snes-images`.
  The tasks in `testing/` and the dated studies that cite it stay as they
  were.

The binaries, in `release`, before and after: `rm2k-render` 1,458,328 →
1,460,176 B (+1.8 KB), `rm2k-snes-images` 1,351,240 → 1,349,128 B (−2.1 KB).

## In ABL

In a clone of ABL outside `/shared`, branch `sin-resample` on `d6053f5`, with
this branch's tools first in the PATH:

* `abl.sfc` goes from `35c76500…` to `0072d314…`, the same with `NO_CACHE=1`
  as with the cache;
* **37 battler patches** change (`just parches-check` said so, colour by
  colour): the battlers are reduced by merging what is least visible, and a
  different shade changes the merges. Regenerated with `just parches`, in their
  own commit. Those of animations and maps do not change;
* **68 goldens** change, in a goldens-only commit. None shifts or gets cropped
  —a one-pixel shift explains none of them—. Almost all are one or two 5-bit
  steps on the edges: the title 1.5% of the pixels, the Game Over 1.5%, the
  animations less than 0.1%, the small pictures less than 1%. **Two change more
  than the rounding**: the large photos (60–80% of the pixels; before and after
  share 4 of 17 colours, and the tree's dark green turned dark blue) and the
  battle with its background, through the ROM and through the MSU-1 (12–18%;
  the background's green sign became more saturated). Both are the scaling
  amplified by the colour reduction —`keep_most_used` in the photos,
  `merge_least_visible` in the background—, not an error of the scaling, but
  they show. There is one that improved: `imagen-grande-nave-40` lost the
  loose black pixels that Pillow's LANCZOS left on the hard edges (why, I did
  not measure);
* `just pruebas`: **993** green with the new goldens, including
  `test_musica_techos.py`.

Side by side, with x4 crops and a summary per golden, in
`/shared/capturas/2026-10-02-sin-resample/`. **The merge waits for taro's
approval**, above all because of the photos and the battle.

Here: `just -f tools/justfile test` 32, `just -f tools/justfile rust-test`
without failures.

## When merging

* Install `rm2k-render` and `images`: `just -f tools/justfile install
  rm2k-render images`. No Python changed.
* Bring into `/shared/abl-snes` the two commits of the clone's `sin-resample`
  branch (`/extras/scratch/corbatita/abl`): the battler patches and the
  goldens.
