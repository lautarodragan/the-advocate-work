---
name: "The font is precomposed three times"
description: "Every cartridge carries the font precomposed for the messages, for the text screens and for the slots, eight phases each: about 365 KB, the same letters for three palettes"
type: refactor
status: doing
assignee: Calandria
agents: [Carpintero, Calandria]
---

Seen by Carpintero on 2026-11-20, at the-advocate `16081af9` and the
ports `1177cbc`, for
[`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md).
Only cartridge is lost.

**What was seen**: `font_pre0`–`7` (the messages, `messages.s`),
`scr_pre0`–`7` (the text screens' inks, `text_layer.s`) and `slot_pre0`–`7`
(the slots' names, `tl_strip`) are each the game's font composed at its
eight phases for one palette: 124,800 + 119,808 + 119,808 bytes in Desert
Nightmare's `release`, 364,416 in all (5.6 banks); 376,896 in Vampires
Dawn's and 364,416 in A Blurred Line's. Whether the three differ in more
than which colour indices the letters take was not checked.

**To reproduce**: the labels' sizes in the build's `.dbg`, each sized by
the next label of its segment.

## Taken (2026-11-20, Calandria)

Hornero's reading, to be checked first: the eight phases are there for
speed (the 65816 shifts one bit at a time, and the font is 6 px wide on
8 px tiles); the three copies would differ only in the colour index the
letters take, which lives in which bitplanes the bits go to. If so, one
1-bit-per-pixel copy at its eight phases, with the planes chosen by a mask
per colour when a letter is written, replaces the three. taro, to doing
it: "dale!".

**Done means**: first, whether the three differ only in colour; then one
copy (or the reason it can't be), every screen that writes text drawn the
same —goldens unmoved—, the composing time per letter measured before and
after (messages, text screens, slots), and `just space` for every
cartridge.

## What differs between the three (2026-11-20, Calandria)

At the-advocate `16081af9` and the ports `1177cbc`, decoding each table
back to pixels —per glyph, phase, row and cell: which pixels are inked,
and with which colour index— from each game's `release` `mapdata.inc`:

* **The shape is the same, byte for byte, in all nine games**: every
  glyph the three share inks the same pixels at the same phase. The bpp,
  the spacing, the rows and the shadow are the same; they are all
  `font_prerender` over `font_bytes_with`.
* **What differs is the colour**: row k of the glyph and the shadow take a
  different palette index in each —the window's gradient in the
  messages', entries 1 + k and 13 in the screens', the bank's by-use
  palette in the slots'—.
* **And the glyphs after the console's 96**: the messages' carry the
  Latin-1 letters their boxes draw (`request.letters`); the screens' and
  the slots' —the same set— carry the ExFont icons' halves after a blank
  (`items::glyphs_after`). Vampires Dawn and Zounds have both, and they
  differ from glyph 96 on; the other games have one or none.

So one table colour-free, with the glyphs of both sets, and the colour put
in by each writer, is possible.
