---
name: "Wally names events by index in three notes"
description: "Three of Wally's notes print an event's index plus one, not its RM2k id: on a map with gaps in its numbering they name another event"
type: bug
status: draft
---

Seen by Hurón on 2026-10-15, reading `rm2k-snes/wally/src/map.rs` at
the-advocate `5d5df69d` while hooking its notes into the cartridge's
degradations; not checked against a map with gaps.

**What happens**: the notes "event N, drawn with tile …, doesn't fit in the
sprite palettes and isn't drawn", "event N is drawn with someone else's
palette, so it isn't baked" and "opaque event(s) baked into the map: …"
print `event + 1`, the index in the map's list plus one. The one about
the console's table, a few lines above, prints `events[e].id`. On a map
whose event ids have gaps —events deleted in the editor— the number is
another event's. `degradations.json` already carries the right id for
the first one (`event-not-drawn`, in `events`); only the text is off.

**How to reproduce**: a map with a deleted event before one that is not
drawn for its palette; the converter's log names the wrong id.
