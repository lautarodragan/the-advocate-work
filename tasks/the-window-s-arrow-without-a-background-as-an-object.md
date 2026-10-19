---
name: "The backgroundless window's arrow as an object"
description: "A window without a background still takes the map's upper layer on its bottom frame row, eight lines across the screen, only to draw the arrow of a message waiting for a key; drawn as an object, that row could be given back too"
type: optimization
status: testing
assignee: taro
agents: [Chajá]
---

taro, on 2026-10-18, looking at the captures of
`a-window-without-background-hides-the-upper-layer-only-on-its-text-lines`
(`/shared/captures/2026-10-18-window-upper-layer/`): an improvement, but
the trees under the window, in Core and Manta's memory, still miss a row of
tiles. "Can't we get that one back too?"

What that row is: the window's bottom frame row, eight lines, which the
window keeps in BG2 when the page can show the arrow of a message waiting
for a key (`WINDOW_BAND_ARROW` in `runtime/message_place.s`). The trees'
tops fall on it. If the arrow were an object —it is a few tiles wide, and
the characters do not cover it in RM2k, where it goes over everything—,
that band would not need BG2 and could give the map back as well.

Done means: on a window without a background, the bottom row's lines show
the map's upper layer, with the arrow still blinking where RM2k puts it,
over the characters; measured in a ROM test, and Core and Manta's trees
whole under the window's empty lines.

## Log

### 2026-10-18, Chajá

Started from the-advocate `b066b885`, the ports `74068b8`, the book
`239069e`; branches `chaja-window-arrow` in the three.

**Design.** The arrow as two 8x8 objects —OBSEL's small size—, at OAM
right after the timer's digits: `Priority_Timer` is 140 and
`Priority_Window` 130, and everything else in OAM goes below the window.
Priority 3, in front of both layers and of the characters; the lower OAM
index wins an overlap between objects, so it covers them too. It needs,
per map:

* **two tiles of the sprite bank that nobody uses**: the first two past
  the bank, if the layout's sprite cap has them. Everything the console
  writes into the bank —slots, the cache, the animation's box, the
  pictures' 8x8 objects— is inside the bank's length (`grow_blocks`,
  `grow`), so past it is free;
* **a whole sprite palette nobody uses**: the characters' are the first
  ones, the battle animation's box the next, the pictures' from the top.
  The arrow's is the top one the pictures leave, with the window's colours
  copied into it, so its tiles are the window's own and no colour is
  lost or merged, and the tint does not reach it (`apply_tint` and
  `upload_palettes` touch only the map's count) —RM2k does not tint the
  window either—.

The record is full (60 bytes of fields and 17 pointers, its 128), so
`rm2k-snes-mapdata` gives each map a word in a table apart, as
`pose_masks_maps`: the tile and the palette, or 0 for a map with no room,
where the arrow stays in the window's cells and keeps its band. The
tiles and the palette are uploaded when the window appears, in
`msg_hdma_build`: that covers a map's load, a System change, coming back
from a menu or a battle, and a big picture going away, which all build
the HDMA again. A big picture up keeps the cells: it overwrites the sprite
bank.

**Limits looked at before writing it**: the PPU keeps the first 32
objects in range on a line, in OAM order, so an early index is never the
one dropped; but on time over —more than 34 tiles on the line— it fetches
tiles from the 32nd object back to the first and drops what is left, so
the arrow, early, is the first to go (bsnes' `Object::run`, which walks
`reverse(range(32))`). Each character crossing the arrow's eight lines is
four tiles: up to eight with the arrow fit, nine already overflowed
without it.

**Done** (the-advocate, `message_arrow.s`, `message_place.s`, `oam.s`,
`window_system.s`; rm2k-snes-mapdata): `arrow_objs`, a word per map
—`arrow_obj` in `record.rs`—, and `window_arrow_obj`, the arrow's two
tiles per System as a ninth piece of `window_systems`. `msg_hdma_build`
asks `arrow_obj_choose`, which leaves the word in `MSG_ARROW_OBJ` and
uploads the tiles and the colours; `msg_bands` leaves the bottom row out
when it is set; `msg_arrow` keeps counting and writes no cells; and
`build_oam`, after the timer and with a window up, calls `arrow_oam`. A
`ChangeSystemGraphics` with the window up uploads the new System's arrow
too. Outside a message it costs `build_oam` an `lda`/`beq`.

**Measured**:

* The object lands on the same pixels as the cells —the bare goldens with
  the arrow up, `arrow-up-no-background` and Royal's
  `system-arrow-no-background`, did not move—. First try was one line
  high (an OAM Y one less), fixed to the window's own line.
* Read off `MSG_ARROW_UP` the objects went up and down a frame after the
  cells, on every edge: OAM is built in the frame and uploaded in the next
  vblank, where the count moves. `arrow_oam` reads the count one ahead,
  and now it is the cells' frame by frame but the first —measured frame by
  frame over 90 frames on the test case, both ROMs—.
* Which maps have no room: the converter's log says it per map ("the
  message arrow stays in the window's cells"). In ABL almost all for the
  palettes; map 6, the city of the memory, for the tiles. Draft:
  [`the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes`](the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes.md).
* A window with its background keeps the cells: it takes BG2 on its 80
  lines anyway, and its mask hides the objects there; nothing to gain.

**The test**: `test_the_layer_above_shows_off_the_text` looks at the
bottom row for 48 frames: beside the arrow's 16 columns the screen with
the window closed, and the arrow's columns different some frames and not
others. At (31,24) the row has nothing of the layer above in the 192
columns looked at, so it passed with the cells too; the case went to
(31,23), where a capture with the global tools (cells) lost a treetop on
the row's eight lines, columns 155 to 182, and with the objects it is
whole.

Captures: `/shared/captures/2026-10-18-window-arrow/`, with a README.

**Final run**, on the branches with main merged (the-advocate `90b0eff0`,
the ports `3905da8`, the book `cfa7f99`): ABL's suite 1577 passed and 2
skipped —with `battle` installed from the merge: the global one predated
Tijereta's attribute shifts, and `test_heat_barrier_halves_the_flame…`
was red against it, green with it—; `just boot` 67 passed; `just
test-game` 45 passed, 1 skipped (before the last merge); `just test` 29
passed; `just crate-test mapdata` and `convert` green. `abl.sfc` sha256
`70a0d496a8cb24d663e3d2457c324ee8bb9038020aef7cf7adcf0ab7102131cc`.
`just space`: the tightest bank 0 has 134 bytes left, bank 1 93.

**What the suite does not cover**: a big picture shown or erased with a
bare window up (the code keeps the cells while it is up), a
`ChangeSystemGraphics` with a bare window up, a map with no room (its
cells and band are the old path, which no bare golden over the layer
above looks at), the time over with nine characters on the arrow's lines,
and a character under the arrow —the arrow's OAM index and priority are
what put it in front, not something a test looks at—.

Branches `chaja-window-arrow`: the-advocate (the arrow as objects; its
frames; merges), the ports (the test and the case), the book (the
divergence, vram.md, cgram.md). **To install when merging: `mapdata` and
`convert`** (`convert` compiles mapdata in); the runtime goes from
`~/the-advocate`.
