---
name: "The window in the tile bank"
description: "A System with a stretched gradient background asks for one tile per shade: the message window goes over 256 tiles and the actor choice over its VRAM range"
type: feature
status: done
agents: [Tijereta]
assignee: taro
---

**Done**, 2026-10-12. Superseded: it asked taro to judge the fused windows, and the windows' background by System (`windows-background-setting-and-flat-text-area.md`) undid almost all the fusing.

What was left behind `window-with-more-than-15-colors` (Tijereta, 2026-10-05).
With the original System and the colors already reduced by Adeleine, the message
window of The Frozen World asks for 266 tiles of 256 and that of The Book of
Three 267; Dooms 2's actor choice goes over `$4800`.

Merging more colors until they fit (`adeleine::merge_until` with the tiles
as the condition) was tried and doesn't work: Frozen ends up with 4 colors and Book of
Three with 2. What's needed is on the tiles' side —grouping the
similar ones, like `adeleine::group_tiles` with the panoramas, or a repeated
background instead of a stretched one—, and it's a judgment call: taro has to see it.

## The assignment (Hornero, 2026-10-11)

taro, on 2026-10-11, chose it as the next thing for the other games:
it holds back four —Book of Three (267 of 256), Frozen World (266), Vampires
Dawn (262, map 15: "this map can't carry a message window") and Dooms 2
(the actor choice goes over `$4800`; with map 1, the slots and the
menu add up to 482–524 tiles of 448)—. The judgment calls are decided by whoever
does it, with before and after captures in `/shared/captures/` for taro
to look at; if it looks fine, it is fine. It must be generic: nothing per game, and
ABL —which already fits— doesn't move (`abl.sfc` byte for byte the same, if
possible; if not, goldens shown).

## What was done (Tijereta, 2026-10-11)

Branches `tijereta-ventana-tiles` in the-advocate, in the ports and in the book.
The decision, with the two paths that were measured and where each one breaks:
"A window with a gradient is fused until it fits" in the book.

- **Message window**: the text area already has one tile per cell; what
  went over was the frame and the arrow (26–28 of 16). **The background
  seen through the frame** is fused (`group_cells`) and the frame goes on top as
  is: the ornaments stay, the text area's gradient stays as in RM2k.
- **The 8bpp screens** (actor choice with the menu bar,
  items and equipment, shop, battle): `fit.rs` cuts their cells like
  `borders` and, if they don't fit, Adeleine (`merge_least_visible_tiles`, new)
  fuses one at a time the least visible one. It travels in the `Skin`, so `convert` and
  `render` draw the same.
- **End Game**: it wasn't tiles but colors (pairs that didn't fit in a
  palette, also Desert Nightmare): `merge_until` with black fixed.
- **Items and equipment leave room for their text**: `item_pairs` measures the most
  loaded list and the windows are also fused if they fit in the bank but
  leave the text without pairs. Book of Three's ROM found it: with the
  windows fused up to the limit, on returning to the menu "L 23" and
  "999" came out. And it was older: Frozen World left 82 pairs of the 132.

Discarded, measured: the repeated background (the frame was still at 14–16 cells
plus the arrow, and the gradient turns into a sawtooth) and fusing whole windows
by k-means (with Royal the frame and the bar alone are 85 of 64; it ate
corners). Merging colors had been discarded on 2026-10-05.

The five games go back to their System, except Vampires Dawn: its screens
fit, but the ROM goes over by one 64 KB piece, so it keeps ABL's
with the comment of why. VD's maps 15 and 150 aren't about the
window: it's the map that doesn't leave room for the window's fixed 8 KB.

## What's left

- **Dooms 2, map 1**: with its System the slots and the menu add up to 482 of
  448, and they're faces, not windows. Separate task.
- **Vampires Dawn with VDBlutsys**: the ROM, not the window.
- Nobody played the fused screens: there are captures from the ROM of the window
  in-game (BoT, Frozen, Dooms 2) and of the menu and the items screen (BoT,
  Dooms 2); the actor choice, the equipment and the shop only through `render`.
- ABL's suite doesn't execute any of these paths: ABL goes in and out byte
  for byte the same. The test that does execute them is `system_gradient.rs`, in
  `screens`, without a ROM.

## On merging

Reinstall `adeleine`, `rm2k-render` and `screens` (lib in the first two:
`screens` is the binary that changes). Captures in
`/shared/captures/2026-10-11-la-ventana-en-el-banco-de-tiles/`.
