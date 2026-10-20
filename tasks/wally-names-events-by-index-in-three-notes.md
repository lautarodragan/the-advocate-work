---
name: "Wally names events by index in three notes"
description: "Three of Wally's notes print an event's index plus one, not its RM2k id: on a map with gaps in its numbering they name another event"
type: bug
status: testing
assignee: taro
agents: [Hurón]
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

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Still so: `map.rs` prints `e + 1` in the "someone else's palette" and
"opaque event(s) baked" notes and `event + 1` in the one about the sprite
palettes, next to `events[e].id` in the console's table. Small and clear.
**Done** is the three notes printing `events[e].id`, with a Wally unit test
over a map whose event ids have a gap that names the right id. First step:
that test, red.

## Done

**2026-10-20, Hurón**, on the-advocate `8f290c39`, branch `huron-wally-ids`.

The three notes in `rm2k-snes/wally/src/map.rs` print `events[e].id`, like
the console's table and the `still-animation-dropped` one. `events` is the
same list the indices point into —the test event, when there is one, is
its index 0 with id 0—.

Two new tests in `rm2k-snes/wally/tests/whole_map.rs`, over the file's game
with its events renumbered 3, 5 and 8 (requests still name them by index),
both shown red first —they printed `1`—:

* `the_baked_note_names_the_event_by_its_id`: "opaque event(s) baked into
  the map: 3";
* `the_lent_baked_note_names_the_event_by_its_id`: eight CharSets of
  fifteen colours of their own fill the sprite palettes, the tile event is
  lent one, and "event 3 is drawn with someone else's palette, so it isn't
  baked".

**Not covered by any test**: the third note, "event N, drawn with tile …,
doesn't fit in the sprite palettes". Reading `drawable_npcs` in
`sprites/split.rs`, `map` cannot reach it today: a tile is discarded only
when every palette is full and all of them are leaders', and the leaders
that are events stop at one palette short of the cap —the condition
`palettes.len() + 1 >= cap`—, so the tile always gets a new one or is lent.
`split` with `palettes: 1` reaches it, but that answer carries indices and
no note. The change there is the same one-liner.

**What was run**, at `290958b1`: `just crate-test wally`, `just rust-test`,
`just test` and `just lint`, green. ABL's `release` built in a worktree of
the ports at `68bf55b`, once with the global tools and once with `wally`,
`screens` and `mapdata` from this branch: `abl.sfc`
(`7ec61010…c252e`), `abl.msu`, `mapdata.inc` and `degradations.json`
byte for byte equal. `converter.log` differs in one line, and it is the
bug: ABL's map 11 has gaps in its numbering, and its 22 baked events went
from "31, 32, 33, 36, …, 54" to "36, 37, 38, 41, …, 59". Nothing in the
ports reads those notes' text (`git grep` over the notes' strings).

**At merge**: reinstall `wally` (`just install wally`). `screens` and
`mapdata` compile Wally in, but only its `sprites`, not `map.rs`: their
binaries do not change behaviour, and reinstalling them is optional.
