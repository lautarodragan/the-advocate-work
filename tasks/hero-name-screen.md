---
name: "The hero name screen"
description: "EnterHeroName (10740) doesn't exist in the engine: only Dooms 2 uses it, once. Design discussed with taro: the cursor in objects, the BG1 background only from the System, the face outside BG1 and the gradient through HDMA"
type: feature
status: wishlist
agents: [Hornero]
---

taro, on 2026-10-11: to the wishlist, it doesn't block any game as a whole.
Of the eight, only Dooms 2 uses it, once.

## What it's like in RM2k

Three windows over black (EasyRPG's `scene_name.cpp`): the actor's
face (64x64, from their FaceSet), the name (192x32) beside it, and the keyboard
(256x160) below. At 256x224 it doesn't fit as is: the keyboard already takes the
full width, and in height they add up to 232 with the margins. The cursor is the
System's, stretched to the cell, and it blinks.

## What was discussed

* **The cursor in the object layer.** Today's screens bake the
  cursor onto the background: for each position they store the rectangle of cells
  that changes, and copy it to the tilemap (`target_bar` in `actor_choice.s`,
  `borders.rs` in screens). With ~90 keys that doesn't scale; with sprites it
  moves without touching BG1. The System's pixels are opaque or transparent,
  so the cursor as a sprite looks the same.
* **BG1 only with the System** (taro's idea): an RM2k image is 256
  indexed colors, and so is the System. Without the face, everything on
  screen —background, frame, cursor, font colors— comes from its palette,
  so it fits whole at 8bpp without losing anything. The face would go in objects or
  in BG2. Careful: there is only one CGRAM. BG2's palettes are entries
  0–127 and the objects' are 128–255, the same ones BG1 uses at 8bpp: what
  is saved is mixing the face with the System, not color
  memory.
* **The gradient through HDMA.** What ran over in tiles in the windows
  (`window-in-the-tile-bank`) wasn't colors but cells: a
  stretched gradient is a different cell in each row. If the background of
  each window uses a single CGRAM entry and an HDMA channel
  rewrites it on each line, the background becomes a single repeated cell.
  Windows that share rows —the face and the name— have different
  gradients: one entry and one channel per window. It only works for a
  vertically stretched background, not for one with texture or tiled.
  It would also work for the other screens, not just this one.

## Where it goes now

Since 2026-10-12 this screen is step 6 of `cheaper-windows.md`: the first
window drawn by the runtime, on a screen that doesn't exist yet so nothing
that works is touched. The setting, the gradient and the cursor in sprites
come before it there.

