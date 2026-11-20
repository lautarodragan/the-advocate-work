---
name: "The font is precomposed three times"
description: "Every cartridge carries the font precomposed for the messages, for the text screens and for the slots, eight phases each: about 365 KB, the same letters for three palettes"
type: refactor
status: draft
agents: [Carpintero]
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
