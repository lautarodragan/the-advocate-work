---
name: "The other transitions"
description: "RM2k's screen transitions the console does not do yet —border to center, blinds, stripes, scrolls, divisions, random blocks, wave, zoom—, what each would take, and which games ask for them"
type: feature
status: wishlist
---

# What

RM2k has twenty-one transitions to erase the screen and twenty-one to show
it (the `fades` table of `Game_System::GetTransition` in easyrpg), asked for
by the database, by `ChangeScreenTransitions` for teleports, and by
`EraseScreen` and `ShowScreen`.

# What is already done

Rewritten on 2026-10-12 by Hornero: the earlier text was from before any of
this existed.

* **The fade** (0), the default.
* **The mosaic** (17), with the PPU's MOSAIC register, darkening at the
  same time, and the sprites not pixelated.
* **The cut** (19) and **none** (20), both ways.
* **The zoom** (16) goes as the fade.
* All of it for teleports, battle, `EraseScreen` and `ShowScreen`. What
  differs from RM2k is in the book,
  `divergences/the-teleport-transitions.md`.

Everything else compiles to the fade.

# Who asks for the rest

Counted on 2026-10-12 over each game's `data/`: the database's defaults
(`system.json`) and every `ChangeScreenTransitions`, `EraseScreen` and
`ShowScreen`. The numbers are RM2k's indices.

* **The database is what weighs.** Book of Three, The Frozen World, El
  Dorado and Dooms 2 have border to center (7) to erase and center to
  border (8) to show for **every teleport**. Today all four go as the fade.
* **All eight games** start each battle with the zoom (16), and come back
  to the map with the zoom (16). Sunset, Dooms 2, Desert Nightmare and El
  Dorado show the battle with horizontal division (14); the rest with the
  mosaic. The zoom is
  [`the-zoom-baked-at-run-time`](the-zoom-baked-at-run-time.md).
* **Commands**:
  * Dooms 2 asks for 7 to erase 21 times and 8 to show 20 times (the same
    as its default, after changing it); scroll up (9) once; vertical
    combine (13) once.
  * A Blurred Line asks for 7 twice, on maps that are not carried yet.
  * Vampires Dawn asks for the mosaic, already done.

# What each would take on the console

The map is in mode 3, with BG1 and BG2 taken by its layers and no third
layer. The console's tools for "black here, image there" are the **window**
with color math's clip to black —two windows, one pair of edges each per
line, changeable per line by HDMA, and it covers sprites too— and **HDMA
on the brightness** (INIDISP), one value per line. Sizes are easyrpg's.

* **Border to center and center to border** (7, 8): a rectangle that
  shrinks or grows. The window, with HDMA for the top and bottom edges.
  Exact, and the cheapest. It is what Dooms 2 asks for.
* **Blinds** (4): 8-pixel horizontal bands that close line by line.
  Brightness per line by HDMA. Exact.
* **"Vertical" stripes** (5): despite the name, easyrpg draws 3-pixel
  horizontal strips coming from the top and the bottom. The same HDMA.
  Exact.
* **Horizontal stripes** (6): vertical columns. Two windows per line do not
  make dozens of columns: black tiles written into the tilemap column by
  column, at 8 pixels where RM2k has fewer. Approximate.
* **Scrolls** (9–12): the screen slides away and black comes in. BG scroll
  plus the sprites moved by as much, and the window over what is uncovered.
  Showing is the same with the new map coming in. Feasible; the map
  wrapping around has to be hidden.
* **Horizontal division** (14): the top half goes up and the bottom one
  down. HDMA on the vertical scroll, a different value above and below the
  middle, and the window over the gap. Feasible.
* **Vertical division and cross division** (13, 15): the left half and the
  right half move apart. One scroll value per line cannot move half a line
  one way and the other half the other way. The window can open the black
  gap in the middle, but the halves would not move. Approximate.
* **Random blocks** (1–3): 4x4 blocks that go black in random order, top to
  bottom or bottom to top: 3,584 on the screen. Nothing covers that exactly
  in mode 3. Black 8x8 tiles in the tilemap of both layers, a few per frame,
  with the sprites hidden. Approximate: 896 blocks, four times RM2k's size.
* **Wave** (18): each line shifted sideways. HDMA on the horizontal scroll,
  the same as the waves of the pictures. Exact for the backgrounds; sprites
  do not wave.
* **Zoom** (16): bringing the map closer is mode 7, and the map is not in
  mode 7. Remains the fade.
* **Erasing with none, blending two frames**: the console has nothing to
  blend two frames with. Remains the cut.

The HDMA channels and the lines they cost have to be counted against what
the message window and the windows' background already use.

# Order, if it is done

1. Border to center and center to border: every teleport of four games,
   and 41 of Dooms 2's 43 commands.
2. Horizontal division, which four games show every battle with.
3. Blinds and the two strip ones, which are the same HDMA.
4. The rest when a game asks for it.
