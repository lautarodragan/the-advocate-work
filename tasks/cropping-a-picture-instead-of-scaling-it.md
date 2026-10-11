---
name: "Cropping a picture instead of scaling it"
description: "An engine option so that a full-screen picture is cropped to the console's window instead of being scaled; ABL uses it on the four Diff photos, which are captures of the map"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-02 (the game's task is in ABL:
`tasks/diff-photos-cropped-and-217-montage-as-in-rm2k.md`): the Diff photos are
captures of the map at 320x240, and the original uses them for a "live to
photo" effect. Scaled to 256 they no longer match the ROM's map. Cropped they
do, because the ROM does not scale the map.

It goes on top of `without-resample-scaling-with-a-rust-library` (Corbatita): with `image` instead of Pillow's
LANCZOS, the scaled photos pick other colours when reduced and the tree's
shadow goes from green to blue. Cropped, they do not go through the scaler.
Hornero proposed waiting for this before merging `without-resample-scaling-with-a-rust-library`, so that that
version never goes in, and taro said to go with whatever seemed right. The
montage of 217 is left for after the mode 7 pilot.

Done by Golondrina, from `main` at `3a188d9f` with Corbatita's branch merged on
top (`2b76713c`); `main` moved to `ef5f8133` with the same merge, and it is
merged before delivering.

## Where the option lives: `[graphics] cropped_pictures`

In `rm2k-snes.toml`, a table by picture name, with the picture's pixel from
which the console's screen is cut:

    [graphics.cropped_pictures]
    PhoneCallDiff = [8, 16]

Why there and not in a versioned patch: the patches are **what the converter
decides to lose** —merged colours, sound effects that do not fit— and it writes
them itself; this is a decision of the game about how a picture is presented,
which the converter cannot take alone because it depends on where the camera is
when the scene shows it. It is the same kind of thing as `[graphics] opaque`:
an engine knob the game turns on, by name, case-insensitive like RM2k. And like
every key of the project file, **it is mandatory** (empty, `{}`, in a game
that crops nothing): the converter has no defaults for what the game says.

What it does, end to end:

* `rm2k-snes-convert` reads it when reading the game (`pictures::Cropped`, in
  `Game`) and passes the crop to the stage of the large pictures. A cropped
  picture **is always large** —it is the screen—, unless its `ShowPicture`
  places it by variables, which still goes to the objects.
* `rm2k-snes-images background` receives `"crop": [x, y]` in the request, and
  only when there is a crop, so the request for the scaled ones is the usual
  one. With a crop it does not scale: the canvas is the console's screen, cut
  from the picture from that pixel, wherever the `ShowPicture` places it. It
  refuses if the window goes outside the picture or if the zoom is not 100 (the
  crop is in the file's pixels).
* Nothing else changes: neither the emission, nor the runtime, nor the
  compiler.

The montage of 217 shows the same four photos, so they go cropped too: it is
the same picture with the same name.

## The crop, verified against the ROM

The four maps are 20x15, RM2k's whole screen, so the photo is what RM2k showed
with the camera at (0, 0). The ROM centres the hero —who arrives through a
`Teleport` and does not move— against the map's edge: from Chimango,
`PhoneCallDiff` and `SurlGravesDiff` from (8, 16), and `SurlBroDiff` and
`ThreeRubbleDiff` from (0, 16).

To verify it, in a separate clone of ABL (not committed), a test cartridge with
maps 212 to 217 and one page per map that enters with the game's `Teleport`
—(8, 10), (6, 10), (8, 9) and (7, 11)—: the real scene runs and puts up the
photo. Each frame up to the photo was saved, and it was measured, at 15 bits:

| map | photo | the ROM against RM2k's map | the next one |
|---|---|---|---|
| 212 | PhoneCallDiff (8, 16) | 99.5 % identical | — |
| 213 | SurlBroDiff (0, 16) | 99.2 % | 81.0 % at (16, 16) |
| 214 | SurlGravesDiff (8, 16) | 83.7 % | 76.1 % at (40, 16) |
| 216 | ThreeRubbleDiff (0, 16) | 96.0 % | 66.7 % at (16, 16) |

"RM2k's map" is its two layers drawn by `rm2k-render layers`, without events;
what does not match is the characters (214 has a hundred graves that are
events). The frame is the last one before the photo without the white flash the
scene puts just before. **The ROM's camera is exactly Chimango's crop in all
four.**

And that the photo is RM2k's screen without shifting: the correlation of the
edges between the photo and RM2k's map gives the maximum without shifting it on
212, 213 and 216, and on 214 at one pixel by very little (0.122 against
0.116): it is the photo that changed the most with respect to the map —other
graves—. The edges of the ROM's screen against each crop of the photo also give
the maximum at the crop, in all four. **Pixel by pixel they do not match, nor
can they**: the photos are retouched —smoothed and with grain, 212 in sepia—
and are another moment of the scene, which is the point of the effect; and the
ROM reduces the colours. What matches is the background, without shifting.

The new golden of `imagen-grande-foto-5` is, pixel by pixel, the ROM's screen
on the real 212 with the photo on top; that of `imagen-grande-fotos-5`, the one
of 213.

## In ABL

In `/extras/scratch/golondrina/abl`, branch `fotos-recortadas`, on top of
`a64eab2` (Corbatita's two commits, which are those of `/shared/abl-snes`):

* `26fc753` asks for the crop in `rm2k-snes.toml`, with the four;
* `a942b02` the goldens, only goldens: **seven**, the ones that show the photos
  —`imagen-grande-foto-5` and `-140`, `imagen-grande-fotos-5`, `-65` and
  `-125`, `imagen-grande-montaje-fotos-3` and `-9`—. No other moves, not even
  Corbatita's 68.

`abl.sfc` goes from `0072d314…` to `8c9e670f…`; the two test cartridges stay
the same (they do not carry the photos). `just espacio` on `release`: 43 free
banks, same as before; the gaps of the used banks go down from 62,373 B to
59,217 B: the cropped photos ask for some 3 KB more than the scaled ones (why,
I did not measure).

Side by side —before `without-resample-scaling-with-a-rust-library`, with `without-resample-scaling-with-a-rust-library` and cropped, and the
map right before each photo against the photo— in
`/shared/capturas/2026-10-02-fotos-recortadas/`, with its `LEEME.txt`. **The
merge waits for taro's approval of the seven goldens.**

## The numbers

* `just pruebas` in the ABL clone, with this branch's tools first in the PATH
  —and `main` merged, which changed nothing in the tree—: **993** green with
  the new goldens, including `test_musica_techos.py`. Without them, the three
  tests of the photos red and nothing else.
* `NO_CACHE=1 just cartuchos` and the build with cache give the same
  `abl.sfc`, `8c9e670f…`.
* `just -f tools/justfile test`: 32.
* `cargo test -p rm2k-snes-images -p rm2k-snes-convert`: green, with four new
  tests —the crop in `background.rs`, and the table in `pictures.rs`—.

## When merging

* Install `images` and `convert`: `just -f tools/justfile install images
  convert`. No Python changed.
* **Before installing them, `/shared/abl-snes` needs the table**: the new
  converter refuses to run without `[graphics] cropped_pictures`. First bring
  the two commits of the clone's `fotos-recortadas` branch
  (`/extras/scratch/golondrina/abl`), which go by fast-forward on `a64eab2`.
