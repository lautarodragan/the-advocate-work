---
name: "The mode 7 pilot, for the zoom of the Diff photos"
description: "A test ROM that does the 100 to 0 % zoom of a Diff photo in mode 7, with the variants that fit in its 256 tiles, so taro can see it on the TV"
type: research
status: done
assignee: taro
---

From taro, on 2026-10-02, after seeing Bandurria's video
(`/shared/capturas/2026-10-01-escenas-diff/`): "I'd like to explore using mode
7. We ruled it out because its use is very brief, but now that I've seen the
video, I realize it's emotionally striking, and the zoom helps convey the
emotion much more". Jilguero's study had ruled it out (option F): mode 7's map
allows 256 8-bit tiles and a whole photo needs 896.

Done by Chimango, from `main` at `cb333da4`.

## What was measured of the original

From Bandurria's raw recording (`raw.mkv`, 60 frames per second), frame by
frame, on 212 and 213, with the width of what isn't black:

* **The flash** is a white `FlashScreen` of strength 31 and 0.2 s
  (`11040 [31, 31, 31, 31, 2, 0]` on 213, 214 and 216; 212 doesn't have it,
  and what flashes there is battle animation 93 of the explosions, on top of
  the photo). The photo appears **under** the white, on the same frame: the
  mean brightness goes from 246 to 102 in 12 frames, in a straight line.
* **The photo stays still for 93 frames** on 213 (the 1.5 s `Wait` plus the
  commands' frames; on 212, 118, with the explosions animation on top) and
  **the zoom is linear**: the width drops by 1/120 per frame, from 640 to 0 in
  exactly 120 frames, centered on the center of the screen. There's no
  acceleration or braking: scale = 1 − t/120. Measured the same on 212 and
  213.
* **The crop**: the four maps are 20x15 —the whole RM2k screen—, so RM2k's
  camera is at (0, 0) and the ROM's (`follow_camera`) wherever the hero leaves
  it, who enters through a `Teleport` and doesn't move: PhoneCallDiff and
  SurlGravesDiff are cropped from (8, 16) and SurlBroDiff and ThreeRubbleDiff
  from (0, 16), at 256x224. `recorte()` in `armar.py` computes it; the
  comparison with screenshots that `las-fotos-diff-recortadas-y-el-montaje.md`
  asks for wasn't done.

## The ROM

`just zoom-modo-7` builds it (`rom/experimentos/zoom-modo-7/`) and verifies it
in snes9x, bsnes and mesen-s; `just zoom-modo-7-videos <originales> <salida>`
records each combination next to the original. It shows the **four photos**
—not just PhoneCallDiff: the other three have noise, 896 distinct tiles out of
896, and are the hard case— with **four variants** each, in a loop: black, the
photo with the flash, still, the zoom, black. Up and down change photo, left
and right change variant, B hides the two numbers in the corner (photo and
variant), Start pauses and Y is slow motion (×8).

1. **media**: the photo at 128x112, averaging 2x2 —188 tiles in PhoneCallDiff,
   225 in the others—, enlarged to double with the matrix. The whole scene in
   mode 7: the still photo already looks blurry and pixelated.
2. **hybrid, media**: still in mode 1, whole at 4 bits, as the game shows it
   today (Adeleine in seven palettes, Voodoo), and on the first frame of the
   zoom it switches to mode 7 with 1's texture.
3. **vq**: the photo at full resolution with 255 distinct tiles, through
   vector quantization: the 896 tiles are grouped into 255 by their shape
   —averaged 2x2, so the grass's noise doesn't decide— and each place shows the
   photo's most representative tile of its group. The whole scene in mode 7.
4. **hybrid, vq**: still in mode 1 and the zoom with 3's texture.

**The flash** is `COLDATA` added to BG1 and the backdrop, and the table of how
much white goes into each of the 12 frames is chosen per photo so that the
mean brightness follows RM2k, which blends towards white instead of adding.
It's on all four photos, even though the original 212 doesn't have it.

### What couldn't be done: the hybrid with a threshold

The assignment asked for full resolution in another mode **while the scale
goes down to a threshold** (60 or 50 %) and mode 7 from there down. **It can't
be done**: neither mode 1 nor 3 scales, and shrinking a 256x224 photo per
frame on the CPU means uploading tens of KB per frame. The only thing that can
be shown at full resolution in another mode is the **still** photo, and that's
why the hybrids switch when the zoom starts. And what the threshold was after
—that the zoom start sharp and the lack of resolution appear when it no longer
shows— is given by the vq texture: it's full resolution, so there's no
threshold to wait for. Below 53 % any 256-tile texture is enough (the screen
shows fewer pixels than it has), and that's why switching texture halfway
through the zoom wouldn't add anything: it would also cost three or four
vblanks of garbage, because the 256 tiles get overwritten while they're being
shown.

### What was measured in the ROM

* **The still photo**, pixel by pixel at 15 bits against the expected one:
  identical in all sixteen combinations and the three cores. That covers the
  whole texture in VRAM, the matrix at scale 1 and the center.
* **The curve**: the width and height of what isn't black, on twelve frames of
  the zoom, against 256·(1 − t/120) by 224·(1 − t/120): within one pixel and
  centered, in all of them. For example, t = 30: 191x167 (media) and 193x168
  (vq) against 192x168; t = 60: exactly 128x112; t = 120: nothing.
* **The hybrids** upload the mode 7 texture in **8 or 9 vblanks** of 4 KB with
  the photo on screen (the whole 128x128 map and the tiles: 30 KB), and the
  mode change with the 256-color palette fits in one vblank: **zero frames in
  black**. The longest vblank ends on line 251 of 261.
* **The three cores give the same** on every frame looked at.
* **How close it is to the photo**, in dB (pixel to pixel / averaged 4x4,
  which measures shape and not grain), is printed by the recipe:

      PhoneCallDiff    modo 1 42.5/47.3   media 30.8/42.4   vq 32.7/44.5
      SurlBroDiff      modo 1 27.8/34.1   media 19.3/34.5   vq 17.8/30.5
      SurlGravesDiff   modo 1 33.0/39.5   media 18.3/35.8   vq 16.8/30.1
      ThreeRubbleDiff  modo 1 33.1/37.7   media 16.8/36.1   vq 15.0/27.5

  In PhoneCallDiff, the sepia one with smooth areas, vq wins at everything. In
  the noisy ones, media keeps the shape better and vq the grain: vq to the eye
  looks like a "photo" but with tiles swapped around —a tombstone or a piece of
  tree that isn't its own—, and media looks washed out. The TV decides that.
* **The hybrids' jump** is that same difference: from 42.5 dB (mode 1) to
  30.8 (media) or 32.7 (vq) in PhoneCallDiff. With media the photo visibly
  softens on the zoom's first frame; with vq the grain stays and the jump is
  less noticeable.
* **The largest media texture that fits** in 256 tiles, deduplicating, is
  152x136 in PhoneCallDiff and 136x120 in the other three: 6 % more resolution
  than 128x112 in the noisy ones. Not worth a variant.

### What looks different from RM2k

* **The cropped photo shrinks what was cropped**: in RM2k, when shrinking, the
  whole 320x240 photo is seen; in the ROM, the 256x224 part that was on
  screen. With the photo small it doesn't show; at 80 % it does, if one
  compares.
* **The center** is the ROM screen's, which isn't the center of RM2k's photo:
  because of the crop, the photo's center falls 24 pixels to the right and 8
  up from the screen's, in PhoneCallDiff. The photo shrinks towards the center
  of what's visible.
* **Mode 7 doesn't filter**: when shrinking, the grain of the noisy photos
  flickers from one frame to the next, more with vq —which has all the grain—
  than with media. Whether it flickers the same in RM2k wasn't measured: it's
  in the videos.
* **The flash adds**: it starts and ends like RM2k's, and in the middle it
  follows its mean brightness, but the light areas saturate sooner.

## The cost of bringing it into the game

What `big_picture.s` does with the photos today: the photo's tiles in mode 1
from word 0 up to `$3FFF`, its tilemap at `$4000`, the message window moved to
`$4800`, its tiles and BG2's above `$5000`; two frames with the screen off when
showing it and fourteen when erasing it, which reloads the map. **Mode 7 owns
`$0000`-`$3FFF` and doesn't move**: the 128x128 map in the low bytes and the
256 tiles in the high ones.

**Variants 1 and 3, mode 7 only** —the cheapest—:

* VRAM: **zero extra**. The texture takes exactly the place of today's photo
  tiles, and the window isn't touched.
* CGRAM: mode 7's palette is 256 colors and overwrites the window's (palette
  0): the texture is limited to colors 16 to 255 —240; in the pilot none goes
  over 239— and the window stays as it was.
* ROM: per photo, media is 12 to 14 KB of tiles, 1.8 KB of map rows (almost
  all zeros: with LZ2, almost nothing) and 512 bytes of palette; vq, 16 KB,
  3.5 KB and 512. **All four: about 62 KB with media and 80 with vq**, more
  than one 64 KB bank. The mode 1 versions stay, because 217's montage uses
  the four photos.
* `big_picture.s`: an entry of `big_table` with the mode 7 texture; `big_load`
  uploading it —three DMAs: rows through the low bytes, the rest of the map as
  zero with the fixed source, tiles through the high ones— with the screen
  off, as today; `BGMODE` 7, `M7SEL` at `$80`; and `big_move` which, with the
  magnification ramp, writes A and D in vblank: **one hardware division per
  frame**, K·d / (d − t) with K = 128 (media) or 256 (vq) —16 bits by 8—,
  which is the pilot's table without a table. On reaching 0, BG1 off and
  `BGMODE` 1, so that the messages that follow in black see the window.
* The converter (`rm2k-snes-images`): media is a 2x2 average and reducing to
  240 colors, which is Adeleine's `merge`; vq is deterministic k-means over
  the averaged tiles and picking representatives, about a hundred new lines in
  Rust.
* **Frames in black: the same as today.** Two when showing it —under the flash
  on 213, 214 and 216; over the map on 212, the flicker it already has—, none
  in the zoom or at the end, and the fourteen of the `ErasePicture`, over
  black.

**Variants 2 and 4, hybrids**, all of the above and also:

* VRAM: both photos at once. The mode 1 one has to move from `$0000`-`$3FFF` to
  `$4000`-`$7FFF` —28 KB of noisy tiles, and its tilemap—, which **overwrites
  the window and BG2's tiles**. In the four scenes there's no message while the
  photo is up, so it can be done, if the window is restored afterwards: about
  10 KB in two or three vblanks during the 1 s `Wait` that follows the zoom on
  all four pages.
* Uploading the mode 7 texture in vblank while the photo is still: in the
  pilot, 8 or 9 vblanks of 4 KB; in the game the vblank already does other
  things, and at 2 KB it would be about 16, against the 93 frames of still
  photo. And the palette and mode change in the vblank of the zoom's first
  frame, which in the pilot fits.
* ROM: the same as 1 and 3; the mode 1 photo is already there.
* `big_picture.s`: also, the other place for the mode 1 photo for these four,
  the upload queue, the switch, and restoring the window.
* **Frames in black: the same as today**, and zero at the switch.

**Apart from mode 7**: the flash with `COLDATA` also works for today's mode 1
photo —the white on 213, 214 and 216 that today gets cut off when the photo
appears, `divergencias/lo-que-las-imagenes-grandes-no-modelan.md`— and for
217's montage in `las-fotos-diff-recortadas-y-el-montaje.md`.

## What's in `/shared/experimentos/2026-10-02-modo-7/`

The ROM, a `LEEME.txt` with the photos, the variants, the buttons and what to
look at on the TV, and `videos/`: sixteen, one per photo and variant, with the
original on the left and the ROM on the right.

**Pending**: that taro see it on the TV and choose a variant —or none—. When
merging there's nothing to install: it touches neither Rust nor `tools/`.

# What taro said at the TV

On 2026-10-03, after seeing it on the SNES: "mode 7 is definitely the way to
approach the photos". It remains to choose a variant —media, hybrid media, vq
or hybrid vq— to bring it into the game.

taro chose the **hybrid vq** (variant 4), on 2026-10-03. It goes into the
engine in `las-fotos-en-modo-7.md`, in the tools repo.
