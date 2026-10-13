---
name: "A refresh sets up every page again, not only the ones that changed"
description: "page_routes runs page_graphic for every event on each refresh, resetting facing and pose to the page's, where RM2k only calls SetupFromPage when the active page changes; Book of Three refreshes every frame"
type: bug
status: draft
---

Seen by Calandria on 2026-10-13, reading the code while fixing
[`book-of-three-the-hero-freezes-in-caer-dallben-east`](book-of-three-the-hero-freezes-in-caer-dallben-east.md),
with the-advocate `81a0a9ce`. **Not measured as something seen**: it is a
suspicion from the code, to be confirmed or discarded.

**What the code does**: on each refresh `page_routes` (in
`runtime/event_pages.s`) runs `page_graphic` for every event whose row
follows its page, even when the active page is the same one as before.
`page_graphic` puts the page's facing in the row (`npc_buf + 10`) and, for
a still row, the page's tile. RM2k's `Game_Event::Refresh` only calls
`SetupFromPage` when the active page changes.

**Why it may show**: Book of Three refreshes on every frame —its parallel
common event 22 turns switches on each time it runs—, so an event whose
facing something changed without a route slot of its own would be put
back to its page's facing on the next frame. `turn_restore` covers the
one that turns toward the hero; what else changes a facing without a slot
was not looked at. Until 2026-10-13 it also asked for every walker's pose
again on every refresh, which is what froze the hero on map 4 (fixed
there: `walker_graphic` keeps the pose if the bank is the same).

**To reproduce / measure**: in Book of Three, an event without a move
route of its own that a command turns, on a map with control, and whether
it keeps the new facing; or count, in an emulator, how often
`page_graphic` runs per frame on map 4.
