---
name: "A font for high resolution, or a narrower one"
description: "Font candidates that read well on a CRT TV and fit in 256 or 512 wide, similar to RM2k's but with legibility before fidelity, for taro to test on the SNES and touch up by hand"
type: research
status: done
assignee: taro
---

From taro, on 2026-09-30, after testing on the SNES the ROM from
`test-rom-the-menu-in-mode-5-on-the-snes.md` (Carancho): "none of them
convinces me. With the text stretched, it looks weird on the CRT TV. In some
cases it gets hard to read". But he doesn't rule out mode 5, because **the
battle also has a lot of UI problems because of the resolution**, and there
it could help. What he proposes to try: "a font designed to work well at
that resolution, that looks as much as possible like the original, but that
sacrifices fidelity before legibility". And he is willing to touch it up by
hand, pixel by pixel.

## What was built (Espinillo, 2026-09-30)

Three candidates, each as **a glyph sheet to edit by hand** in
`rom/experimentos/fuentes/hojas/`, and **`just fuentes`**, which reads the
sheets, builds with them the mockups of the pause menu and of the battle
windows, builds the test ROM with those and verifies it on snes9x, bsnes and
mesen-s, screen by screen against its mockup. How a sheet is edited, in
`rom/experimentos/fuentes/LEEME.md`; after editing it, running the recipe
again is enough.

The ROM is the sibling of `menu-modo-5`, with the same code: `build.py` and
`verify.py` from there learned to receive other screens —the mode comes
from the width, the faces from a `.json` alongside— and to set up as many
banks as needed. `just menu-modo-5` still comes out byte for byte identical
(sha256 before and after: `1b85307e…`).

The candidates, derived from the Mincho with mechanical rules (a starting
point, not a design):

1. **`baja-ancho-variable`**: the usual resolution. Each glyph cropped to its
   ink plus one pixel of air, and of two equal inner columns one remains
   —the "o", the "n", the "H" go from 5 to 4—: what FF6 or Chrono Trigger
   do. Digits and slash by hand, 4 of ink, all with an advance of 5. **It
   doesn't have the TV problem.**
2. **`alta-ancho-fijo`**: high resolution, fixed advance of 10 (5 in low).
   Each column of the Mincho with a vertical stroke of 2 or more rows
   measures 2 pixels in high, the rest 1, and equal consecutive ones are
   merged; between two strokes the gap measures 2. Those with three strokes
   (m, w, M, W) are narrowed to 8 with gaps of 1.
3. **`alta-ancho-variable`**: the same rule, without narrowing, with 2 of air.

The stroke rule was also tried with "3 or more rows": it saves 4% more but
leaves the 2-row diagonals (the "v", the "w") 1 pixel wide, which is what
blurs. The 2 one stayed.

### How much width each one gains

The **average advance**, weighted by the letters of the game's names,
titles, techniques, items, states and enemies, in low-res pixels: today's
6; `baja-ancho-variable` 4.7 (78%); `alta-ancho-fijo` 5 (83%);
`alta-ancho-variable` 3.64 (61%).

But what matters is whether RM2k's **layout** fits, and that is measured by
`mockups.py` packing it: each block of text starts where the previous one
ends plus a fixed gap. With today's font the packed menu measures exactly
320, so the gaps are RM2k's. `just fuentes` prints it
(`build/fuentes/maquetas/medidas.txt`); on 2026-09-30, with the sheets as
they came out:

| candidate | menu, like RM2k | menu, tight | battle, party | battle, worst case |
|-----------|-----------------|----------------|--------------|------------------|
| baja-ancho-variable (256) | 277: 21 short | 255: **fits** | 228: fits | 268: 12 short |
| alta-ancho-fijo (512)     | 566: 54 short | 522: 10 short  | 458: fits | 538: 26 short |
| alta-ancho-variable (512) | 510: **fits** | 466 | 409: fits | 486: fits |

"Worst case" is with the longest texts in the game —"Gang Member" as name,
"Agency Guard" as title, "Brambles" as state, "Components" as
technique—; "party", with Kersh, Core and Manta. In the menu the two cases
hardly differ, because what rules is the Ex line: "Ex" and two 6-digit
fields, 76 pixels in low. **"Tight" is three concessions**: 4 of air on
each side of the face instead of 8, the command window without the cursor's
slack, and the experience in 5-digit fields (an ABL actor goes past 99,999
near level 40).

**So, spelled out: the variable-width one in low resolution doesn't fit
with the 320 layout as it is —it is 21 pixels short—, but with those three
concessions it does fit, with the game's worst case, and has 1 to spare.**
It is the one without the TV problem. The battle fits with today's party
(28 to spare) and not with the worst case: an 11-letter name, an 8-letter
state and "Components" in the commands go over by 12.

`alta-ancho-fijo` has nothing in its favour other than legibility: in the
ROM it costs the same as the variable-width one (see below) and it doesn't
fit in the menu. It is only worth it if on the TV it reads clearly better
than the variable one.

### What there is to look at

* `/shared/captures/2026-09-30-fuentes/`: the side-by-side comparisons
  (RM2k, today's ROM and the three, at the same physical size), the ×4 crops
  of Kersh's row, the sheets with the letter on top, the sheets to edit,
  the loose mockups and `medidas.txt`. With a `LEEME.txt`.
* `/shared/experiments/2026-09-30-fuentes/`: the ROM, `fuentes.sfc`, with a
  `LEEME.txt` of what to look at on the TV.

### What it would cost in the ROM (estimated, not implemented)

**The ROM already has a text compositor** (`compose_char` in
`messages.s`): the message window doesn't use one letter per cell, it
composes 6-wide glyphs into a buffer of 4-bit tiles and uploads it by DMA.
What it doesn't know is variable width: it computes x as `8 + 6 × column`,
which modulo 8 only lands on 0, 2, 4 or 6, and that is why it carries the
font **pre-shifted in those four phases** with the colour and the shadow
already applied: 95 glyphs × 156 bytes × 4 = 59 KB (`font_prerender` in
`screens/src/message_window.rs`).

* **`baja-ancho-variable`, in low.** It is the compositor already there with
  three changes: an advance table (95 bytes), x accumulated instead of
  multiplied, and **the eight phases** instead of four. With the
  pre-shifted tables that doubles the font, +59 KB per colour, and the menu
  uses three (white, red and grey): not worth it. The cheap thing is a 1-bit
  font (95 × 12 bytes, 1.1 KB) and shifting it while composing, which with
  the screen off —the menu opens that way— isn't noticeable. The expensive
  thing is moving the menu and the battle from "one letter per cell"
  (`layout.rs`, `slot_glyph_cells`) to composed text. Measured on the
  mockup, the menu text touches 299 8x8 tiles (279 distinct, ~9 KB); with
  the three faces, 108 more, that is about 400, and today's menu area
  (`SLOT_VRAM`..`SLOT_MAP` in `vram.py`) reaches 448: it fits, just. The
  battle touches 158 (~5 KB), and when the HP change a row is recomposed,
  ~30 tiles in vblank.
  **A few hundred bytes of code and two or three days**, almost all of it
  moving the screens to composed text.
* **As a bonus, in the messages**: today 39 characters of 6 fit per line;
  with an average advance of 4.7, about 49, which is what fits in RM2k's
  window. There would be many fewer boxes split by the distribution
  (`refit`). There the compositor runs with the map going and with a cap of
  5 letters per frame (`MSG_CHARS`), measured with the pre-shifted tables:
  with the 1-bit font it would have to be measured again, or pay the 59 KB
  of the eight phases only for the window's colour.
* **The high-res ones**, what Ñacurutú estimated for mode 5 in
  `mock-up-the-menu-in-high-resolution.md`: the mode change and the faces as
  sprites are cheap; the text asks for the same compositor, in high, and
  about 25 KB of VRAM. Measured on these mockups, the menu text touches 486
  tiles with the variable one and 531 with the fixed one (12 KB distinct,
  both), and the battle one, 246 and 280. **The fixed advance of 10 doesn't
  save the compositor**: 10 doesn't divide 16, so the glyphs don't land
  aligned with mode 5's 16x8 cells either. The two high-res ones cost the
  same, and it is more than the low one: the low-res compositor already
  exists and the high-res one has to be written, plus mode 5 on each screen
  that uses it.

### Missing

That taro looks at them on the TV with the ROM, and touches up the sheets.
What asks for the most hand work is in the high-res ones: the "s", the
"c", the "a" and the diagonals have loose high-res pixels. With an edited
sheet, `just fuentes` builds everything again.

On merging there is nothing to install: it doesn't touch Rust or add
scripts to the PATH.

# What taro chose

On 2026-10-03: he likes the two variable-width ones, the low one and the
high one, and wants to try them in the game. First the low one in the whole
game —`variable-width-letters-in-low-resolution.md`, in the tools repo—, and
then mode 5 as a project knob, to compare two builds without reverting
anything.
