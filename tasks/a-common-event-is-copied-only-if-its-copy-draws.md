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

## Log

**Chajá, 2026-11-20**, from the-advocate `16081af9`, the ports `1177cbc`.

Where the decision can be made. The copies are decided before the events'
scan, and the scan needs them: it gathers what each map can show with the
copy's pages, and tells which pictures are the map's own
(`pictures_own`). Wally says whether the copy's pictures went in, and the
compile lays the bytecode out, both well after. So it goes in three
places:

* **Per common, after the scan**: the scan's `commons_pictures` gathers
  each automatic body as it runs without a map, its calls pasted —which is
  what a copy carries—. A common none of whose pictures is small
  (`pictures::any_small`, the same `is_big` and plane-of-objects fit
  `for_map` uses) is decided again as not copied, and the scan asked
  again, so no map gathers its pictures. A cartridge whose copies all have
  something small scans once, as before. Desert Nightmare's 12 —with the
  11 it calls, 36 pictures, all 320x240— goes out here; 14 has
  `Kartencursor`, 7x4, and stays.
* **Per map, after Wally and the compile**, when the map's code is laid
  out: the copy's pages are dropped from a map where Wally put the map's
  own pictures in instead (`pictures_own` in its answer: the copy would
  draw nothing), or where the code with them would not go to WRAM and
  without them would (`code_behind_grid`, which `code_in_rom` in
  rm2k-snes-mapdata now asks too). The event stays, with no pages, last,
  so no index moves; the map leaves the `copies` list, so the shared body
  starts there, as on a map that had no room for the event.
* Dropping after the compile and not before is what lets the cap be
  measured and not estimated: the bytecode with the copy is only known
  there. What it leaves: the copy's pictures, which Wally placed because
  they cost the map nothing, stay in the map's table unused, and its texts
  in the text block.

Not done: the shared set fitting beside the map's bank —Carpintero's "small
ones only where the common table's set does not fit"— is the emission's to
say, after all of this; a copy on those maps draws as well, so it stays.
