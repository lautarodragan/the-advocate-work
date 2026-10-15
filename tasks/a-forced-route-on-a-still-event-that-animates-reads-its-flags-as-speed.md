---
name: "A forced route on a still event that animates reads its flags as speed"
description: "The runtime takes a forced route's speed from +13 of the event's row, which on a still event that animates also carries bit 7 —and bit 6 since 2026-10-15—"
type: bug
status: draft
---

Seen by Calandria on 2026-10-15, reading the runtime for
[`book-of-three-the-intros-torches-stand-still`](book-of-three-the-intros-torches-stand-still.md),
with the-advocate `1a2df48e`. Not seen in a game.

**What is there**: when a forced move route takes an event, the route's
speed is `lda npc_buf + 13, y` of its row, as is —`runtime/event_routes.s`,
"At the speed of the page it is drawn with"—. On a still event that
animates, +13 is the speed with bit 7 set, and on the one that uploads for
its twins, bit 6 too: the route would get a speed of `$83` or `$C3`.

**Why it has not shown**: the converter does not animate a still event that
some compiled page sends a route to —`moves` in Wally—, so in the eight
ports no route reaches such a row. A route on "this event" from a common
event, or a test page's `also_walk`, could.

**How to see it**: a map with a still event with continuous animation that
only a common event moves.
