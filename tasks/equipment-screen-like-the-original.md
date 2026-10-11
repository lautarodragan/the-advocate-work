---
name: "The equipment screen like the original"
description: "The System windows and the red cursor bar from the item screen, brought to the equip screen"
type: feature
status: done
assignee: taro
---

From taro, on 2026-09-28: "Now I want to implement the UI improvements
we made in the item menu for the equipment menu".

The item work is in `la-pantalla-de-items-como-el-original.md`
(Jacarandá, `f3b0cc90`): the System windows on BG1 behind BG2's
text, and the red bar as the cursor instead of the ">". Its "Equipar y
habilidades" section already said what was useful: the mechanism, but with its own set of
windows and its own tilemap, and the bar done differently, because this screen
composes the whole text in `texto_buf` every frame.

## What the original does

The captures with RPG_RT and Wine, at 320x240, in
`/shared/capturas/2026-09-28-el-menu/original-equipo*.png`.

- **Four windows**: help at the top across the full width (32 high); on the
  left the actor —the name and below it the four parameters in one
  column, with the value it would become—; on the right the five slots; and
  at the bottom across the full width the list of what can be equipped, in two columns.
- **Red (colour 1)**: the parameter terms, the slot terms, and
  the arrow between the current value and the one it would become (measured in the capture:
  the arrow is red, not white).
- **The red bar** takes up the slot's whole row —term and what's equipped,
  from edge to edge of the window—, and while choosing it stays on the slot
  and another marks the candidate in the list.
- The term and what's equipped go stuck together: "Right HandModified Blaster-R".

## What differed in the ROM

Everything on black, one column, the ">" as cursor, the parameters in two
columns of two —"Attack 280> 95 Defense 147>147" reached the edge of the
screen— and the terms in white. The "up" and "down" colours were already
there (Tero, `el-menu-como-rm2k.md`).

## What was done

- **Three windows on BG1**, one below the other (`pantallas.EQ_VENTANAS`):
  help, same as the item one (48, two lines); the actor one, of 80,
  with the four parameters in one column like RM2k and the name on the
  right; and the bottom one, of 96, with the five slots or —while choosing— the
  list. The text stays on BG2 without knowing anything about them.
- **The three windows start the text in the same column**, column 1: the
  slot terms below the parameter terms, and the names in
  the list below them (`EQ_TEXTO_COL`). taro asked for it on seeing the
  goldens: the first version had the slots in column 2 —it came from making
  the bar's tip coincide with the item one's, not from anything visible— and
  the list in 3, the item one's. The count and the colon of the list
  stay in the item columns; what's equipped in a slot can have
  nineteen letters.
- **The bar**: on the slot, across the width of the row as in the original,
  and on the candidate; with the text in the same column they're the same bar,
  from x=4 to x=244: three pixels of black between it and the frame. Every frame,
  after the 1792 bytes of the text, the ten rows of cells of the
  bottom window without cursor are uploaded and on top the two with the cursor (`eq_barra`):
  768 bytes, without remembering where it was.
- **The terms and the arrow in red**: a fourth variant of the font,
  `ITEM_ROJO`, palette 3. **Whole**: measured, the font in red is **ten
  tiles** more (326 to 336, under the cap of 384 the battle imposes), because
  tiles are deduplicated by index and the red's gradient falls on the same
  indices as the white's. The letters of the terms alone were thirty-five:
  with fewer letters the palette order, which is by frequency, comes out
  different. `pant_glifo` adds one table per variant instead of asking which one.
- **Tiles and colours shared with items** (`titulo.marcos`): the two
  screens don't open at the same time and upload to the same place, so they upload the
  same set and each its own tilemap. The 17 item tiles weren't enough:
  equipment adds seven of its own —the bar's tip in column 0 shares a
  tile with the frame— and the joint set is **24**, which with the font of
  336 end **exactly** at $3800, where the tilemap starts: not a single
  8bpp tile is left. `_controlar_marco_de_items` checks the whole set, so what
  comes later —the shop windows, for example— will have to
  share or find another place. The windows' colours moved down from CGRAM entry 48
  to 64, behind the red palette.
- The parameters with more breathing room: the value in column 9 of the block and the
  arrow in 12, since there's room to spare in the actor window.
- The new code goes in bank 1 (`banco_de_la_pantalla.s`,
  `pantalla_de_equipo.s`).

## What doesn't fit

- **The actor and the slots side by side**: with 8-pixel letters the
  parameters with the new value are fifteen cells and a slot with what's equipped
  twenty-nine; the screen has thirty-two. They go one below the other.
- **The slots and the list at the same time**: below the actor window there are
  six 16-pixel rows left and the slots use five. The list still
  **replaces** the slots while choosing, as it already did.
- **The list in two columns**: same as in items, two twenty-letter names
  don't fit in 256. One column, and now of **five** rows and not
  eight: it's what the bottom window allows. It scrolls as before when the
  cursor goes past.
- **The one-line help**: it goes with two, as in items.
- **The shop**: it uses the same font and the same ">" (`EQ_CURSOR` stays
  because of it); it wasn't touched.
- The font at 6 pixels: it was already declared.

## Tests

- `equipo`, `equipo-lista`, `equipo-sube-baja` and `equipo-sube` change: the
  windows, the bar, the terms and the arrow in red, and the new
  layout. New `equipo-ranura`: the bar on the head, which is a
  slot that isn't the first and is empty. `equipo-lista` already covered the bar
  on the list, in its second row.
- `pantallas.pantalla_equipo` draws the windows and the bar (`Texto.ventanas`),
  so `test_menu_equipo_dibujo.py` also compares that pixel by pixel.
- **What no test runs**: the bar with the list scrolled —more than
  five candidates—. The calculation is the same as for the text (the cursor minus
  the first visible one), but no case has that many.
- `rama-equipo*` don't change: they're map captures.
- Before, now and the original, side by side, in
  `/shared/capturas/2026-09-28-equipo/`.
- Aligning the columns moved the ROM, and with it when each write
  to the DSP lands within the frame: `dcbest`, which was close to the cap, started
  clipping two samples (`test_musica_techos.py`). `just techos` was run,
  which is what the test asks for, and the table goes in its own commit.
- Verified with `just cartuchos` and `just pruebas` on this branch: all
  green. `just espacio`: in `release` bank 0 went from 190 to 196 B free
  and bank 1 from 4,499 to 4,380; in `test-special`, from 1,083 to 1,089 and from
  7,003 to 6,884. The new data —the equipment tilemap, its bars and the
  red font— are about 4 KB in the data banks.

## What taro has to look at

- Menu, Equipment, an actor: the three windows, the terms in red, the
  bar across the width of the slot; move it through the five.
- A on a slot: the bar on the list, the values it would become with the
  red arrow; with a weapon or an armour with several candidates, go down and
  up.
- Equip and go back with B: the slots with the new item; and B again, the menu and
  the map as always (BG1 turns on in this screen and the map restores it).
- A battle after having equipped: the font grew ten tiles and the battle
  uploads it.
