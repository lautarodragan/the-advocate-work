---
name: "Vampires Dawn's loads spend seconds on effects from the .msu"
description: "A door in Vampires Dawn adds 78 frames to the fade on average, up to 215: most of it uploading sound effects read from the .msu, which go up whole and do not fit in the fade's frozen ticks"
type: refactor
status: draft
---

Seen by Cardón on 2026-10-18, measuring
[`maps-load-faster-without-losing-anything`](maps-load-faster-without-losing-anything.md),
with the-advocate `7ca45aa6`, in snes9x with the game's `.msu` and no
tracks.

**What was seen**: over 409 of its maps, each reached by a door fade from
the one before, a jump adds 83.8 frames to the fade before that change and
78.5 after, against 13 to 21 in the other ports; the load's own tick went
from 83 to 36, and the rest is the package finishing on the fade's last
black tick. Before the change, 45 of the 83 were sound effects read from
the `.msu` (`se_msu_upload` in `runtime/msu_effects.s`), which go up whole,
each one in one go, and so since the change all on the fade's last black
tick, where an overrun does not show (`whole_ones`). The slowest maps: 195 (215 frames), 163 (208), 164 (206),
141 (201), 169 (200).

**To reproduce**: `just cartridges` in `vampires-dawn/`, and the measuring
script described in that task's log, or any door between two maps of the
list above, counting hardware frames until `fade` goes back to zero.
