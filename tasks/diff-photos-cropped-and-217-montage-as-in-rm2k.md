---
name: "The Diff photos cropped, and 217's montage as in RM2k"
description: "217's montage as in RM2k: each Diff photo at 50 % over black with a white flash on top; the crop of the photos, the other half of this task, is done"
type: feature
status: todo
---

From taro, on 2026-10-02, looking at the goldens of
`large-pictures-on-bg1-in-mode-1.md` (Aguilucho):

- **The Diff photos** (212, 213, 214, 216) are captures of the map at that
  moment, and the original uses them for a "live to photo" effect that
  works very well. Scaled to 256 wide they no longer match the ROM's
  map and the effect is lost. taro's idea: **crop them** to what
  the ROM shows, algorithmically —two captures of RPG_RT, compare them, and
  look for the difference to be the same in the ROM—. The ROM does not scale the
  map: the crop is the camera's offset (RM2k centers on 320x240,
  the ROM on 256x224) and the map's edge.
- **217's montage**: the two goldens `big-picture-montage-photos-3` and
  `-9` show different scenes on one side and the other, because the
  original's frame is from another moment of the cycle. And neither of the two options that
  Aguilucho left is what RM2k does: the original puts each photo at 50 % over
  black with a white flash on top. Since
  2026-10-02 ("Colour math for translucent events", in the book's
  `optimizations/tried-and-left-out.md`) color math is used
  for pictures: the photo at 50 % over black is the darkened photo, and the
  flash can be done by adding a fixed color (`COLDATA`). Aguilucho's strip
  `tira-destellos.png` is only those flashes, without photo: that is why
  they are gray rectangles.

If the mode 7 pilot (`mode-7-pilot-for-the-zoom-of-the-diff-photos.md`) turns out well, the zoom
of the photos comes back, and this goes together with it.

## Checked on 2026-10-16 (Carpintero)

**The crop is done**: [`cropping-a-picture-instead-of-scaling-it`](cropping-a-picture-instead-of-scaling-it.md)
(`[graphics] cropped_pictures`, the four Diff photos and the montage's,
verified against the ROM's camera). The mode 7 pilot is done too, and the
zoom with it ([`picture-zoom-in-mode-7`](picture-zoom-in-mode-7.md)). What
is left of this task is **217's montage**: on the-advocate `759aa0ba` it is
still five frames of photo and three of black, without the white, as the
book's `divergences/what-large-pictures-do-not-model.md` says.
