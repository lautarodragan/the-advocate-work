---
name: "A window without a background hides the upper layer only on its text lines"
description: "The backgroundless message window takes BG2 on all 80 of its lines; give the map's upper layer back on the lines with no text"
type: feature
status: done
assignee: taro
agents: [Chajá]
---

taro, on 2026-10-18: a message window without a background takes BG2
—the map's upper layer: roofs, treetops— on all 80 lines of the window,
because HDMA points BG2 at the window's tilemap there (see the divergence
"The window without a background does not cover the characters" in the
book, and `message_place.s` in the-advocate). Proposal, agreed with taro:
on the lines where no text is drawn, BG2 keeps showing the map.

**Done** is the window's HDMA stretches built from the text lines the box
uses, at the granularity of a line of text (with its shadow), so a
one-line message takes about 16 lines instead of 80. Left out on purpose:
the cells left and right of the text on the same line —one tilemap and
one scroll per scanline for BG2; the PPU's windows would show the lower
layer, not the upper one—; that goes written as the measured limit in the
divergence.

**Case to look at** (taro): A Blurred Line, Core and Manta's memory; in its
second part, their talk removes parts of the trees.

## Log

### 2026-10-18, Chajá

Started from the-advocate `9033e6dd`, the ports `ffc3a5b`, the book
`021de46`; branches `chaja-window-upper-layer` in the three.

**Design.** Which lines carry text is decided **by the runtime, as each
line starts**, not by the event compiler: the composer builds the whole
page off screen and the window only appears when it is done —`msg_state`
2, and `msg_hdma_build` in that same vblank—, so when the HDMA is built
the composer has already read every line's length. That costs no byte per
box in ROM and no header bit (the header is full: lines, auto-close,
pauses), and it is right with `\N` and `\V` for free, which only grow a
line that already has a length. A wait in the middle cuts the box and the
window appears with the lines up to the cut: those are the ones counted,
and the ones after it join when they are composed.

The window is six stretches of its own height: the frame's top row (8
lines), the four text lines (16 each: the two cell rows the composer
writes per line, where the glyph sits at 2 and its shadow ends at 15) and
the bottom row (8), where the arrow is. With the frame, all six. Without
it: a text line if its length is not zero; on a choice every option line
(the bar is drawn on empty ones too, and the window must not jump as it
moves); with a face, the four (the face covers lines 16 to 63 of the
window); and the bottom row unless the page cannot show the arrow
(a choice, the digits, `\^`) —RM2k draws the arrow with opacity 0 too,
`Window::Draw`—.

**Done in the runtime** (`message_place.s`): `msg_line_rows`, called by
the composer at every line start, keeps `MSG_ROWS`; `msg_hdma_build`
walks the six bands and emits the stretches —at most six entries, one of
them a 127-line split—; `msg_swap_build` trades every window stretch, not
one. Channel 2 went **indirect**: each entry points at the camera's four
bytes or the window's, so `flush_video` writes the camera once and not
per stretch. Bank 0: a `jsl`; BSS: 17 bytes more for the tables.

**The scene** (taro's): map 5, the island, which is the memory's second
part (map 6 is the city, after it). The `manta` case with the presses of
`test_memory.py` reaches it; a message of two lines gave back three
treetops; one of four lines changes nothing, as expected —every line has
text, and the trees beside it are the measured limit—.

**The test**: `window-middle-one-line`, map 5 (31,24), a bare middle
window with "CORE"; `test_the_layer_above_shows_off_the_text` compares the
window's bands without text against the screen after A closes it, on the
left 192 columns (the water on the right animates). Red on 9033e6dd —24
lines, 96 to 135—, green with the change. A first try on map 7 passed on
both: that room has nothing in the layer above under the window, so the
bare goldens of map 7 do not move either.

ABL's suite on the first version: 1566 passed, no golden moved —the bare
windows of the goldens have nothing in the layer above under their empty
lines—. `just boot` did not build Sunset over Imdahl: FAR2, bank $C0, 110
bytes over on a painted map's cartridge. The window's HDMA build, its
bands and the trade over a painting moved to FAR3 (bank $C1), all reached
with `jsl`. `just boot` with `-n 8` steps on itself —two workers building
the same game—: it is run serially (draft:
`the-other-games-tests-do-not-run-in-parallel.md`).

**Final run**, on the branches with `main` merged (it had not moved): ABL's
suite 1566 passed and 2 skipped; `just boot` 67 passed —Sunset's painted
maps and GateStreet included, which is the BG1/BG2 trade—; `just
test-game` 44 passed, 1 skipped; `just test` 29 passed. `abl.sfc` sha256
`2186b440bbd25446ed4981163967b326d5bb722df5d929100d14c7efa2e51d49`.
Captures, before and after with the difference, in
`/shared/captures/2026-10-18-window-upper-layer/`.

**What the suite does not cover**: a bare window with a face, with a
choice, with an `InputNumber` or cut at a wait over a layer above —the
bands those take are what the code says, not something a test looks
at—; and a bare window whose text lines are not together (an empty line
between two with text), which makes two window stretches: on a painted
map, the trade over each of them is what `msg_swap_build` says, and only
Sunset's goldens and GateStreet's test look at that trade, with whatever
messages they have.

Branches `chaja-window-upper-layer`: the-advocate (two commits: the
bands, and their move to FAR3), the ports (the case and the test), the
book (the divergence, vram.md, the optimizations entry). **To install
when merging: nothing** —only `runtime/` changed, which the global tools
read from `~/the-advocate`—.

**2026-10-19, taro**: played in ABL, Core and Manta's memory, on the island; "perfect". Done.
