---
name: "ABL's EraseEvent tests leave for the test game"
description: "The test game's test_erase_event.py now asks everything ABL's test_erase_event_for_real.py asked, of an event with a graphic; ABL's test and its two cases in test-special are left over"
type: test
status: draft
author: tijereta
game: abl
links:
  part-of: [abl-s-test-cartridges-become-test-game-cases]
  relates: [eraseevent-no-test-looks-at-what-is-seen]
---

Seen by Tijereta on 2026-11-22, doing
[`eraseevent-no-test-looks-at-what-is-seen`](eraseevent-no-test-looks-at-what-is-seen.md),
with the-advocate `tijereta-erase-event` (from `6a8f4162`) and the ports
at `1850365`.

The test game's `tests/test_erase_event.py`, map 14 "Erasure", asks what
ABL's `tests/rpgmaker/test_erase_event_for_real.py` asks, of a statue with
a graphic instead of ABL's invisible test-page event: that a foreground
page goes on past its `EraseEvent`, that another page of the erased event
does not start, and that loading the map again brings it back. It adds what
ABL's comment says that test leaves to a same-map jump: a `Teleport` to the
map it is on keeps the event erased.

What stays in ABL for it: the test, and its two cases `erase-event` and
`erase-event-after`, which only `test-special` carries —`release` excludes
them— so taking them out changes no golden of the cartridge taro plays,
but changes what `test-special` carries, and the other tests on it run
again.

What is not in the test game, and stays in ABL unless it gets a page of its
own: `tests/rpgmaker/test_erase_event.py`, an `EraseEvent` after a
`Teleport` to another map, which does nothing. It is a page of ABL's map
311, played. The test game could carry it as a touched event that jumps to
another map and then erases, with the page's next command as the check.

The events crate's three `EraseEvent` tests (`compile.rs`: after a jump,
this event's row, in a common event) are the compiler's bytecode and need
no ROM: they stay where they are. The ROM side of "in a common event it
does nothing" is tested nowhere.
