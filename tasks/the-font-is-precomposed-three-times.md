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
