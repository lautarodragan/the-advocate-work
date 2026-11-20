---
name: "A common event is copied only if its copy draws"
description: "An automatic common event with pictures is copied into each map so its pictures can be drawn; copy it only where the copy draws a picture the shared body cannot, and never let a copy push a map's code past what decompresses, so `commons_not_copied` is no longer needed"
type: feature
status: doing
assignee: Chajá
agents: [Chajá]
game: desert-nightmare
---

From Carpintero's study (the book's
`ports/desert-nightmare/research/2026-11-20-where-the-room-goes.md`,
task [`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md)),
recommendation 1, and the drafts
[`desert-nightmare-common-12-is-copied-and-draws-nothing`](desert-nightmare-common-12-is-copied-and-draws-nothing.md):
Desert Nightmare's commons 12 and 14 are copied into 181 maps; the copies
of 12 draw nothing (all its pictures, and 11's, are 320x240) and are ~1.05
MB of the maps' LZ2 bytecode; 14's copy draws the map cursor. Copied, the
maps pass `LZ2_CAP_CODE` and keep their bytecode raw in the ROM, which is
why Chajá added `[events] commons_not_copied = [14]`.

taro, translated, on that option: "the next step should be to not need
that option", and to launching this: "Dale".

**What**: `CommonPages::decide` (`common_pages.rs` in convert) copies a
common only into the maps where the copy would draw a picture that fits
(Wally's `picture_own`), and a copy that would push a map past
`LZ2_CAP_CODE` is not made there (the shared body runs, as on a map
without room). Then remove `commons_not_copied` from the converter and
from Desert Nightmare's project, or say why it should stay.

**Done means**: Desert Nightmare builds without the option, with 14
copied where its cursor draws and 12 not copied; no map's code raw in the
ROM because of a copy; `just space` before/after; Frozen World's
`BringUpMenu` (common 15, the reason copies exist) still drawn; every other
game's ROMs byte for byte the same or the reason.
