---
name: "Draw the faces"
description: "ChangeFaceGraphic is accepted without drawing the face: the message box comes out without it"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Split from `draw-the-faces-and-really-wait-on-the-escapes.md` on
2026-10-12, by taro.

`ChangeFaceGraphic` (10130) is in the event compiler's `ACCEPTED_UNDONE` and
does nothing; the box comes out without a face. A face is 48x48 with its
own palette: it competes for VRAM and for CGRAM with the window and the
map. The research on the windows
([`2026-10-11-the-windows-made-cheaper`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-11-the-windows-made-cheaper.html),
section 4) measured a face's palette written by HDMA on the window's lines.
When doing it, remove it from that list.

taro, on 2026-10-15: "I'm assuming it will be too complicated, but that is
assuming without evidence". Launched on Fable: measure first, then build
the first version that fits.

## Measured (Tijereta, 2026-10-15, ports `f015801`)

A script over the eight dumps —maps and common events, every page—:

```text
                  ChangeFaceGraphic  set   clear  right  flip  ChangeActorFace  faces  FaceSets  boxes
Desert Nightmare   2,062            1,848   214     0     0        0             25      7      2,389
Dooms 2              831              717   114     0     0        1 (1 page)    41      9      1,631
Vampires Dawn     10,623            8,100 2,523     0     0        5 (5 pages)   88     15     17,936
Frozen World           0                0     0     0     0       13 (7 pages)    0      0      3,933
the other four         0                0     0     0     0        0              0      0
```

**No game puts the face on the right or mirrors it**: both are features
of the format without a user among the eight; the test game exercises
them. Where a box's face is known at compile time, walking each page in
order: Desert Nightmare 2,067 boxes after a face is set in the same page,
318 after a clear, 4 before any face command; Dooms 2 1,228 / 225 / 36,
plus 142 in pages with no face command at all; Vampires Dawn 11,281 /
4,790 / 708, plus 1,157 in pages without one. **The face leaks across
pages**: of the pages with a face command, 1,224 of 1,348 (Desert
Nightmare), 129 of 151 (Dooms 2) and 2,160 of 2,686 (Vampires Dawn) end
with a face still set, so a page that shows a box without naming a face
most likely shows the one the last page left.

VRAM and CGRAM: a face needs **nothing of either** with the design below,
in every layout, which is why no per-layout number is written here.

## Design

* **Tiles**: into the window's own text cells. RM2k draws the face at
  (16, 16) of the window, 48x48: that is text cells 1..6 of rows 1..6, and
  the text starts at x 72 of the text area (`LeftMargin + FaceSize +
  RightFaceMargin`, easyrpg's `Window_Message`). The composer copies the
  face's tiles into `text_buf` after priming each line's background, like
  a letter; on the right it takes cells 23..28, with RM2k's 8 px to the
  edge. 36 tiles of 4bpp per face in ROM, 1,152 B, plus 30 B of palette:
  Vampires Dawn's 88 faces are 104 KB.
* **Palette**: BG palette 1 —CGRAM 17..31— **only on the window's lines**,
  written by HDMA channel 5 on the window's first fifteen lines, one
  colour a line, before the face's first line (16), and restored from
  `cgram_shadow` on lines 64..78, after its last. Channel 5 is free on the
  map (the battle's shake uses it, with no window up); 7 is `vram_drain`'s
  general DMA every vblank. One channel, one colour a line, is what
  commercial games do with CGRAM in the hblank; the research's prototype
  wrote up to eight.
* **The tilemap**: the 36 cells' palette bits flip to 1 when the face's
  side changes, in the vblank in which the window appears, both planes.
  Every other box leaves them at 0.
* **The text**: compiled narrower —240 - 72 px— when the page has set a
  face before the box, or when the state is unknown in a game that uses
  faces (the leak above): a line clipped at the edge is worse than one
  extra box. Known cleared: full width.
* **Degrades**: a face whose FaceSet is not in the game nor the RTP is a
  blank face, declared in `degradations.json`; a face in a bare window
  recolours the map's entries 17..31 on its 80 lines; the face's
  transparent pixels take the window's background colour, since a 4bpp
  cell is one palette; the face is not saved; `ChangeActorFace` is
  accepted as a debt and the menu keeps the database's face. In the
  book's divergence, "What faces do not model".

## Done (Tijereta, 2026-10-15)

* the-advocate, branch `tijereta-faces`: `OP_FACE` (0x55; 0x56 unused),
  the compiler's arm and the narrow reflow, `rm2k-snes-screens faces`,
  the emission of `message_face_N` and `message_face_ptr`, and
  `runtime/message_face.s` with its hooks; the test game's case `faces`
  and `test_faces.py`, five goldens in both cores.
* the-advocate-docs, `tijereta-faces`: the divergence, the VRAM and CGRAM
  pages, the three ports' known issues, the test game's page.
* The five boxes next to RPG_RT 2015 under Wine, in
  `/shared/captures/2026-10-15-faces/`: the face where RM2k puts it.
* **What bit**: the three vblank jobs of a box —the old side's cells, the
  new side's, the HDMA table— in one vblank next to the line's 1920-byte
  DMA ran past its end on the meadow, and from the second box on the
  face came out in the text's colours. One per line's vblank now.
* **What bit, second**: with everything in far RAM, A Blurred Line's
  release cartridge did not link —`FARBSS` 171 bytes past its area; it
  had 12 free, the face asked for 183—. Two things: the HDMA table went to
  ROM, in indirect mode, so the RAM is the 120 bytes of colours it points
  at, and the box's small state to bank 0's `BSS`; and the pool grew by
  the strips' and the VRAM map's stretch, `$7E6A00` to `$7E6BFF`, which
  went into the segment as `.res`, 126 bytes to the pool. **The measured
  limit**: the pool was full before the face; the next thing that needs
  far RAM takes over the next stretch —`$7E6C00`, the music decoder's—
  the same way, with `just space` saying what is left.
* To install when merging: `cartridge events screens mapdata convert`
  —`just install cartridge events screens mapdata convert`—, and
  rm2k-render changed as a library (`Picture::mirrored`).
* **Run, on the merged tree** (the-advocate `ec71cf6d` merged in):
  `just rust-test`, `just test` (29), `just test-game` (22 passed, 1
  skipped; the five new goldens identical in bsnes), ABL's `just tests`
  with these tools (1555 passed, 2 skipped; no golden moved: A Blurred
  Line shows no face), `just space` (release: bank 0 739 B, far RAM 15 B,
  BSS 83 B; test-msu: bank 1 801 B, far RAM 207 B), and the ports' `just
  boot` (44 passed, before Zounds came in; Zounds alone after).
