---
name: "A route's graphic on a row its pages draw is undone after a battle"
description: "After a battle or a big picture every row is set up from its page again, and a row whose page draws something gets the page's graphic back over the one a route's command 34 gave it"
type: bug
status: draft
agents: [Calandria]
---

Seen by Calandria on 2026-10-19, reading the code while fixing
[`characters-a-route-gives-a-graphic-are-not-drawn`](characters-a-route-gives-a-graphic-are-not-drawn.md),
with the-advocate `a550d052` (branch `calandria-route-graphics`). Not seen
playing: no test reaches it.

**What happens**: `npc_poses_forget` —after a battle (`back_from_battle`)
and a big picture (`big_back_far`)— asks the next refresh to set every row
up from its page again, so a walker's page uploads its pose (d309f807).
Since `a550d052` a page that draws nothing leaves its row alone then, which
is what keeps the characters a route dresses on events with no graphic
(The Book of Three's map 21, Gurgi and Gwydion across the fight). But a row
whose page **does** draw something still goes through `page_graphic`'s
`with_graphic`, and a walker takes its page's pose bank and palette again
(`walker_graphic`): if a route had changed its graphic with command 34
before the battle, the change is undone. RM2k does not set the page up
again when it comes back from a battle (`Game_Event::RefreshPage` only on
a page change), so the route's graphic stays.

**How to see it**: an event with a graphic on its page, a forced route
that changes it with command 34, then a battle; after it, the event shows
its page's graphic. In which game's scene this happens is not measured.
