---
name: "Still events that animate don't share their twins' slot in a cache"
description: "In a map with a cache of slots each still event that animates wants a slot of its own while in view, so Sunset's and Vampires Dawn's crowded maps give up their animations or make events wait"
type: bug
status: testing
assignee: taro
agents: [Calandria]
---

Seen by Calandria on 2026-10-16, with the-advocate `8c6a345b` (main
`63b46ae9` plus the empty-page fix) and the ports `059ddcd`, measuring
[`abl-the-sixty-one-torches-of-map-148-stand-still`](abl-the-sixty-one-torches-of-map-148-stand-still.md).
Read from `wally map` on each `release` request, not played.

**What it is**: outside a cache, the still events with the same look and
speed share one slot and only the first uploads (`moves` in wally). In a
cache nobody shares (`Animate::share` is false there): each one that
animates asks for `128 + event` while in view, so a group of torches on
screen asks for as many slots as torches. The maps the task listed still
give up animations for it, or would make events wait, and fusing more
ground would not help those with a panorama:

| Map | Ground tiles | Cache slots, all animating | At once on screen | Ground to fuse for that many slots |
|---|---|---|---|---|
| Sunset 1 | 2 (panorama) | 11 | 21 | — |
| Sunset 2 | 2 (panorama) | 10 | 23 | — |
| Sunset 3 | 2 (panorama) | 6 | 36 | no layout holds it |
| Sunset 12 | 2 (panorama) | 7 | 22 | — |
| Sunset 13 | 2 (panorama) | 7 | 24 | no layout holds it |
| Sunset 14 | 2 (panorama) | 7 | 21 | — |
| Sunset 15 | 2 (panorama) | 7 | 14 | — |
| Vampires Dawn 201 | 498 | 11 | 15 | 18 tiles |
| Vampires Dawn 222 | 222 | 27 | 30 | no layout holds it |
| Vampires Dawn 236 | 489 | 10 | 12 | 9 tiles |
| Vampires Dawn 240 | 489 | 10 | 13 | 9 tiles |

"Ground to fuse" is how many more background tiles a layout with room for
that many slots would leave than the map has today; "—" is a map that
shows its panorama, whose layouts are others and whose ground is not what
is over. 201, 236 and 240 fit without fusing, and the conversion only
fuses a map that fits nothing.

Sunset's 46 is something else: see
[`animations-given-up-for-a-picture-that-is-not-drawn`](animations-given-up-for-a-picture-that-is-not-drawn.md).

**How to see it**: `still-animation-dropped` and `events-wait-for-a-slot`
in `build/release/degradations.json` of `sunset-over-imdahl/` and
`vampires-dawn/`.

## Log

**2026-10-17, Calandria**: done in
[`rain-drops-cost-a-cache-its-slots`](rain-drops-cost-a-cache-its-slots.md),
the-advocate's `calandria-rain-and-slots` (`ceb31253`): a twin's row
carries its leader's key and the cache hands both the same slot; in a
cache a twin that only appears with its page shares too. Of this table,
Vampires Dawn's 201, 222, 236 and 240 and Sunset's 2, 13 and 15 animate
everything; Sunset's 1, 3, 12 and 14 still give up some looks, where
animating them would make events wait. The ROM test is the ports'
`tests/test_cache_twins.py`.
