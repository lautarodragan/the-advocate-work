---
name: "The most efficient windows"
description: "Analyze every window —messages, menus, items, equipment, shop, battle, slots, actor choice, hero name— with a System background configured by knob (gradient or solid color via HDMA/hblank), faces out of BG1 and the cursor in objects; measure and propose"
type: research
status: testing
agents: [Tijereta]
assignee: taro
---

taro, on 2026-10-11, after talking about the name screen
(`la-pantalla-del-nombre-del-heroe.md`): that it be analyzed for
all the windows, not only that one. "If we can make the windows, in
general, more efficient, it's a win all around."

What taro said, to keep in mind:

* **The face does not have to be pixel perfect**: it can be shrunk a bit if
  needed to round to 8 px or to save a row or column of tiles.
* **There is no need to detect whether the background is a gradient**: a knob in
  `rm2k-snes.toml` that replaces the System's background with one of our own,
  configurable —a gradient, or a solid color—. With the knob, from a
  System only the numbers, the icons and the borders are taken; the background is
  ignored.
* **The message window in the game**: if it has a background, it takes up a whole
  strip of the screen, so the mode and/or the palettes could be changed
  in the hblank of its first line and its last, if the cycles allow.
* **For ABL**, another option of the knob: solid color. Even if it changes
  nothing of what is seen, having it declared allows assuming things and
  optimizing in the runtime. His question: is a single palette of 16
  colors enough for background, frame and text in all its windows?
* **Each game's analysis is done once** —statically, or with AI—, not
  in a tool: the tools only read the project's knob and
  take the corresponding runtime path.
* **Different code per game** ("macros"): he does not rule it out, but knows it
  adds bug surface and perhaps does not contribute. Today there is already something like it: the
  runtime under `.ifdef paint_table` and `.ifdef MSU_REQUIRED`.

## The assignment (Hornero, 2026-10-11)

A research in the book, not the implementation: the six ideas —the background
knob, the message window strip, the cursor in objects, the
faces out of BG1, ABL's 16-color palette and per-game code—, each
one measured on the eight games, with the proposed knob, each game's
value and an implementation order in small steps. Base:
the-advocate `fc6f7456`, ports `a85b7e3`.

## How it is measured (Tijereta)

The eight games are built in a worktree of the ports with a wrapper around
`rm2k-snes-screens` that saves each request; then
`screens convert` is run again on those requests with retouched Systems —the
solid background, the transparent cursor— and blank faces, and the
tiles are counted. What changes is what the idea saves. The Systems are read from
the `.zip`s; the retouched copies go to `~/scratch/tijereta/`.

## What was done (Tijereta, 2026-10-11)

The research is in the book, branch `tijereta-ventanas`:
`src/research/2026-10-11-las-ventanas.md`, "The windows, made cheaper".
No code of the tools or of the ports was touched. The main points:

- **The knob** (`[windows] background`, a color or a list of stops
  of a vertical gradient) is what pays off most: with a single-entry
  background, Book of Three, Frozen World and Vampires Dawn with its VDBlutsys
  stop merging all their screens, and Frozen World's message window
  goes from 15 colors to 7. A gradient costs one entry and one HDMA
  channel per group of windows that share lines.
- **The strip**: the prototype wrote 8 colors per line with 8 channels
  without one bad line in snes9x, bsnes and Mesen-S; the limit is the channels
  (on the map 5 and 7 are always free). It does not gain VRAM, and the palette
  change is blocked by the windows without background. It serves the gradient and
  the palette of a face in the message window. Not IRQ: that belongs to
  `irq_music`.
- **The cursor in objects** saves Dooms 2's actor choice (69 → 27
  tiles out of 64); in the message window the object mask blocks it.
- **The faces**: what they take in the menu bank, from 0 (Sunset) to 216
  (Vampires Dawn) out of 448. In the message window they are not drawn, and DN,
  Dooms 2 and VD request them 1848, 722 and 8195 times: they fit in the cells of the
  text area that the face leaves free.
- **ABL in one palette**: the message window yes (13, 12 with a plain
  background); all the windows with the four inks, no (33).
- **Per-game code**: data, not `.ifdef`; the risk is the path that
  no test runs.

Captures in `/shared/capturas/2026-10-11-las-ventanas/`. The
measuring scripts stayed in `~/scratch/tijereta/ventanas/py/` and the prototype in
`~/scratch/tijereta/hdma/`: throwaway.

## What was left unmeasured

Real hardware (the FX Pak), how long `irq_music` takes, the battle's window
groups, Dooms 2's 38-color cursor in an object palette,
and where the face tiles would go in objects.

## When merging

Nothing to install. Only the book.

Finding not fixed: `el-texto-de-objetos-de-abl-no-entra.md`.
